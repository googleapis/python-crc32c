#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e -x

if [[ -z ${REPO_ROOT} ]]; then
    MANYLINUX_DIR=$(echo $(cd $(dirname ${0}); pwd))
    SCRIPTS_DIR=$(dirname ${MANYLINUX_DIR})
    REPO_ROOT=$(dirname ${SCRIPTS_DIR})
fi
MAIN_PYTHON_BIN=${MAIN_PYTHON_BIN:-"/opt/python/cp37-cp37m/bin"}
CRC32C_INSTALL_PREFIX=${REPO_ROOT}/usr

#
# Build the `crc32c` C library
#
# Desired artifacts are:
#
# - /usr/local/include/crc32c/crc32c.h
# - /usr/local/lib64/libcrc32c.so
#
${MAIN_PYTHON_BIN}/python -m pip install --upgrade setuptools pip wheel
${MAIN_PYTHON_BIN}/python -m pip install "cmake >= 3.12.0"

cd ${REPO_ROOT}/google_crc32c/
git submodule update --init --recursive 
rm -rf build
mkdir build
cd build/
${MAIN_PYTHON_BIN}/cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCRC32C_BUILD_TESTS=no \
    -DCRC32C_BUILD_BENCHMARKS=no \
    -DBUILD_SHARED_LIBS=yes \
    -DCMAKE_INSTALL_PREFIX:PATH=${CRC32C_INSTALL_PREFIX} \
    ..

#
# Install the library and header file under `/usr/local/
#
make all install

#
# Clean up.
#
rm -fr ${REPO_ROOT}/google_crc32c/build/
