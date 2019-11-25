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
set CRC32C_INSTALL_PREFIX=C:\bin\
pushd crc32c
mkdir build
cd build
C:\Python37\Scripts\cmake ^
    -DCRC32C_BUILD_TESTS=no ^
    -DCRC32C_BUILD_BENCHMARKS=no ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=yes ^
    -DCMAKE_INSTALL_PREFIX:PATH=%CRC32C_INSTALL_PREFIX% ^
    ..

@REM cmake ^
@REM     -G "%CMAKE_GENERATOR%" ^
@REM     -DCRC32C_BUILD_TESTS=no ^
@REM     -DCRC32C_BUILD_BENCHMARKS=no ^
@REM     -DBUILD_SHARED_LIBS=yes ^
@REM     -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=yes ^
@REM     -DCMAKE_INSTALL_PREFIX:PATH=%CRC32C_INSTALL_PREFIX% ^
@REM     ..

C:\Python37\Scripts\cmake --build . --config RelWithDebInfo --target install
dir %CRC32C_INSTALL_PREFIX% /b /s
popd

@rem Build wheels (requires CRC32C_INSTALL_PREFIX is set)
cd %APPVEYOR_BUILD_FOLDER%
py -3.5 -m pip wheel .
py -3.6 -m pip wheel .
py -3.7 -m pip wheel .

@rem TODO: add 64/32 bit both here.
