#!/bin/sh

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

external="../3rdparty"

VLC_version="2.2.4"

VLC="$external/VLC/$VLC_version"

#--------------------------------------------------------------------------------------------------

bin4="bin"
bin5="latest"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 ] || [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] || [ $2 != "win32" -a \
                                                                       $2 != "linux" ]; then

    echo "Usage: configure <qt4 | qt5 | clean> <win32 | linux>"

    exit 1
fi

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
# VLC
#--------------------------------------------------------------------------------------------------

echo "COPYING VLC"

if [ $1 = "qt4" ]; then

    bin="$bin4"
else
    bin="$bin5"
fi

rm -rf "$bin"/plugins
mkdir  "$bin"/plugins

cp -r "$VLC"/plugins/access       "$bin"/plugins
cp -r "$VLC"/plugins/audio_filter "$bin"/plugins
cp -r "$VLC"/plugins/audio_mixer  "$bin"/plugins
cp -r "$VLC"/plugins/audio_output "$bin"/plugins
cp -r "$VLC"/plugins/codec        "$bin"/plugins
cp -r "$VLC"/plugins/control      "$bin"/plugins
cp -r "$VLC"/plugins/demux        "$bin"/plugins
cp -r "$VLC"/plugins/misc         "$bin"/plugins
cp -r "$VLC"/plugins/video_chroma "$bin"/plugins
cp -r "$VLC"/plugins/video_filter "$bin"/plugins
cp -r "$VLC"/plugins/video_output "$bin"/plugins

if [ $2 = "win32" ]; then

    cp "$VLC"/libvlc*.dll "$bin"
fi
