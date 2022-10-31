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

ButtonPianoAction
{
    id: buttonSettingsAction

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* mandatory */ property variant settings

    property int currentIndex: -1
    property int activeIndex : -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    borderRight: 0

    // NOTE: We disable the button when we have a single source.
    enabled: (settings.length > 1)

    checkable: true
    checked  : (areaContextual.item == buttonSettingsAction)

    // NOTE: We make sure the text is always opaque even when the item is disabled.
    itemText.opacity: 1.0

    iconAction.visible: enabled

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onPressed: onPress()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showPanel()
    {
        areaContextual.showPanelSettings(buttonSettingsAction, 0, settings, currentIndex,
                                         activeIndex);
    }

    //---------------------------------------------------------------------------------------------
    // Events

    /* virtual */ function onPress() { showPanel() }

    /* virtual */ function onSelect(index) {}
}
