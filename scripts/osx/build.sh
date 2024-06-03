#!/bin/bash
# Copyright 2018 Google LLC
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
echo "BUILDING FOR OSX"

# ``readlink -f`` is not our friend on OS X. This relies on **some**
# ``python`` being installed.
SCRIPT_FI=$(python -c "import os; print(os.path.realpath('${0}'))")
OSX_DIR=$(dirname ${SCRIPT_FI})
SCRIPTS_DIR=$(dirname ${OSX_DIR})
export REPO_ROOT=$(dirname ${SCRIPTS_DIR})

# set up pyenv & shell environment for switching across python versions
eval "$(pyenv init -)"
eval "$(pyenv init --path)"

install_python_pyenv() {
    version=$1

    if [ -z "$(command -v python$version)" ]; then
        echo "Python $version is not installed. Installing..."
        pyenv install $version
        pyenv shell $version
        echo "Python $version installed."
    else
        echo "Python $version is already installed."
    fi
}

# Build and install `libcrc32c`
export PY_BIN="${PY_BIN:-python3}"
export CRC32C_INSTALL_PREFIX="${REPO_ROOT}/usr"

cd ${REPO_ROOT}
# Add directory as safe to avoid "detected dubious ownership" fatal issue
git config --global --add safe.directory $REPO_ROOT/google_crc32c
git submodule update --init --recursive

${OSX_DIR}/build_c_lib.sh

# Build wheel for Python 3.7.
install_python_pyenv 3.7
export PY_BIN="python3.7"
export PY_TAG="cp37-cp37m"
${OSX_DIR}/build_python_wheel.sh

# Build wheel for Python 3.8.
# Note that the 'm' SOABI flag is no longer supported for Python >= 3.8
install_python_pyenv 3.8
export PY_BIN="python3.8"
export PY_TAG="cp38-cp38"
${OSX_DIR}/build_python_wheel.sh

# Build wheel for Python 3.9.
install_python_pyenv 3.9
export PY_BIN="python3.9"
export PY_TAG="cp39-cp39"
${OSX_DIR}/build_python_wheel.sh

# Build wheel for Python 3.10.
install_python_pyenv 3.10
export PY_BIN="python3.10"
export PY_TAG="cp310-cp310"
${OSX_DIR}/build_python_wheel.sh

# Build wheel for Python 3.11.
install_python_pyenv 3.11
export PY_BIN="python3.11"
export PY_TAG="cp311-cp311"
${OSX_DIR}/build_python_wheel.sh

# Build wheel for Python 3.12.
install_python_pyenv 3.12
export PY_BIN="python3.12"
export PY_TAG="cp312-cp312"
${OSX_DIR}/build_python_wheel.sh

# Clean up.
rm -fr ${CRC32C_INSTALL_PREFIX}
