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

@rem This test file runs for one Python version at a time, and is intended to
@rem be called from within the build loop.

FOR %%P IN (3.8.10, 3.9.13, 3.10.11, 3.11.9, 3.12.4) DO (
    py -%%P -m pip install --no-index --find-links=wheels google-crc32c --force-reinstall

    py -%%P ./scripts/check_crc32c_extension.py

    py -%%P -m pip install pytest
    py -%%P -m pytest tests
)