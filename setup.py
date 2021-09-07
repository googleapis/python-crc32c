# Copyright 2018 Google LLC
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

import os
import platform
import shutil
import sys

import setuptools
import setuptools.command.build_ext

_EXTRA_DLL = "extra-dll"
_DLL_FILENAME = "crc32c.dll"

# Explicit environment variable disables pure-Python fallback
CRC32C_PURE_PYTHON_EXPLICIT = "CRC32C_PURE_PYTHON" in os.environ
_FALSE_OPTIONS = ("0", "false", "no", "False", "No", None)
CRC32C_PURE_PYTHON = os.getenv("CRC32C_PURE_PYTHON") not in _FALSE_OPTIONS
CRC32C_CFFI = os.getenv("CRC32C_CFFI") not in _FALSE_OPTIONS


def copy_dll(build_lib):
    if os.name != "nt":
        return

    install_prefix = os.environ.get("CRC32C_INSTALL_PREFIX")
    if install_prefix is None:
        return

    installed_dll = os.path.join(install_prefix, "bin", _DLL_FILENAME)
    lib_dlls = os.path.join(build_lib, "google_crc32c", _EXTRA_DLL)
    os.makedirs(lib_dlls, exist_ok=True)
    relocated_dll = os.path.join(lib_dlls, _DLL_FILENAME)
    shutil.copyfile(installed_dll, relocated_dll)


class BuildExtWithDLL(setuptools.command.build_ext.build_ext):
    def run(self):
        copy_dll(self.build_lib)
        result = setuptools.command.build_ext.build_ext.run(self)
        return result


def do_setup(**kwargs):
    setuptools.setup(
        packages=["google_crc32c"],
        package_dir={"": "src"},
        **kwargs
    )


def build_c_extension():
    module_path = os.path.join("src", "google_crc32c", "_crc32c.c")
    module = setuptools.Extension(
        "google_crc32c._crc32c",
        sources=[os.path.normcase(module_path)],
        libraries=["crc32c"],
    )

    install_prefix = os.getenv("CRC32C_INSTALL_PREFIX")
    if install_prefix is not None:
        install_prefix = os.path.realpath(install_prefix)
        print(f"#### using local install of 'crc32c': {install_prefix}")
        library_dirs = [os.path.join(install_prefix, "lib")]
        if os.name == "nt":
            library_dirs.append(os.path.join(install_prefix, "bin"))
        kwargs = {
            "include_dirs": [os.path.join(install_prefix, "include")],
            "library_dirs": library_dirs,
            "rpath": os.pathsep.join(library_dirs),
        }
    else:
        print("#### using global install of 'crc32c'")
        kwargs = {}

    do_setup(
        ext_modules=[module],
        cmdclass={"build_ext": BuildExtWithDLL},
        **kwargs
    )

def build_cffi():
    build_path = os.path.join("src", "google_crc32c_build.py")
    builder = "{}:FFIBUILDER".format(build_path)
    cffi_dep = "cffi >= 1.0.0"
    do_setup(
        package_data={"google_crc32c": [os.path.join(_EXTRA_DLL, _DLL_FILENAME)]},
        setup_requires=[cffi_dep],
        cffi_modules=[builder],
        install_requires=[cffi_dep],
        cmdclass={"build_ext": BuildExtWithDLL},
    )


if CRC32C_PURE_PYTHON:
    print("### Building explicitly-requested pure-Python version")
    do_setup()
    sys.exit(0)

# The native C extenstion segfaults for MacOS 11 (Big Sur) where
# Python < 3.9.  As a workaround, build the CFFI version for all MacOS
# versions where Python < 3.9.
macos_lt_py39 = platform.system() == "Darwin" and sys.version_info < (3, 9)
if CRC32C_CFFI or macos_lt_py39:
    if CRC32C_CFFI:
        print("### Building explicitly-requested CFFI version")
    else:
        print("### Building CFFI version on MacOS, Python < 3.9")
    builder = build_cffi
    builder_name = "CFFI shim"
else:
    print("### Building C extension")
    builder = build_c_extension
    builder_name = "C extension"

try:
    builder()
except SystemExit:
    if CRC32C_PURE_PYTHON_EXPLICIT:
        # If build / install fails, it is likely a compilation error with
        # the C extension:  advise user how to enable the pure-Python
        # build.
        print(
            f"Compiling the {builder_name} for the crc32c library failed. "
            "To enable building / installing a pure-Python-only version, "
            "set 'CRC32C_PURE_PYTHON=1' in the environment."
        )
        raise

    # Unfortunately, this output will not be visible under pip unless
    # pip's verboseity is greater than the default.  Run `pip -v` to see it.
    print(
        f"Compiling the {builder_name} for the crc32c library failed. "
        "Falling back to pure Python build."
    )
    do_setup()
