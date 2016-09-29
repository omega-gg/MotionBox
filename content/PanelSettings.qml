//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

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

    anchors.right: parent.right
    anchors.top  : parent.bottom

    anchors.rightMargin: (gui.isMini) ? -st.dp2 : st.dp96

    width: buttonMaximum.x + buttonMaximum.width + st.dp7 + borderRight

    height: st.dp76 + borderSizeHeight

    borderBottom: 0

    visible: false

    backgroundOpacity: st.panelContextual_backgroundOpacity

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

        AnchorChanges
        {
            target: panelSettings

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_faster }

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
    // Events
    //---------------------------------------------------------------------------------------------

    onPQualityChanged:
    {
        if (player.isPaused) player.stop();

        if      (pQuality == 1) player.quality = AbstractBackend.QualityMinimum;
        else if (pQuality == 2) player.quality = AbstractBackend.QualityLow;
        else if (pQuality == 3) player.quality = AbstractBackend.QualityMedium;
        else if (pQuality == 4) player.quality = AbstractBackend.QualityHigh;
        else if (pQuality == 5) player.quality = AbstractBackend.QualityUltra;
        else                    player.quality = AbstractBackend.QualityMaximum;
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

        panelShare.collapse();

        isExposed = true;

        z = 1;

        panelShare.z = 0;

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
        id: barPlayback

        width: buttonRepeat.x + buttonRepeat.width + st.dp5

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Playback")

            font.pixelSize: st.dp12
        }
    }

    BorderVertical
    {
        id: border

        anchors.left: barPlayback.right
    }

    BarTitleSmall
    {
        anchors.left : border.right
        anchors.right: parent.right

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Video quality")

            font.pixelSize: st.dp12
        }
    }

    ButtonPianoIcon
    {
        anchors.right: parent.right

        width : st.dp26 + borderSizeWidth
        height: st.dp26

        borderLeft : borderSize
        borderRight: 0

        icon          : st.icon16x16_close
        iconSourceSize: st.size16x16

        onClicked: collapse()
    }

    Item
    {
        anchors.left : parent.left
        anchors.right: parent.right

        anchors.top   : barPlayback.bottom
        anchors.bottom: parent.bottom

        ButtonPushIcon
        {
            id: buttonShuffle

            anchors.left: parent.left

            anchors.leftMargin: st.dp5

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp44

            checkable: true
            checked  : local.shuffle

            icon          : st.icon24x24_shuffle
            iconSourceSize: st.size24x24

            onClicked: local.shuffle = !(checked)
        }

        ButtonPushIcon
        {
            id: buttonRepeat

            anchors.left: buttonShuffle.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp44

            checkable: true
            checked  : (pRepeat > 0)

            icon: (pRepeat == 2) ? st.icon24x24_repeatOne
                                 : st.icon24x24_repeat

            iconSourceSize: st.size24x24

            onClicked:
            {
                pRepeat = (pRepeat + 1) % 3;

                if (pRepeat == 0) checked = false;
                else              checked = true;

                player.repeat = pRepeat;
            }
        }

        ButtonPushLeftIcon
        {
            id: buttonMinimum

            anchors.left: buttonRepeat.right

            anchors.leftMargin: st.dp12

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp38

            padding: st.dp6

            highlighted: (pQualityActive == 1)

            checked   : (pQuality == 1)
            checkHover: false

            icon          : st.icon16x16_point
            iconSourceSize: st.size16x16

            onPressed: pQuality = 1
        }

        ButtonPushCenter
        {
            id: buttonLow

            anchors.left: buttonMinimum.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp52

            padding: 0

            highlighted: (pQualityActive == 2)

            checked   : (pQuality == 2)
            checkHover: false

            text: qsTr("Low")

            onPressed: pQuality = 2
        }

        ButtonPushCenter
        {
            id: buttonMedium

            anchors.left: buttonLow.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp52

            padding: 0

            highlighted: (pQualityActive == 3)

            checked   : (pQuality == 3)
            checkHover: false

            text: qsTr("Med")

            onPressed: pQuality = 3
        }

        ButtonPushCenter
        {
            id: buttonHigh

            anchors.left: buttonMedium.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp52

            padding: 0

            highlighted: (pQualityActive == 4)

            checked   : (pQuality == 4)
            checkHover: false

            text: qsTr("High")

            onPressed: pQuality = 4
        }

        ButtonPushCenter
        {
            id: buttonUltra

            anchors.left: buttonHigh.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp52

            padding: 0

            highlighted: (pQualityActive == 5)

            checked   : (pQuality == 5)
            checkHover: false

            text: qsTr("Ultra")

            onPressed: pQuality = 5
        }

        ButtonPushRightIcon
        {
            id: buttonMaximum

            anchors.left: buttonUltra.right

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp38

            padding: st.dp6

            highlighted: (pQualityActive == 6)

            checked   : (pQuality == 6)
            checkHover: false

            icon          : st.icon16x16_point
            iconSourceSize: st.size16x16

            onPressed: pQuality = 6
        }
    }
}
