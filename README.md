# Godot Engine

<p align="center">
  <a href="https://godotengine.org">
    <img src="misc/logo/logo_outlined.svg" width="400" alt="Godot Engine logo">
  </a>
</p>

## 2D and 3D cross-platform game engine

**[Godot Engine](https://godotengine.org) is a feature-packed, cross-platform
game engine to create 2D and 3D games from a unified interface.** It provides a
comprehensive set of [common tools](https://godotengine.org/features), so that
users can focus on making games without having to reinvent the wheel. Games can
be exported with one click to a number of platforms, including the major desktop
platforms (Linux, macOS, Windows), mobile platforms (Android, iOS), as well as
Web-based platforms and [consoles](https://godotengine.org/consoles).

## Free, open source and community-driven

Godot is completely free and open source under the very permissive [MIT license](https://godotengine.org/license).
No strings attached, no royalties, nothing. The users' games are theirs, down
to the last line of engine code. Godot's development is fully independent and
community-driven, empowering users to help shape their engine to match their
expectations. It is supported by the [Godot Foundation](https://godot.foundation/)
not-for-profit.

Before being open sourced in [February 2014](https://github.com/godotengine/godot/commit/0b806ee0fc9097fa7bda7ac0109191c9c5e0a1ac),
Godot had been developed by [Juan Linietsky](https://github.com/reduz) and
[Ariel Manzur](https://github.com/punto-) for several years as an in-house
engine, used to publish several work-for-hire titles.

![Screenshot of a 3D scene in the Godot Engine editor](https://raw.githubusercontent.com/godotengine/godot-design/master/screenshots/editor_tps_demo_1920x1080.jpg)

## Getting the engine

### Windows RTX build

The RTX branch combines the [Godot 4.8 beta 4 source][beta4] with
[NVIDIA's path tracer and DLSS integration][nvidia-rtx]. It includes Forward+
hardware path tracing, DLSS Super Resolution, Ray Reconstruction and Frame
Generation, Reflex, and ray tracing debugging tools. Feature availability
depends on the GPU, driver, and rendering backend.

With the [Windows build dependencies][windows-build] installed, build the x64
editor with Vulkan and Direct3D 12 support from PowerShell.

```powershell
python -m pip install scons zstandard
python misc/scripts/install_d3d12_sdk_windows.py
python misc/scripts/install_accesskit.py
$env:GODOT_VERSION_STATUS = 'beta4'
scons platform=windows target=editor arch=x86_64 d3d12=yes angle=no use_streamline=yes
```

Copy the Windows x64 runtime DLLs from [Streamline SDK 2.10.0][streamline-sdk]
(`bin/x64`, excluding `development`) beside the editor executable in `bin/`.
For path tracing, use Forward+ with Vulkan and enable **Pathtracing Enabled**
on the scene's `Environment`. The Direct3D 12 driver supports DLSS Super
Resolution in the raster renderer. For Ray Reconstruction with Vulkan, select
**DLSS** under
**Rendering > Scaling 3D > Mode** and **DLSS Ray Reconstruction** as the
environment's denoiser. A scale below 1.0 enables upscaling. A scale of 1.0 runs
at native resolution.

[beta4]: https://github.com/godotengine/godot/commit/b070e63b161aa816afac71dcfc9d60859d38f220
[nvidia-rtx]: https://github.com/NVIDIA-RTX/godot/commit/49a825dc52c0f1892ff5ce5cdbbe7572c638d41a
[windows-build]: https://docs.godotengine.org/en/latest/engine_details/development/compiling/compiling_for_windows.html
[streamline-sdk]: https://github.com/NVIDIA-RTX/Streamline/releases/tag/v2.10.0

### Binary downloads

Official binaries for the Godot editor and the export templates can be found
[on the Godot website](https://godotengine.org/download).

### Compiling from source

[See the official docs](https://docs.godotengine.org/en/latest/engine_details/development/compiling)
for compilation instructions for every supported platform.

## Community and contributing

Godot is not only an engine but an ever-growing community of users and engine
developers. The main community channels are listed [on the homepage](https://godotengine.org/community).

The best way to get in touch with the core engine developers is to join the
[Godot Contributors Chat](https://chat.godotengine.org).

To get started contributing to the project, see the [contributing guide](CONTRIBUTING.md).
This document also includes guidelines for reporting bugs.

## Documentation and demos

The official documentation is hosted on [Read the Docs](https://docs.godotengine.org).
It is maintained by the Godot community in its own [GitHub repository](https://github.com/godotengine/godot-docs).

The [class reference](https://docs.godotengine.org/en/latest/classes/)
is also accessible from the Godot editor.

We also maintain official demos in their own [GitHub repository](https://github.com/godotengine/godot-demo-projects)
as well as the [Asset Store](https://store.godotengine.org/).

There are also a number of other
[learning resources](https://docs.godotengine.org/en/latest/community/tutorials.html)
provided by the community, such as text and video tutorials, demos, etc.
Consult the [community channels](https://godotengine.org/community)
for more information.

[![Code Triagers Badge](https://www.codetriage.com/godotengine/godot/badges/users.svg)](https://www.codetriage.com/godotengine/godot)
[![Translate on Weblate](https://hosted.weblate.org/widgets/godot-engine/-/godot/svg-badge.svg)](https://hosted.weblate.org/engage/godot-engine/?utm_source=widget)
