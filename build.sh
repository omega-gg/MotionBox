#!/bin/sh

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

MotionBox="../.."

external="/c/dev/workspace/3rdparty"

#--------------------------------------------------------------------------------------------------

Qt4_version="4.8.7"
Qt5_version="5.5.1"

MinGW_version="4.9.2"

#--------------------------------------------------------------------------------------------------

Qt4="$external/Qt/$Qt4_version/bin"
Qt5="$external/Qt/$Qt5_version/bin"

MinGW="$external/MinGW/$MinGW_version/bin"

#--------------------------------------------------------------------------------------------------
# Linux

lib64="/lib/x86_64-linux-gnu"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ] \
   || \
   [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] || [ $2 != "win32" -a $2 != "linux" ] \
   || \
   [ $# = 3 -a "$3" != "deploy" ]; then

    echo "Usage: build <qt4 | qt5 | clean> <win32 | linux> [deploy]"

    exit 1
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
# Building MotionBox
#--------------------------------------------------------------------------------------------------

echo "BUILDING MotionBox"
echo "------------------"

if [ $1 = "qt4" ]; then

    QT_SELECT=qt4

    build="build/qt4"
else
    QT_SELECT=qt5

    build="build/qt5"
fi

if [ $2 = "win32" ]; then

    spec=win32-g++

    if [ $1 = "qt4" ]; then

        PATH="$Qt4:$MinGW:$PATH"
    else
        PATH="$Qt5:$MinGW:$PATH"
    fi

elif [ $2 = "linux" ]; then

    if [ $(uname -m) = "x86_64" ]; then

        spec=linux-g++-64
    else
        spec=linux-g++-32
    fi
fi

qmake --version
echo ""

if [ "$3" = "deploy" ]; then

    cd dist

    sh qrc.sh deploy
    echo ""

    cd ../$build

    qmake -r -spec $spec "CONFIG += release" \
                         "DEFINES += SK_DEPLOY" "RESOURCES = dist/MotionBox.qrc" $MotionBox
else
    cd $build

    qmake -r -spec $spec "CONFIG += release" $MotionBox
fi

if [ $2 = "win32" ]; then

    mingw32-make
else
    make
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
