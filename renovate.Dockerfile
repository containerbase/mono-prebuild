#-------------------------
# renovate rebuild trigger
# https://github.com/UpliftGames/wally/releases
#-------------------------

# makes lint happy
FROM scratch

# renovate: datasource=github-releases depName=wally packageName=UpliftGames/wally versioning=semver
ENV WALLY_VERSION=0.3.2
