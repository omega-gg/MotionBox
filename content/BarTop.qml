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

    property alias buttonDiscover: buttonDiscover
    property alias buttonBrowse  : buttonBrowse

    property alias lineEditSearch: lineEditSearch

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

    z: (window.fullScreen) ? 1 : 0

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: isExpanded

        AnchorChanges
        {
            target: barTop

            anchors.top: undefined

            anchors.bottom: parent.top
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_normal }

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

        visible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

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
            id: buttonDiscover

            width: pWidth

            visible: (gui.isMini == false)

            enabled: false

            checkable: true
            checked  : panelDiscover.isExposed

            icon          : st.icon32x32_url
            iconSourceSize: st.size32x32

            text: qsTr("Discovery")

            font.pixelSize: st.dp14

            onPressed:
            {
                gui.restoreBars();

                panelDiscover.toggleExpose();
            }
        }

        ButtonPianoFull
        {
            id: buttonBrowse

            anchors.left: buttonDiscover.right

            width: panelLibrary.width - buttonDiscover.width

            visible: (gui.isMini == false)

            checkable: true

            checked: (gui.isExpanded == false && panelBrowse.isExposed)

            icon          : st.icon32x32_search
            iconSourceSize: st.size32x32

            text: qsTr("Browse")

            font.pixelSize: st.dp14

            onPressed:
            {
                if (gui.isExpanded)
                {
                    gui.restore();

                    panelBrowse.expose();
                }
                else panelBrowse.toggleExpose();
            }
        }

        LineEditSearch
        {
            id: lineEditSearch

            anchors.left: (gui.isMini) ? parent.left
                                       : buttonBrowse.right

            anchors.right: buttons.left
        }

        Item
        {
            id: buttons

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.rightMargin: st.dp16

            width: (gui.isMini) ? buttonExpand.width + buttonWall.width
                                : buttonExpand.width + buttonWall.width + buttonRelated.width

            states: State
            {
                name: "hidden"; when: panelTracks.isExpanded

                AnchorChanges
                {
                    target: buttons

                    anchors.left : parent.right
                    anchors.right: undefined
                }
            }

            transitions: Transition
            {
                AnchorAnimation { duration: st.duration_normal }
            }

            ButtonPianoIcon
            {
                id: buttonExpand

                anchors.right: buttonWall.left

                borderLeft: borderSize

                checkable: true

                checked: (gui.isMini) ? gui.isMicro
                                      : gui.isExpanded

                icon: (gui.isMini) ? st.icon24x24_goUp
                                   : st.icon24x24_expand

                iconSourceSize: st.size24x24

                onClicked:
                {
                    if (gui.isMini) gui.toggleMicro ();
                    else            gui.toggleExpand();
                }
            }

            ButtonPianoIcon
            {
                id: buttonWall

                anchors.right: (gui.isMini) ? parent.right
                                            : buttonRelated.left

                checkable: true
                checked  : wall.isExposed

                icon          : st.icon24x24_wall
                iconSourceSize: st.size24x24

                onClicked: gui.toggleWall()
            }

            ButtonPianoIcon
            {
                id: buttonRelated

                anchors.right: parent.right

                visible: (gui.isMini == false)

                checkable: true
                checked  : panelRelated.isExposed

                icon          : st.icon24x24_related
                iconSourceSize: st.size24x24

                onClicked: panelRelated.toggleExpose()
            }
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom
    }
}
