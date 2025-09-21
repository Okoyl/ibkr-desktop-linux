# Troubleshooting Guide

## Index of Common Issues

- [Missing Charts](#missing-charts)
---

## Missing Charts
That probably means that the QTWebEgine components fail to render using any it's default gpu rendering backend.
One workaround is to force software rendering by setting the environment variable `QTWEBENGINE_CHROMIUM_FLAGS` to `--disable-gpu`.

```shell
export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"
```

Another hacky workaround is to setup dxvk in your wine prefix, this should in theory allow hardware acceleration using vulkan.

```shell
export WINEPREFIX=~/.wine-ibkr
winetricks dxvk

export QTWEBENGINE_CHROMIUM_FLAGS="--use-vulkan --ignore-gpu-blocklist --enable-features=Vulkan,UseSkiaRenderer"
```

Using Vulkan you can also select a specific GPU if you have multiple ones, for example to use the discrete nvidia card instead of the integrated intel one:

```shell
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
```

Or for AMD:

```shell
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.json
```


**If you found another fix or workaround please open an issue or a PR to add it here.**
