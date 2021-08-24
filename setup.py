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
import shutil
import setuptools
import setuptools.command.build_ext
import warnings

_EXTRA_DLL = "extra-dll"
_DLL_FILENAME = "crc32c.dll"


def copy_dll(build_lib):
    if os.name != "nt":
        return

    install_prefix = os.environ.get("CRC32C_INSTALL_PREFIX")
    if install_prefix is None:
        return

    installed_dll = os.path.join(install_prefix, "bin", _DLL_FILENAME)
    lib_dlls = os.path.join(build_lib, "google_crc32c", _EXTRA_DLL)
    os.makedirs(lib_dlls)
    relocated_dll = os.path.join(lib_dlls, _DLL_FILENAME)
    shutil.copyfile(installed_dll, relocated_dll)


class BuildExtWithDLL(setuptools.command.build_ext.build_ext):
    def run(self):
        copy_dll(self.build_lib)
        result = setuptools.command.build_ext.build_ext.run(self)
        return result


module_path = os.path.join("src", "google_crc32c", "_crc32c.c")
module = setuptools.Extension(
    "google_crc32c._crc32c",
    sources=[os.path.normcase(module_path)],
    include_dirs=["usr/include"],
    libraries=["crc32c", "stdc++"],
    library_dirs=["usr/lib"],
)


def main(with_extension=True):
    if with_extension:
        ext_modules = [module]
    else:
        ext_modules = []

    setuptools.setup(
        packages=["google_crc32c"],
        package_dir={"": "src"},
        ext_modules=ext_modules,
        cmdclass={"build_ext": BuildExtWithDLL},
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        raise
    except SystemExit:
        # If installation fails, it is likely a compilation error with the
        # C extension. Try to install again without it.
        warnings.warn(
            "Compiling the C Extension has failed. Only a pure "
            "python implementation will be usable."
        )
        main(with_extension=False)
