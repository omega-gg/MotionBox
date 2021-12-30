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

Item
{
    id: barTop

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExpanded: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonBackward: buttonBackward
    property alias buttonForward : buttonForward

    property alias lineEditSearch: lineEditSearch

    property alias buttonBrowse : buttonBrowse
    property alias buttonExpand : buttonExpand
    property alias buttonWall   : buttonWall
    property alias buttonRelated: buttonRelated

    property alias border: border

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right
    anchors.top  : parent.top

    anchors.topMargin: barWindow.height

    height: st.dp32 + border.size

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "hiddenFullScreen"; when: (window.fullScreen && isExpanded)

            AnchorChanges
            {
                target: barTop

                anchors.top: undefined

                anchors.bottom: parent.top
            }
        },
        State
        {
            name: "hidden"; when: isExpanded

            AnchorChanges
            {
                target: barTop

                anchors.top: undefined

                anchors.bottom: barWindow.bottom
            }
        }
    ]

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
                script:
                {
                    if (isExpanded == false) return;

                    if (window.fullScreen) barWindow.visible = false;

                    visible = false;
                }
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

        barWindow.visible = true;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_normal
    }

    Rectangle
    {
        id: bar

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: border.top

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
            id: buttonBackward

            enabled: (currentTab != null && currentTab.hasPreviousBookmark)

            highlighted: (enabled && player.isPlaying)

            icon          : st.icon16x16_goBackward
            iconSourceSize: st.size16x16

            onClicked:
            {
                //panelDiscover.collapse();

                currentTab.setPreviousBookmark();
            }
        }

        ButtonPianoIcon
        {
            id: buttonForward

            anchors.left: buttonBackward.right

            enabled: (currentTab != null && currentTab.hasNextBookmark)

            highlighted: (enabled && player.isPlaying)

            icon          : st.icon16x16_goForward
            iconSourceSize: st.size16x16

            onClicked:
            {
                //panelDiscover.collapse();

                currentTab.setNextBookmark();
            }
        }

        LineEditSearch
        {
            id: lineEditSearch

            anchors.left : buttonForward.right
            anchors.right: buttons.left
        }

        Item
        {
            id: buttons

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.rightMargin: st.dp16

            width: buttonBrowse.width + buttonExpand.width + buttonWall.width + buttonRelated.width

            ButtonPianoIcon
            {
                id: buttonBrowse

                anchors.right: buttonExpand.left

                borderLeft: borderSize

                checkable: true

                checked: (timer.running || (gui.isExpanded == false && panelBrowse.isExposed))

                icon          : st.icon20x20_search
                iconSourceSize: st.size20x20

                onPressed:
                {
                    if (gui.isExpanded)
                    {
                        timer.start();

                        gui.restore();

                        panelBrowse.expose();
                    }
                    else panelBrowse.toggleExpose();
                }
            }

            ButtonPianoIcon
            {
                id: buttonExpand

                anchors.right: buttonWall.left

                checkable: true

                checked: gui.isExpanded

                icon          : st.icon20x20_expand
                iconSourceSize: st.size20x20

                onPressed: gui.toggleExpand()
            }

            ButtonPianoIcon
            {
                id: buttonWall

                anchors.right: buttonRelated.left

                checkable: true
                checked  : wall.isExposed

                icon          : st.icon20x20_wall
                iconSourceSize: st.size20x20

                onPressed:
                {
                    if (panelTracks.isExpanded)
                    {
                        panelTracks.restore();

                        gui.exposeWall();
                    }
                    else gui.toggleWall();
                }
            }

            ButtonPianoIcon
            {
                id: buttonRelated

                anchors.right: parent.right

                checkable: true
                checked  : panelRelated.isExposed

                icon          : st.icon20x20_related
                iconSourceSize: st.size20x20

                onPressed:
                {
                    if (panelTracks.isExpanded)
                    {
                        panelTracks.restore();

                        panelRelated.expose();
                    }
                    else panelRelated.toggleExpose();
                }
            }
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom
    }
}
