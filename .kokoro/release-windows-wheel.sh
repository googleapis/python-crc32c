#!/bin/bash

set -eo pipefail

# Build for Windows
../scripts/osx/build.sh
# TODO: APPVEYOR

./release.sh
