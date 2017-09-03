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

BarTitle
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property variant itemBefore: null
    property variant itemAfter : null

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

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

    height: st.dp32 + borderSizeHeight

    borderBottom: 0

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonPiano
    {
        id: buttonCancel

        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        width: st.dp100

        text: qsTr("Cancel")

        KeyNavigation.backtab: buttonOk
        KeyNavigation.tab    : itemAfter

        onClicked: ok()
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

        onClicked: cancel()
    }
}
