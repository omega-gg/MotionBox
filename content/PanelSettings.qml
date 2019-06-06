//=================================================================================================
/*
    Copyright (C) 2015-2017 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick 1.0
import Sky     1.0

Panel
{
    id: panelSettings

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    //---------------------------------------------------------------------------------------------
    // Private

    property int pRepeat: local.repeat

    property int pQuality      : local.quality
    property int pQualityActive: player.qualityActive

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

//#QT_4
    anchors.right: parent.right
    anchors.top  : parent.bottom

    anchors.rightMargin: (gui.isMini) ? 0 : st.dp96
//#ELSE
    // FIXME Qt5.12 Win8: Panel size changes for no reason when hidden.
    x: (gui.isMini) ? parent.width - width
                    : parent.width - width - st.dp96

    y: parent.height + height
//#END

    width: st.dp400 + borderSizeWidth

    height: barBottom.y + barBottom.height + st.dp50 + borderSizeHeight

    borderRight : (gui.isMini) ? 0 : borderSize
    borderBottom: 0

    visible: false

    backgroundOpacity: st.panelContextual_backgroundOpacity

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

//#QT_4
        AnchorChanges
        {
            target: panelSettings

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
//#ELSE
        PropertyChanges
        {
            target: panelSettings

            y: parent.height - panelSettings.height
        }
//#END
    }

    transitions: Transition
    {
        SequentialAnimation
        {
//#QT_4
            AnchorAnimation
            {
                duration: st.duration_faster

                easing.type: st.easing
            }
//#ELSE
            NumberAnimation
            {
                property: "y"

                duration: st.duration_faster

                easing.type: st.easing
            }
//#END

            ScriptAction
            {
                script:
                {
                    if (isExposed == false) visible = false;

                    z = 0;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events private
    //---------------------------------------------------------------------------------------------

    onPQualityChanged:
    {
        if      (pQuality == 1) player.quality = AbstractBackend.Quality240;
        else if (pQuality == 2) player.quality = AbstractBackend.Quality360;
        else if (pQuality == 3) player.quality = AbstractBackend.Quality480;
        else if (pQuality == 4) player.quality = AbstractBackend.Quality720;
        else if (pQuality == 5) player.quality = AbstractBackend.Quality1080;
        else if (pQuality == 6) player.quality = AbstractBackend.Quality1440;
        else                    player.quality = AbstractBackend.Quality2160;
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            collapse();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        gui.restoreMicro();

        if (isExposed || actionCue.tryPush(gui.actionSettingsExpose)) return;

        gui.panelAddHide();

        panelGet.collapse();

        isExposed = true;

        z = 1;

        panelGet.z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionSettingsCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitleSmall
    {
        id: barTop

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0
    }

    BarTitleText
    {
        id: itemOutput

        anchors.top   : barTop.top
        anchors.bottom: barTop.bottom

        anchors.bottomMargin: barTop.borderBottom

        width: buttonVideo.x + buttonVideo.width + st.dp5

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment  : Text.AlignVCenter

        text: qsTr("Output")

        font.pixelSize: st.dp12
    }

    BorderVertical
    {
        id: borderTop

        anchors.left  : itemOutput.right
        anchors.top   : barTop.top
        anchors.bottom: barBottom.top
    }

    BarTitleText
    {
        anchors.left  : borderTop.right
        anchors.right : parent.right
        anchors.top   : itemOutput.top
        anchors.bottom: itemOutput.bottom

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment  : Text.AlignVCenter

        text: qsTr("Playback")

        font.pixelSize: st.dp12
    }

    ButtonPushLeft
    {
        id: buttonAudio

        anchors.left: parent.left
        anchors.top : barTop.bottom

        anchors.leftMargin: st.dp5
        anchors.topMargin : st.dp5

        width: st.dp70

        highlighted: (player.outputActive == AbstractBackend.OutputAudio)
        checked    : (player.output       == AbstractBackend.OutputAudio)

        checkHover: false

        text: qsTr("Audio")

        onClicked: player.output = AbstractBackend.OutputAudio
    }

    ButtonPushRight
    {
        id: buttonVideo

        anchors.left: buttonAudio.right
        anchors.top : buttonAudio.top

        width: st.dp70

        highlighted: (player.outputActive == AbstractBackend.OutputMedia)
        checked    : (player.output       == AbstractBackend.OutputMedia)

        checkHover: false

        text: qsTr("Video")

        onClicked: player.output = AbstractBackend.OutputMedia
    }

    ButtonCheckLabel
    {
        id: buttonCheck

        anchors.left : borderTop.right
        anchors.right: buttonShuffle.left
        anchors.top  : buttonAudio.top

        anchors.leftMargin: st.dp5

        checked: local.autoPlay

        text: qsTr("Autoplay")

        onCheckClicked: local.autoPlay = checked
    }

    ButtonPushIcon
    {
        id: buttonShuffle

        anchors.right: buttonRepeat.left
        anchors.top  : buttonCheck.top

        width: st.dp44

        highlighted: (player.isPlaying && checked)

        checked: local.shuffle

        icon          : st.icon24x24_shuffle
        iconSourceSize: st.size24x24

        onClicked: local.shuffle = !(checked)
    }

    ButtonPushIcon
    {
        id: buttonRepeat

        anchors.right: parent.right
        anchors.top  : buttonCheck.top

        anchors.rightMargin: st.dp5

        width: st.dp44

        highlighted: buttonShuffle.highlighted

        checked: (pRepeat > 0)

        icon: (pRepeat == 2) ? st.icon24x24_repeatOne
                             : st.icon24x24_repeat

        iconSourceSize: st.size24x24

        onClicked:
        {
            pRepeat = (pRepeat + 1) % 3;

            player.repeat = pRepeat;
        }
    }

    BarTitleSmall
    {
        id: barBottom

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : barTop.bottom

        anchors.topMargin: st.dp50
    }

    BarTitleText
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : barBottom.top
        anchors.bottom: barBottom.bottom

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment  : Text.AlignVCenter

        text: qsTr("Quality")

        font.pixelSize: st.dp12
    }

    ButtonsCheck
    {
        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : barBottom.bottom

        anchors.leftMargin : st.dp5
        anchors.rightMargin: st.dp5
        anchors.topMargin  : st.dp5

        model: ListModel {}

        currentIndex : pQuality       - 1
        currentActive: pQualityActive - 1

        Component.onCompleted:
        {
            model.append({ "title": qsTr("240p")  });
            model.append({ "title": qsTr("360p")  });
            model.append({ "title": qsTr("480p")  });
            model.append({ "title": qsTr("720p")  });
            model.append({ "title": qsTr("1080p") });
            model.append({ "title": qsTr("1440p") });
            model.append({ "title": qsTr("2160p") });
        }

        onPressed: pQuality = currentIndex + 1
    }
}
