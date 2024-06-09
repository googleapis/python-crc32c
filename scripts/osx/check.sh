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
echo "CHECKING OSX WHEELS"
VERSION=$(awk "/version \= ([0-9.]+)/" setup.cfg)
PACKAGE_VERSION=${VERSION:10}

# ``readlink -f`` is not our friend on OS X. This relies on **some**
# ``python`` being installed.
SCRIPT_FI=$(python -c "import os; print(os.path.realpath('${0}'))")
OSX_DIR=$(dirname ${SCRIPT_FI})
SCRIPTS_DIR=$(dirname ${OSX_DIR})
export REPO_ROOT=$(dirname ${SCRIPTS_DIR})

# set up pyenv & shell environment for switching across python versions
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
ls ${REPO_ROOT}/wheels

SUPPORTED_PYTHON_VERSIONS=("3.7" "3.8" "3.9" "3.10" "3.11" "3.12")

for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
    PYTHON="python${PYTHON_VERSION}"
    pyenv shell $PYTHON_VERSION
    VIRTUALENV="venv${PYTHON_VERSION//.}"
    # Make sure we have an updated `pip`.
    curl https://bootstrap.pypa.io/get-pip.py | ${PYTHON}
    # Make sure virtualenv and delocate.
    ${PYTHON} -m pip install --upgrade delocate
    LISTDEPS_CMD="${PYTHON}/delocate-listdeps --all --depending"
    ${PYTHON} -m venv ${VIRTUALENV}

    WHL=${REPO_ROOT}/wheels/google_crc32c-${PACKAGE_VERSION}-cp37-cp37m-macosx_10_9_x86_64.whl
    ${VIRTUALENV}/bin/pip install ${WHL}
    ${VIRTUALENV}/bin/pip install pytest
    ${VIRTUALENV}/bin/py.test ${REPO_ROOT}/tests
    ${VIRTUALENV}/bin/python ${REPO_ROOT}/scripts/check_crc32c_extension.py
    ${LISTDEPS_CMD} ${WHL}
    rm -fr ${VIRTUALENV}

done
