#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../Sky"

external="../3rdparty"

#--------------------------------------------------------------------------------------------------
# environment

compiler_win="mingw"

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "linux" -a $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "clean" ]; then

    echo "Usage: configure <win32 | win64 | macOS | linux | android> [clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

external="$external/$1"

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

    compiler="$compiler_win"
else
    os="default"

    compiler="default"
fi

path="$Sky/deploy"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

# NOTE: We want to keep the 'storage' folder.
if [ -d "bin/storage" ]; then

    mv bin/storage .

    rm -rf bin/*
    touch  bin/.gitignore

    mv storage bin
else
    rm -rf bin/*
    touch  bin/.gitignore
fi

# NOTE: We have to remove the folder to delete .qmake.stash.
rm -rf build
mkdir  build
touch  build/.gitignore

if [ "$2" = "clean" ]; then

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# MinGW
#--------------------------------------------------------------------------------------------------

echo "CONFIGURING MotionBox"
echo "---------------------"

if [ $compiler = "mingw" ]; then

    echo "COPYING MinGW"

    cp "$path"/libgcc_s_*-1.dll    bin
    cp "$path"/libstdc++-6.dll     bin
    cp "$path"/libwinpthread-1.dll bin
fi

#--------------------------------------------------------------------------------------------------
# SSL
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    echo "COPYING SSL"

    if [ $qt = "qt4" ]; then

        cp "$path"/libeay32.dll bin
        cp "$path"/ssleay32.dll bin
    else
        cp "$path"/libssl*.dll    bin
        cp "$path"/libcrypto*.dll bin
    fi
fi

#--------------------------------------------------------------------------------------------------
# VLC
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    echo "COPYING VLC"

    rm -rf bin/plugins
    mkdir  bin/plugins

    cp -r "$path"/plugins bin

    cp "$path"/libvlc*.dll bin

elif [ $1 = "macOS" ]; then

    echo "COPYING VLC"

    rm -rf bin/plugins
    mkdir  bin/plugins

    cp -r "$path"/plugins bin

    cp "$path"/libvlc*.dylib bin

elif [ $1 = "linux" ]; then

    echo "COPYING VLC"

    rm -rf bin/vlc
    mkdir  bin/vlc

    cp -r "$path"/vlc bin

    cp "$path"/libvlc*.so* bin

    if [ -f "$path"/libidn.so* ]; then

        cp "$path"/libidn.so* bin
    fi
fi

#--------------------------------------------------------------------------------------------------
# libtorrent
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    echo "COPYING libtorrent"

    cp "$path"/*torrent-rasterbar.dll bin

elif [ $1 = "macOS" ]; then

    echo "COPYING libtorrent"

    cp "$path"/libtorrent-rasterbar.dylib bin

elif [ $1 = "linux" ]; then

    echo "COPYING libtorrent"

    cp "$path"/libtorrent-rasterbar*.so* bin
fi

#--------------------------------------------------------------------------------------------------
# Boost
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    echo "COPYING Boost"

    cp "$path"/libboost*.dylib bin

elif [ $1 = "linux" ]; then

    echo "COPYING Boost"

    cp "$path"/libboost*.so* bin
fi

echo "---------------------"
