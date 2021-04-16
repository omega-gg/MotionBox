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
    id: itemNew

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int type: -1
    property int mode:  0

    //---------------------------------------------------------------------------------------------
    // Style

    property color colorA: st.buttonPiano_colorCheckA
    property color colorB: st.buttonPiano_colorCheckB

    //---------------------------------------------------------------------------------------------
    // Private

    property int pCount: 3

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias isFocused: lineEdit.isFocused

    property alias text: lineEdit.text

    //---------------------------------------------------------------------------------------------

    property alias button: button

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: st.itemList_height

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onModeChanged:
    {
        if (mode == 1)
        {
            type = 0;

            pCount = 2;
        }
        else if (mode != 2)
        {
            type = 0;

            pCount = 3;
        }
        else type = 2;
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function focus()
    {
        lineEdit.focus();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onKeyPressed (event) {}
    function onKeyReleased(event) {}

    //---------------------------------------------------------------------------------------------
    // Private

    function pSwitchA()
    {
        if (mode == 2) return;

        type = (type + 1) % pCount;
    }

    function pSwitchB()
    {
        if (mode == 2) return;

        type = (type - 1) % pCount;

        if (type < 0)
        {
            type = pCount - 1;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pGetIcon()
    {
        if (type == 1)
        {
            return st.icon16x16_feed;
        }
        else if (type == 2)
        {
            return st.icon16x16_folder;
        }
        else return st.icon16x16_playlist;
    }

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

        ButtonPianoIcon
        {
            id: button

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp32 + borderSizeWidth

            borderRight: borderSize

            enabled: (mode != 2)

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            icon: pGetIcon()

            iconSourceSize: st.size16x16

            itemIcon.opacity: 1.0

            onClicked:
            {
                if (mouse.button & Qt.LeftButton)
                {
                     pSwitchA();
                }
                else pSwitchB();
            }
        }

        LineEditBox
        {
            id: lineEdit

            anchors.left  : button.right
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Tab)
                {
                    event.accepted = true;

                    pSwitchA();
                }
                else if (event.key == Qt.Key_Backtab)
                {
                    event.accepted = true;

                    pSwitchB();
                }
                else itemNew.onKeyPressed(event);
            }

            function onKeyReleased(event)
            {
                if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
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
