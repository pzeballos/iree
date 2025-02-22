################################################################################
# Autogenerated by build_tools/bazel_to_cmake/bazel_to_cmake.py from           #
# iree/compiler/Conversion/LinalgToLLVMGPU/BUILD                               #
#                                                                              #
# Use iree_cmake_extra_content from iree/build_defs.oss.bzl to add arbitrary   #
# CMake-only content.                                                          #
#                                                                              #
# To disable autogeneration for this file entirely, delete this header.        #
################################################################################

iree_add_all_subdirs()

iree_cc_library(
  NAME
    LinalgToLLVMGPU
  HDRS
    "ConvertToLLVM.h"
    "KernelConfig.h"
    "Passes.h"
  SRCS
    "ConvertToLLVM.cpp"
    "ConvertToNVVM.cpp"
    "ConvertToROCDL.cpp"
    "KernelConfig.cpp"
    "LowerExecutableTargetPass.cpp"
    "Passes.cpp"
    "RemoveTrivialLoops.cpp"
    "TileAndDistribute.cpp"
    "VectorizationPass.cpp"
  DEPS
    MLIRAffine
    MLIRAffineToStandard
    MLIRGPU
    MLIRGPUToNVVMTransforms
    MLIRGPUToROCDLTransforms
    MLIRIR
    MLIRLinalg
    MLIRLinalgTransforms
    MLIRMath
    MLIRMemRefTransforms
    MLIRNVVMIR
    MLIRPass
    MLIRROCDLIR
    MLIRSCFToStandard
    MLIRStandard
    MLIRStandardOpsTransforms
    MLIRStandardToLLVM
    MLIRStandardToSPIRV
    MLIRTransforms
    MLIRVector
    MLIRVectorToLLVM
    MLIRVectorToSCF
    iree::compiler::Conversion::CodegenUtils
    iree::compiler::Conversion::Common
    iree::compiler::Dialect::HAL::IR
    iree::compiler::Dialect::IREE::IR
    iree::compiler::Dialect::Shape::Transforms
    tensorflow::mlir_hlo
  PUBLIC
)

### BAZEL_TO_CMAKE_PRESERVES_ALL_CONTENT_BELOW_THIS_LINE ###
