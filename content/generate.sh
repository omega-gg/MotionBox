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
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ] \
   || \
   [ $1 != "qt4" -a $1 != "qt5" -a $1 != "clean" ] \
   || \
   [ $2 != "win32" -a $2 != "win64" -a $2 != "macOS" -a $2 != "linux" -a $2 != "android" ] \
   || \
   [ $# = 3 -a "$3" != "all" -a "$3" != "deploy" ]; then

    echo "Usage: generate <qt4 | qt5 | clean>"
    echo "                <win32 | win64 | macOS | linux | android>"
    echo "                [all | deploy]"

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

if [ "$3" = "deploy" ]; then

    path="qrc"
else
    path="$bin"
fi

cd ../dist

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ $1 = "clean" ]; then

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

if [ "$3" = "deploy" ]; then

    echo "COPYING pictures"

    cp -r $content/pictures $path

    echo "COPYING text"

    cp -r $content/text $path
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

    defines="DESKTOP WINDOWS"

elif [ $2 = "macOS" ]; then

    defines="DESKTOP MAC"

elif [ $1 = "linux" ]; then

    defines="DESKTOP LINUX"
else
    defines="ANDROID"
fi

defines="$defines BarWindow icons_slide icons_scale icons_add icons_external icons_playback"

"$Sky"/deploy/deployer $path $version MotionBox.qrc "$defines" \
"$SkyBase"/Style.qml \
"$SkyBase"/Window.qml \
"$SkyBase"/RectangleBorders.qml \
"$SkyBase"/BaseButton.qml \
"$SkyComponents"/StyleComponents.qml \
"$SkyComponents"/AreaContextual.qml \
"$SkyComponents"/ItemSlide.qml \
"$SkyComponents"/ItemWipe.qml \
"$SkyComponents"/LoaderSlide.qml \
"$SkyComponents"/LoaderWipe.qml \
"$SkyComponents"/PageWipe.qml \
"$SkyComponents"/LineHorizontal.qml \
"$SkyComponents"/LineHorizontalDrop.qml \
"$SkyComponents"/LineVertical.qml \
"$SkyComponents"/BorderHorizontal.qml \
"$SkyComponents"/BorderVertical.qml \
"$SkyComponents"/BorderButton.qml \
"$SkyComponents"/WindowScale.qml \
"$SkyComponents"/RectangleBordersDrop.qml \
"$SkyComponents"/RectangleShadow.qml \
"$SkyComponents"/RectangleLogo.qml \
"$SkyComponents"/Icon.qml \
"$SkyComponents"/IconOverlay.qml \
"$SkyComponents"/IconLoading.qml \
"$SkyComponents"/TextBase.qml \
"$SkyComponents"/TextRich.qml \
"$SkyComponents"/TextClick.qml \
"$SkyComponents"/TextLink.qml \
"$SkyComponents"/TextDate.qml \
"$SkyComponents"/TextListDefault.qml \
"$SkyComponents"/TextSubtitle.qml \
"$SkyComponents"/Panel.qml \
"$SkyComponents"/PanelContextual.qml \
"$SkyComponents"/PanelImage.qml \
"$SkyComponents"/BaseToolTip.qml \
"$SkyComponents"/ToolTip.qml \
"$SkyComponents"/BarTitle.qml \
"$SkyComponents"/BarTitleSmall.qml \
"$SkyComponents"/BarTitleText.qml \
"$SkyComponents"/BarSetting.qml \
"$SkyComponents"/BarSettingReset.qml \
"$SkyComponents"/BaseButtonPush.qml \
"$SkyComponents"/BaseButtonPiano.qml \
"$SkyComponents"/ButtonPush.qml \
"$SkyComponents"/ButtonPushIcon.qml \
"$SkyComponents"/ButtonPushFull.qml \
"$SkyComponents"/ButtonPushLeft.qml \
"$SkyComponents"/ButtonPushLeftIcon.qml \
"$SkyComponents"/ButtonPushLeftFull.qml \
"$SkyComponents"/ButtonPushCenter.qml \
"$SkyComponents"/ButtonPushCenterIcon.qml \
"$SkyComponents"/ButtonPushRight.qml \
"$SkyComponents"/ButtonPushRightIcon.qml \
"$SkyComponents"/ButtonPushOverlay.qml \
"$SkyComponents"/ButtonPiano.qml \
"$SkyComponents"/ButtonPianoIcon.qml \
"$SkyComponents"/ButtonPianoFull.qml \
"$SkyComponents"/ButtonPianoReset.qml \
"$SkyComponents"/ButtonRound.qml \
"$SkyComponents"/ButtonCheck.qml \
"$SkyComponents"/ButtonCheckLabel.qml \
"$SkyComponents"/ButtonImage.qml \
"$SkyComponents"/ButtonImageBorders.qml \
"$SkyComponents"/ButtonMask.qml \
"$SkyComponents"/ButtonStream.qml \
"$SkyComponents"/ButtonsCheck.qml \
"$SkyComponents"/ButtonsItem.qml \
"$SkyComponents"/BaseLabelRound.qml \
"$SkyComponents"/LabelRound.qml \
"$SkyComponents"/LabelRoundAnimated.qml \
"$SkyComponents"/LabelRoundInfo.qml \
"$SkyComponents"/LabelLoading.qml \
"$SkyComponents"/LabelLoadingText.qml \
"$SkyComponents"/LabelLoadingButton.qml \
"$SkyComponents"/LabelStream.qml \
"$SkyComponents"/CheckBox.qml \
"$SkyComponents"/BaseLineEdit.qml \
"$SkyComponents"/LineEdit.qml \
"$SkyComponents"/LineEditLabel.qml \
"$SkyComponents"/LineEditValue.qml \
"$SkyComponents"/LineEditBox.qml \
"$SkyComponents"/LineEditBoxClear.qml \
"$SkyComponents"/BaseTextEdit.qml \
"$SkyComponents"/Console.qml \
"$SkyComponents"/BaseList.qml \
"$SkyComponents"/List.qml \
"$SkyComponents"/ListCompletion.qml \
"$SkyComponents"/ListContextual.qml \
"$SkyComponents"/ScrollArea.qml \
"$SkyComponents"/ScrollBar.qml \
"$SkyComponents"/ScrollList.qml \
"$SkyComponents"/ScrollListDefault.qml \
"$SkyComponents"/ScrollCompletion.qml \
"$SkyComponents"/ScrollerVertical.qml \
"$SkyComponents"/ScrollerList.qml \
"$SkyComponents"/Slider.qml \
"$SkyComponents"/SliderVolume.qml \
"$SkyComponents"/SliderStream.qml \
"$SkyComponents"/BaseTabs.qml \
"$SkyComponents"/TabsBrowser.qml \
"$SkyComponents"/TabsTrack.qml \
"$SkyComponents"/TabsPlayer.qml \
"$SkyComponents"/TabBarProgress.qml \
"$SkyComponents"/BaseWall.qml \
"$SkyComponents"/Wall.qml \
"$SkyComponents"/WallBookmarkTrack.qml \
"$SkyComponents"/WallVideo.qml \
"$SkyComponents"/PlayerBrowser.qml \
"$SkyComponents"/ItemList.qml \
"$SkyComponents"/ItemTab.qml \
"$SkyComponents"/ItemWall.qml \
"$SkyComponents"/ComponentList.qml \
"$SkyComponents"/ComponentContextual.qml \
"$SkyComponents"/ComponentCompletion.qml \
"$SkyComponents"/ComponentTab.qml \
"$SkyComponents"/ComponentTabBrowser.qml \
"$SkyComponents"/ComponentTabTrack.qml \
"$SkyComponents"/ComponentWall.qml \
"$SkyComponents"/ComponentWallBookmarkTrack.qml \
"$SkyComponents"/ContextualCategory.qml \
"$SkyComponents"/ContextualItem.qml \
"$SkyComponents"/ContextualItemCover.qml \
"$SkyComponents"/ContextualItemConfirm.qml \
