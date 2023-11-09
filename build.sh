#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

target="MotionBox"

MotionBox="../.."

external="$PWD/../3rdparty"

#--------------------------------------------------------------------------------------------------

Qt4_version="4.8.7"
Qt5_version="5.15.2"
Qt6_version="6.6.0"

#--------------------------------------------------------------------------------------------------

make_arguments="-j 4"

#--------------------------------------------------------------------------------------------------
# Windows

ProgramFiles="/c/Program Files (x86)"

BuildTools="$ProgramFiles/Microsoft Visual Studio/2022/BuildTools"

#--------------------------------------------------------------------------------------------------

MinGW_version="11.2.0"

jom_version="1.1.3"

MSVC_version="14"

WindowsKit_version="10"

#--------------------------------------------------------------------------------------------------
# Android

SDK_version="33"
SDK_version_minimum="21"

NDK_version="25"

#--------------------------------------------------------------------------------------------------
# environment

compiler_win="mingw"

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

makeAndroid()
{
    if [ ! -d "${1}" ]; then

        mkdir $1
    fi

    cd $1

    if [ $qt = "qt5" ]; then

        qtconf=""
    else
        qtconf="-qtconf $2"
    fi

    $qmake -r -spec $spec $qtconf "$config" \
           "ANDROID_ABIS=$1" \
           "ANDROID_MIN_SDK_VERSION=$SDK_version_minimum" \
           "ANDROID_TARGET_SDK_VERSION=$SDK_version" ../..

    make $make_arguments

    make INSTALL_ROOT=android-build install

    cd ..
}

getOs()
{
    case `uname` in
    MINGW*)  os="windows";;
    Darwin*) os="macOS";;
    Linux*)  os="linux";;
    *)       os="other";;
    esac

    type=`uname -m`

    if [ $type = "x86_64" ]; then

        if [ $os = "windows" ]; then

            echo win64
        else
            echo $os
        fi

    elif [ $os = "windows" ]; then

        echo win32
    else
        echo $os
    fi
}

getPath()
{
    echo $(ls "$1" | grep $2 | tail -1)
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "linux" -a $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "all" -a "$2" != "deploy" -a "$2" != "clean" ]; then

    echo "Usage: build <win32 | win64 | macOS | linux | android> [all | deploy | clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# All
#--------------------------------------------------------------------------------------------------

if [ "$2" = "all" ]; then

    sh 3rdparty.sh $1 all

    sh configure.sh $1 sky

    cd ../Sky

    sh build.sh $1 tools

    cd -

    sh build.sh $1 deploy

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

host=$(getOs)

external="$external/$1"

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

    compiler="$compiler_win"

    if [ $compiler = "mingw" ]; then

        MinGW="$external/MinGW/$MinGW_version/bin"
    else
        jom="$external/jom/$jom_version"

        MSVC_version=$(getPath "$BuildTools/VC/Tools/MSVC" $MSVC_version)

        MSVC="$BuildTools/VC/Tools/MSVC/$MSVC_version"

        WindowsKit="$ProgramFiles/Windows Kits/$WindowsKit_version"

        WindowsKit_version=$(getPath "$WindowsKit/bin" $WindowsKit_version)

        echo "MSVC version $MSVC_version"
        echo ""
        echo "WindowsKit version $WindowsKit_version"
        echo ""

        if [ $1 = "win32" ]; then

            abi="x86"
        else
            abi="x64"
        fi
    fi
else
    if [ $1 = "android" -a $host != "linux" ]; then

        echo "You have to cross-compile $1 from Linux (preferably Ubuntu)."

        exit 1
    fi

    os="default"

    compiler="default"
fi

if [ $qt = "qt4" ]; then

    Qt="$external/Qt/$Qt4_version"

elif [ $qt = "qt5" ]; then

    Qt="$external/Qt/$Qt5_version"
else
    Qt="$external/Qt/$Qt6_version"
fi

if [ $1 = "android" -a $qt = "qt6" ]; then

    QtBin="$Qt/gcc_64/bin"
else
    QtBin="$Qt/bin"
fi

qmake="$QtBin/qmake"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ "$2" = "clean" ]; then

    echo "CLEANING"

    # NOTE: We have to remove the folder to delete .qmake.stash.
    rm -rf build
    mkdir  build
    touch  build/.gitignore

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Build MotionBox
#--------------------------------------------------------------------------------------------------

echo "BUILDING $target"
echo "------------------"

export QT_SELECT="$qt"

if [ $qt = "qt4" ]; then

    config="CONFIG+=release"
else
    config="CONFIG+=release qtquickcompiler"
fi

if [ $compiler = "mingw" ]; then

    spec=win32-g++

    PATH="$Qt/bin:$MinGW:$PATH"

elif [ $compiler = "msvc" ]; then

    if [ $qt = "qt4" ]; then

        spec=win32-msvc2015
    else
        spec=win32-msvc
    fi

    PATH="$jom:$MSVC/bin/Host$abi/$abi:\
$WindowsKit/bin/$WindowsKit_version/$abi:\
$Qt/bin:$PATH"

    export INCLUDE="$MSVC/include:\
$WindowsKit/Include/$WindowsKit_version/ucrt:\
$WindowsKit/Include/$WindowsKit_version/um:\
$WindowsKit/Include/$WindowsKit_version/shared"

    export LIB="$MSVC/lib/$abi:\
$WindowsKit/Lib/$WindowsKit_version/ucrt/$abi:\
$WindowsKit/Lib/$WindowsKit_version/um/$abi"

elif [ $1 = "macOS" ]; then

    spec=macx-clang

    export PATH="$Qt/bin:$PATH"

elif [ $1 = "linux" ]; then

    if [ -d "/usr/lib/x86_64-linux-gnu" ]; then

        spec=linux-g++-64
    else
        spec=linux-g++-32
    fi

elif [ $1 = "android" ]; then

    spec=android-clang

    export ANDROID_NDK_ROOT="$external/NDK/$NDK_version"

    export ANDROID_NDK_PLATFORM="android-$SDK_version"

    # NOTE android: This variable enforces the linux clang compiler.
    export ANDROID_NDK_HOST="linux-x86_64"
fi

$qmake --version
echo ""

cd content

if [ "$2" = "deploy" ]; then

    sh generate.sh $1 deploy
else
    sh generate.sh $1
fi

echo ""

cd ../build

if [ "$2" = "deploy" ]; then

    config="$config deploy"
fi

if [ $1 = "android" ]; then

    makeAndroid armeabi-v7a "$Qt"/android_armv7/bin/target_qt.conf
    makeAndroid arm64-v8a   "$Qt"/android_arm64_v8a/bin/target_qt.conf
    makeAndroid x86         "$Qt"/android_x86/bin/target_qt.conf
    makeAndroid x86_64      "$Qt"/android_x86_64/bin/target_qt.conf

elif [ $1 = "macOS" -a $qt = "qt6" ]; then

    $qmake -r -spec $spec "$config" QMAKE_APPLE_DEVICE_ARCHS="x86_64" ..
else
    $qmake -r -spec $spec "$config" ..
fi

if [ $compiler = "mingw" ]; then

    mingw32-make $make_arguments

elif [ $compiler = "msvc" ]; then

    jom

elif [ $1 != "android" ]; then

    make $make_arguments
fi

cd ..

echo "------------------"

#--------------------------------------------------------------------------------------------------
# Deploying MotionBox
#--------------------------------------------------------------------------------------------------

if [ "$2" = "deploy" ]; then

    echo ""
    echo "DEPLOYING $target"
    echo "-------------------"

    sh deploy.sh $1

    echo "-------------------"
fi
