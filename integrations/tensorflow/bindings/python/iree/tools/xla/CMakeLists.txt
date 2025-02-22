# Copyright 2020 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

iree_py_library(
  NAME
    xla
  SRCS
    "__init__.py"
  DEPS
    iree_tf_compiler_iree-import-xla
)

iree_symlink_tool(
  TARGET xla
  FROM_TOOL_TARGET iree_tf_compiler_iree-import-xla
  TO_EXE_NAME iree-import-xla
)

iree_py_install_package(
  COMPONENT IreePythonPackage-tools-xla
  PACKAGE_NAME iree_tools_xla
  MODULE_PATH iree/tools/xla
  DEPS
    iree_tf_compiler_iree-import-xla
)

# Since imported, need to resolve the TARGET_FILE ourselves instead of
# install TARGETS form.
install(
  PROGRAMS "$<TARGET_FILE:iree_tf_compiler_iree-import-xla>"
  DESTINATION "${PY_INSTALL_MODULE_DIR}"
  COMPONENT "${PY_INSTALL_COMPONENT}"
)
