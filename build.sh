#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

MotionBox="../.."

external="$PWD/../3rdparty"

#--------------------------------------------------------------------------------------------------

Qt4_version="4.8.7"
Qt5_version="5.14.1"

MinGW_version="7.3.0"

#--------------------------------------------------------------------------------------------------

make_arguments="-j 4"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ] \
   || \
   [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] \
   || \
   [ $2 != "win32" -a $2 != "win64" -a $2 != "macOS" -a $2 != "linux" ] \
   || \
   [ $# = 3 -a "$3" != "deploy" ]; then

    echo "Usage: build <qt4 | qt5 | clean> <win32 | win64 | macOS | linux> [deploy]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

external="$external/$2"

if [ $2 = "win32" -o $2 = "win64" ]; then

    os="windows"

    MinGW="$external/MinGW/$MinGW_version/bin"
else
    os="default"
fi

if [ $1 = "qt4" ]; then

    Qt="$external/Qt/$Qt4_version"
else
    Qt="$external/Qt/$Qt5_version"
fi

if [ $os = "windows" -o $2 = "macOS" ]; then

    qmake="$Qt/bin/qmake"
else
    qmake="qmake"
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ $1 = "clean" ]; then

    echo "CLEANING"

    rm -rf build/qt4/*
    rm -rf build/qt5/*

    touch build/qt4/.gitignore
    touch build/qt5/.gitignore

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Build MotionBox
#--------------------------------------------------------------------------------------------------

echo "BUILDING MotionBox"
echo "------------------"

if [ $1 = "qt4" ]; then

    export QT_SELECT=qt4

    build="build/qt4"

    config="CONFIG += release"
else
    export QT_SELECT=qt5

    build="build/qt5"

    config="CONFIG += release qtquickcompiler"
fi

if [ $os = "windows" ]; then

    spec=win32-g++

    PATH="$Qt/bin:$MinGW:$PATH"

elif [ $2 = "macOS" ]; then

    spec=macx-clang

    export PATH=$Qt/bin:$PATH

elif [ $2 = "linux" ]; then

    if [ -d "/usr/lib/x86_64-linux-gnu" ]; then

        spec=linux-g++-64
    else
        spec=linux-g++-32
    fi
fi

$qmake --version
echo ""

cd dist

if [ "$3" = "deploy" ]; then

    sh qrc.sh $QT_SELECT $2 deploy
else
    sh qrc.sh $QT_SELECT $2
fi

echo ""

cd ../$build

if [ "$3" = "deploy" ]; then

    $qmake -r -spec $spec "$config" "DEFINES += SK_DEPLOY" $MotionBox
else
    $qmake -r -spec $spec "$config" $MotionBox
fi

if [ $os = "windows" ]; then

    mingw32-make $make_arguments
else
    make $make_arguments
fi

echo "------------------"

#--------------------------------------------------------------------------------------------------
# Deploying MotionBox
#--------------------------------------------------------------------------------------------------

if [ "$3" = "deploy" ]; then

    echo ""
    echo "DEPLOYING MotionBox"
    echo "-------------------"

    cd $MotionBox

    sh deploy.sh $1 $2

    echo "-------------------"
fi
