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
    // Properties
    //---------------------------------------------------------------------------------------------
    // NOTE: We have to rely on these properties to avoid binding loops in BasePanelSettings.

    /* read */ property int contentWidth : st.dp192

    // NOTE: This is useful for BasePanelSettings.
    /* read */ property int contentHeight: list.contentHeight + button.height

    //---------------------------------------------------------------------------------------------
    // Private

    property int pRepeat: local.repeat

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: player.scanOutput = true

    onVisibleChanged:
    {
        if (visible)
        {
            timer.stop();

            player.scanOutput = true;
        }
        // NOTE: We want to clear the output(s) later in case we reopen this page right away.
        //       That being said, we don't want to scan at all time.
        else timer.restart();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.pageOutput_interval

        onTriggered: player.scanOutput = false
    }

    ScrollList
    {
        id: list

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: button.top

        model: ModelOutput { backend: player.backend }

        delegate: ComponentList
        {
            isCurrent: current

            text: name

            onClicked:
            {
                player.currentOutput = index;

                // NOTE: We want to hide the panel right away.
                panelOutput.collapse();
            }
        }
    }

    ButtonWide
    {
        id: button

        anchors.bottom: parent.bottom

        text: qsTr("Enter code")
    }
}
