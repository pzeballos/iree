// Copyright 2021 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include "iree/compiler/Conversion/LinalgToLLVMGPU/ConvertToLLVM.h"

#include "iree/compiler/Conversion/CodegenUtils/FunctionUtils.h"
#include "iree/compiler/Dialect/IREE/IR/IREEOps.h"
#include "mlir/Conversion/VectorToLLVM/ConvertVectorToLLVM.h"
#include "mlir/Dialect/GPU/Passes.h"
#include "mlir/Dialect/LLVMIR/NVVMDialect.h"
#include "mlir/Dialect/LLVMIR/ROCDLDialect.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Dialect/Vector/VectorOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir {
namespace iree_compiler {

namespace {

/// Scalarize math ops. It is needed to lower vector operation that don't have
/// vector support in CUDA and ROCM device library.
template <typename MathOpTy>
struct ScalarizeMathOp : public OpRewritePattern<MathOpTy> {
  using OpRewritePattern<MathOpTy>::OpRewritePattern;

  LogicalResult matchAndRewrite(MathOpTy mathOp,
                                PatternRewriter &rewriter) const override {
    auto vecType = mathOp.getType().template dyn_cast<VectorType>();
    if (!vecType) return failure();
    Location loc = mathOp.getLoc();
    Value newVector = rewriter.create<ConstantOp>(
        loc, vecType, rewriter.getZeroAttr(vecType));

    for (int64_t element : llvm::seq(int64_t(0), vecType.getNumElements())) {
      llvm::SmallVector<int64_t> indices;
      int64_t projectIndex = element;
      for (int64_t dim : llvm::seq(int64_t(0), vecType.getRank())) {
        int64_t index = projectIndex % vecType.getDimSize(dim);
        projectIndex = projectIndex / vecType.getDimSize(dim);
        indices.push_back(index);
      }
      SmallVector<Value> newOperands;
      for (Value operand : mathOp->getOperands()) {
        newOperands.push_back(
            rewriter.create<vector::ExtractOp>(loc, operand, indices));
      }
      Value scalarOp = rewriter.create<MathOpTy>(loc, newOperands);
      newVector =
          rewriter.create<vector::InsertOp>(loc, scalarOp, newVector, indices);
    }
    rewriter.replaceOp(mathOp, newVector);
    return success();
  }
};

/// Pass to test scalarization pattern.
class ScalarizationTestPass
    : public PassWrapper<ScalarizationTestPass, OperationPass<FuncOp>> {
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<vector::VectorDialect>();
  }
  void runOnOperation() override {
    OwningRewritePatternList patterns(&getContext());
    populateScalarizeMathOps(patterns);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};

// Convention with the HAL side to pass kernel arguments.
// The bindings are ordered based on binding index then compressed and mapped to
// dense set of arguments.
// This function looks at the symbols and return the mapping between binding
// index and kernel argument index. For instance if the kernel has bindings 1,
// 5, 6 it will return the mapping [1, 0], [5, 1], [6, 2]
static llvm::SmallDenseMap<uint64_t, size_t> getKernelArgMapping(
    Operation *func) {
  llvm::SmallDenseMap<uint64_t, size_t> mapBindingArgIndex;
  llvm::SmallVector<uint64_t> bindingUsed;
  Operation *symbolTableOp = SymbolTable::getNearestSymbolTable(func);
  SymbolTable::walkSymbolTables(symbolTableOp, true, [&](Operation *op, bool) {
    if (auto interface = dyn_cast<IREE::HAL::InterfaceOp>(op)) {
      interface.walk([&](Operation *symbolOp) {
        if (auto binding = dyn_cast<IREE::HAL::InterfaceBindingOp>(symbolOp)) {
          uint64_t bindingIndex = binding.binding().getZExtValue();
          bindingUsed.push_back(bindingIndex);
        }
      });
    }
  });
  std::sort(bindingUsed.begin(), bindingUsed.end());
  for (auto binding : llvm::enumerate(bindingUsed)) {
    mapBindingArgIndex[binding.value()] = binding.index();
  }
  return mapBindingArgIndex;
}

class ConvertFunc : public ConvertToLLVMPattern {
 public:
  explicit ConvertFunc(MLIRContext *context, LLVMTypeConverter &converter)
      : ConvertToLLVMPattern(mlir::FuncOp::getOperationName(), context,
                             converter, 100) {}
  LogicalResult matchAndRewrite(
      Operation *op, ArrayRef<Value> operands,
      ConversionPatternRewriter &rewriter) const override {
    auto funcOp = cast<FuncOp>(op);
    FunctionType fnType = funcOp.getType();
    (void)fnType;
    if (!funcOp.isPublic()) return failure();

    // illegal FuncOp must have 0 inputs.
    assert(fnType.getNumInputs() == 0 && fnType.getNumResults() == 0);

    TypeConverter::SignatureConversion signatureConverter(/*numOrigInputs=*/0);
    llvm::SmallDenseMap<uint64_t, size_t> argMapping =
        getKernelArgMapping(funcOp);
    SmallVector<Type, 8> llvmInputTypes(argMapping.size());
    funcOp.walk([&](IREE::HAL::InterfaceBindingSubspanOp input) {
      auto memrefType = input.getType().cast<MemRefType>();
      Type elType = memrefType.getElementType();
      auto llvmType =
          LLVM::LLVMPointerType::get(elType, memrefType.getMemorySpaceAsInt());
      uint64_t binding = input.queryBindingOp().binding().getZExtValue();
      llvmInputTypes[argMapping[binding]] = llvmType;
    });
    signatureConverter.addInputs(llvmInputTypes);

    // Construct newFunc with all attributes except return type & symbol name.
    SmallVector<NamedAttribute, 4> funcAttrs;
    for (auto attr : funcOp->getAttrs()) {
      if (attr.first == SymbolTable::getSymbolAttrName() ||
          attr.first == mlir::function_like_impl::getTypeAttrName()) {
        continue;
      }
      funcAttrs.push_back(attr);
    }

    auto llvmFuncType = LLVM::LLVMFunctionType::get(
        LLVM::LLVMVoidType::get(rewriter.getContext()), llvmInputTypes);
    auto newFuncOp = rewriter.create<LLVM::LLVMFuncOp>(
        funcOp.getLoc(), funcOp.getName(), llvmFuncType,
        LLVM::Linkage::External, funcAttrs);

    // Copy all of funcOp's operations into newFuncOp's body and perform region
    // type conversion.
    rewriter.inlineRegionBefore(funcOp.getBody(), newFuncOp.getBody(),
                                newFuncOp.end());
    if (failed(rewriter.convertRegionTypes(&newFuncOp.getBody(), *typeConverter,
                                           &signatureConverter)))
      return failure();

    rewriter.eraseOp(funcOp);
    return success();
  }
};

class ConvertIREEBindingOp : public ConvertToLLVMPattern {
 public:
  explicit ConvertIREEBindingOp(MLIRContext *context,
                                LLVMTypeConverter &converter)
      : ConvertToLLVMPattern(
            IREE::HAL::InterfaceBindingSubspanOp::getOperationName(), context,
            converter) {}
  LogicalResult matchAndRewrite(
      Operation *op, ArrayRef<Value> operands,
      ConversionPatternRewriter &rewriter) const override {
    // Bail until nested under an LLVMFuncOp.
    auto llvmFuncOp = op->getParentOfType<LLVM::LLVMFuncOp>();
    if (!llvmFuncOp) return failure();
    assert(llvmFuncOp.getNumArguments() > 0);

    llvm::SmallDenseMap<uint64_t, size_t> argMapping =
        getKernelArgMapping(llvmFuncOp);
    Location loc = op->getLoc();
    auto ireeBindingOp = cast<IREE::HAL::InterfaceBindingSubspanOp>(op);
    IREE::HAL::InterfaceBindingSubspanOpAdaptor adaptor(operands);
    MemRefType memrefType =
        ireeBindingOp.getResult().getType().dyn_cast<MemRefType>();
    uint64_t binding = ireeBindingOp.queryBindingOp().binding().getZExtValue();
    Value llvmBufferBasePtr = llvmFuncOp.getArgument(argMapping[binding]);
    // Add the byte offset.
    Value llvmBufferBasei8Ptr = rewriter.create<LLVM::BitcastOp>(
        loc,
        LLVM::LLVMPointerType::get(rewriter.getIntegerType(8),
                                   llvmBufferBasePtr.getType()
                                       .cast<LLVM::LLVMPointerType>()
                                       .getAddressSpace()),
        llvmBufferBasePtr);
    llvmBufferBasei8Ptr = rewriter.create<LLVM::GEPOp>(
        loc, llvmBufferBasei8Ptr.getType(), llvmBufferBasei8Ptr,
        adaptor.byte_offset());
    llvmBufferBasePtr = rewriter.create<LLVM::BitcastOp>(
        loc, llvmBufferBasePtr.getType(), llvmBufferBasei8Ptr);
    if (memrefType.hasStaticShape()) {
      auto desc = MemRefDescriptor::fromStaticShape(
          rewriter, loc, *getTypeConverter(), memrefType, llvmBufferBasePtr);
      rewriter.replaceOp(op, {desc});
    } else {
      // TODO: pull those paramters from HAL constants.
      assert(0 && "TODO: implement dynamic shape");
    }

    return success();
  }
};

/// A pattern to convert hal.interface.workgroup.id/count/size into
/// corresponding NVVM/ROCDL ops.
template <typename InterfaceOpTy, typename XOp, typename YOp, typename ZOp>
struct HALInterfaceWorkgroupOpsConverter final
    : public OpConversionPattern<InterfaceOpTy> {
  using OpConversionPattern<InterfaceOpTy>::OpConversionPattern;

  LogicalResult matchAndRewrite(
      InterfaceOpTy op, ArrayRef<Value> operands,
      ConversionPatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Type i32Type = rewriter.getI32Type();
    Value newOp;
    int32_t index = static_cast<int32_t>(op.dimension().getSExtValue());
    switch (index) {
      case 0:
        newOp = rewriter.create<XOp>(loc, i32Type);
        break;
      case 1:
        newOp = rewriter.create<YOp>(loc, i32Type);
        break;
      case 2:
        newOp = rewriter.create<ZOp>(loc, i32Type);
        break;
      default:
        return failure();
    }

    newOp =
        rewriter.create<LLVM::SExtOp>(loc, rewriter.getIntegerType(64), newOp);
    rewriter.replaceOp(op, {newOp});
    return success();
  }
};

}  // anonymous namespace

void populateLLVMConversionPatterns(MLIRContext *context,
                                    OwningRewritePatternList &patterns,
                                    LLVMTypeConverter &converter,
                                    bool useROCM) {
  patterns.insert<ConvertFunc, ConvertIREEBindingOp>(context, converter);
  if (useROCM) {
    patterns.insert<HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupIDOp, ROCDL::BlockIdXOp,
                        ROCDL::BlockIdYOp, ROCDL::BlockIdZOp>,
                    HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupCountOp, ROCDL::GridDimXOp,
                        ROCDL::GridDimYOp, ROCDL::GridDimZOp>,
                    HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupSizeOp, ROCDL::BlockDimXOp,
                        ROCDL::BlockDimYOp, ROCDL::BlockDimZOp>>(context);
  } else {
    patterns.insert<HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupIDOp, NVVM::BlockIdXOp,
                        NVVM::BlockIdYOp, NVVM::BlockIdZOp>,
                    HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupCountOp, NVVM::GridDimXOp,
                        NVVM::GridDimYOp, NVVM::GridDimZOp>,
                    HALInterfaceWorkgroupOpsConverter<
                        IREE::HAL::InterfaceWorkgroupSizeOp, NVVM::BlockDimXOp,
                        NVVM::BlockDimYOp, NVVM::BlockDimZOp>>(context);
  }
}

void populateScalarizeMathOps(RewritePatternSet &patterns) {
  patterns.add<ScalarizeMathOp<math::SqrtOp>, ScalarizeMathOp<AbsFOp>,
               ScalarizeMathOp<math::AtanOp>, ScalarizeMathOp<math::Atan2Op>,
               ScalarizeMathOp<CeilFOp>, ScalarizeMathOp<math::CosOp>,
               ScalarizeMathOp<math::ExpOp>, ScalarizeMathOp<math::ExpM1Op>,
               ScalarizeMathOp<FloorFOp>, ScalarizeMathOp<math::LogOp>,
               ScalarizeMathOp<math::Log1pOp>, ScalarizeMathOp<math::Log10Op>,
               ScalarizeMathOp<math::Log2Op>, ScalarizeMathOp<math::PowFOp>,
               ScalarizeMathOp<math::RsqrtOp>, ScalarizeMathOp<math::SinOp>,
               ScalarizeMathOp<math::SqrtOp>, ScalarizeMathOp<math::TanhOp>>(
      patterns.getContext());
}

static PassRegistration<ScalarizationTestPass> scalarization_test_pass(
    "iree-llvmgpu-scalarize-math-op", "Test pass for scalarization patterns.");

}  // namespace iree_compiler
}  // namespace mlir
