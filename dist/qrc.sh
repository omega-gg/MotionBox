#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../../Sky"

SkyComponents="$Sky/src/SkyComponents"

#--------------------------------------------------------------------------------------------------

content="../content"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ] \
   || \
   [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] \
   || \
   [ $2 != "win32" -a $2 != "win64" -a $2 != "macOS" -a $2 != "linux" -a $2 != "android" ] \
   || \
   [ $# = 3 -a "$3" != "deploy" ]; then

    echo "Usage: qrc <qt4 | qt5 | clean>"
    echo "           <win32 | win64 | macOS | linux | android>"
    echo "           [deploy]"

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

if [ $1 = "clean" -o "$3" = "deploy" ]; then

    echo "CLEANING"

    rm -f qrc/*.qml

    rm -rf qrc/pictures
    rm -rf qrc/text

    if [ $1 = "clean" ]; then

        exit 0
    fi

    echo ""
fi

#--------------------------------------------------------------------------------------------------
# QML
#--------------------------------------------------------------------------------------------------

echo "COPYING QML"

array=("Style"
       "AreaContextual"
       "ItemSlide"
       "ItemWipe"
       "LoaderSlide"
       "LoaderWipe"
       "PageWipe"
       "LineHorizontal"
       "LineHorizontalDrop"
       "LineVertical"
       "BorderHorizontal"
       "BorderVertical"
       "BorderButton"
       "Window"
       "WindowScale"
       "RectangleBorders"
       "RectangleBordersDrop"
       "RectangleShadow"
       "RectangleLogo"
       "Icon"
       "IconOverlay"
       "IconLoading"
       "TextBase"
       "TextRich"
       "TextClick"
       "TextLink"
       "TextDate"
       "TextListDefault"
       "TextSubtitle"
       "Panel"
       "PanelContextual"
       "PanelImage"
       "BaseToolTip"
       "ToolTip"
       "BarTitle"
       "BarTitleSmall"
       "BarTitleText"
       "BarSetting"
       "BarSettingReset"
       "BaseButton"
       "BaseButtonPush"
       "BaseButtonPiano"
       "ButtonPush"
       "ButtonPushIcon"
       "ButtonPushFull"
       "ButtonPushLeft"
       "ButtonPushLeftIcon"
       "ButtonPushLeftFull"
       "ButtonPushCenter"
       "ButtonPushCenterIcon"
       "ButtonPushRight"
       "ButtonPushRightIcon"
       "ButtonPushOverlay"
       "ButtonPiano"
       "ButtonPianoIcon"
       "ButtonPianoFull"
       "ButtonPianoReset"
       "ButtonRound"
       "ButtonCheck"
       "ButtonCheckLabel"
       "ButtonImage"
       "ButtonImageBorders"
       "ButtonMask"
       "ButtonStream"
       "ButtonsCheck"
       "ButtonsItem"
       "BaseLabelRound"
       "LabelRound"
       "LabelRoundAnimated"
       "LabelRoundInfo"
       "LabelLoading"
       "LabelLoadingText"
       "LabelLoadingButton"
       "LabelStream"
       "CheckBox"
       "BaseLineEdit"
       "LineEdit"
       "LineEditLabel"
       "LineEditValue"
       "LineEditBox"
       "LineEditBoxClear"
       "BaseTextEdit"
       "Console"
       "BaseList"
       "List"
       "ListCompletion"
       "ListContextual"
       "ScrollArea"
       "ScrollBar"
       "ScrollList"
       "ScrollListDefault"
       "ScrollCompletion"
       "ScrollerVertical"
       "ScrollerList"
       "Slider"
       "SliderVolume"
       "SliderStream"
       "BaseTabs"
       "TabsBrowser"
       "TabsTrack"
       "TabsPlayer"
       "TabBarProgress"
       "BaseWall"
       "Wall"
       "WallBookmarkTrack"
       "WallVideo"
       "PlayerBrowser"
       "ItemList"
       "ItemTab"
       "ItemWall"
       "ComponentList"
       "ComponentContextual"
       "ComponentCompletion"
       "ComponentTab"
       "ComponentTabBrowser"
       "ComponentTabTrack"
       "ComponentWall"
       "ComponentWallBookmarkTrack"
       "ContextualCategory"
       "ContextualItem"
       "ContextualItemCover"
       "ContextualItemConfirm")

for name in "${array[@]}"
do
    fileNames="$paths $SkyComponents/$name.qml"
done

cp $fileNames qrc

cp "$content"/*.qml qrc

#--------------------------------------------------------------------------------------------------
# Content
#--------------------------------------------------------------------------------------------------

if [ "$3" = "deploy" ]; then

    echo "COPYING pictures"

    cp -r "$SkyComponents"/pictures qrc

    cp -r "$content"/pictures qrc

    echo "COPYING text"

    cp -r "$content"/text qrc
fi

#--------------------------------------------------------------------------------------------------
# Icon
#--------------------------------------------------------------------------------------------------

if [ $2 = "macOS" ]; then

    echo "GENERATING icon"

    mkdir icon.iconset

    cp pictures/icon/16.png  icon.iconset/icon_16x16.png
    cp pictures/icon/24.png  icon.iconset/icon_24x24.png
    cp pictures/icon/32.png  icon.iconset/icon_32x32.png
    cp pictures/icon/48.png  icon.iconset/icon_48x48.png
    cp pictures/icon/64.png  icon.iconset/icon_64x64.png
    cp pictures/icon/128.png icon.iconset/icon_128x128.png
    cp pictures/icon/256.png icon.iconset/icon_256x256.png
    cp pictures/icon/512.png icon.iconset/icon_512x512.png

    iconutil -c icns icon.iconset

    rm -rf icon.iconset
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Deployer
#--------------------------------------------------------------------------------------------------

if [ $1 = "qt5" ]; then

    if [ $os = "windows" ]; then

        version=2.11
    else
        version=2.7
    fi
else
    version=1.1
fi

if [ $os = "windows" ]; then

    defines="$defines WINDOWS"

elif [ $2 = "macOS" ]; then

    defines="$defines MAC"

elif [ $1 = "linux" ]; then

    defines="$defines LINUX"
else
    defines="$defines ANDROID"
fi

"$Sky"/deploy/deployer qrc $version MotionBox.qrc $defines
