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
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property string pSource

    property int pCount: -1
    property int pIndex: -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    sources: [ Qt.resolvedUrl("PageSubtitles.qml") ]

    titles: [ qsTr("Subtitles") ]

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: player

        /* QML_CONNECTION */ function onSubtitlesChanged()
        {
            var subtitles = player.subtitles;

            var source = controllerPlaylist.cleanSource(player.source);

            if (pSource == source)
            {
                if (pIndex == -1)
                {
                    pUpdateView();

                    return;
                }

                if (subtitles.length != pCount)
                {
                    pCount = subtitles.length;

                    if (pCount)
                    {
                        pIndex = 0;

                        applySubtitle(subtitles[0], 0);
                    }
                    else applySubtitle("", -1);
                }
                else applySubtitle(subtitles[pIndex], pIndex);

                pUpdateView();

                return;
            }

            pSource = source;

            pCount = subtitles.length;

            if (pCount)
            {
                var id = controllerNetwork.extractFragmentValue(player.source, "sid");

                if (id > 0 && id < pCount)
                {
                    pIndex = id;
                }
                else pIndex = 0;

                applySubtitle(subtitles[pIndex], pIndex);
            }
            else applySubtitle("", -1);

            pUpdateView();
        }
    }
    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function applySubtitle(source, id)
    {
        playerTab.subtitle = source;

        gui.updateTrackSubtitle(id);
    }

    function clearSubtitle()
    {
        if (indexCurrent == 0 && page) page.clearSubtitle();
    }

    function clearIndex() { pIndex = -1 }

    //---------------------------------------------------------------------------------------------
    // BasePanelSettings reimplementation

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionGetExpose)) return;

        gui.panelAddHide();

        panelSettings.collapse();
        panelOutput  .collapse();

        loadPage();

        isExposed = true;

        z = 1;

        panelSettings.z = 0;
        panelOutput  .z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionGetCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }
}
