
#--------------------------------------
# Ubuntu flavor
#--------------------------------------
ARG DISTRO=jammy

#--------------------------------------
# base images
#--------------------------------------
FROM ghcr.io/containerbase/ubuntu:22.04@sha256:b000e69a50ff940390233025e7a337fb8469b509e2334fa4d018ac30f3e18cdb AS build-jammy

#--------------------------------------
# containerbase image
#--------------------------------------
FROM ghcr.io/containerbase/base:14.68.4@sha256:091455dbb4507f3e4ff58d1e04c65f37c89c3b514b11156d38eb2f6de0206990 AS containerbase

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
RUN install-tool git v2.56.1

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
