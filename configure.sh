#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

external="../3rdparty"

#--------------------------------------------------------------------------------------------------

Qt4_version="4.8.7"
Qt5_version="5.12.2"

MinGW_version="7.3.0"

VLC_version="3.0.6"

libtorrent_version="1.1.12"

Boost_version="1.69.0"

#--------------------------------------------------------------------------------------------------

bin4="bin"
bin5="latest"

#--------------------------------------------------------------------------------------------------
# Linux

include32="/usr/include/i386-linux-gnu"
include64="/usr/include/x86_64-linux-gnu"

Qt5_version_linux="5.9.5"

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

    MinGW="$external/MinGW/$MinGW_version"

elif [ $2 = "linux" ]; then

    windows=false

    if [ $1 = "qt5" ]; then

        Qt5_version="$Qt5_version_linux"
    fi

    if [ -d "${include64}" ]; then

        include="$include64"
    else
        include="$include32"
    fi
else
    windows=false
fi

#--------------------------------------------------------------------------------------------------

Qt4="$external/Qt/$Qt4_version"
Qt5="$external/Qt/$Qt5_version"

SSL="$external/OpenSSL"

zlib="$external/zlib"

VLC="$external/VLC/$VLC_version"

libtorrent="$external/libtorrent/$libtorrent_version"

Boost="$external/Boost/$Boost_version"

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

    #----------------------------------------------------------------------------------------------
    # Qt

    rm -rf include/Qt4
    rm -rf include/Qt5

    #----------------------------------------------------------------------------------------------
    # VLC

    rm -rf include/vlc

    #----------------------------------------------------------------------------------------------
    # libtorrent

    rm -rf include/libtorrent

    #----------------------------------------------------------------------------------------------
    # Boost

    rm -rf include/Boost

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

if [ $1 = "qt4" ]; then

    echo "COPYING Qt4"

    bin="$bin4"

    if [ $2 = "linux" ]; then

        mkdir -p include/Qt4/QtCore/private
        mkdir -p include/Qt4/QtGui/private
        mkdir -p include/Qt4/QtDeclarative/private

        cp "$Qt4"/src/corelib/kernel/*_p.h include/Qt4/QtCore/private

        cp "$Qt4"/src/gui/kernel/*_p.h include/Qt4/QtGui/private

        cp "$Qt4"/src/declarative/qml/*_p.h           include/Qt4/QtDeclarative/private
        cp "$Qt4"/src/declarative/graphicsitems/*_p.h include/Qt4/QtDeclarative/private
        cp "$Qt4"/src/declarative/util/*_p.h          include/Qt4/QtDeclarative/private
    fi
else
    echo "COPYING Qt5"

    bin="$bin5"

    mkdir -p include/Qt5/QtCore/private
    mkdir -p include/Qt5/QtGui/private
    mkdir -p include/Qt5/QtQml/private
    mkdir -p include/Qt5/QtQuick/private

    if [ $windows = true ]; then

        cp -r "$Qt5"/include/QtCore  include/Qt5
        cp -r "$Qt5"/include/QtGui   include/Qt5
        cp -r "$Qt5"/include/QtQml   include/Qt5
        cp -r "$Qt5"/include/QtQuick include/Qt5

        cp -r "$Qt5"/include/QtGui/$Qt5_version/QtGui/qpa include/Qt5/QtGui

        mv include/Qt5/QtCore/$Qt5_version/QtCore/private/*   include/Qt5/QtCore/private
        mv include/Qt5/QtGui/$Qt5_version/QtGui/private/*     include/Qt5/QtGui/private
        mv include/Qt5/QtQml/$Qt5_version/QtQml/private/*     include/Qt5/QtQml/private
        mv include/Qt5/QtQuick/$Qt5_version/QtQuick/private/* include/Qt5/QtQuick/private

    elif [ $2 = "linux" ]; then

        cp -r "$include"/qt5/QtCore  include/Qt5
        cp -r "$include"/qt5/QtGui   include/Qt5
        cp -r "$include"/qt5/QtQml   include/Qt5
        cp -r "$include"/qt5/QtQuick include/Qt5

        cp -r "$include"/qt5/QtGui/$Qt5_version/QtGui/qpa include/Qt5/QtGui

        mv include/Qt5/QtCore/$Qt5_version/QtCore/private/*   include/Qt5/QtCore/private
        mv include/Qt5/QtGui/$Qt5_version/QtGui/private/*     include/Qt5/QtGui/private
        mv include/Qt5/QtQml/$Qt5_version/QtQml/private/*     include/Qt5/QtQml/private
        mv include/Qt5/QtQuick/$Qt5_version/QtQuick/private/* include/Qt5/QtQuick/private

    elif [ $2 = "macOS" ]; then

        Qt5=/usr/local/opt/qt\@5.5
    fi
fi

if [ $windows = true ]; then

    cp "$MinGW"/bin/libgcc_s_*-1.dll    "$bin"
    cp "$MinGW"/bin/libstdc++-6.dll     "$bin"
    cp "$MinGW"/bin/libwinpthread-1.dll "$bin"
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
# zlib
#--------------------------------------------------------------------------------------------------

if [ $2 = "win32" ]; then

    cp "$MinGW"/i686-w64-mingw32/lib/libz.a lib

elif [ $2 = "win64" ]; then

    cp "$MinGW"/x86_64-w64-mingw32/lib/libz.a lib
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

    if [ $windows = true ]; then

        cp -r "$VLC"/sdk/include/vlc include

        cp "$VLC"/sdk/lib/libvlc* lib

    elif [ $2 = "macOS" ]; then

        cp -r /Applications/VLC.app/Contents/MacOS/include include

        cp -r /Applications/VLC.app/Contents/MacOS/lib lib
    fi
fi

#--------------------------------------------------------------------------------------------------
# libtorrent
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    echo "COPYING libtorrent"

    cp -r "$libtorrent"/libtorrent include

    cp "$libtorrent"/libtorrent.* lib

elif [ $2 = "macOS" ]; then

    echo "COPYING libtorrent"

    cp -r /usr/local/include/libtorrent include

    cp /usr/local/lib/libtorrent-* lib
fi

#--------------------------------------------------------------------------------------------------
# Boost
#--------------------------------------------------------------------------------------------------

if [ $windows = true ]; then

    echo "COPYING Boost"

    cp -r "$Boost"/Boost include

    cp "$Boost"/libboost*.* lib

elif [ $2 = "macOS" ]; then

    echo "COPYING Boost"

    cp -r /usr/local/opt/boost\@1.55/include include

    cp -r /usr/local/opt/boost\@1.55/lib lib
fi
