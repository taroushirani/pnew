# pnew - (not so) portable NNSVS environment for Windows

This repository contains the helper scripts to build [NNSVS](https://github.com/r9y9/nnsvs) environment for Windows. The environment made by these scripts makes use of [WinPython](https://winpython.github.io/) and [MSYS2](https://www.msys2.org/).  It is fully functional, and (not so) portable(total 4GB of disk usage).

## System requirements
- Windows 10 64bit RS4(1803) or later: The helper scripts make use of curl and tar, which are added from Windows 10 RS4(1803). 
- About 4GB of free storage space.
- [NVidia CUDA Toolkit (10.1/10.2)](https://developer.nvidia.com/cuda-toolkit) (optional): PyTorch supports CUDA 10.1 and 10.2. Be careful not to select CUDA 11.0.

## Build dependencies
### [Visual Studio Build Tools 2019](https://visualstudio.microsoft.com/visual-cpp-build-tools/) and [Windows 10 SDK 10.0.14393.0](https://developer.microsoft.com/windows/downloads/sdk-archive/)

Some python libraries which NNSVS depends on require C/C++ compiler to make their python modules.  To be consistent with WinPython, it must be Microsoft Visual C++ 14.0. You can use [Visual Studio Build Tools 2019](https://visualstudio.microsoft.com/visual-cpp-build-tools/). There are some notes;

1. "MSVC v140" contains the toolkit of Microsoft Visual C++ 14.0, but it lacks MSBuild.exe.
2. "MSVC v142" contains MSBuild.exe.
3. The latest version of Windows 10 SDK which Microsoft Visual C++ 14.0 on Windows 10 can handle is 10.0.14393.0(for detail, please see [VS: Do not select a Windows SDK too high for current VS version (!2388) · Merge Requests · CMake / CMake · GitLab](https://gitlab.kitware.com/cmake/cmake/-/merge_requests/2388)).
. You can download it from [Windows SDK archive](https://developer.microsoft.com/windows/downloads/sdk-archive/), but it lacks rc.exe.
4. The latest Windows 10 SDK(10.0.18362.0) contains rc.exe.

*Please be sure to check "MSVC v142", "Windows 10 SDK", "CMake", "MSVC v140" when you install "Visual Studio Build Tools".*

## Usage
1. Download this repository to where you want to create NNSVS environment.
2. Launch VS2015 x64 Native Tools Command Prompt from Windows menu, and move to the directory where you download this repository. You can use the normal command prompt, but you have to set correct PATH, LIB, INCLUDE environment variables manually to use the toolchains.
3. Run bootstrap.bat.
4. Launch msys64/MSYS.exe and do as you like.

## Known issues
To use WinPython from MSYS2(mintty), you have to wrap it with [winpty](https://github.com/rprichard/winpty)(You can install it from pacman).

## Resources
- [NNSVS](https://github.com/r9y9/nnsvs)
