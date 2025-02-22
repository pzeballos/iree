# Copyright 2020 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

load("//build_tools/bazel:tblgen.bzl", "gentbl_cc_library")

package(
    default_visibility = ["//visibility:public"],
    features = ["layering_check"],
    licenses = ["notice"],  # Apache 2.0
)

gentbl_cc_library(
    name = "PassesIncGen",
    tbl_outs = [
        (
            ["-gen-pass-decls"],
            "Passes.h.inc",
        ),
    ],
    tblgen = "@llvm-project//mlir:mlir-tblgen",
    td_file = "Passes.td",
    td_srcs = [
        "@llvm-project//mlir:PassBaseTdFiles",
    ],
)

cc_library(
    name = "PassHeaders",
    hdrs = [
        "PassDetail.h",
        "Passes.h",
        "Passes.h.inc",
        "Rewriters.h",
    ],
    deps = [
        ":PassesIncGen",
        "@llvm-project//mlir:Pass",
        "@llvm-project//mlir:Transforms",
    ],
)

cc_library(
    name = "Conversion",
    srcs = [
        "Passes.cpp",
    ],
    deps = [
        ":PassHeaders",
        ":PassesIncGen",
        "//iree/compiler/Conversion/Common",
        "//iree/compiler/Conversion/HLOToLinalg",
    ],
)

cc_library(
    name = "init_conversions",
    hdrs = [
        "init_conversions.h",
    ],
    deps = [
        ":PassHeaders",
        "//iree/compiler/Conversion/LinalgToLLVM",
        "//iree/compiler/Conversion/LinalgToLLVMGPU",
        "//iree/compiler/Conversion/LinalgToLinalg",
        "//iree/compiler/Conversion/LinalgToSPIRV",
        "//iree/compiler/Conversion/LinalgToVector",
        "//iree/compiler/Conversion/VectorToLLVM",
    ],
)
