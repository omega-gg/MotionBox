//=================================================================================================
/*
    Copyright (C) 2015-2026 MotionBox authors united with omega. <http://omega.gg/about>

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

BaseContextualList
{
    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onItemClicked: function(id)
    {
        var item = areaContextual.item;

        if (item) item.onSelect(id);

        areaContextual.hidePanels();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    // NOTE: We make sure id(s) are equivalent to index(es).
    function load(settings, currentIndex, activeIndex)
    {
        var array = new Array;

        for (var i = 0; i < settings.length; i++)
        {
            var data = settings[i];

            var icon = data.icon;

            if (icon)
            {
                 array.push({ "id": i, "title": data.title, "icon": icon,
                              "iconSize": data.iconSize });
            }
            else array.push({ "id": i, "title": data.title });
        }

        currentPage.values = array;

        currentPage.selectedId = currentIndex;
        currentPage.currentId  = activeIndex;
    }
}
