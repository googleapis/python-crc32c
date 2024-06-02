#!/bin/bash

set -eo pipefail

REPO_ROOT=$(pwd)/github/python-crc32c
cd github/python-crc32c

# Build for OSX
./scripts/osx/build.sh

# REPO_ROOT=$(pwd)
./.kokoro/release.sh
