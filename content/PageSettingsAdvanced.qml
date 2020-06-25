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
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: bar.y + bar.height + st.dp50

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: slider.value = player.speed

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitleSmall
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Playback speed")

            font.pixelSize: st.dp12
        }
    }

    Slider
    {
        id: slider

        anchors.left : parent.left
        anchors.right: buttonCheck.left
        anchors.top  : bar.bottom

        anchors.leftMargin: st.dp5
        anchors.topMargin : st.dp12

        minimum: 0.0
        maximum: 2.0

        onValueChanged:
        {
            var speed = value.toFixed(1);

            if (player.speed == speed) return;

            if (speed < 1.0)
            {
                speed = 0.5 + speed * 0.5;

                player.speed = speed.toFixed(1);

                buttonCheck.checked = true;
            }
            else
            {
                player.speed = speed;

                if (speed == 1.0)
                {
                     buttonCheck.checked = false;
                }
                else buttonCheck.checked = true;
            }
        }
    }

    ButtonCheckLabel
    {
        id: buttonCheck

        anchors.right: parent.right
        anchors.top  : bar.bottom

        anchors.rightMargin: st.dp5
        anchors.topMargin  : st.dp5

        enabled: checked
        checked: (player.speed != 1.0)

        text: player.speed.toFixed(1)

        onCheckClicked:
        {
            if (checked) return;

            slider.value = 1.0;
        }
    }
}
