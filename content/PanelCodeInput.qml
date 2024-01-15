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

Panel
{
    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias spacing: input.spacing

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: input.width + spacing * 2 + borderSizeWidth

    height: input.y + input.height + spacing + borderSizeHeight

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BarSettings
    {
        id: bar

        borderTop: 0

        text: qsTr("Enter Magic Number")
    }

    CodeInput
    {
        id: input

        anchors.top: bar.bottom

        anchors.topMargin: spacing

        anchors.horizontalCenter: parent.horizontalCenter

        color: st.baseLineEdit_colorText

        colorBackground: st.lineEdit_color

        onHide: areaPanel.hidePanel()

        onValidate:
        {
            var ip = "";

            for (var i = 0; i < 4; i++)
            {
                ip += (digits[i] - 100) + '.';
            }

            areaPanel.hidePanel();

            core.connectToHost("vbml:connect/" + ip.substring(0, ip.length - 1));
        }
    }
}
