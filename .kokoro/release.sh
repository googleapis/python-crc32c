#!/bin/bash
# Copyright 2023 Google LLC
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

set -eo pipefail
echo "Release script started"

if [ "$(uname)" == "Darwin" ]; then
    # Mac OS
    PYTHON=$(PYENV_VERSION=3.9 pyenv which python)
    PYTHON_BIN=$(dirname ${PYTHON})

    RELEASETOOL=${PYTHON_BIN}/releasetool
    TWINE=${PYTHON_BIN}/twine
    ${PYTHON} -m pip install gcp-releasetool twine --user

    echo "Change to code directory"
    REPO_ROOT=$(pwd)
    cd "${REPO_ROOT}"
    ls

else
    # Kokoro Linux
    # mv /keys/73713_google_cloud_pypi_password /73713_google_cloud_pypi_password

    PATH=/opt/python/cp39-cp39/bin/:$PATH
    PYTHON_BIN=/opt/python/cp39-cp39/bin/
    RELEASETOOL=${PYTHON_BIN}/releasetool
    PYTHON=${PYTHON_BIN}/python
    TWINE=${PYTHON_BIN}/twine
    ${PYTHON} -m pip install gcp-releasetool twine

    echo "Change to code directory"
    REPO_ROOT=/var/code/python-crc32c/
    cd "${REPO_ROOT}"
    ls

fi

echo "Download dependencies for release script"

# Start the releasetool reporter
${PYTHON} -m pip install --require-hashes -r ${REPO_ROOT}/.kokoro/requirements.txt
${RELEASETOOL} publish-reporter-script > /tmp/publisher-script; source /tmp/publisher-script

# Ensure that we have the latest versions of Twine, Wheel, and Setuptools.
${PYTHON} -m pip install --upgrade twine wheel setuptools --user

# Disable buffering, so that the logs stream through.
export PYTHONUNBUFFERED=1
echo "## RELASE WORKFLOW SUCCESSFUL ##"
echo "## Uploading Wheels ##"
# TODO: ONE OF THE BELOW WORKS
# Move into the package, build the distribution and upload.
# TWINE_PASSWORD=$(cat "${KOKORO_KEYSTORE_DIR}/73713_google-cloud-pypi-token-keystore-1")
# TWINE_PASSWORD=$(cat "${KOKORO_KEYSTORE_DIR}/73713_google_cloud_pypi_password")
# cd github/python-crc32c
# python3 setup.py sdist bdist_wheel
# twine upload --username __token__ --password "${TWINE_PASSWORD}" dist/*

${PYTHON} setup.py sdist
# ${TWINE} upload --skip-existing --username gcloudpypi --password "${TWINE_PASSWORD}" dist/* wheels/*
