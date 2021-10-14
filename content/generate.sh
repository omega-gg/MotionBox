#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../../Sky"

SkyBase="$Sky/src/SkyBase"

SkyComponents="$Sky/src/SkyComponents"

#--------------------------------------------------------------------------------------------------

content="../content"

bin="../bin"

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
   [ $# = 2 -a "$2" != "all" -a "$2" != "deploy" -a "$2" != "clean" ]; then

    echo "Usage: generate <win32 | win64 | macOS | linux | android> [all | deploy | clean]"

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

if [ "$2" = "deploy" ]; then

    path="qrc"
else
    path="$bin"
fi

cd ../dist

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ "$2" = "clean" ]; then

    echo "CLEANING"

    rm -f $bin/*.qml

    rm -rf $bin/pictures
    rm -rf $bin/text

    rm -f qrc/*.qml

    rm -rf qrc/pictures
    rm -rf qrc/text

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# QML
#--------------------------------------------------------------------------------------------------

echo "COPYING QML"

cp $content/*.qml $path

#--------------------------------------------------------------------------------------------------
# Content
#--------------------------------------------------------------------------------------------------

if [ "$2" = "all" -o "$2" = "deploy" ]; then

    echo "COPYING pictures"

    cp -r $content/pictures $path

    echo "COPYING text"

    cp -r $content/text $path
fi

#--------------------------------------------------------------------------------------------------
# Icon
#--------------------------------------------------------------------------------------------------

if [ $1 = "macOS" ]; then

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

if [ $qt = "qt5" ]; then

    if [ $1 = "linux" ]; then

        version=2.7
    else
        version=2.14
    fi
else
    version=1.1
fi

if [ $os = "windows" ]; then

    defines="DESKTOP WINDOWS"

elif [ $1 = "macOS" ]; then

    defines="DESKTOP MAC"

elif [ $1 = "linux" ]; then

    defines="DESKTOP LINUX"
else
    defines="MOBILE ANDROID"
fi

if [ "$2" = "deploy" ]; then

    defines="$defines DEPLOY"
fi

defines="$defines BarWindow icons_slide icons_scale icons_add icons_external icons_playback"

files="\
$SkyBase/Style.qml \
$SkyBase/Window.qml \
$SkyBase/ItemSlide.qml \
$SkyBase/ItemWipe.qml \
$SkyBase/LoaderSlide.qml \
$SkyBase/LoaderWipe.qml \
$SkyBase/AreaContextual.qml \
$SkyBase/RectangleBorders.qml \
$SkyBase/RectangleShadow.qml \
$SkyBase/RectangleShadowClick.qml \
$SkyBase/TextBase.qml \
$SkyBase/TextClick.qml \
$SkyBase/TextLink.qml \
$SkyBase/TextSubtitle.qml \
$SkyBase/BasePanel.qml \
$SkyBase/BasePanelContextual.qml \
$SkyBase/BaseButton.qml \
$SkyBase/BaseLineEdit.qml \
$SkyBase/BaseTextEdit.qml \
$SkyBase/BaseConsole.qml \
$SkyBase/BaseSlider.qml \
$SkyBase/BasePlayerBrowser.qml \
$SkyComponents/StyleComponents.qml \
$SkyComponents/PageWipe.qml \
$SkyComponents/LineHorizontal.qml \
$SkyComponents/LineHorizontalDrop.qml \
$SkyComponents/LineVertical.qml \
$SkyComponents/BorderHorizontal.qml \
$SkyComponents/BorderVertical.qml \
$SkyComponents/BorderButton.qml \
$SkyComponents/WindowScale.qml \
$SkyComponents/RectangleBordersDrop.qml \
$SkyComponents/RectangleLogo.qml \
$SkyComponents/RectangleLive.qml \
$SkyComponents/Icon.qml \
$SkyComponents/IconOverlay.qml \
$SkyComponents/IconLoading.qml \
$SkyComponents/TextRich.qml \
$SkyComponents/TextDate.qml \
$SkyComponents/TextListDefault.qml \
$SkyComponents/Panel.qml \
$SkyComponents/PanelContextual.qml \
$SkyComponents/PanelImage.qml \
$SkyComponents/BaseToolTip.qml \
$SkyComponents/ToolTip.qml \
$SkyComponents/BarTitle.qml \
$SkyComponents/BarTitleSmall.qml \
$SkyComponents/BarTitleText.qml \
$SkyComponents/BarSetting.qml \
$SkyComponents/BarSettingReset.qml \
$SkyComponents/BaseButtonPush.qml \
$SkyComponents/BaseButtonPiano.qml \
$SkyComponents/ButtonPush.qml \
$SkyComponents/ButtonPushIcon.qml \
$SkyComponents/ButtonPushFull.qml \
$SkyComponents/ButtonPushLeft.qml \
$SkyComponents/ButtonPushLeftIcon.qml \
$SkyComponents/ButtonPushLeftFull.qml \
$SkyComponents/ButtonPushCenter.qml \
$SkyComponents/ButtonPushCenterIcon.qml \
$SkyComponents/ButtonPushRight.qml \
$SkyComponents/ButtonPushRightIcon.qml \
$SkyComponents/ButtonPushOverlay.qml \
$SkyComponents/ButtonPiano.qml \
$SkyComponents/ButtonPianoIcon.qml \
$SkyComponents/ButtonPianoFull.qml \
$SkyComponents/ButtonPianoAction.qml \
$SkyComponents/ButtonPianoWindow.qml \
$SkyComponents/ButtonPianoReset.qml \
$SkyComponents/ButtonRound.qml \
$SkyComponents/ButtonCheck.qml \
$SkyComponents/ButtonCheckLabel.qml \
$SkyComponents/ButtonImage.qml \
$SkyComponents/ButtonImageBorders.qml \
$SkyComponents/ButtonMask.qml \
$SkyComponents/ButtonStream.qml \
$SkyComponents/ButtonsCheck.qml \
$SkyComponents/ButtonsItem.qml \
$SkyComponents/BaseLabelRound.qml \
$SkyComponents/LabelRound.qml \
$SkyComponents/LabelRoundAnimated.qml \
$SkyComponents/LabelRoundInfo.qml \
$SkyComponents/LabelLoading.qml \
$SkyComponents/LabelLoadingText.qml \
$SkyComponents/LabelLoadingButton.qml \
$SkyComponents/LabelStream.qml \
$SkyComponents/CheckBox.qml \
$SkyComponents/LineEdit.qml \
$SkyComponents/LineEditLabel.qml \
$SkyComponents/LineEditValue.qml \
$SkyComponents/LineEditBox.qml \
$SkyComponents/LineEditBoxClear.qml \
$SkyComponents/Console.qml \
$SkyComponents/BaseList.qml \
$SkyComponents/List.qml \
$SkyComponents/ListCompletion.qml \
$SkyComponents/ListContextual.qml \
$SkyComponents/ScrollArea.qml \
$SkyComponents/ScrollBar.qml \
$SkyComponents/ScrollList.qml \
$SkyComponents/ScrollListDefault.qml \
$SkyComponents/ScrollCompletion.qml \
$SkyComponents/ScrollerVertical.qml \
$SkyComponents/ScrollerList.qml \
$SkyComponents/Slider.qml \
$SkyComponents/SliderVolume.qml \
$SkyComponents/SliderStream.qml \
$SkyComponents/BaseTabs.qml \
$SkyComponents/TabsBrowser.qml \
$SkyComponents/TabsTrack.qml \
$SkyComponents/TabsPlayer.qml \
$SkyComponents/TabBarProgress.qml \
$SkyComponents/BaseWall.qml \
$SkyComponents/Wall.qml \
$SkyComponents/WallBookmarkTrack.qml \
$SkyComponents/WallVideo.qml \
$SkyComponents/PlayerBrowser.qml \
$SkyComponents/ItemList.qml \
$SkyComponents/ItemTab.qml \
$SkyComponents/ItemWall.qml \
$SkyComponents/ComponentList.qml \
$SkyComponents/ComponentContextual.qml \
$SkyComponents/ComponentCompletion.qml \
$SkyComponents/ComponentTab.qml \
$SkyComponents/ComponentTabBrowser.qml \
$SkyComponents/ComponentTabTrack.qml \
$SkyComponents/ComponentWall.qml \
$SkyComponents/ComponentWallBookmarkTrack.qml \
$SkyComponents/ContextualCategory.qml \
$SkyComponents/ContextualItem.qml \
$SkyComponents/ContextualItemCover.qml \
$SkyComponents/ContextualItemConfirm.qml"

#--------------------------------------------------------------------------------------------------
# Dev

# NOTE: We only need those files to communicate about the application.
if [ "$2" != "deploy" ]; then

    files="$files \
$SkyBase/CursorSvg.qml"
fi

#--------------------------------------------------------------------------------------------------

"$Sky"/deploy/deployer $path $version MotionBox.qrc "$defines" $files
