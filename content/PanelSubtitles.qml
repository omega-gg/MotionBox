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

PanelSettingsAction
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
            var subtitles = player.subtitlesData;

            pCount = subtitles.length;

            if (pCount == 0)
            {
                applySubtitle("", -1);

                pUpdateView();

                return;
            }

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
                    pIndex = 0;

                    applySubtitle(subtitles[0].source, 0);
                }
                else applySubtitle(subtitles[pIndex].source, pIndex);

                pUpdateView();

                return;
            }

            pSource = source;

            var id = controllerNetwork.extractFragmentValue(player.source, "sid");

            if (id != "" && id >= 0 && id < pCount)
            {
                pIndex = id;

                applySubtitle(subtitles[id].source, id);
            }
            else
            {
                pIndex = 0;

                for (var i = 0; i < pCount; i++)
                {
                    var subtitle = subtitles[i];

                    // NOTE: Do not select auto-generated subtitles by default.
                    if (subtitle.title.indexOf("(auto-generated)") != -1) continue;

                    applySubtitle(subtitle.source, i);

                    pUpdateView();

                    return;
                }

                applySubtitle("", -1);
            }

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
        if (currentIndex == 0 && page) page.clearSubtitle();
    }

    function clearIndex() { pIndex = -1 }

    //---------------------------------------------------------------------------------------------
    // BasePanelSettings reimplementation

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionSubtitlesExpose)) return;

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
        if (isExposed == false || actionCue.tryPush(gui.actionSubtitlesCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateView()
    {
        if (currentIndex != 0 || page == null) return

        page.updateView();
    }
}
