#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

target="MotionBox"

Sky="../Sky"

backend="../backend"

#--------------------------------------------------------------------------------------------------
# environment

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "linux" -a $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "clean" ]; then

    echo "Usage: deploy <win32 | win64 | macOS | linux | android> [clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"
else
    os="default"
fi

if [ $qt = "qt5" ]; then

    qx="5"

elif [ $qt = "qt6" ]; then

    if [ $1 = "macOS" ]; then

        qx="A"
    else
        qx="6"
    fi
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -rf deploy/*

touch deploy/.gitignore

if [ "$2" = "clean" ]; then

    exit 0
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Bundle
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    cp -r bin/$target.app deploy

    deploy="deploy/$target.app/Contents/MacOS"

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

sh deploy.sh $1 tools

cd -

path="$Sky/deploy"

cp -r "$path"/imageformats $deploy

if [ $qt = "qt5" ]; then

    QtQuick="QtQuick.2"

elif [ $qt = "qt6" ]; then

    QtQuick="QtQuick"
fi

if [ $qt != "qt4" ]; then

    cp -r "$path"/platforms $deploy
    cp -r "$path"/$QtQuick  $deploy

    if [ $qt = "qt6" ]; then

        cp -r "$path"/QtQml $deploy
    fi

    if [ $1 = "linux" ]; then

        cp -r "$path"/xcbglintegrations $deploy
    fi
fi

if [ $os = "windows" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/*.dll $deploy

    rm -f $deploy/Sk*.dll

elif [ $1 = "macOS" ]; then

    # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
    cp "$path"/qt.conf $deploy/../Resources

    cp -r "$path"/plugins $deploy

    cp "$path"/*.dylib $deploy

    rm -f $deploy/Sk*.dylib

elif [ $1 = "linux" -o $1 = "android" ]; then

    # FIXME Linux: We can't seem to be able to enforce our VLC libraries on ArchLinux.
    #cp -r "$path"/vlc $deploy

    cp "$path"/*.so* $deploy

    rm -f $deploy/Sk*.so*
fi

echo "-------------"
echo ""

#--------------------------------------------------------------------------------------------------
# MotionBox
#--------------------------------------------------------------------------------------------------

echo "COPYING $target"

if [ $os = "windows" ]; then

    cp bin/$target.exe deploy

elif [ $1 = "macOS" ]; then

    cd $deploy

    #----------------------------------------------------------------------------------------------
    # target

    install_name_tool -change @rpath/QtCore.framework/Versions/$qx/QtCore \
                              @loader_path/QtCore.dylib $target

    install_name_tool -change @rpath/QtGui.framework/Versions/$qx/QtGui \
                              @loader_path/QtGui.dylib $target

    install_name_tool -change @rpath/QtNetwork.framework/Versions/$qx/QtNetwork \
                              @loader_path/QtNetwork.dylib $target

    install_name_tool -change @rpath/QtOpenGL.framework/Versions/$qx/QtOpenGL \
                              @loader_path/QtOpenGL.dylib $target

    install_name_tool -change @rpath/QtQml.framework/Versions/$qx/QtQml \
                              @loader_path/QtQml.dylib $target

    if [ -f QtQmlModels.dylib ]; then

        install_name_tool -change @rpath/QtQmlModels.framework/Versions/$qx/QtQmlModels \
                                  @loader_path/QtQmlModels.dylib $target
    fi

    install_name_tool -change @rpath/QtQuick.framework/Versions/$qx/QtQuick \
                              @loader_path/QtQuick.dylib $target

    install_name_tool -change @rpath/QtSvg.framework/Versions/$qx/QtSvg \
                              @loader_path/QtSvg.dylib $target

    install_name_tool -change @rpath/QtWidgets.framework/Versions/$qx/QtWidgets \
                              @loader_path/QtWidgets.dylib $target

    install_name_tool -change @rpath/QtXml.framework/Versions/$qx/QtXml \
                              @loader_path/QtXml.dylib $target

    if [ $qt = "qt5" ]; then

        install_name_tool -change @rpath/QtXmlPatterns.framework/Versions/$qx/QtXmlPatterns \
                                  @loader_path/QtXmlPatterns.dylib $target
    else
        install_name_tool -change @rpath/QtCore5Compat.framework/Versions/$qx/QtCore5Compat \
                                  @loader_path/QtCore5Compat.dylib $target
    fi

    otool -L $target

    #----------------------------------------------------------------------------------------------
    # QtGui

    if [ $qt = "qt6" ]; then

        install_name_tool -change @rpath/QtDBus.framework/Versions/$qx/QtDBus \
                                  @loader_path/QtDBus.dylib QtGui.dylib
    fi

    otool -L QtGui.dylib

    #----------------------------------------------------------------------------------------------
    # platforms

    if [ $qt = "qt5" ]; then

        install_name_tool -change @rpath/QtDBus.framework/Versions/$qx/QtDBus \
                                  @loader_path/../QtDBus.dylib platforms/libqcocoa.dylib

        install_name_tool -change @rpath/QtPrintSupport.framework/Versions/$qx/QtPrintSupport \
                                  @loader_path/../QtPrintSupport.dylib platforms/libqcocoa.dylib
    fi

    otool -L platforms/libqcocoa.dylib

    #----------------------------------------------------------------------------------------------
    # QtQuick

    if [ -f QtQmlModels.dylib ]; then

        install_name_tool -change \
                          @rpath/QtQmlWorkerScript.framework/Versions/$qx/QtQmlWorkerScript \
                          @loader_path/../QtQmlWorkerScript.dylib \
                          $QtQuick/libqtquick2plugin.dylib
    fi

    otool -L $QtQuick/libqtquick2plugin.dylib

    #----------------------------------------------------------------------------------------------
    # VLC

    install_name_tool -change @rpath/libvlccore.dylib \
                              @loader_path/libvlccore.dylib libvlc.dylib

    otool -L libvlc.dylib

    #----------------------------------------------------------------------------------------------
    # libtorrent

    install_name_tool -change libboost_system.dylib \
                              @loader_path/libboost_system.dylib libtorrent-rasterbar.dylib

    otool -L libtorrent-rasterbar.dylib

    #----------------------------------------------------------------------------------------------

    cd -

elif [ $1 = "linux" ]; then

    cp bin/$target $deploy

    # NOTE: This script is useful for compatibilty. It enforces the application path for libraries.
    cp dist/script/start.sh $deploy

    chmod 755 $deploy/start.sh

elif [ $1 = "android" ]; then

    cp bin/lib$target* $deploy
fi

#--------------------------------------------------------------------------------------------------
# backend
#--------------------------------------------------------------------------------------------------

echo "COPYING backend"

mkdir -p $deploy/backend/cover

cp "$backend"/cover/* $deploy/backend/cover

cp "$backend"/*.vbml $deploy/backend
