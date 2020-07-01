#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

MotionBox="../.."

external="$PWD/../3rdparty"

#--------------------------------------------------------------------------------------------------

Qt4_version="4.8.7"
Qt5_version="5.14.2"

#--------------------------------------------------------------------------------------------------

make_arguments="-j 4"

#--------------------------------------------------------------------------------------------------
# Windows

ProgramFiles="/c/Program Files (x86)"

BuildTools="$ProgramFiles/Microsoft Visual Studio/2019/BuildTools"

#--------------------------------------------------------------------------------------------------

MinGW_version="7.3.0"

jom_version="1.1.3"

MSVC_version="14"

WindowsKit_version="10"

#--------------------------------------------------------------------------------------------------
# Android

NDK_version="21"

#--------------------------------------------------------------------------------------------------
# environment

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

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
   [ $1 != "win32" -a $1 != "win64" -a $1 != "win32-msvc" -a $1 != "win64-msvc" -a \
     $1 != "macOS" -a $1 != "linux" -a $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "all" -a "$2" != "deploy" -a "$2" != "clean" ]; then

    echo "Usage: build <win32 | win64 | win32-msvc | win64-msvc | macOS | linux | android>"
    echo "             [all | deploy | clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# All
#--------------------------------------------------------------------------------------------------

if [ "$2" = "all" ]; then

    sh 3rdparty.sh $1

    sh configure.sh $1 sky

    cd ../Sky

    sh build.sh $qt $1 tools

    cd -

    sh build.sh $1 deploy

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

host=$(getOs)

external="$external/$1"

if [ $1 = "win32" -o $1 = "win64" -o $1 = "win32-msvc" -o $1 = "win64-msvc" ]; then

    os="windows"

    if [ $1 = "win32" -o $1 = "win64" ]; then

        compiler="mingw"

        MinGW="$external/MinGW/$MinGW_version/bin"
    else
        compiler="msvc"

        jom="$external/jom/$jom_version"

        MSVC_version=$(getPath "$BuildTools/VC/Tools/MSVC" $MSVC_version)

        MSVC="$BuildTools/VC/Tools/MSVC/$MSVC_version"

        WindowsKit="$ProgramFiles/Windows Kits/$WindowsKit_version"

        WindowsKit_version=$(getPath "$WindowsKit/bin" $WindowsKit_version)

        echo "MSVC version $MSVC_version"
        echo ""
        echo "WindowsKit version $WindowsKit_version"
        echo ""

        if [ $1 = "win32-msvc" ]; then

            target="x86"
        else
            target="x64"
        fi
    fi

elif [ $1 = "android" ]; then

    if [ $host != "linux" ]; then

        echo "You have to cross-compile $1 from Linux (preferably Ubuntu)."

        exit 1
    fi

    os="default"

    compiler="default"

    abi="armeabi-v7a arm64-v8a x86 x86_64"
else
    os="default"

    compiler="default"
fi

if [ $qt = "qt4" ]; then

    Qt="$external/Qt/$Qt4_version"
else
    Qt="$external/Qt/$Qt5_version"
fi

if [ $os = "windows" -o $1 = "macOS" -o $1 = "android" ]; then

    qmake="$Qt/bin/qmake"
else
    qmake="qmake"
fi

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

echo "BUILDING MotionBox"
echo "------------------"

if [ $qt = "qt4" ]; then

    export QT_SELECT=qt4

    config="CONFIG+=release"
else
    export QT_SELECT=qt5

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

    PATH="$jom:$MSVC/bin/Host$target/$target:\
$WindowsKit/bin/$WindowsKit_version/$target:\
$Qt/bin:$PATH"

    export INCLUDE="$MSVC/include:\
$WindowsKit/Include/$WindowsKit_version/ucrt:\
$WindowsKit/Include/$WindowsKit_version/um:\
$WindowsKit/Include/$WindowsKit_version/shared"

    export LIB="$MSVC/lib/$target:\
$WindowsKit/Lib/$WindowsKit_version/ucrt/$target:\
$WindowsKit/Lib/$WindowsKit_version/um/$target"

elif [ $1 = "macOS" ]; then

    spec=macx-clang

    export PATH=$Qt/bin:$PATH

elif [ $1 = "linux" ]; then

    if [ -d "/usr/lib/x86_64-linux-gnu" ]; then

        spec=linux-g++-64
    else
        spec=linux-g++-32
    fi

elif [ $1 = "android" ]; then

    spec=android-clang

    export ANDROID_NDK_ROOT="$external/NDK/$NDK_version"
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

    $qmake -r -spec $spec "$config" "ANDROID_ABIS=$abi" ..
else
    $qmake -r -spec $spec "$config" ..
fi

if [ $compiler = "mingw" ]; then

    mingw32-make $make_arguments

elif [ $compiler = "msvc" ]; then

    jom
else
    make $make_arguments
fi

cd ..

echo "------------------"

#--------------------------------------------------------------------------------------------------
# Deploying MotionBox
#--------------------------------------------------------------------------------------------------

if [ "$2" = "deploy" ]; then

    echo ""
    echo "DEPLOYING MotionBox"
    echo "-------------------"

    sh deploy.sh $1

    echo "-------------------"
fi
