#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../Sky"

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

    echo "Usage: deploy <qt4 | qt5 | clean> <win32 | win64 | macOS | linux>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $2 = "win32" -o $2 = "win64" ]; then

    windows=true
else
    windows=false
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -rf deploy/*

touch deploy/.gitignore

if [ $1 = "clean" ]; then

    exit 0
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Sky
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING Sky"
echo "-------------"

cd "$Sky"

sh deploy.sh $1 $2 tools

cd -

deploy="$Sky/deploy"

cp -r "$deploy"/imageformats deploy

if [ $1 = "qt5" ]; then

    cp -r "$deploy"/platforms deploy
    cp -r "$deploy"/QtQuick.2 deploy

    if [ $2 = "linux" ]; then

        cp -r "$deploy"/xcbglintegrations deploy
    fi
fi

if [ $windows = true ]; then

    cp -r "$deploy"/plugins deploy

    cp "$deploy"/*.dll deploy

    rm -f deploy/Sk*.dll

elif [ $2 = "macOS" ]; then

    cp -r "$deploy"/plugins deploy

    cp "$deploy"/*.dylib deploy

    rm -f deploy/Sk*.dylib

    cp "$deploy"/Qt* deploy

elif [ $2 = "linux" ]; then

    #cp -r "$deploy"/vlc deploy

    cp "$deploy"/*.so* deploy

    rm -f deploy/Sk*.so*
fi

echo "------------"
echo ""

#--------------------------------------------------------------------------------------------------
# MotionBox
#--------------------------------------------------------------------------------------------------

echo "COPYING MotionBox"

if [ $1 = "qt4" ]; then

    bin="$bin4"
else
    bin="$bin5"
fi

cp "$bin"/MotionBox* deploy

if [ $2 = "macOS" ]; then

    cd deploy

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/QtCore MotionBox

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/QtGui MotionBox

    install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork \
                              @loader_path/QtNetwork MotionBox

    install_name_tool -change @rpath/QtOpenGL.framework/Versions/5/QtOpenGL \
                              @loader_path/QtOpenGL MotionBox

    install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml \
                              @loader_path/QtQml MotionBox

    install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick \
                              @loader_path/QtQuick MotionBox

    install_name_tool -change @rpath/QtSvg.framework/Versions/5/QtSvg \
                              @loader_path/QtSvg MotionBox

    install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets \
                              @loader_path/QtWidgets MotionBox

    install_name_tool -change @rpath/QtXml.framework/Versions/5/QtXml \
                              @loader_path/QtXml MotionBox

    install_name_tool -change @rpath/QtXmlPatterns.framework/Versions/5/QtXmlPatterns \
                              @loader_path/QtXmlPatterns MotionBox

elif [ $2 = "linux" ]; then

    cp dist/scripts/start.sh deploy
fi
