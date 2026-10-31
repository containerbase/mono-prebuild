
#--------------------------------------
# Ubuntu flavor
#--------------------------------------
ARG DISTRO=jammy

#--------------------------------------
# base images
#--------------------------------------
FROM ghcr.io/containerbase/ubuntu:22.04@sha256:076e7bf82319619f28dd0aa9c02ab34b055ad37100395b4f49a2ffba04fb5e11 AS build-jammy

#--------------------------------------
# containerbase image
#--------------------------------------
FROM ghcr.io/containerbase/base:14.59.0@sha256:88013d3d2c88ecfe9e44eaaa22ee771cefb3a51117002cbc073b9a95a8f969da AS containerbase

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
RUN install-tool git v2.56.0

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
RUN install-tool python 3.15.2

# # renovate: datasource=docker versioning=docker
# RUN install-tool rust 1.93.0

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY --chmod=755 bin/install-builder.sh /usr/local/bin/

ENV TOOL_NAME=mono

RUN install-builder.sh

WORKDIR /usr/src/mono

COPY --chmod=755 bin/builder.sh /usr/local/bin/
