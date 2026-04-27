
#--------------------------------------
# Ubuntu flavor
#--------------------------------------
ARG DISTRO=jammy

#--------------------------------------
# base images
#--------------------------------------
FROM ghcr.io/containerbase/ubuntu:22.04@sha256:962f6cadeae0ea6284001009daa4cc9a8c37e75d1f5191cf0eb83fe565b63dd7 AS build-jammy

#--------------------------------------
# containerbase image
#--------------------------------------
FROM ghcr.io/containerbase/base:14.9.4@sha256:e7163335fccb8825596664248137c6640d8ae086f5dbf8fe5b827dd96f763330 AS containerbase

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
RUN install-tool git v2.54.0

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
RUN install-tool python 3.14.4

# # renovate: datasource=docker versioning=docker
# RUN install-tool rust 1.93.0

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY --chmod=755 bin/install-builder.sh /usr/local/bin/

ENV TOOL_NAME=mono

RUN install-builder.sh

WORKDIR /usr/src/mono

COPY --chmod=755 bin/builder.sh /usr/local/bin/
