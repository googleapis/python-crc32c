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
# install required packages for pyenv
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
brew install openssl readline sqlite3 xz zlib tcl-tk

install_python_pyenv() {
    version=$1

    if [ -z "$(command -v python$version)" ]; then
        echo "Python $version is not installed. Installing..."
        pyenv install $version
        echo "Python $version installed."
    else
        echo "Python $version is already installed."
    fi
    pyenv shell $version
}

# Build and install `libcrc32c`
export PY_BIN="${PY_BIN:-python3}"
export CRC32C_INSTALL_PREFIX="${REPO_ROOT}/usr"

cd ${REPO_ROOT}
# Add directory as safe to avoid "detected dubious ownership" fatal issue
git config --global --add safe.directory $REPO_ROOT
git config --global --add safe.directory $REPO_ROOT/google_crc32c
git submodule update --init --recursive

${OSX_DIR}/build_c_lib.sh

SUPPORTED_PYTHON_VERSIONS=("3.7" "3.8" "3.9" "3.10" "3.11" "3.12")

for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
    echo "Build wheel for Python ${PYTHON_VERSION}"
    SOABI_FLAG="m"
    if [ "${PYTHON_VERSION}" != "3.7" ]; then
        SOABI_FLAG=""
    fi
    install_python_pyenv $PYTHON_VERSION
    export PY_BIN="python${PYTHON_VERSION}"
    export PY_TAG="cp${PYTHON_VERSION//.}-cp${PYTHON_VERSION//.}${SOABI_FLAG}"
    ${OSX_DIR}/build_python_wheel.sh

done

# Clean up.
rm -fr ${CRC32C_INSTALL_PREFIX}
