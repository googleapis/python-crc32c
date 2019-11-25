@REM available windows versions on CI as of 2019-Nov-25
@REM  -3.7-64
@REM  -3.7-32
@REM  -3.6-64
@REM  -3.6-32
@REM  -3.5-64
@REM  -3.5-32
@REM  -3.4-64
@REM  -3.4-32
@REM  -2.7-64
@REM  -2.7-32"Build Wheel"



@rem First, build libcrc32c
mkdir %BUILD_DIR%
cd %BUILD_DIR%
cmake
    -G "%CMAKE_GENERATOR%"
    -DCRC32C_BUILD_TESTS=no
    -DCRC32C_BUILD_BENCHMARKS=no
    -DBUILD_SHARED_LIBS=yes
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=yes
    -DCMAKE_INSTALL_PREFIX:PATH=%CRC32C_INSTALL_PREFIX%
    ..
cmake --build . --config RelWithDebInfo --target install
dir %CRC32C_INSTALL_PREFIX% /b /s


@rem Build wheels (requires CRC32C_INSTALL_PREFIX is set)
cd %APPVEYOR_BUILD_FOLDER%
py -3.5 -m pip wheel .
py -3.6 -m pip wheel .
py -3.7 -m pip wheel .

@rem TODO: add 64/32 bit both here.


REM test_script:
REM     # Install the wheel with pip
REM     - "%PYTHON35%\\python -m pip install --no-index --find-links=. google-crc32c"
REM     - "%PYTHON36%\\python -m pip install --no-index --find-links=. google-crc32c"
REM     - "%PYTHON37%\\python -m pip install --no-index --find-links=. google-crc32c"
REM     # Install pytest with pip
REM     - "%PYTHON35%\\python -m pip install pytest"
REM     - "%PYTHON36%\\python -m pip install pytest"
REM     - "%PYTHON37%\\python -m pip install pytest"
REM     # Run the tests
REM     - "%PYTHON35%/python -m pytest tests"
REM     - "%PYTHON36%/python -m pytest tests"
REM     - "%PYTHON37%/python -m pytest tests"

REM artifacts:
REM     - path: 'google_crc32c*win*.whl'
