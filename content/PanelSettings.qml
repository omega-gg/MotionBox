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
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    sources: [ Qt.resolvedUrl("PageSettingsVideo.qml"),
               Qt.resolvedUrl("PageSettingsMain.qml"),
               Qt.resolvedUrl("PageConsole.qml"),
               Qt.resolvedUrl("PageAboutMain.qml") ]

    titles: [ qsTr("Video"), qsTr("General"), qsTr("Console"), qsTr("About") ]

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionSettingsExpose)) return;

        gui.panelAddHide();

        panelGet.collapse();

        loadPage();

        isExposed = true;

        z = 1;

        panelGet.z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionSettingsCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }
}
