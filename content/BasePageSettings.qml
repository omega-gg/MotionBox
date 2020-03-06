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
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property variant itemBefore: null
    property variant itemAfter : null

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias footer: footer

    property alias buttonCancel: buttonCancel
    property alias buttonOk    : buttonOk

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal cancel
    signal ok

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    acceptedButtons: Qt.NoButton

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            ok();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitle
    {
        id: footer

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        height: st.dp32 + borderSizeHeight

        borderBottom: 0

        ButtonPiano
        {
            id: buttonCancel

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp100

            text: qsTr("Cancel")

            KeyNavigation.backtab: buttonOk
            KeyNavigation.tab    : itemAfter

            onClicked: cancel()
        }

        ButtonPiano
        {
            id: buttonOk

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp100

            borderLeft : borderSize
            borderRight: 0

            text: qsTr("OK")

            KeyNavigation.backtab: itemBefore
            KeyNavigation.tab    : buttonCancel

            onClicked: ok()
        }
    }
}
