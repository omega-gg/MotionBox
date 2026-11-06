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

    Component.onCompleted:
    {
        currentPage.values =
        [
            { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
              "title": qsTr("Open File") },

            { "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
              "title": qsTr("Open Folder") },

            { "id": 2, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
              "title": qsTr("Update Backends") },

            { "id": 3, "title": qsTr("Reset Backends") }
        ];
    }

    /* QML_EVENT */ onItemClicked: function(id)
    {
        if (id == 0) // Open File
        {
            setSelectedId(0);

//#QT_4
            gui.browseFile();
//#ELSE
            // NOTE: We call this later to avoid a crash when the ContextualItem gets deleted.
            Qt.callLater(gui.browseFile);
//#END
        }
        else if (id == 1) // Open Folder
        {
            setSelectedId(1);

//#QT_4
            gui.browseFolder();
//#ELSE
            // NOTE: We call this later to avoid a crash when the ContextualItem gets deleted.
            Qt.callLater(gui.browseFolder);
//#END
        }
        else if (id == 2) // Update Backends
        {
            core.updateBackends();
        }
        else if (id == 3) // Reset Backends
        {
            core.resetBackends();
        }

        areaContextual.hidePanels();
    }
}
