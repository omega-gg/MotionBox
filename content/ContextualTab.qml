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

    // NOTE: The panel shows the author under the list.
    /* read */ property string author
    /* read */ property string feed

    //---------------------------------------------------------------------------------------------
    // Private

    property variant pTab: null

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    title: qsTr("Track")

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onItemClicked: function(id)
    {
        if (id == 0) // Add to ...
        {
            var playlist = pTab.playlist;

            if (playlist == null)
            {
                playlistTemp.clearTracks();

                pTab.copyTrackTo(playlistTemp);

                areaContextual.showPanelAdd(0, playlistTemp, 0);
            }
            else areaContextual.showPanelAdd(0, playlist, pTab.trackIndex);

            return;
        }
        else if (id == 1) // More like this
        {
            areaContextual.searchMore(pTab.playlist, pTab.source, pTab.title);
        }
        else if (id == 2) // VideoTag
        {
            gui.showTagTab();
        }
        else if (id == 3) // Open link
        {
            gui.openSource(pTab.source);
        }
        else if (id == 4) // Copy link
        {
            gui.applyLink(pTab.source);
        }
        else if (id == 5) // Sources
        {
            areaContextual.showPanelLinks(pTab.source);

            return;
        }
        else if (id == 6) // Reload
        {
            gui.reload(pTab.playlist, pTab.trackIndex);
        }
        else if (id == 7) // Reset timeline
        {
            player.stop();

            pTab.source = gui.clearContext(pTab.source);

            // NOTE: We reload the track to ensure that the duration is accurate.
            gui.reloadTab(pTab);

            currentTab.currentTime = -1;

            player.reloadSource();
        }
        else if (id == 8) // Save VBML
        {
            core.saveVbml(pTab.title, pTab.toVbml());
        }
        else if (id == 9) // Close
        {
            gui.closeTrack();
        }

        areaContextual.hidePanels();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load(tab)
    {
        pTab = tab;

        var isValid = tab.isValid;

        var hasSource = false;

        var hasContext = false;

        if (isValid)
        {
            var data = tab.trackData;

            feed = data.feed;

            author = gui.getTrackAuthor(data.author, feed);

            hasSource = (data.source != "");

            // NOTE: Reset timeline only needs a context when there's a source.
            hasContext = (hasSource == false || areaContextual.checkContext(tab.source));
        }

        currentPage.values =
        [
            { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
              "title": qsTr("Add to ..."), "enabled": isValid },

            { "id": 1, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
              "title": qsTr("More like this"), "enabled": (isValid && tab.title != "") },

            { "id": 2, "icon": st.icon16x16_tag, "iconSize": st.size16x16,
              "title": qsTr("VideoTag"), "enabled": isValid },

            { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
              "title": qsTr("Open link"), "enabled": hasSource },

            { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
              "title": qsTr("Copy link"), "enabled": hasSource },

            { "id": 5, "icon": st.icon16x16_list, "iconSize": st.size16x16,
              "title": qsTr("Sources"), "enabled": hasSource },

            { "id": 6, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
              "title": qsTr("Reload"), "enabled": isValid },

            { "id": 7, "icon": st.icon16x16_recent, "iconSize": st.size16x16,
              "title": qsTr("Reset timeline"), "enabled": hasContext },

            { "id": 8, "icon": st.icon16x16_download, "iconSize": st.size16x16,
              "title": qsTr("Save VBML"), "enabled": isValid },

            { "id": 9, "title": qsTr("Close Track"), "enabled": isValid }
        ];
    }

    function browseFeed()
    {
        gui.browseFeed(pTab);
    }
}
