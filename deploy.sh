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

compiler_win="mingw"

qt="qt6"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

deployMacOS()
{
    installMacOS "$target" ""

    if [ -f "QtWebEngineProcess" ]; then

        installMacOS "QtWebEngineProcess" ""
    fi

    for file in *.dylib; do

        [ -e "$file" ] || continue

        installMacOS "$file" ""
    done

    find platforms \
         imageformats \
         tls \
         multimedia \
         QtQuick \
         QtQml \
         QtMultimedia \
         QtWebView \
         QtWebEngine \
         QtWebChannel \
    -name "*.dylib" | while read -r plugin; do

        case "$plugin" in
            */*/*/*) path="../../" ;;
            *)       path="../"    ;;
        esac

        installMacOS "$plugin" "$path"
    done
}

installMacOS()
{
    list=$(otool -L "$1" | grep -o "Qt[A-Za-z0-9]*\.framework" | sed 's/\.framework//' | sort -u)

    for library in $list; do

        install_name_tool -change "@rpath/$library.framework/Versions/$qx/$library" \
                                  "@loader_path/${2}${library}.dylib" "$1" 2>/dev/null
    done
}

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

    compiler="$compiler_win"
else
    if [ $1 = "iOS" -o $1 = "android" ]; then

        os="mobile"
    else
        os="default"
    fi

    compiler="default"
fi

if [ $qt = "qt5" ]; then

    QtX="Qt5"

    qx="5"

elif [ $qt = "qt6" ]; then

    QtX="Qt6"

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

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

if [ $qt = "qt5" ]; then

    QtQuick="QtQuick.2"

elif [ $qt = "qt6" ]; then

    QtQuick="QtQuick"
fi

if [ $os = "windows" ]; then

    if [ $compiler = "mingw" ]; then

        cp "$path"/libgcc_s_*-1.dll    $deploy
        cp "$path"/libstdc++-6.dll     $deploy
        cp "$path"/libwinpthread-1.dll $deploy
    fi

    if [ $qt = "qt4" ]; then

        mkdir $deploy/imageformats

        cp "$path"/QtCore4.dll        $deploy
        cp "$path"/QtGui4.dll         $deploy
        cp "$path"/QtDeclarative4.dll $deploy
        cp "$path"/QtNetwork4.dll     $deploy
        cp "$path"/QtOpenGL4.dll      $deploy
        cp "$path"/QtScript4.dll      $deploy
        cp "$path"/QtSql4.dll         $deploy
        cp "$path"/QtSvg4.dll         $deploy
        cp "$path"/QtWebKit4.dll      $deploy
        cp "$path"/QtXml4.dll         $deploy
        cp "$path"/QtXmlPatterns4.dll $deploy

        cp "$path"/imageformats/qsvg4.dll  $deploy/imageformats
        cp "$path"/imageformats/qjpeg4.dll $deploy/imageformats
    else
        mkdir $deploy/platforms
        mkdir $deploy/imageformats
        mkdir $deploy/$QtQuick
        mkdir $deploy/QtMultimedia

        if [ $qt = "qt5" ]; then

            mkdir -p $deploy/mediaservice
        else
            mkdir -p $deploy/tls
            mkdir -p $deploy/multimedia

            mkdir -p $deploy/QtQml/WorkerScript
        fi

        if [ $qt = "qt5" ]; then

            cp "$path"/libEGL.dll    deploy
            cp "$path"/libGLESv2.dll deploy
        else
            # FFmpeg
            cp "$path"/sw*.dll deploy
            cp "$path"/av*.dll deploy
        fi

        cp "$path/$QtX"Core.dll            $deploy
        cp "$path/$QtX"Gui.dll             $deploy
        cp "$path/$QtX"Network.dll         $deploy
        cp "$path/$QtX"OpenGL.dll          $deploy
        cp "$path/$QtX"Qml.dll             $deploy
        cp "$path/$QtX"Quick.dll           $deploy
        cp "$path/$QtX"Svg.dll             $deploy
        cp "$path/$QtX"Widgets.dll         $deploy
        cp "$path/$QtX"Xml.dll             $deploy
        cp "$path/$QtX"Multimedia.dll      $deploy
        cp "$path/$QtX"MultimediaQuick.dll $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/$QtX"XmlPatterns.dll $deploy
            cp "$path/$QtX"WinExtras.dll   $deploy
        else
            cp "$path/$QtX"Core5Compat.dll $deploy
            cp "$path/$QtX"QmlMeta.dll     $deploy
        fi

        if [ -f "$path/$QtX"QmlModels.dll ]; then

            cp "$path/$QtX"QmlModels.dll       $deploy
            cp "$path/$QtX"QmlWorkerScript.dll $deploy
        fi

        cp "$path"/platforms/qwindows.dll $deploy/platforms

        cp "$path"/imageformats/qsvg.dll  $deploy/imageformats
        cp "$path"/imageformats/qjpeg.dll $deploy/imageformats
        cp "$path"/imageformats/qwebp.dll $deploy/imageformats

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/dsengine.dll $deploy/mediaservice
        else
            cp "$path"/tls/qopensslbackend.dll  $deploy/tls
            cp "$path"/tls/qschannelbackend.dll $deploy/tls

            cp "$path"/multimedia/ffmpegmediaplugin.dll $deploy/multimedia
        fi

        cp "$path"/$QtQuick/qtquick2plugin.dll $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir             $deploy/$QtQuick

        cp "$path"/QtMultimedia/*multimedia*.dll $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir           $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            cp "$path"/QtQml/WorkerScript/workerscriptplugin.dll $deploy/QtQml/WorkerScript
            cp "$path"/QtQml/WorkerScript/qmldir                 $deploy/QtQml/WorkerScript
        fi
    fi

elif [ $1 = "macOS" ]; then

    if [ $qt != "qt4" ]; then

        mkdir $deploy/platforms
        mkdir $deploy/imageformats
        mkdir $deploy/$QtQuick
        mkdir $deploy/QtMultimedia

        if [ $qt = "qt5" ]; then

            mkdir -p $deploy/mediaservice
        else
            mkdir -p $deploy/tls
            mkdir -p $deploy/multimedia

            mkdir -p $deploy/QtQml/WorkerScript
        fi

        # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
        cp "$path"/qt.conf $deploy

        cp "$path"/QtCore.dylib            $deploy
        cp "$path"/QtGui.dylib             $deploy
        cp "$path"/QtNetwork.dylib         $deploy
        cp "$path"/QtOpenGL.dylib          $deploy
        cp "$path"/QtCore.dylib            $deploy
        cp "$path"/QtQml.dylib             $deploy
        cp "$path"/QtQuick.dylib           $deploy
        cp "$path"/QtSvg.dylib             $deploy
        cp "$path"/QtWidgets.dylib         $deploy
        cp "$path"/QtXml.dylib             $deploy
        cp "$path"/QtMultimedia.dylib      $deploy
        cp "$path"/QtMultimediaQuick.dylib $deploy
        cp "$path"/QtDBus.dylib            $deploy
        cp "$path"/QtPrintSupport.dylib    $deploy

        if [ $qt = "qt5" ]; then

            cp "$path"/QtXmlPatterns.dylib $deploy
        else
            cp "$path"/QtCore5Compat.dylib $deploy
            cp "$path"/QtQmlMeta.dylib     $deploy
        fi

        if [ -f "$path"/QtQmlModels.dylib ]; then

            cp "$path"/QtQmlModels.dylib       $deploy
            cp "$path"/QtQmlWorkerScript.dylib $deploy
        fi

        cp "$path"/platforms/libqcocoa.dylib $deploy/platforms

        cp "$path"/imageformats/libqsvg.dylib  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.dylib $deploy/imageformats
        cp "$path"/imageformats/libqwebp.dylib $deploy/imageformats

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/libqavfcamera.dylib $deploy/mediaservice
        else
            cp "$path"/tls/libqopensslbackend.dylib         $deploy/tls
            cp "$path"/tls/libqsecuretransportbackend.dylib $deploy/tls

            cp "$path"/multimedia/libffmpegmediaplugin.dylib $deploy/multimedia
        fi

        cp "$path"/$QtQuick/libqtquick2plugin.dylib $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir                  $deploy/$QtQuick

        cp "$path"/QtMultimedia/lib*multimedia*.dylib $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir                $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            cp "$path"/QtQml/WorkerScript/libworkerscriptplugin.dylib $deploy/QtQml/WorkerScript
            cp "$path"/QtQml/WorkerScript/qmldir                      $deploy/QtQml/WorkerScript
        fi
    fi

elif [ $1 = "linux" ]; then

    if [ $qt = "qt4" ]; then

        mkdir $deploy/imageformats

        #cp "$path"/libpng16.so.16 $deploy

        cp "$path"/libQtCore.so.4        $deploy
        cp "$path"/libQtGui.so.4         $deploy
        cp "$path"/libQtDeclarative.so.4 $deploy
        cp "$path"/libQtNetwork.so.4     $deploy
        cp "$path"/libQtOpenGL.so.4      $deploy
        cp "$path"/libQtScript.so.4      $deploy
        cp "$path"/libQtSql.so.4         $deploy
        cp "$path"/libQtSvg.so.4         $deploy
        cp "$path"/libQtWebKit.so.4      $deploy
        cp "$path"/libQtXml.so.4         $deploy
        cp "$path"/libQtXmlPatterns.so.4 $deploy

        cp "$path"/imageformats/libqsvg.so  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.so $deploy/imageformats
    else
        mkdir $deploy/platforms
        mkdir $deploy/imageformats
        mkdir $deploy/$QtQuick
        mkdir $deploy/QtMultimedia
        mkdir $deploy/xcbglintegrations

        if [ $qt = "qt5" ]; then

            mkdir -p $deploy/mediaservice
        else
            mkdir -p $deploy/tls
            mkdir -p $deploy/multimedia

            mkdir -p $deploy/QtQml/WorkerScript
        fi

        #cp "$path"/libz.so.* $deploy

        cp "$path"/libicudata.so.* $deploy
        cp "$path"/libicui18n.so.* $deploy
        cp "$path"/libicuuc.so.*   $deploy

        #cp "$path"/libdouble-conversion.so.* $deploy
        #cp "$path"/libpng16.so.*             $deploy
        #cp "$path"/libharfbuzz.so.*          $deploy
        #cp "$path"/libxcb-xinerama.so.*      $deploy

        # NOTE: Required for Ubuntu 20.04.
        #if [ -f "$path"/libpcre2-16.so.0 ]; then

            #cp "$path"/libpcre2-16.so.0 $deploy
        #fi

        cp "$path/lib$QtX"Core.so.$qx            $deploy
        cp "$path/lib$QtX"Gui.so.$qx             $deploy
        cp "$path/lib$QtX"Network.so.$qx         $deploy
        cp "$path/lib$QtX"OpenGL.so.$qx          $deploy
        cp "$path/lib$QtX"Qml.so.$qx             $deploy
        cp "$path/lib$QtX"Quick.so.$qx           $deploy
        cp "$path/lib$QtX"Svg.so.$qx             $deploy
        cp "$path/lib$QtX"Widgets.so.$qx         $deploy
        cp "$path/lib$QtX"Xml.so.$qx             $deploy
        cp "$path/lib$QtX"Multimedia.so.$qx      $deploy
        cp "$path/lib$QtX"MultimediaQuick.so.$qx $deploy
        cp "$path/lib$QtX"XcbQpa.so.$qx          $deploy
        cp "$path/lib$QtX"DBus.so.$qx            $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/lib$QtX"XmlPatterns.so.$qx $deploy
        else
            cp "$path/lib$QtX"Core5Compat.so.$qx $deploy
            cp "$path/lib$QtX"QmlMeta.so.$qx     $deploy
        fi

        if [ -f "$path/lib$QtX"QmlModels.so.$qx ]; then

            cp "$path/lib$QtX"QmlModels.so.$qx       $deploy
            cp "$path/lib$QtX"QmlWorkerScript.so.$qx $deploy
        fi

        cp "$path"/platforms/libqxcb.so $deploy/platforms

        cp "$path"/imageformats/libqsvg.so  $deploy/imageformats
        cp "$path"/imageformats/libqjpeg.so $deploy/imageformats

        if [ -f "$path"/imageformats/libqwebp.so ]; then

            cp "$path"/imageformats/libqwebp.so $deploy/imageformats
        fi

        if [ $qt = "qt5" ]; then

            cp "$path"/mediaservice/libgstcamerabin.so $deploy/mediaservice
        else
            cp "$path"/tls/libqopensslbackend.so $deploy/tls

            cp "$path"/multimedia/libffmpegmediaplugin.so $deploy/multimedia
        fi

        cp "$path"/xcbglintegrations/libqxcb-egl-integration.so $deploy/xcbglintegrations
        cp "$path"/xcbglintegrations/libqxcb-glx-integration.so $deploy/xcbglintegrations

        cp "$path"/$QtQuick/libqtquick2plugin.so $deploy/$QtQuick
        cp "$path"/$QtQuick/qmldir               $deploy/$QtQuick

        cp "$path"/QtMultimedia/lib*multimedia*.so $deploy/QtMultimedia
        cp "$path"/QtMultimedia/qmldir             $deploy/QtMultimedia

        if [ $qt = "qt6" ]; then

            cp "$path"/QtQml/WorkerScript/libworkerscriptplugin.so $deploy/QtQml/WorkerScript
            cp "$path"/QtQml/WorkerScript/qmldir                   $deploy/QtQml/WorkerScript
        fi
    fi
fi

#--------------------------------------------------------------------------------------------------
# SSL
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    if [ $qt = "qt4" ]; then

        cp "$path"/libeay32.dll $deploy
        cp "$path"/ssleay32.dll $deploy
    else
        cp "$path"/libssl*.dll    $deploy
        cp "$path"/libcrypto*.dll $deploy
    fi

elif [ $1 = "linux" ]; then

    cp "$path"/libssl.so*    $deploy
    cp "$path"/libcrypto.so* $deploy
fi

#--------------------------------------------------------------------------------------------------
# VLC
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/libvlc*.dll $deploy

elif [ $1 = "macOS" ]; then

    cp -r "$path"/plugins $deploy

    cp "$path"/libvlc*.dylib $deploy

elif [ $1 = "linux" ]; then

    cp -r "$path"/vlc $deploy

    cp "$path"/libvlc*.so* $deploy

    if [ -f "$path"/libidn.so* ]; then

        cp "$path"/libidn.so* $deploy
    fi
fi

#--------------------------------------------------------------------------------------------------
# libtorrent
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    cp "$path"/*torrent-rasterbar.dll $deploy

elif [ $1 = "macOS" ]; then

    cp "$path"/libtorrent-rasterbar.dylib $deploy

elif [ $1 = "linux" ]; then

    cp "$path"/libtorrent-rasterbar*.so* $deploy
fi

#--------------------------------------------------------------------------------------------------
# Boost
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

    cp "$path"/libboost*.dylib $deploy

elif [ $1 = "linux" ]; then

    cp "$path"/libboost*.so* $deploy
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

    deployMacOS

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

    codesign --force --deep --sign - deploy/$target.app

elif [ $1 = "linux" ]; then

    cp bin/$target $deploy

    # NOTE: This script is useful for compatibilty. It enforces the application path for libraries.
    cp dist/script/start.sh $deploy

    chmod +x $deploy/start.sh

elif [ $1 = "android" ]; then

    cp bin/lib$target* $deploy
fi

#--------------------------------------------------------------------------------------------------
# backend
#--------------------------------------------------------------------------------------------------

if [ $os != "mobile" ]; then

    echo "COPYING backend"

    mkdir -p $deploy/backend/cover

    cp "$backend"/cover/* $deploy/backend/cover

    cp "$backend"/*.vbml $deploy/backend
fi
