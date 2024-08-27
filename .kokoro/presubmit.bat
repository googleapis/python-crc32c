@rem Copyright 2019 Google LLC. All rights reserved.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.

@echo "Starting Windows build"

cd /d %~dp0
cd ..

@rem as this package uses submodules make sure we have all content
call git config --global --add safe.directory C:/tmpfs/src/github/python-crc32c
call git submodule update --recursive || goto :error

@echo "Build Wheels and Run Tests"
call scripts\windows\build.bat || goto :error

for /r %%a in (*.whl) do xcopy "%%a" %KOKORO_ARTIFACTS_DIR% /i

goto :EOF

:error
exit /b 1
