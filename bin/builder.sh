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


echo -e "\e[0m\e[33m prepare repo ...\e[0m\e[2m"
git reset --quiet --hard "mono-${TOOL_VERSION}"
git submodule --quiet update --init --recursive

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m configure ${TOOL_NAME} ...\e[0m\e[2m"
./autogen.sh \
  --prefix="${tp}" \
  --disable-libraries \
  --disable-mcs-build \
  --disable-support-build \
  --enable-nls=no \
  ;

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m build ${TOOL_NAME} ...\e[0m\e[2m"
make -O "-j$(nproc)" all
make -O "-j$(nproc)" -C runtime install

shell_wrapper mono "${tp}/bin"

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m test ${TOOL_NAME} ...\e[0m\e[2m"
mono --version

# Download the latest stable `nuget.exe` to `/usr/local/bin`
sudo curl --retry 5 --fail -sSL -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

mono /usr/local/bin/nuget.exe help

file "${tp}/bin/mono"
ldd "${tp}/bin/mono"

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m package ${TOOL_NAME} ...\e[0m\e[2m"
echo "Compressing ${TOOL_NAME} ${TOOL_VERSION} for ${CODENAME}-${ARCH}"
tar -cJf "/cache/${TOOL_NAME}-${TOOL_VERSION}-${CODENAME}-${ARCH}.tar.xz" -C "$(find_tool_path)" "${TOOL_VERSION}"

echo -e "\e[0m======================================================="
echo -e "\e[0m\e[32m done\e[0m"
