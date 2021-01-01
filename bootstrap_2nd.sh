#! /bin/bash
set -eux

ROOT_DIR=$(pwd)
WORKING_DIR=/tmp

export PATH=/opt/python:/opt/python/Scripts:$PATH

cd $WORKING_DIR

### Pacman settings.
# Initialize pacman
pacman-key --init

# Update pacman repository
pacman -Syuu --noconfirm

### Toolchains settings
## Install git, winpty
pacman -Su --noconfirm git winpty tar

### Python settings
## Upgrade pip
python -m pip install -U pip

## Upgrade numpy, cython
pip install -U numpy cython

## Install pytorch
# for CUDA 11.0
#pip install torch===1.7.0+cu110 torchvision===0.8.1+cu110 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html
# for CUDA 10.2
pip install torch===1.7.0 torchvision===0.8.1 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html
# for CUDA 10.1
#pip install torch==1.7.0+cu101 torchvision==0.8.1+cu101 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html
# for CUDA 9.2
# Follow instructions at this URL: https://github.com/pytorch/pytorch#from-source
# for no CUDA
#pip install torch==1.7.0+cpu torchvision==0.8.1+cpu torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html

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
export PATH=/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/BuildTools/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/BuildTools/MSBuild/Current/Bin/amd64/:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/Community/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2019/Community/MSBuild/Current/Bin/amd64/:/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio\ 14.0/VC/bin/amd64:/c/Program\ Files\ \(x86\)/Windows\ Kits/10/bin/10.0.14393.0/x64/:/c/Program\ Files\ \(x86\)/Windows\ Kits/10/bin/10.0.18362.0/x64/:$PATH
pip install pysptk

# bandmat can't be installed via pip with python3.7 or later(https://github.com/MattShannon/bandmat/issues/10)
git clone https://github.com/MattShannon/bandmat.git
cd bandmat && pip install . && cd $WORKING_DIR

# Clone locally modified version of fastdtw to install compiled version of fastdtw. 
git clone -b vs_2015 https://github.com/taroushirani/fastdtw.git
cd fastdtw && pip install . && cd $WORKING_DIR

git clone https://github.com/r9y9/nnmnkwii
cd nnmnkwii && pip install . && cd $WORKING_DIR

git clone https://github.com/r9y9/nnsvs
cd nnsvs && pip install . && cd $WORKING_DIR

## hts_engine_API
git clone https://github.com/r9y9/hts_engine_API
cd hts_engine_API/src && mkdir -p build && cd build && cmake  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/opt/hts_engine_API .. && make -j > hts_engine_API_build.log 2>&1 &&  make install && cd $WORKING_DIR

# Copy hts_engine_API-1.dll to the directory set in Windows PATH environment variable.
cp /opt/hts_engine_API/lib/hts_engine_API-1.dll /opt/python/

## sinsy
# (1) Visual Studio does not create a import library when no function is declared with __declspec(dllexport), so we can't use sinsy.dll to build pysinsy.  We have to use static link on building.
# (2) (Maybe) because of it, we have to link hts_engine_API explicitly when we build pysinsy.
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

### cleanup
rm -rf $WORKING_DIR/bandmat $WORKING_DIR/nnmnkwii $WORKING_DIR/pysinsy $WORKING_DIR/hts_engine_API $WORKING_DIR/nnsvs $WORKING_DIR/sinsy
