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

ButtonWideExtra
{
    id: buttonSettings

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* mandatory */ property variant settings

    property bool active: false

    property int marginY: 0

    property int currentIndex: -1
    property int activeIndex : -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    checkable: true
    checked  : (areaContextual.item == buttonSettings)

    itemText.horizontalAlignment: Text.AlignLeft

    itemText.color: st.getTextColor(isHighlighted, active)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onPressed: onPress()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showPanel()
    {
        areaContextual.showPanelSettings(buttonSettings, marginY, settings, currentIndex,
                                         activeIndex);
    }

    //---------------------------------------------------------------------------------------------
    // Events

    /* virtual */ function onPress() { showPanel() }

    /* virtual */ function onSelect(index) {}
}
