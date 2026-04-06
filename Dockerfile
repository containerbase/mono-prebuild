
#--------------------------------------
# Ubuntu flavor
#--------------------------------------
ARG DISTRO=jammy

#--------------------------------------
# base images
#--------------------------------------
FROM ghcr.io/containerbase/ubuntu:22.04@sha256:eb29ed27b0821dca09c2e28b39135e185fc1302036427d5f4d70a41ce8fd7659 AS build-jammy

#--------------------------------------
# containerbase image
#--------------------------------------
FROM ghcr.io/containerbase/base:14.6.14@sha256:9c80af117229bfb52cfb29727ad0ebfe956421bbb13785ebd9936ddcd082a62b AS containerbase

FROM build-${DISTRO}

# Allows custom apt proxy usage
ARG APT_HTTP_PROXY

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env ENV=/usr/local/etc/env
SHELL ["/bin/bash" , "-c"]

# Set up containerbase
COPY --from=containerbase /usr/local/sbin/ /usr/local/sbin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
RUN install-containerbase

# renovate: datasource=github-tags packageName=git/git
RUN install-tool git v2.53.0

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
RUN install-tool python 3.14.3

# # renovate: datasource=docker versioning=docker
# RUN install-tool rust 1.93.0

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY --chmod=755 bin/install-builder.sh /usr/local/bin/

ENV TOOL_NAME=mono

RUN install-builder.sh

WORKDIR /usr/src/mono

COPY --chmod=755 bin/builder.sh /usr/local/bin/
