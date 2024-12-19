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

    - Private License Usage:
    MotionBox licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and MotionBox authors. For further information
    contact us at contact@omega.gg.
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

    /* read */ property bool isChannel: player.trackIsChannel

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonPlay: buttonPlay

    property alias buttonPrevious: buttonPrevious
    property alias buttonNext    : buttonNext

    property alias buttonSubtitles : buttonSubtitles
    property alias buttonSettings  : buttonSettings
    property alias buttonOutput    : buttonOutput
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
    // Children
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

        ButtonPianoIcon
        {
            id: buttonPlay

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            enabled: (player.source != "")

            highlighted: (enabled && player.isPlaying)

            icon: (player.isPlaying) ? st.icon16x16_pause
                                     : st.icon16x16_play

            iconSourceSize: st.size16x16

            onClicked:
            {
                if (player.isPlaying)
                {
                    gui.pause();
                }
                else player.play();
            }
        }

        ButtonPushLeftIcon
        {
            id: buttonPrevious

            anchors.left: buttonPlay.right
            anchors.top : buttonPlay.top

            anchors.leftMargin: st.dp6

            width : st.dp48
            height: width

            margins: st.dp6

            showBorder: false

            enabled: player.hasPreviousTrack

            highlighted: (enabled && player.isPlaying)

            icon          : st.icon12x12_backward
            iconSourceSize: st.size12x12

            onClicked: player.setPreviousTrack()
        }

        ButtonPushRightIcon
        {
            id: buttonNext

            anchors.left: buttonPrevious.right
            anchors.top : buttonPrevious.top

            width : st.dp48
            height: width

            margins: st.dp6

            showBorder: false

            enabled: player.hasNextTrack

            highlighted: (enabled && player.isPlaying)

            icon: (player.shuffle) ? st.icon16x16_shuffle
                                   : st.icon12x12_forward

            iconSourceSize: (player.shuffle) ? st.size16x16
                                             : st.size12x12

            acceptedButtons: (player.isPlaying) ? Qt.LeftButton | Qt.RightButton
                                                : Qt.LeftButton

            /* QML_EVENT */ onClicked: function(mouse)
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

        SliderVolume
        {
            id: sliderVolume

            anchors.left: buttonNext.right
            anchors.top : parent.top

            anchors.leftMargin: st.dp4
            anchors.topMargin : st.dp8

            width: st.dp150

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
            anchors.left  : sliderStream.left
            anchors.right : sliderStream.right
            anchors.bottom: sliderStream.top

            anchors.bottomMargin: -st.dp8

            slider: sliderStream
        }

        SliderStream
        {
            id: sliderStream

            anchors.left : borderA.right
            anchors.right: buttonTag.left
            anchors.top  : parent.top

            anchors.leftMargin : st.dp7
            anchors.rightMargin: st.dp2
            anchors.topMargin  : st.dp8

            height: st.sliderStream_height

            active: player.isPlaying

            live: (active && isChannel)

            currentTime:
            {
                // NOTE: There's no seek bar on a channel.
                if (isChannel)
                {
                    return -1;
                }
                else if (player.hasStarted && enabled)
                {
                    return player.currentTime;
                }
                else return player.trackCurrentTime;
            }

            duration:
            {
                // NOTE: There's no seek bar on a channel.
                if (isChannel)
                {
                    return -1;
                }
                else if (player.hasStarted && player.duration != -1)
                {
                    return player.duration;
                }
                else return player.trackDuration;
            }

            progress: player.progress

            onHandleReleased:
            {
                if (player.hasStarted == false)
                {
                    player.play();
                }

                // NOTE: When clicking on the slider we try to interpolate a chapter position.
                if (slider.isClicked())
                {
                     player.seek(st.getChapterTime(sliderStream, st.dp4));
                }
                else player.seek(slider.value);

                panelTag.collapse();
            }
        }

        ButtonPushIcon
        {
            id: buttonTag

            anchors.right: borderB.left
            anchors.top  : buttonSettings.top

            anchors.rightMargin: st.dp7

            width : st.dp44
            height: width

            checkable: true
            checked  : panelTag.isExposed

            icon          : st.icon16x16_tag
            iconSourceSize: st.size16x16

            onPressed: panelTag.toggleExpose()
        }

        BorderVertical
        {
            id: borderB

            anchors.right: buttonSubtitles.left

            anchors.rightMargin: st.dp7
        }

        ButtonPushLeftIcon
        {
            id: buttonSubtitles

            anchors.right: buttonSettings.left
            anchors.top  : buttonSettings.top

            width : st.dp44
            height: width

            showBorder: false

            checkable: true
            checked  : panelSubtitles.isExposed

            icon          : st.icon20x20_subtitles
            iconSourceSize: st.size20x20

            onPressed: panelSubtitles.toggleExpose()
        }

        ButtonPushCenterIcon
        {
            id: buttonSettings

            anchors.right: buttonOutput.left
            anchors.top  : buttonOutput.top

            width : st.dp38
            height: st.dp44

            showBorder: false

            checkable: true
            checked  : panelSettings.isExposed

            icon          : st.icon20x20_settings
            iconSourceSize: st.size20x20

            onPressed: panelSettings.toggleExpose()
        }

        ButtonPushCenterIcon
        {
            id: buttonOutput

            anchors.right: buttonFullScreen.left
            anchors.top  : buttonFullScreen.top

            width : st.dp38
            height: st.dp44

            showBorder: false

            highlighted: player.hasOutput

            checkable: true
            checked  : panelOutput.isExposed

            icon          : st.icon24x24_output
            iconSourceSize: st.size24x24

            onPressed: panelOutput.toggleExpose()
        }

        ButtonPushRightIcon
        {
            id: buttonFullScreen

            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.rightMargin: st.dp12
            anchors.topMargin  : st.dp2

            width : st.dp44
            height: width

            showBorder: false

            highlighted: window.fullScreen

            icon: (window.fullScreen) ? st.icon20x20_shrink
                                      : st.icon20x20_extend

            iconSourceSize: st.size20x20

            onClicked: gui.toggleFullScreen()
        }
    }

    BorderHorizontal { id: border }
}
