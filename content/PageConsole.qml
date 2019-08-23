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
    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property bool pAtBottom: true

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    height: st.dp220

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        onLogChanged: itemText.text = core.log
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ScrollArea
    {
        anchors.fill: parent

        contentHeight: itemText.y + itemText.height

        onContentHeightChanged: if (pAtBottom) scrollToBottom()

        onValueChanged: pAtBottom = atBottom

        BaseTextEdit
        {
            id: itemText

            anchors.left : parent.left
            anchors.right: parent.right
            anchors.top  : parent.top

            text: core.log

            textFormat: Text.RichText

            wrapMode: Text.Wrap

            color      : st.text_color
            colorCursor: color

            font.family   : "consolas"
            font.pixelSize: st.dp14
            font.bold     : false
        }
    }
}
