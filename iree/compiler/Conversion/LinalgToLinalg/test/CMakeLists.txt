################################################################################
# Autogenerated by build_tools/bazel_to_cmake/bazel_to_cmake.py from           #
# iree/compiler/Conversion/LinalgToLinalg/test/BUILD                           #
#                                                                              #
# Use iree_cmake_extra_content from iree/build_defs.oss.bzl to add arbitrary   #
# CMake-only content.                                                          #
#                                                                              #
# To disable autogeneration for this file entirely, delete this header.        #
################################################################################

iree_add_all_subdirs()

iree_lit_test_suite(
  NAME
    lit
  SRCS
    "conv1x1_to_matmul.mlir"
    "conv2d_to_img2col.mlir"
    "pad_tensor_to_tensor.mlir"
  DATA
    iree::tools::IreeFileCheck
    iree::tools::iree-opt
)

### BAZEL_TO_CMAKE_PRESERVES_ALL_CONTENT_BELOW_THIS_LINE ###
