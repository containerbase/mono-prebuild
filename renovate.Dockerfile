#-------------------------
# renovate rebuild trigger
# https://gitlab.winehq.org/mono/mono
#-------------------------

# makes lint happy
FROM scratch

# renovate: datasource=gitlab-releases depName=mono packageName=mono/mono versioning=semver
ENV MONO_VERSION=6.14.1
