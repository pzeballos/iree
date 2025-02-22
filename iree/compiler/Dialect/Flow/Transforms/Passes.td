// Copyright 2021 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_DIALECT_FLOW_PASSES
#define IREE_DIALECT_FLOW_PASSES

include "mlir/Pass/PassBase.td"

def ConvertToFlowTensorOps :
    Pass<"iree-flow-convert-to-flow-tensor-ops-pass", "FuncOp"> {
  let summary = "Convert operations to equivalent flow.tensor.* operations";
  let constructor = "mlir::iree_compiler::IREE::Flow::createConvertToFlowTensorOpsPass()";
}

def DeduplicateExecutables :
    Pass<"iree-flow-deduplicate-executables", "ModuleOp"> {
  let summary = "Deduplicates executables that are identical";
  let constructor = "mlir::iree_compiler::IREE::Flow::createDeduplicateExecutablesPass()";
}

def DispatchLinalgOnTensors :
    Pass<"iree-flow-dispatch-linalg-on-tensors-pass", "FuncOp"> {
  let summary = "Dispatch Linalg operations on tensors by using tile and distribute";
  let constructor = "mlir::iree_compiler::IREE::Flow::createDispatchLinalgOnTensorsPass()";
}

def ExpandVariableDynamicDims :
    Pass<"iree-flow-expand-variable-dynamic-dims", "ModuleOp"> {
  let summary = "Expands !shapex.ranked_shape dynamic dimensions stored in variables.";
  let constructor = "mlir::iree_compiler::IREE::Flow::createExpandVariableDynamicDimsPass()";
}

def ExportBenchmarkFuncs :
    Pass<"iree-flow-export-benchmark-funcs-pass", "ModuleOp"> {
  let summary = "Exports benchmark functions";
  let constructor = "mlir::iree_compiler::IREE::Flow::createExportBenchmarkFuncsPass()";
}

def FormStreams :
    Pass<"iree-flow-form-streams", "FuncOp"> {
  let summary = "Identifies dispatches that can be grouped into streams within functions";
  let constructor = "mlir::iree_compiler::IREE::Flow::createFormStreamsPass()";
}

def HoistUnstreamableOps :
    Pass<"iree-flow-hoist-unstreamable-ops", "FuncOp"> {
  let summary = "Hoist ops that cannot be captured in streams to the top of their block.";
  let constructor = "mlir::iree_compiler::IREE::Flow::createHoistUnstreamableOpsPass()";
}

def HLOToHLOPreprocessing :
    Pass<"iree-flow-hlo-to-hlo-preprocessing", "FuncOp"> {
  let summary = "Apply hlo to hlo transformations for some hlo ops";
  let constructor = "mlir::iree_compiler::IREE::Flow::createHLOToHLOPreprocessingPass()";
}

def InjectDispatchTracing :
    Pass<"iree-flow-inject-dispatch-tracing", "FuncOp"> {
  let summary = "Injects dispatch region tracing";
  let constructor = "mlir::iree_compiler::IREE::Flow::createInjectDispatchTracingPass()";
}

def PromoteI1ToI8 :
    Pass<"iree-flow-promote-i1-to-i8", "FuncOp"> {
  let summary = "Legalizes i1 tensor constants to i8s";
  let constructor = "mlir::iree_compiler::IREE::Flow::createPromoteI1ToI8Pass()";
}

def LegalizeInputTypes :
    Pass<"iree-flow-legalize-input-types", "ModuleOp"> {
  let summary = "Legalizes input types to ones supported by the IREE flow dialect";
  let constructor = "mlir::iree_compiler::IREE::Flow::createLegalizeInputTypesPass()";
}

def OutlineDispatchRegions :
    Pass<"iree-flow-outline-dispatch-regions2", "ModuleOp"> {
  let summary = "Outlines dispatch regions into executables";
  let constructor = "mlir::iree_compiler::IREE::Flow::createOutlineDispatchRegionsPass()";
}

def OutlineLargeConstants :
    Pass<"iree-flow-outline-large-constants", "ModuleOp"> {
  let summary = "Outlines large tensor constants into flow.variables at the module level.";
  // TODO(#5493): add a flag for this.
  let constructor = "mlir::iree_compiler::IREE::Flow::createOutlineLargeConstantsPass(25)";
}

def PromoteTensorLoads :
    Pass<"iree-flow-promote-tensor-loads", "FuncOp"> {
  let summary = "Converts standard ops which match to flow.tensor.load (typically causing a read-back)";
  let constructor = "mlir::iree_compiler::IREE::Flow::createPromoteTensorLoadsPass()";
}

def StripAndSplatConstantVariables :
    Pass<"iree-flow-strip-and-splat-constant-variables", "ModuleOp"> {
  let summary = "Strips constant flow.variables and replaces them with splats.";
  let constructor = "mlir::iree_compiler::IREE::Flow::createStripAndSplatConstantVariablesPass()";
}

def VerifyCompilerInputLegality :
    Pass<"iree-verify-compiler-input-legality", "ModuleOp"> {
  let summary = "Verifies that only supported IR constructs are passed to the compiler.";
  let constructor = "mlir::iree_compiler::IREE::Flow::createVerifyCompilerInputLegality()";
}

#endif  // IREE_DIALECT_FLOW_PASSES
