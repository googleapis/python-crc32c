#!/bin/bash
# Copyright 2024 Google LLC
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

# Start the releasetool reporter
python3 -m pip install --require-hashes -r ${REPO_ROOT}/.kokoro/requirements.txt

# Disable buffering, so that the logs stream through.
export PYTHONUNBUFFERED=1

TWINE_PASSWORD=$(cat "${KOKORO_KEYSTORE_DIR}/73713_google-cloud-pypi-token-keystore-1")
python3 -m twine upload --skip-existing --username gcloudpypi --password "${TWINE_PASSWORD}" ${REPO_ROOT}/wheels/*
