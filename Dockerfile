
#--------------------------------------
# Ubuntu flavor
#--------------------------------------
ARG DISTRO=jammy

#--------------------------------------
# base images
#--------------------------------------
FROM ghcr.io/containerbase/ubuntu:22.04@sha256:3b06811b2afd352be909dd088a004166d665dc76d38b13eada33522a9d915c6f AS build-jammy

#--------------------------------------
# containerbase image
#--------------------------------------
FROM ghcr.io/containerbase/base:14.13.12@sha256:3d30cd7ec586567f9ed4b98570b485c9ddfe1e60019f0ab6cdf451677d1ca42b AS containerbase

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
RUN install-tool git v2.55.0

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
RUN install-tool python 3.14.6

# # renovate: datasource=docker versioning=docker
# RUN install-tool rust 1.93.0

ENTRYPOINT [ "dumb-init", "--", "builder.sh" ]

COPY --chmod=755 bin/install-builder.sh /usr/local/bin/

ENV TOOL_NAME=mono

RUN install-builder.sh

WORKDIR /usr/src/mono

COPY --chmod=755 bin/builder.sh /usr/local/bin/
