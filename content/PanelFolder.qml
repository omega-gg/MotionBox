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
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property real ratio: 3.0

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    default property alias content: content.data

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    anchors.top   : parent.top
    anchors.bottom: parent.bottom

    width:
    {
        var size = Math.round(parent.width / ratio);

        return Math.min(size, st.dp320 + border.size);
    }

    Rectangle
    {
        id: content

        anchors.fill: parent

        anchors.rightMargin: border.size

        color: st.panelFolder_color
    }

    BorderVertical
    {
        id: border

        anchors.right: parent.right
    }
}
