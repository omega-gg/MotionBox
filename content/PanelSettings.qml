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

    height: barBottom.y + barBottom.height + st.dp50 + borderSizeHeight

    borderBottom: 0

    visible: false

    backgroundOpacity: (gui.isExpanded) ? st.panelContextual_backgroundOpacity : 1.0

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
        id: barTop

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0
    }

    Item
    {
        id: itemOutput

        anchors.top   : barTop.top
        anchors.bottom: barTop.bottom

        anchors.bottomMargin: barTop.borderBottom

        width: buttonVideo.x + buttonVideo.width + st.dp5

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Output")

            font.pixelSize: st.dp12
        }
    }

    BorderVertical
    {
        id: borderTop

        anchors.left  : itemOutput.right
        anchors.top   : barTop.top
        anchors.bottom: barBottom.top
    }

    Item
    {
        anchors.left  : borderTop.right
        anchors.right : buttonClose.left
        anchors.top   : itemOutput.top
        anchors.bottom: itemOutput.bottom

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Speed")

            font.pixelSize: st.dp12
        }
    }

    ButtonPianoIcon
    {
        id: buttonClose

        anchors.right: parent.right

        width : st.barTitleSmall_height + borderSizeWidth
        height: st.barTitleSmall_height

        borderLeft : borderSize
        borderRight: 0

        icon          : st.icon16x16_close
        iconSourceSize: st.size16x16

        onClicked: collapse()
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

    Slider
    {
        id: slider

        anchors.left: borderTop.right
        anchors.top : barTop.bottom

        anchors.leftMargin: st.dp5
        anchors.topMargin : st.dp12

        width: st.slider_width

        minimum: 0.0
        maximum: 2.0

        Component.onCompleted: value = local.speed

        onValueChanged:
        {
            var speed = value.toFixed(1);

            if (speed != 1.0)
            {
                if (speed < 1.0)
                {
                    speed = 0.5 + speed * 0.5;
                }

                buttonCheck.checked = true;
            }
            else buttonCheck.checked = false;

            player.speed = speed;
        }
    }

    ButtonCheckLabel
    {
        id: buttonCheck

        anchors.left: slider.right
        anchors.top : barTop.bottom

        anchors.rightMargin: st.dp5
        anchors.topMargin  : st.dp5

        checkable: (player.outputActive != AbstractBackend.OutputInvalid)

        text: player.speed.toFixed(1)

        button.enabled: (player.speed != 1.0)

        onCheckClicked:
        {
            if (checked == false)
            {
                slider.value = 1.0;
            }
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

    Item
    {
        id: itemPlayback

        anchors.top   : barBottom.top
        anchors.bottom: barBottom.bottom

        width: buttonRepeat.x + buttonRepeat.width + st.dp5

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
        id: borderBottom

        anchors.left: itemPlayback.right
        anchors.top : barBottom.top
    }

    Item
    {
        anchors.left  : borderBottom.right
        anchors.right : parent.right
        anchors.top   : itemPlayback.top
        anchors.bottom: itemPlayback.bottom

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Quality")

            font.pixelSize: st.dp12
        }
    }

    ButtonPushIcon
    {
        id: buttonShuffle

        anchors.left: parent.left
        anchors.top : barBottom.bottom

        anchors.leftMargin: st.dp5
        anchors.topMargin : st.dp5

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
        anchors.top : buttonShuffle.top

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
        anchors.top : buttonRepeat.top

        anchors.leftMargin: st.dp12

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
        anchors.top : buttonMinimum.top

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
        anchors.top : buttonLow.top

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
        anchors.top : buttonMedium.top

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
        anchors.top : buttonHigh.top

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
        anchors.top : buttonUltra.top

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
