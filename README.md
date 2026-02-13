# containerbase mono releases

[![build](https://github.com/containerbase/mono-prebuild/actions/workflows/build.yml/badge.svg)](https://github.com/containerbase/mono-prebuild/actions/workflows/build.yml?query=branch%3Amain)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/containerbase/mono-prebuild)
![License: MIT](https://img.shields.io/github/license/containerbase/mono-prebuild)

Prebuild mono[^1] runtime releases used by [containerbase/base](https://github.com/containerbase/base).

## Local development

Build the image

```bash
docker build -t builder --build-arg APT_HTTP_PROXY=http://apt-proxy:3142 --build-arg DISTRO=jammy .
```

Test the image

```bash
docker run --rm -it -v ${PWD}/.cache:/cache -e DEBURG=true builder 6.14.1
```

`${PWD}/.cache` will contain packed releases after successful build.

Optional environment variables

| Name             | Description                                          | Default   |
| ---------------- | ---------------------------------------------------- | --------- |
| `DISTRO`         | Set an ubuntu base distro, only `jammy` is supported | `jammy`   |
| `APT_HTTP_PROXY` | Set an APT http proxy for installing build deps      | `<empty>` |
| `DEBUG`          | Show verbose php build output                        | `<empty>` |

[^1]: <https://gitlab.winehq.org/mono/mono>
