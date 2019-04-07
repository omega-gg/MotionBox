#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

external="../3rdparty"

#--------------------------------------------------------------------------------------------------

MinGW_version="7.3.0"

VLC_version="3.0.6"

#--------------------------------------------------------------------------------------------------

bin4="bin"
bin5="latest"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 ] || [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] || [ $2 != "win32" -a \
                                                                       $2 != "win64" -a \
                                                                       $2 != "macOS" -a \
                                                                       $2 != "linux" ]; then

    echo "Usage: configure <qt4 | qt5 | clean> <win32 | win64 | macOS | linux>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $2 = "win32" -o $2 = "win64" ]; then

    windows=true

    external="$external/$2"

    MinGW="$external/MinGW/$MinGW_version/bin"
else
    windows=false
fi

SSL="$external/OpenSSL"

VLC="$external/VLC/$VLC_version"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ $1 = "clean" ]; then

    echo "CLEANING"

    rm -rf lib
    mkdir  lib
    touch  lib/.gitignore

    rm -rf "$bin4"
    mkdir  "$bin4"
    touch  "$bin4"/.gitignore

    rm -rf "$bin5"
    mkdir  "$bin5"
    touch  "$bin5"/.gitignore

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

if [ $1 = "qt4" ]; then

    echo "COPYING Qt4"

    bin="$bin4"
else
    echo "COPYING Qt5"

    bin="$bin5"
fi

if [ $windows = true ]; then

    cp "$MinGW"/libgcc_s_*-1.dll    "$bin"
    cp "$MinGW"/libstdc++-6.dll     "$bin"
    cp "$MinGW"/libwinpthread-1.dll "$bin"
fi

#--------------------------------------------------------------------------------------------------
# SSL
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    echo "COPYING SSL"

    cp "$SSL"/libeay32.dll "$bin"
    cp "$SSL"/ssleay32.dll "$bin"
fi

#--------------------------------------------------------------------------------------------------
# VLC
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    echo "COPYING VLC"

    rm -rf "$bin"/plugins
    mkdir  "$bin"/plugins

    cp -r "$VLC"/plugins/access        "$bin"/plugins
    cp -r "$VLC"/plugins/audio_filter  "$bin"/plugins
    cp -r "$VLC"/plugins/audio_mixer   "$bin"/plugins
    cp -r "$VLC"/plugins/audio_output  "$bin"/plugins
    cp -r "$VLC"/plugins/codec         "$bin"/plugins
    cp -r "$VLC"/plugins/control       "$bin"/plugins
    cp -r "$VLC"/plugins/demux         "$bin"/plugins
    cp -r "$VLC"/plugins/misc          "$bin"/plugins
    cp -r "$VLC"/plugins/packetizer    "$bin"/plugins
    cp -r "$VLC"/plugins/stream_filter "$bin"/plugins
    cp -r "$VLC"/plugins/stream_out    "$bin"/plugins
    cp -r "$VLC"/plugins/video_chroma  "$bin"/plugins
    cp -r "$VLC"/plugins/video_filter  "$bin"/plugins
    cp -r "$VLC"/plugins/video_output  "$bin"/plugins

    cp "$VLC"/libvlc*.dll "$bin"
fi
