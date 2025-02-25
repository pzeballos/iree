// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "iree_tf_compiler/MHLO/Passes.h"

#include "iree/compiler/Conversion/Passes.h"
#include "iree/compiler/Dialect/Flow/Transforms/Passes.h"
#include "iree/compiler/Dialect/Shape/Transforms/Passes.h"
#include "mlir-hlo/Dialect/mhlo/transforms/passes.h"
#include "mlir/Conversion/SCFToStandard/SCFToStandard.h"
#include "mlir/Dialect/SCF/Passes.h"
#include "mlir/Dialect/Shape/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Transforms/Passes.h"

namespace mlir {
namespace iree_integrations {
namespace MHLO {

void buildMHLOImportPassPipeline(OpPassManager &pm) {
  //----------------------------------------------------------------------------
  // Convert control flow and flatten tuples (like tuple<tensor<...>, ...>)
  //----------------------------------------------------------------------------
  // NOTE: FlattenTuplesInCFGPass requires inlining to have run and has some
  // sensitivity to structured control flow ops.
  // SCF would be ideal as a target (as that matches our other IREE inputs) but
  // the current HLO to SCF pass is extremely basic and doesn't handle anything
  // but tf.while for less-than comparisons from 0. Since those are common we
  // still try to pull those out here but then fall back on the full conversion
  // to CFG form.
  pm.addPass(mlir::createInlinerPass());
  pm.addNestedPass<FuncOp>(mhlo::createControlFlowToScfPass());
  pm.addNestedPass<FuncOp>(mhlo::createLegalizeControlFlowPass());
  pm.addNestedPass<FuncOp>(mlir::createLowerToCFGPass());
  pm.addPass(createFlattenTuplesInCFGPass());
  pm.addNestedPass<FuncOp>(mlir::createCanonicalizerPass());

  // Mostly delicate to the IREE side MHLO legalization pipeline, now that
  // we have handled the weird that comes from legacy HLO clients.
  mlir::iree_compiler::IREE::Flow::buildMHLOInputTransformPassPipeline(pm);

  // Import pipelines should end with canonicalization because they may have
  // access to dialects and patterns that the core compiler does not.
  pm.addNestedPass<FuncOp>(mlir::createCanonicalizerPass());
}

void registerMHLOImportPassPipeline() {
  mlir::PassPipelineRegistration<> pipeline(
      "iree-mhlo-import-pipeline",
      "Run IREE-specific passes for importing MHLO code into IREE",
      [](OpPassManager &passManager) {
        buildMHLOImportPassPipeline(passManager);
      });
}

}  // namespace MHLO
}  // namespace iree_integrations
}  // namespace mlir
