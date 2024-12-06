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

BasePanelSettings
{
    id: panelSettingsAction

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias page: loader.item

    property alias button: button

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    loader: loader

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32 + borderSizeHeight

        borderTop: 0

        ButtonSettingsAction
        {
            id: button

            width: st.dp128

            text: getTitle()

            settings: getSettings()

            currentIndex: panelSettingsAction.currentIndex

            font.pixelSize: st.dp14

            //-------------------------------------------------------------------------------------
            // ButtonSettingsAction events

            function onSelect(index)
            {
                selectTab(index);
            }
        }
    }

    LoaderSlide
    {
        id: loader

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom
    }
}
