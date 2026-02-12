#!/bin/bash

set -e

# shellcheck source=/dev/null
. /usr/local/containerbase/util.sh
# shellcheck source=/dev/null
. /usr/local/containerbase/utils/v2/overrides.sh

# add required system packages
install-apt \
    build-essential \
    cmake \
    file \
    libssl-dev \
    pkg-config \
    ;

# prepare mono source
git clone --recursive https://gitlab.winehq.org/mono/mono.git /usr/src/mono

# create folders
create_tool_path > /dev/null
mkdir /cache

echo "------------------------"
# echo "init repo"

# pushd /usr/src/mono > /dev/null
# cargo update
# cargo fetch
# git reset --hard
