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

    sources: [ Qt.resolvedUrl("PageApplication.qml"),
               Qt.resolvedUrl("PageVideo.qml"),
               Qt.resolvedUrl("PageAdvanced.qml"),
               Qt.resolvedUrl("PageSettingsProxy.qml"),
               Qt.resolvedUrl("PageSettingsTorrent.qml"),
               Qt.resolvedUrl("PageConsole.qml"),
               Qt.resolvedUrl("PageAbout.qml") ]

    titles: [ qsTr("Application"), qsTr("Player"), qsTr("Advanced"), qsTr("Proxy"),
              qsTr("Torrent"), qsTr("Console"), qsTr("About") ]

    currentIndex: 1

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionSettingsExpose)) return;

        gui.panelAddHide();

        panelSubtitles.collapse();
        panelOutput   .collapse();

        loadPage();

        isExposed = true;

        z = 1;

        panelSubtitles.z = 0;
        panelOutput   .z = 0;

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
