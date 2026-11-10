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

    property variant pList : null
    property int     pIndex: -1

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onItemClicked: function(id)
    {
        var folder = pList.folder;

        if (id == 0) // Play
        {
            folder.loadCurrentIndex(pIndex, true);

            gui.playItem(folder, pIndex);

            folder.currentItem.selectCurrentTrack();
        }
        else if (id == 1) // Add to ...
        {
            areaContextual.showPanelAdd(1, folder, pIndex);

            return;
        }
        else if (id == 2) // More like this
        {
            areaContextual.searchMore(null, folder.itemSource(pIndex), folder.itemTitle(pIndex));
        }
        else if (id == 3) // VideoTag
        {
            gui.showTagPlaylist(folder, pIndex);
        }
        else if (id == 4) // Open link
        {
            gui.openSource(folder.itemSource(pIndex));
        }
        else if (id == 5) // Copy link
        {
            gui.applyLink(folder.itemSource(pIndex));
        }
        else if (id == 6) // Reload
        {
            folder.loadCurrentIndex(pIndex, true);

            var item = folder.currentItem;

            if (item.source)
            {
                item.reloadQuery();
            }
            else core.reload(item.label);
        }
        else if (id == 7) // Rename
        {
            pList.renameItem(pIndex);
        }
        else if (id == 8) // Move to ...
        {
            areaContextual.showPanelAdd(2, folder, pIndex);

            return;
        }
        else if (id == 9) // Save VBML
        {
            var playlist = gui.createItemAt(folder, pIndex);

            core.saveVbml(playlist.title, playlist.toVbml(2));

            playlist.tryDelete();
        }
        else if (id == 10) // Remove
        {
            pList.removeItem(pIndex, true);

            if (folder == feeds && pIndex == 0 && history)
            {
                history.tryDelete();

                history = null;
            }
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

        var folder = list.folder;

        var type = core.itemType(folder, index);

        var isPlaylist = (type == LibraryItem.Playlist || type == LibraryItem.PlaylistFeed);

        var isFeed = (type == LibraryItem.PlaylistFeed);

        var isLocal = folder.itemIsLocal(index);

        if      (isFeed)     title = qsTr("Feed");
        else if (isPlaylist) title = qsTr("Playlist");
        else                 title = qsTr("Folder");

        var name = (isFeed) ? "Feed" : "Playlist";

        var array = new Array;

        if (folder.isFolderBase && isPlaylist)
        {
            array.push(pGetItem(0, st.icon16x16_play, st.size16x16, qsTr("Play")));

            if (isLocal)
            {
                array.push(pGetItem(3, st.icon16x16_tag, st.size16x16, qsTr("VideoTag")));

                if (folder == feeds)
                {
                    var label = folder.itemLabel(index);

                    if (label == "suggest" || label == "recent" || label == "interactive"
                        ||
                        label == "downloads")
                    {
                        array.push(pGetItem(6, st.icon16x16_refresh, st.size16x16, qsTr("Reload")));
                    }
                }
                else array.push({ "id": 7, "title": qsTr("Rename")      },
                                { "id": 8, "title": qsTr("Move to ...") });

                array.push(pGetItem(9, st.icon16x16_download, st.size16x16, qsTr("Save VBML")),

                           { "id": 10, "type": ContextualPage.ItemConfirm,
                             "title": "Delete " + name });
            }
            else
            {
                if (folder == feeds)
                {
                    array.push(pGetItem(1, st.icon18x18_addIn, st.size18x18, qsTr("Add to ...")));
                }

                pPushLinks(array);

                if (folder != feeds)
                {
                    array.push({ "id": 8, "title": qsTr("Move to ...") });
                }

                array.push(pGetItem(9, st.icon16x16_download, st.size16x16, qsTr("Save VBML")),

                           { "id": 10, "type": ContextualPage.ItemConfirm,
                             "title": "Remove " + name });
            }
        }
        else if (folder.isFolderBase) // Folder
        {
            array.push({ "id": 7, "title": qsTr("Rename") },

                       { "id": 10, "type": ContextualPage.ItemConfirm,
                         "title": qsTr("Delete Folder") });
        }
        else if (isPlaylist)
        {
            array.push(pGetItem(0, st.icon16x16_play,  st.size16x16, qsTr("Play")),
                       pGetItem(1, st.icon18x18_addIn, st.size18x18, qsTr("Add to ...")));

            if (isLocal == false)
            {
                pPushLinks(array);

                array.push(pGetItem(9, st.icon16x16_download, st.size16x16, qsTr("Save VBML")));
            }
        }
        else if (isLocal == false) // Folder
        {
            pPushLinks(array);
        }

        currentPage.values = array;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pPushLinks(array)
    {
        array.push(pGetItem(2, st.icon16x16_addBold,  st.size16x16, qsTr("More like this")),
                   pGetItem(3, st.icon16x16_tag,      st.size16x16, qsTr("VideoTag")),
                   pGetItem(4, st.icon16x16_external, st.size16x16, qsTr("Open link")),
                   pGetItem(5, st.icon16x16_link,     st.size16x16, qsTr("Copy link")),
                   pGetItem(6, st.icon16x16_refresh,  st.size16x16, qsTr("Reload")));
    }

    function pGetItem(id, icon, iconSize, title)
    {
        return { "id": id, "icon": icon, "iconSize": iconSize, "title": title };
    }
}
