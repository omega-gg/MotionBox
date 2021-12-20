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

MouseArea
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property variant pItem: null

    property int pMargin    : 8
    property int pMarginSize: pMargin * 2

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width : (pItem) ? pItem.width  + pMarginSize : 0
    height: (pItem) ? pItem.height + pMarginSize : 0

    z: 1

    visible: false

    acceptedButtons: Qt.NoButton

    dropEnabled: true

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    QML_EVENT onDragEntered: function(event) { event.accepted = true }

    onDragExited:
    {
        if (window.isDragging == false) return;

        var x = window.mouseX;
        var y = window.mouseY;

        if (x > window.borderLeft && x < window.width
            &&
            y > window.borderTop  && y < window.height)
        {
            collapse();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function setItem(item, margin /* 0 */)
    {
        if (pItem == item && pMargin == margin) return;

        pItem = item;

        if (margin == undefined)
        {
             pMargin = 8;
        }
        else pMargin = margin;

        if (item)
        {
            pApplyPosition();

            visible = true;
        }
        else visible = false;
    }

    function clearItem()
    {
        if (pItem == null) return;

        pItem = null;

        visible = false;
    }

    //---------------------------------------------------------------------------------------------

    function collapse()
    {
        clearItem();

        gui.restore();

        panelBrowse.collapse();
    }

    //---------------------------------------------------------------------------------------------

    function updatePosition()
    {
        if (pItem == null) pApplyPosition();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pApplyPosition()
    {
        var position = parent.mapFromItem(pItem, 0, 0);

        x = position.x - pMargin;
        y = position.y - pMargin;
    }
}
