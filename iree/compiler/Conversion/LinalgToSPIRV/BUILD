# Copyright 2019 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

package(
    default_visibility = ["//visibility:public"],
    features = ["layering_check"],
    licenses = ["notice"],  # Apache 2.0
)

cc_library(
    name = "CodeGenOptionUtils",
    srcs = [
        "CodeGenOptionUtils.cpp",
    ],
    hdrs = [
        "CodeGenOptionUtils.h",
    ],
    deps = [
        "@llvm-project//llvm:Support",
    ],
)

cc_library(
    name = "LinalgToSPIRV",
    srcs = [
        "ConcretizeTileAmongWorkgroupsPass.cpp",
        "ConvertToGPUPass.cpp",
        "ConvertToSPIRVPass.cpp",
        "FoldGPUProcessorIDUses.cpp",
        "KernelDispatchUtils.cpp",
        "Passes.cpp",
        "TileAndVectorizeInOneWorkgroupPass.cpp",
        "Utils.cpp",
        "VectorToCooperativeMatrixPass.cpp",
        "VectorToGPUPass.cpp",
        "VectorizeMemrefLoadStorePass.cpp",
    ],
    hdrs = [
        "KernelDispatchUtils.h",
        "MemorySpace.h",
        "Passes.h",
        "Utils.h",
    ],
    deps = [
        ":CodeGenOptionUtils",
        "//iree/compiler/Conversion:PassHeaders",
        "//iree/compiler/Conversion/CodegenUtils",
        "//iree/compiler/Conversion/Common",
        "//iree/compiler/Conversion/HLOToLinalg",
        "//iree/compiler/Conversion/LinalgToVector",
        "//iree/compiler/Dialect/Flow/IR",
        "//iree/compiler/Dialect/HAL/IR",
        "//iree/compiler/Dialect/HAL/IR:HALDialect",
        "//iree/compiler/Dialect/IREE/IR",
        "//iree/compiler/Dialect/Shape/IR",
        "//iree/compiler/Dialect/Shape/Transforms",
        "@llvm-project//llvm:Support",
        "@llvm-project//mlir:Affine",
        "@llvm-project//mlir:AffineToStandardTransforms",
        "@llvm-project//mlir:Analysis",
        "@llvm-project//mlir:DialectUtils",
        "@llvm-project//mlir:GPUDialect",
        "@llvm-project//mlir:GPUToSPIRV",
        "@llvm-project//mlir:GPUTransforms",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:LinalgOps",
        "@llvm-project//mlir:LinalgTransforms",
        "@llvm-project//mlir:MemRefDialect",
        "@llvm-project//mlir:MemRefTransforms",
        "@llvm-project//mlir:Pass",
        "@llvm-project//mlir:SCFDialect",
        "@llvm-project//mlir:SCFToGPUPass",
        "@llvm-project//mlir:SCFToSPIRV",
        "@llvm-project//mlir:SPIRVConversion",
        "@llvm-project//mlir:SPIRVDialect",
        "@llvm-project//mlir:SPIRVTransforms",
        "@llvm-project//mlir:SideEffectInterfaces",
        "@llvm-project//mlir:StandardOps",
        "@llvm-project//mlir:StandardToSPIRV",
        "@llvm-project//mlir:Support",
        "@llvm-project//mlir:TosaDialect",
        "@llvm-project//mlir:TosaToStandard",
        "@llvm-project//mlir:Transforms",
        "@llvm-project//mlir:VectorOps",
        "@llvm-project//mlir:VectorToSPIRV",
        "@mlir-hlo//:hlo",
        "@mlir-hlo//:legalize_to_linalg",
    ],
)
