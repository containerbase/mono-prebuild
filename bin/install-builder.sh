#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh
# shellcheck source=/dev/null
. /usr/local/containerbase/utils/v2/overrides.sh

echo -e "\e[0m\e[32m install builder ...\e[0m\e[2m"
echo -e "\e[0m=======================================================\e[2m"

echo -e "\e[0m\e[33m add required system packages ...\e[0m\e[2m"
install-apt \
    automake \
    build-essential \
    cmake \
    file \
    libssl-dev \
    libtool \
    pkg-config \
    ;


echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m prepare mono source ...\e[0m\e[2m"
echo -e "\e[0m-------------------------------------------------------"
git clone --quiet --recursive https://gitlab.winehq.org/mono/mono.git /usr/src/mono

echo -e "\e[0m-------------------------------------------------------"

echo -e "\e[0m\e[33m create folders ...\e[0m\e[2m"
create_tool_path > /dev/null
mkdir /cache

#echo "------------------------"
# echo "init repo"

# pushd /usr/src/mono > /dev/null
# cargo update
# cargo fetch
# git reset --hard

echo -e "\e[0m======================================================="
echo -e "\e[0m\e[32m done\e[0m"
