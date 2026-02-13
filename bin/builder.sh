#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh
# shellcheck source=/dev/null
. /usr/local/containerbase/utils/v2/overrides.sh

# trim leading v
export TOOL_VERSION=${1#v}

# shellcheck disable=SC1091
CODENAME=$(. /etc/os-release && echo "${VERSION_CODENAME}")

ARCH=$(uname -p)
tp=$(create_versioned_tool_path)

check_semver "${TOOL_VERSION}"

echo -e "\e[0m\e[32m building ${TOOL_NAME} ${TOOL_VERSION} for ${CODENAME}-${ARCH} ...\e[0m\e[2m"
echo -e "\e[0m=======================================================\e[2m"

if [[ "${DEBUG}" == "true" ]]; then
  set -x
fi


echo -e "\e[0m\e[33m prepare source ...\e[0m\e[2m"
curl --retry 5 --fail -sSLo "/tmp/mono-${TOOL_VERSION}.tar.xz" "https://dl.winehq.org/mono/sources/mono/mono-${TOOL_VERSION}.tar.xz"
tar --strip 1 -xf "/tmp/mono-${TOOL_VERSION}.tar.xz"

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m configure ${TOOL_NAME} ...\e[0m\e[2m"
./configure \
  --prefix="${tp}" \
  --disable-boehm \
  --disable-libraries \
  --enable-nls=no \
  --with-mcs-docs=no \
  ;

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m build ${TOOL_NAME} ...\e[0m\e[2m"
make -O "-j$(nproc)" all
make -O "-j$(nproc)" -C mono install
make -O "-j$(nproc)" -C runtime install
make -O "-j$(nproc)" -C data install
make -O "-j$(nproc)" -C support install
rm -rf "${tp}"/{share,include}
rm -rf "${tp}/lib"/*.{a,la}


echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m test ${TOOL_NAME} ...\e[0m\e[2m"

shell_wrapper mono "${tp}/bin"
mono --version

file "${tp}/bin/mono"
ldd "${tp}/bin/mono"

# Download the latest stable `nuget.exe` to `/usr/local/bin`
curl --retry 5 --fail -sSL -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

mono /usr/local/bin/nuget.exe help
mono /usr/local/bin/nuget.exe search nuget.commandline -Take 1


echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m package ${TOOL_NAME} ...\e[0m\e[2m"
echo "Compressing ${TOOL_NAME} ${TOOL_VERSION} for ${CODENAME}-${ARCH}"
tar -cJf "/cache/${TOOL_NAME}-${TOOL_VERSION}-${CODENAME}-${ARCH}.tar.xz" -C "$(find_tool_path)" "${TOOL_VERSION}"

echo -e "\e[0m======================================================="
echo -e "\e[0m\e[32m done\e[0m"
