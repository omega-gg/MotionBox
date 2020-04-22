#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../Sky"

backend="../backend"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 ] || [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] || [ $2 != "win32" -a \
                                                                       $2 != "win64" -a \
                                                                       $2 != "macOS" -a \
                                                                       $2 != "linux" -a \
                                                                       $2 != "android" ]; then

    echo "Usage: deploy <qt4 | qt5 | clean> <win32 | win64 | macOS | linux | android>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $2 = "win32" -o $2 = "win64" ]; then

    os="windows"
else
    os="default"
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
# Bundle
#--------------------------------------------------------------------------------------------------

if [ $2 = "macOS" ]; then

    cp -r bin/MotionBox.app deploy

    deploy="deploy/MotionBox.app/Contents/MacOS"

    rm -rf $deploy/plugins

    rm $deploy/*.dylib
else
    deploy="deploy"
fi

#--------------------------------------------------------------------------------------------------
# Sky
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING Sky"
echo "-------------"

cd "$Sky"

sh deploy.sh $1 $2 tools

cd -

path="$Sky/deploy"

cp -r "$path"/imageformats $deploy

if [ $1 = "qt5" ]; then

    cp -r "$path"/platforms $deploy
    cp -r "$path"/QtQuick.2 $deploy

    if [ $2 = "linux" ]; then

        cp -r "$path"/xcbglintegrations $deploy
    fi
fi

if [ $os = "windows" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/*.dll $deploy

    rm -f $deploy/Sk*.dll

elif [ $2 = "macOS" ]; then

    # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
    cp "$path"/qt.conf $deploy/../Resources

    cp -r "$path"/plugins $deploy

    cp "$path"/*.dylib $deploy

    rm -f $deploy/Sk*.dylib

elif [ $2 = "linux" ]; then

    cp -r "$path"/vlc $deploy

    cp "$path"/*.so* $deploy

    rm -f $deploy/Sk*.so*
fi

echo "-------------"
echo ""

#--------------------------------------------------------------------------------------------------
# MotionBox
#--------------------------------------------------------------------------------------------------

echo "COPYING MotionBox"

if [ $os = "windows" ]; then

    cp bin/MotionBox.exe deploy

elif [ $2 = "macOS" ]; then

    cd $deploy

    mv QtQuick.2 ../Resources

    #----------------------------------------------------------------------------------------------
    # Qt

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/QtCore.dylib MotionBox

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/QtGui.dylib MotionBox

    install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork \
                              @loader_path/QtNetwork.dylib MotionBox

    install_name_tool -change @rpath/QtOpenGL.framework/Versions/5/QtOpenGL \
                              @loader_path/QtOpenGL.dylib MotionBox

    install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml \
                              @loader_path/QtQml.dylib MotionBox

    if [ -f QtQmlModels.dylib ]; then

        install_name_tool -change @rpath/QtQmlModels.framework/Versions/5/QtQmlModels \
                                  @loader_path/QtQmlModels.dylib MotionBox
    fi

    install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick \
                              @loader_path/QtQuick.dylib MotionBox

    install_name_tool -change @rpath/QtSvg.framework/Versions/5/QtSvg \
                              @loader_path/QtSvg.dylib MotionBox

    install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets \
                              @loader_path/QtWidgets.dylib MotionBox

    install_name_tool -change @rpath/QtXml.framework/Versions/5/QtXml \
                              @loader_path/QtXml.dylib MotionBox

    install_name_tool -change @rpath/QtXmlPatterns.framework/Versions/5/QtXmlPatterns \
                              @loader_path/QtXmlPatterns.dylib MotionBox

    #----------------------------------------------------------------------------------------------
    # platforms

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/../QtCore.dylib platforms/libqcocoa.dylib

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/../QtGui.dylib platforms/libqcocoa.dylib

    install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets \
                              @loader_path/../QtWidgets.dylib platforms/libqcocoa.dylib

    install_name_tool -change @rpath/QtDBus.framework/Versions/5/QtDBus \
                              @loader_path/../QtDBus.dylib platforms/libqcocoa.dylib

    install_name_tool -change @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport \
                              @loader_path/../QtPrintSupport.dylib platforms/libqcocoa.dylib

    #----------------------------------------------------------------------------------------------
    # imageformats

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/../QtCore.dylib imageformats/libqjpeg.dylib

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/../QtGui.dylib imageformats/libqjpeg.dylib

    #----------------------------------------------------------------------------------------------

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/../QtCore.dylib imageformats/libqsvg.dylib

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/../QtGui.dylib imageformats/libqsvg.dylib

    install_name_tool -change @rpath/QtWidgets.framework/Versions/5/QtWidgets \
                              @loader_path/../QtWidgets.dylib imageformats/libqsvg.dylib

    install_name_tool -change @rpath/QtSvg.framework/Versions/5/QtSvg \
                              @loader_path/../QtSvg.dylib imageformats/libqsvg.dylib

    #----------------------------------------------------------------------------------------------
    # QtQuick.2

    # NOTE: codesign does not like the '.' in the "QtQuick.2" folder name.

    install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui \
                              @loader_path/../MacOS/QtGui.dylib \
                              ../Resources/QtQuick.2/libqtquick2plugin.dylib

    install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml \
                              @loader_path/../MacOS/QtQml.dylib \
                              ../Resources/QtQuick.2/libqtquick2plugin.dylib

    install_name_tool -change @rpath/QtQuick.framework/Versions/5/QtQuick \
                              @loader_path/../MacOS/QtQuick.dylib \
                              ../Resources/QtQuick.2/libqtquick2plugin.dylib

    if [ -f QtQmlModels.dylib ]; then

        install_name_tool -change @rpath/QtQmlModels.framework/Versions/5/QtQmlModels \
                                  @loader_path/../MacOS/QtQmlModels.dylib \
                                  ../Resources/QtQuick.2/libqtquick2plugin.dylib

        install_name_tool -change @rpath/QtQmlWorkerScript.framework/Versions/5/QtQmlWorkerScript \
                                  @loader_path/../MacOS/QtQmlWorkerScript.dylib \
                                  ../Resources/QtQuick.2/libqtquick2plugin.dylib
    fi

    #----------------------------------------------------------------------------------------------
    # VLC

    install_name_tool -change @rpath/libvlccore.dylib \
                              @loader_path/libvlccore.dylib libvlc.dylib

    #----------------------------------------------------------------------------------------------
    # libtorrent

    install_name_tool -change libboost_system.dylib \
                              @loader_path/libboost_system.dylib libtorrent.dylib

    cd -

elif [ $2 = "linux" ]; then

    cp bin/MotionBox $deploy

    cp dist/script/start.sh $deploy

    chmod 755 $deploy/start.sh

elif [ $2 = "android" ]; then

    cp bin/libMotionBox* $deploy
fi

#--------------------------------------------------------------------------------------------------
# backend
#--------------------------------------------------------------------------------------------------

echo "COPYING backend"

mkdir -p $deploy/backend/cover

cp "$backend"/cover/* $deploy/backend/cover

cp "$backend"/*.vbml $deploy/backend
