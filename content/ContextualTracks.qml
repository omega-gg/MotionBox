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
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property variant pList: null

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onItemClicked: function(id)
    {
        if (id == 0) // Add to ...
        {
            areaContextual.showPanelAdd(0, pList.playlist, -1);

            return;
        }
        else if (id == 1) // Remove selected
        {
            pList.removeSelected(true);
        }

        areaContextual.hidePanels();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load(list)
    {
        pList = list;

        title = list.playlist.selectedCount + " " + qsTr("Tracks");

        var array = [ { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                        "title": qsTr("Add to ...") } ];

        if (gui.listPlaylist == list)
        {
            array.push({ "id": 1, "type": ContextualPage.ItemConfirm,
                         "title": qsTr("Remove") + " " + title });
        }

        currentPage.values = array;
    }
}
