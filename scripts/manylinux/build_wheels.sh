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

#
# Determine the Python versions for which we are to build wheels.
#
echo "BUILD_PYTHON: ${BUILD_PYTHON}"
PYTHON_VERSIONS=""

if [[ -z ${BUILD_PYTHON} ]]; then
    #
    # Collect all Python versions available in the image.
    #
    for PYTHON_BIN in /opt/python/*/bin; do
        # H/T: https://stackoverflow.com/a/229606/1068170
        if [[ "${PYTHON_BIN}" == *"36"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
            continue
        elif [[ "${PYTHON_BIN}" == *"37"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
            continue
        elif [[ "${PYTHON_BIN}" == *"38"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
            continue
        elif [[ "${PYTHON_BIN}" == *"39"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
            continue
        elif [[ "${PYTHON_BIN}" == *"310"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
            continue
        else
            echo "Ignoring unsupported version: ${PYTHON_BIN}"
            echo "====================================="
        fi
    done
else
    #
    # Collect only the specified Python version(s).
    #

    # Strip the `-dev` suffix, since it isn't present in the manylinux
    # directory # name for Python 3.10.
    STRIPPED_PYTHON=$(echo ${BUILD_PYTHON} | sed -e "s/\.//g" | sed -e "s/-dev$//")
    for PYTHON_BIN in /opt/python/*/bin; do
        # Match both `cp*` and `pp*`.
        if [[ "${PYTHON_BIN}" == *"${STRIPPED_PYTHON}"* ]]; then
            PYTHON_VERSIONS="${PYTHON_VERSIONS} ${PYTHON_BIN}"
        fi
    done
fi

#
# Build the wheels.
#
cd ${REPO_ROOT}
for PYTHON_BIN in ${PYTHON_VERSIONS}; do
    ${PYTHON_BIN}/python -m pip install --upgrade setuptools pip wheel
    ${PYTHON_BIN}/python -m pip -v wheel . --wheel-dir dist_wheels/
done

#
# Bundle external shared libraries into the wheels
#
${MAIN_PYTHON_BIN}/python -m pip install --upgrade setuptools pip wheel
${MAIN_PYTHON_BIN}/python -m pip install \
        --requirement ${REPO_ROOT}/scripts/dev-requirements.txt

for whl in dist_wheels/google_crc32c*.whl; do
    ${MAIN_PYTHON_BIN}/auditwheel repair "${whl}" --wheel-dir wheels/
done

#
# Clean up.
#
rm -fr ${REPO_ROOT}/dist_wheels/
