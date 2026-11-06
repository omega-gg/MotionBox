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

    property variant pList : null
    property int     pIndex: -1

    property string pSource

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    title: qsTr("Track")

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onItemClicked: function(id)
    {
        var playlist = pList.playlist;

        if (id == 0) // Add to ...
        {
            if (playlist.indexSelected(pIndex))
            {
                 areaContextual.showPanelAdd(0, playlist, -1);
            }
            else areaContextual.showPanelAdd(0, playlist, pIndex);

            return;
        }
        else if (id == 1) // More like this
        {
            areaContextual.searchMore(playlist, pSource, playlist.trackTitle(pIndex));
        }
        else if (id == 2) // VideoTag
        {
            gui.showTagTrack(playlist, pIndex);
        }
        else if (id == 3) // Open link
        {
            gui.openSource(pSource);
        }
        else if (id == 4) // Copy link
        {
            gui.applyLink(pSource);
        }
        else if (id == 5) // Sources
        {
            areaContextual.showPanelLinks(pSource);

            return;
        }
        else if (id == 6) // Reload
        {
            gui.reload(playlist, pIndex);
        }
        else if (id == 7) // Reset timeline
        {
            playlist.setTrackSource(pIndex, gui.clearContext(pSource));

            // NOTE: We reload the track to ensure that the duration is accurate.
            gui.reload(playlist, pIndex);

            currentTab.currentTime = -1;
        }
        else if (id == 8) // Save VBML
        {
            core.saveVbml(playlist.trackTitle(pIndex), playlist.trackVbml(pIndex));
        }
        else if (id == 9) // Set as Cover
        {
            var cover = playlist.trackCover(pIndex);

            if (cover != "")
            {
                playlist.cover = cover;
            }
        }
        else if (id == 10) // Remove
        {
            pList.removeTrack(pIndex, true);
        }
        else if (id == 11) // Download
        {
            areaContextual.showPanelDownload(playlist.trackData(pIndex));

            return;
        }

        areaContextual.hidePanels();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load(list, index)
    {
        pList  = list;
        pIndex = index;

        var playlist = list.playlist;

        var data = playlist.trackData(index);

        pSource = data.source;

        feed = data.feed;

        author = gui.getTrackAuthor(data.author, feed);

        var hasSource = (pSource != "");

        var array =
        [
            { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
              "title": qsTr("Add to ...") },

            { "id": 1, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
              "title": qsTr("More like this"), "enabled": (data.title != "") },

            { "id": 2, "icon": st.icon16x16_tag, "iconSize": st.size16x16,
              "title": qsTr("VideoTag") },

            { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
              "title": qsTr("Open link"), "enabled": hasSource },

            { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
              "title": qsTr("Copy link"), "enabled": hasSource },

            { "id": 5, "icon": st.icon16x16_list, "iconSize": st.size16x16,
              "title": qsTr("Sources"), "enabled": hasSource },

            { "id": 6, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
              "title": qsTr("Reload"), "enabled": hasSource },

            { "id": 7, "icon": st.icon16x16_recent, "iconSize": st.size16x16,
              "title": qsTr("Reset timeline"),
              "enabled": (hasSource && areaContextual.checkContext(pSource)) },

            { "id": 8, "icon": st.icon16x16_download, "iconSize": st.size16x16,
              "title": qsTr("Save VBML") },

            { "id": 11, "icon": st.icon16x16_download, "iconSize": st.size16x16,
              "title": qsTr("Download"), "enabled": areaContextual.checkDownload(data) }
        ];

        if (playlist.isLocal)
        {
            array.push({ "id":  9, "title": qsTr("Set as Cover") },
                       { "id": 10, "title": qsTr("Remove Track") });
        }

        currentPage.values = array;
    }

    function browseFeed()
    {
        gui.browseFeedTrack(feed, pSource);
    }
}
