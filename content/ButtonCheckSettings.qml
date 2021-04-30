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

Rectangle
{
    id: buttonCheckSettings

    //---------------------------------------------------------------------------------------------
    // Alias
    //---------------------------------------------------------------------------------------------

    property int padding: st.buttonPiano_padding

    property alias borderSize: border.size

    property alias checked: button.checked

    property alias text: itemText.text

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal checkClicked

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    height: st.buttonPiano_height + borderSize

    color: st.labelRoundInfo_color

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    TextBase
    {
        id: itemText

        anchors.left  : parent.left
        anchors.right : button.left
        anchors.top   : parent.top
        anchors.bottom: border.top

        anchors.leftMargin: buttonCheckSettings.padding

        verticalAlignment: Text.AlignVCenter

        color: st.labelRoundInfo_colorText
    }

    ButtonCheck
    {
        id: button

        anchors.right: parent.right

        anchors.verticalCenter: itemText.verticalCenter

        enabled: parent.enabled

        onCheckClicked: buttonCheckSettings.checkClicked()
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom
    }
}
