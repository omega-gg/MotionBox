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

Item
{
    id: itemNew

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int type: 0

    //---------------------------------------------------------------------------------------------
    // Style

    property color colorA: st.buttonPianoEdit_colorPressA
    property color colorB: st.buttonPianoEdit_colorPressB

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias isFocused: lineEdit.isFocused

    property alias text: lineEdit.text

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: st.itemList_height

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function focus()
    {
        lineEdit.focus();
    }

    //---------------------------------------------------------------------------------------------

    function switchType()
    {
        local.typePlaylist = (local.typePlaylist + 1) % 2;
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onKeyPressed (event) {}
    function onKeyReleased(event) {}

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: border.top

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: colorA }
            GradientStop { position: 1.0; color: colorB }
        }

        Icon
        {
            anchors.fill: button

            visible: (type == 1)

            source    : st.icon32x32_folder
            sourceSize: st.size32x32

            iconStyle: Sk.IconRaised
        }

        ButtonPianoIcon
        {
            id: button

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp32 + borderSizeWidth

            visible: (type != 1)

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            icon: (local.typePlaylist) ? st.icon32x32_feed
                                       : st.icon32x32_playlist

            onClicked: switchType()
        }

        LineEditClear
        {
            id: lineEdit

            anchors.left  : button.right
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            itemFocus.visible: false

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Tab)
                {
                    event.accepted = true;

                    if (type == 0) switchType();
                }
                else itemNew.onKeyPressed(event);
            }

            function onKeyReleased(event)
            {
                if (event.key == Qt.Key_Tab)
                {
                    event.accepted = true;
                }
                else itemNew.onKeyReleased(event);
            }
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom
    }
}