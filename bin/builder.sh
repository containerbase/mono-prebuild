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

echo "Building ${TOOL_NAME} ${TOOL_VERSION} for ${CODENAME}-${ARCH}"

if [[ "${DEBUG}" == "true" ]]; then
  set -x
fi

echo "------------------------"
echo "init repo"
git reset --quiet --hard "mono-${TOOL_VERSION}"

./autogen.sh \
  --prefix="${tp}" \
  --disable-libraries \
  --disable-mcs-build \
  --disable-support-build \
  --enable-nls=no \
  ;

echo "------------------------"
echo "------------------------"
./autogen.sh --help
echo "------------------------"
make help

echo "------------------------"
echo "------------------------"
echo "build ${TOOL_NAME}"
make -O "-j$(nproc)" all
make -O "-j$(nproc)" -C runtime install

shell_wrapper mono "${tp}/bin"

echo "------------------------"
echo "testing"
mono --version

# Download the latest stable `nuget.exe` to `/usr/local/bin`
sudo curl --retry 5 --fail -sSL -o /usr/local/bin/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

mono /usr/local/bin/nuget.exe help

file "${tp}/bin/mono"
ldd "${tp}/bin/mono"

echo "------------------------"
echo "create archive"
echo "Compressing ${TOOL_NAME} ${TOOL_VERSION} for ${CODENAME}-${ARCH}"
tar -cJf "/cache/${TOOL_NAME}-${TOOL_VERSION}-${CODENAME}-${ARCH}.tar.xz" -C "$(find_tool_path)" "${TOOL_VERSION}"
