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

BarWindow
{
    id: barWindow

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    buttonApplicationMaximum: buttonMini.x - st.dp32

    viewDrag.acceptedButtons: Qt.LeftButton | Qt.RightButton

    buttonMaximize.visible: (gui.isMini == false)

    onButtonPressed:
    {
        gui.restoreBars();

        panelApplication.toggleExpose();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function onMaximize()
    {
        gui.toggleMaximize();
    }

    function onDoubleClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
             gui.toggleBarMaximize();
        }
        else pToggleMini();
    }

    //---------------------------------------------------------------------------------------------

    function pToggleMini()
    {
        gui.toggleMini();

        window.checkLeave(st.duration_faster);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonPianoIcon
    {
        id: buttonMini

        anchors.right : barWindow.buttonIconify.left
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        borderLeft : borderSize
        borderRight: 0

        checkable: true
        checked  : gui.isMini

        icon: (gui.isMini) ? st.icon16x16_maxi
                           : st.icon16x16_mini

        iconSourceSize: st.size16x16

        onClicked: pToggleMini()
    }
}
