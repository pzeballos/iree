################################################################################
# Autogenerated by build_tools/bazel_to_cmake/bazel_to_cmake.py from           #
# iree/compiler/Dialect/Modules/Check/IR/BUILD                                 #
#                                                                              #
# Use iree_cmake_extra_content from iree/build_defs.oss.bzl to add arbitrary   #
# CMake-only content.                                                          #
#                                                                              #
# To disable autogeneration for this file entirely, delete this header.        #
################################################################################

iree_add_all_subdirs()

iree_cc_library(
  NAME
    IR
  HDRS
    "CheckOps.h"
    "CheckOps.h.inc"
  SRCS
    "CheckOps.cpp"
    "CheckOps.cpp.inc"
  DEPS
    MLIRIR
    MLIRStandard
    iree::compiler::Dialect::HAL::IR
  PUBLIC
)

iree_cc_library(
  NAME
    CheckDialect
  HDRS
    "CheckDialect.h"
  SRCS
    "CheckDialect.cpp"
  DEPS
    ::IR
    MLIRIR
    MLIRParser
    MLIRTransforms
    iree::compiler::Dialect::HAL::Conversion
    iree::compiler::Dialect::Modules::Check::Conversion
    iree::compiler::Dialect::Modules::Check::check_imports
    iree::compiler::Dialect::VM::Conversion
  PUBLIC
)

iree_tablegen_library(
  NAME
    check_ops_gen
  TD_FILE
    "CheckOps.td"
  OUTS
    -gen-op-decls CheckOps.h.inc
    -gen-op-defs CheckOps.cpp.inc
)

iree_tablegen_doc(
  NAME
    CheckDialectDocGen
  TD_FILE
    "CheckOps.td"
  OUTS
    -gen-dialect-doc CheckDialect.md
)

### BAZEL_TO_CMAKE_PRESERVES_ALL_CONTENT_BELOW_THIS_LINE ###
