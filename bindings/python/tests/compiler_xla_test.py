# Lint as: python3
# Copyright 2020 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import logging
import os
import sys
import tempfile
import unittest

# TODO: No idea why pytype cannot find names from this module.
# pytype: disable=name-error
# pytype: disable=module-attr
import iree.compiler.xla

if not iree.compiler.xla.is_available():
  print(f"Skipping test {__file__} because the IREE XLA compiler "
        f"is not installed")
  sys.exit(0)


class CompilerTest(unittest.TestCase):

  def testImportBinaryPbFile(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    text = iree.compiler.xla.compile_file(path,
                                          import_only=True).decode("utf-8")
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)
    self.assertIn("iree.module.export", text)

  def testCompileBinaryPbFile(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    binary = iree.compiler.xla.compile_file(
        path, target_backends=iree.compiler.xla.DEFAULT_TESTING_BACKENDS)
    logging.info("Binary length = %d", len(binary))
    self.assertIn(b"main", binary)

  def testImportBinaryPbFileOutputFile(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    with tempfile.NamedTemporaryFile("wt", delete=False) as f:
      try:
        f.close()
        output = iree.compiler.xla.compile_file(path,
                                                import_only=True,
                                                output_file=f.name)
        self.assertIsNone(output)
        with open(f.name, "rt") as f_read:
          text = f_read.read()
      finally:
        os.remove(f.name)
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)

  def testCompileBinaryPbFileOutputFile(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    with tempfile.NamedTemporaryFile("wt", delete=False) as f:
      try:
        f.close()
        output = iree.compiler.xla.compile_file(
            path,
            output_file=f.name,
            target_backends=iree.compiler.DEFAULT_TESTING_BACKENDS)
        self.assertIsNone(output)
        with open(f.name, "rb") as f_read:
          binary = f_read.read()
      finally:
        os.remove(f.name)
    logging.info("Binary length = %d", len(binary))
    self.assertIn(b"main", binary)

  def testImportBinaryPbBytes(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    with open(path, "rb") as f:
      content = f.read()
    text = iree.compiler.xla.compile_str(content,
                                         import_only=True).decode("utf-8")
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)

  def testCompileBinaryPbBytes(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.pb")
    with open(path, "rb") as f:
      content = f.read()
    binary = iree.compiler.xla.compile_str(
        content, target_backends=iree.compiler.xla.DEFAULT_TESTING_BACKENDS)
    logging.info("Binary length = %d", len(binary))
    self.assertIn(b"main", binary)

  def testImportHloTextFile(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.hlo")
    text = iree.compiler.xla.compile_file(
        path, import_only=True, import_format="hlo_text").decode("utf-8")
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)
    self.assertIn("iree.module.export", text)

  def testImportHloTextStr(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.hlo")
    with open(path, "rt") as f:
      content = f.read()
    text = iree.compiler.xla.compile_str(
        content, import_only=True, import_format="hlo_text").decode("utf-8")
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)
    self.assertIn("iree.module.export", text)

  def testImportHloTextBytes(self):
    path = os.path.join(os.path.dirname(__file__), "testdata", "xla_sample.hlo")
    with open(path, "rb") as f:
      content = f.read()
    text = iree.compiler.xla.compile_str(
        content, import_only=True, import_format="hlo_text").decode("utf-8")
    logging.info("%s", text)
    self.assertIn("linalg.generic", text)
    self.assertIn("iree.module.export", text)


if __name__ == "__main__":
  logging.basicConfig(level=logging.DEBUG)
  unittest.main()
