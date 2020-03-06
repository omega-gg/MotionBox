//=================================================================================================
/*
    Copyright (C) 2015-2020 MotionBox authors united with omega. <http://omega.gg/about>

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

MouseArea
{
    id: barControls

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExpanded: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonPlay: buttonPlay

    property alias buttonPrevious: buttonPrevious
    property alias buttonNext    : buttonNext

    property alias buttonAdd: buttonAdd

    property alias buttonSettings  : buttonSettings
    property alias buttonGet       : buttonGet
    property alias buttonFullScreen: buttonFullScreen

    property alias sliderVolume: sliderVolume
    property alias sliderStream: sliderStream

    property alias border: border

    property alias borderA: borderA
    property alias borderB: borderB

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    anchors.bottom: parent.bottom

    height: st.dp48 + border.size

    acceptedButtons: Qt.NoButton

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: isExpanded

        AnchorChanges
        {
            target: barControls

            anchors.top   : parent.bottom
            anchors.bottom: undefined
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }

            ScriptAction
            {
                script: if (isExpanded) visible = false
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expand()
    {
        if (isExpanded) return;

        isExpanded = true;
    }

    function restore()
    {
        if (isExpanded == false) return;

        isExpanded = false;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: parent.bottom

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.barTitle_colorA }
            GradientStop { position: 1.0; color: st.barTitle_colorB }
        }

        BorderHorizontal
        {
            visible: (st.barTitle_colorA != st.barTitle_colorB)

            color: st.barTitle_colorBorderLine
        }

        ButtonPushIcon
        {
            id: buttonPrevious

            anchors.left: parent.left
            anchors.top : parent.top

            anchors.leftMargin: st.dp6

            width : st.dp48
            height: width

            margins: st.dp6

            enabled: player.hasPreviousTrack

            highlighted: (enabled && player.isPlaying)

            icon          : st.icon24x24_backward
            iconSourceSize: st.size24x24

            hoverRetain: true

            onClicked: player.setPreviousTrack()
        }

        ButtonPushIcon
        {
            id: buttonNext

            anchors.left: buttonPlay.right
            anchors.top : buttonPlay.top

            anchors.leftMargin: -st.border_size

            width : st.dp48
            height: width

            margins: st.dp6

            enabled: player.hasNextTrack

            highlighted: (enabled && player.isPlaying)

            icon: (player.shuffle) ? st.icon24x24_shuffle
                                   : st.icon24x24_forward

            iconSourceSize: st.size24x24

            acceptedButtons: (player.isPlaying) ? Qt.LeftButton | Qt.RightButton
                                                : Qt.LeftButton

            hoverRetain: true

            onClicked:
            {
                if (mouse.button & Qt.RightButton)
                {
                    if (player.isPlaying)
                    {
                        local.shuffle = !(local.shuffle);
                    }
                }
                else player.setNextTrack();
            }
        }

        ButtonPushIcon
        {
            id: buttonPlay

            anchors.left: buttonPrevious.right
            anchors.top : buttonPrevious.top

            anchors.leftMargin: -st.border_size

            width : st.dp48
            height: width

            margins: st.dp6

            enabled: (player.source != "")

            highlighted: (enabled && player.isPlaying)

            icon: (player.isPlaying) ? st.icon24x24_pause
                                     : st.icon24x24_play

            iconSourceSize: st.size24x24

            hoverRetain: true

            onClicked:
            {
                if (player.isPlaying)
                {
                    gui.pause();
                }
                else player.play();
            }
        }

        SliderVolume
        {
            id: sliderVolume

            anchors.left: buttonNext.right
            anchors.top : parent.top

            anchors.leftMargin: st.dp8
            anchors.topMargin : st.dp8

            width: st.sliderVolume_width

            value: local.volume

            onValueChanged: player.volume = value
        }

        BorderVertical
        {
            id: borderA

            x: st.dp320
        }

        LabelStream
        {
            height: st.labelStream_height

            borderTop   : 0
            borderBottom: 0

            slider: sliderStream
        }

        SliderStream
        {
            id: sliderStream

            anchors.left : borderA.right
            anchors.right: buttonAdd.left
            anchors.top  : parent.top

            anchors.leftMargin : st.dp7
            anchors.rightMargin: st.dp2
            anchors.topMargin  : st.dp8

            height: st.sliderStream_height

            enabled: (player.hasStarted && duration > 0)

            active: player.isPlaying

            currentTime: (enabled) ? player.currentTime
                                   : player.trackCurrentTime

            duration: (player.duration == -1) ? player.trackDuration
                                              : player.duration

            progress: player.progress

            onHandleReleased: player.seek(slider.value)

            onReset:
            {
                if (player.isPaused)
                {
                    player.stop();

                    playerTab.currentTime = -1;
                }
                else if (player.isPlaying)
                {
                    player.seek(0);
                }
                else playerTab.currentTime = -1;
            }
        }

        ButtonRound
        {
            id: buttonAdd

            anchors.right: borderB.left

            anchors.top: parent.top

            anchors.rightMargin: st.dp7
            anchors.topMargin  : st.dp5

            width : st.dp38
            height: width

            enabled: currentTab.isValid

            highlighted: player.isPlaying

            checkable: true
            checked  : (panelAdd.item == barControls)

            icon          : st.icon24x24_addIn
            iconSourceSize: st.size24x24

            onPressed: gui.panelAddShow()
        }

        BorderVertical
        {
            id: borderB

            anchors.right: buttonSettings.left

            anchors.rightMargin: st.dp7
        }

        ButtonPushIcon
        {
            id: buttonSettings

            anchors.right: buttonGet.left
            anchors.top  : buttonGet.top

            width: st.dp44

            highlighted: player.isPlaying

            checkable: true
            checked  : panelSettings.isExposed

            icon          : st.icon24x24_tuning
            iconSourceSize: st.size24x24

            onPressed: panelSettings.toggleExpose()
        }

        ButtonPushIcon
        {
            id: buttonGet

            anchors.right: buttonFullScreen.left
            anchors.top  : buttonFullScreen.top

            width: st.dp44

            checkable: true
            checked  : panelGet.isExposed

            icon          : st.icon24x24_share
            iconSourceSize: st.size24x24

            onPressed: panelGet.toggleExpose()
        }

        ButtonPushIcon
        {
            id: buttonFullScreen

            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.rightMargin: st.dp11
            anchors.topMargin  : st.dp4

            width: st.dp44

            highlighted: window.fullScreen

            icon: (window.fullScreen) ? st.icon24x24_shrink
                                      : st.icon24x24_extend

            iconSourceSize: st.size24x24

            onClicked: gui.toggleFullScreen()
        }
    }

    BorderHorizontal { id: border }
}
