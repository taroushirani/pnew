#! /bin/bash
set -eux

export PATH=/opt/python:/opt/python/Scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/mingw64/bin

ROOT_DIR=$(pwd)
WORKING_DIR=/tmp

cd $WORKING_DIR

### Pacman settings.
# Initialize pacman
pacman-key --init

# Update pacman repository
pacman -Syuu --noconfirm

### Toolchains settings
## Install git, winpty
pacman -Su --noconfirm git winpty

### Python settings
## Upgrade numpy, cython
pip install -U numpy cython

## Install pytorch
# for CUDA 10.2
pip install torch===1.6.0 torchvision===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html
# for CUDA 10.1
#pip install torch==1.6.0+cu101 torchvision==0.7.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html
# for CUDA 9.2
# Follow instructions at this URL: https://github.com/pytorch/pytorch#from-source 

## Install nnmnkwii, NNSVS
# Pysptk require Microsoft Visual C++ 14.0.
# You can download "Visual Studio Build Tools 2019" from https://visualstudio.microsoft.com/visual-cpp-build-tools/.
#
# (1) "MSVC v140" contains the toolkit of Microsoft Visual C++ 14.0, but it lacks MSBuild.exe.
# (2) "MSVC v142" contains MSBuild.exe.
# (3) The latest version of Windows 10 SDK which Microsoft Visual C++ 14.0 can handle is 10.0.14393.0.
#     You can download it from Windows SDK archive(https://developer.microsoft.com/windows/downloads/sdk-archive/),
#     but it lacks rc.exe.
# (4) The latest Windows 10 SDK(10.0.18362.0) contains rc.exe.
#
# Please be sure to check "MSVC v142", "Windows 10 SDK", "CMake", "MSVC v140" when you install "Visual Studio Build Tools".
# 
export PATH=/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/BuildTools/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/BuildTools/MSBuild/Current/Bin/amd64/:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio\ 14.0/VC/bin/amd64:/c/Program\ Files\ \(x86\)/Windows\ Kits/10/bin/10.0.14393.0/x64/:/c/Program\ Files\ \(x86\)/Windows\ Kits/10/bin/10.0.18362.0/x64/:$PATH
pip install pysptk
git clone https://github.com/r9y9/nnmnkwii
cd nnmnkwii && pip install . && cd $WORKING_DIR
git clone https://github.com/r9y9/nnsvs 
cd nnsvs && pip install . && cd $WORKING_DIR

## hts_engine_API
git clone https://github.com/r9y9/hts_engine_API
cd hts_engine_API/src && ./waf configure --prefix=/opt/hts_engine_API && ./waf build  && ./waf install && cd $WORKING_DIR
# Copy hts_engine_API-1.dll to the directory set in Windows PATH environment variable.
cp /opt/hts_engine_API/lib/hts_engine_API-1.dll /opt/python/

## sinsy
# 
git clone  -q https://github.com/r9y9/sinsy
cd sinsy/src/ && mkdir -p build && cd build 
cmake -G "Visual Studio 14 2015 Win64" -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=/opt/sinsy -DHTS_ENGINE_INCLUDE_DIR=/opt/hts_engine_API/include/ -DHTS_ENGINE_LIB=/opt/hts_engine_API/lib/hts_engine_API.lib ..
cmake --build . --config Release 
cmake -DCMAKE_INSTALL_CONFIG_NAME=Release -P cmake_install.cmake
cd $WORKING_DIR

## Pysinsy
git clone -b vc_2015 https://github.com/taroushirani/pysinsy.git
cd pysinsy
SINSY_INSTALL_PREFIX=/opt/sinsy/ HTS_ENGINE_API_INSTALL_PREFIX=/opt/hts_engine_API/ pip install .
cd $WORKING_DIR

