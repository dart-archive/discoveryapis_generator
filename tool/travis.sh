#!/bin/bash

# Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Run tests
pub run test

# Validate that we can re-generate the example discovery doc.
dart --enable-asserts bin/generate.dart files --input-dir=example --output-dir=example --no-core-prefixes
