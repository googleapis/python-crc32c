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

py -3.7 -m pip install cmake

@rem First, build libcrc32c
set CRC32C_INSTALL_PREFIX=%KOKORO_ARTIFACTS_DIR%\bin\

echo %CRC32C_INSTALL_PREFIX%

set CMAKE_GENERATOR="Visual Studio 15 2017 Win64"
pushd crc32c

git submodule update --init --recursive

mkdir build

@REM removed -DCRC32C_BUILD_TESTS=no 
C:\Python37\Scripts\cmake -G %CMAKE_GENERATOR% -DCRC32C_BUILD_BENCHMARKS=no -DBUILD_SHARED_LIBS=yes ^
-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=yes -DCMAKE_INSTALL_PREFIX:PATH=%CRC32C_INSTALL_PREFIX% .

C:\Python37\Scripts\cmake --build . --config RelWithDebInfo --target install
dir %CRC32C_INSTALL_PREFIX% /b /s
popd

copy %CRC32C_INSTALL_PREFIX%bin\crc32c.dll .

@rem update python deps
py -3.5 -m pip install --upgrade pip setuptools wheel
py -3.6 -m pip install --upgrade pip setuptools wheel
py -3.7 -m pip install --upgrade pip setuptools wheel

@rem Build wheels (requires CRC32C_INSTALL_PREFIX is set)
py -3.5-64 -m pip wheel .
py -3.5-32 -m pip wheel .
py -3.6-64 -m pip wheel .
py -3.6-32 -m pip wheel .
py -3.7-64 -m pip wheel .
py -3.7-32 -m pip wheel .
