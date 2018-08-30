//=================================================================================================
/*
    Copyright (C) 2015-2017 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick 1.0
import Sky     1.0

AreaContextual
{
    id: areaContextual

    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property variant pItem : null
    property int     pIndex: -1

    property variant pData: null

    property string pSource
    property string pAuthor
    property string pFeed

    property bool pButtonsVisible: (currentPage == pageTrack || currentPage == pageTab)

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias currentPage: listContextual.currentPage

    //---------------------------------------------------------------------------------------------

    property alias panelContextual: panelContextual
    property alias panelAdd       : panelAdd

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    z: 1

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pShowPanelAdd()
    {
        if (gui.isMini)
        {
             areaContextual.showPanelMargins(panelAdd, barTop, st.dp2, -st.dp2);
        }
        else areaContextual.showPanel(panelAdd,
                                      panelContextual.item,
                                      panelContextual.position,
                                      panelContextual.posX,
                                      panelContextual.posY,
                                      panelContextual.marginX,
                                      panelContextual.marginY,
                                      panelContextual.isCursorChild);
    }

    //---------------------------------------------------------------------------------------------

    function pCheckPlay(folder, index)
    {
        if (folder.currentIndex != index)
        {
            pageFolder.setItemVisible(1, false);

            return;
        }

        var item = folder.currentItem;

        if (item.isPlaylist && item.count)
        {
             pageFolder.setItemVisible(1, true);
        }
        else pageFolder.setItemVisible(1, false);
    }

    //---------------------------------------------------------------------------------------------

    function pBrowse(query)
    {
        gui.restore();

        panelBrowse.browse(query);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    PanelContextual
    {
        id: panelContextual

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        minimumWidth : st.dp160
        minimumHeight: st.dp32

        preferredWidth : st.dp160
        preferredHeight: pGetPreferredHeight()

        //-----------------------------------------------------------------------------------------
        // Events
        //-----------------------------------------------------------------------------------------

        onIsActiveChanged:
        {
            if (isActive)
            {
                listContextual.focus();
            }
            else if (currentPage)
            {
                currentPage.currentId = -1;
            }
        }

        //-----------------------------------------------------------------------------------------
        // Functions
        //-----------------------------------------------------------------------------------------

        function loadPageFolder(list, index)
        {
            pItem  = list;
            pIndex = index;

            var folder = list.folder;

            var type = core.itemType(folder, index);

            if (folder.isFolderBase)
            {
                if (type == LibraryItem.Playlist)
                {
                    pageFolder.set(0, { "title": qsTr("Playlist") });

                    pCheckPlay(folder, index);

                    pageFolder.setItemVisible(5, true);

                    if (folder.itemIsLocal(index))
                    {
                        pageFolder.set(6, { "title": qsTr("Delete Playlist") });

                        pageFolder.setItemVisible(3, false);
                        pageFolder.setItemVisible(4, true);
                    }
                    else
                    {
                        pageFolder.set(6, { "title": qsTr("Remove Playlist") });
                        pageFolder.set(3, { "title": qsTr("Webpage")         });

                        pageFolder.setItemVisible(3, true);
                        pageFolder.setItemVisible(4, false);
                    }
                }
                else if (type == LibraryItem.PlaylistFeed)
                {
                    pageFolder.set(0, { "title": qsTr("Feed") });

                    pCheckPlay(folder, index);

                    pageFolder.setItemVisible(5, true);

                    if (folder.itemIsLocal(index))
                    {
                        pageFolder.set(6, { "title": qsTr("Delete Feed") });

                        pageFolder.setItemVisible(3, false);
                        pageFolder.setItemVisible(4, true);
                    }
                    else
                    {
                        pageFolder.set(6, { "title": qsTr("Remove Feed") });
                        pageFolder.set(3, { "title": qsTr("Webpage")     });

                        pageFolder.setItemVisible(3, true);
                        pageFolder.setItemVisible(4, false);
                    }
                }
                else
                {
                    pageFolder.set(0, { "title": qsTr("Folder")        });
                    pageFolder.set(6, { "title": qsTr("Delete Folder") });

                    pageFolder.setItemVisible(1, false);
                    pageFolder.setItemVisible(3, false);
                    pageFolder.setItemVisible(4, true);
                    pageFolder.setItemVisible(5, false);
                }

                pageFolder.setItemVisible(2, false);
                pageFolder.setItemVisible(6, true);
            }
            else
            {
                if (type == LibraryItem.Playlist)
                {
                    pageFolder.set(0, { "title": qsTr("Playlist") });

                    pCheckPlay(folder, index);

                    pageFolder.setItemVisible(2, true);
                }
                else if (type == LibraryItem.PlaylistFeed)
                {
                    pageFolder.set(0, { "title": qsTr("Feed") });

                    pCheckPlay(folder, index);

                    pageFolder.setItemVisible(2, true);
                }
                else
                {
                    pageFolder.set(0, { "title": qsTr("Folder") });

                    pageFolder.setItemVisible(1, false);
                    pageFolder.setItemVisible(2, false);
                }

                if (folder.itemIsLocal(index) == false)
                {
                    var source = folder.itemSource(index);

                    pageFolder.set(3, { "title": gui.getOpenTitle(source) });

                    pageFolder.setItemVisible(3, true);
                }
                else pageFolder.setItemVisible(3, false);

                pageFolder.setItemVisible(4, false);
                pageFolder.setItemVisible(5, false);
                pageFolder.setItemVisible(6, false);
            }

            listContextual.currentPage = pageFolder;
        }

        //-----------------------------------------------------------------------------------------

        function loadPageTrack(list, index)
        {
            pItem  = list;
            pIndex = index;

            var playlist = list.playlist;

            var selectedCount = playlist.selectedCount;

            if (selectedCount > 1 && playlist.indexSelected(index))
            {
                var title = selectedCount + " " + qsTr("Tracks");

                pageTracks.set(0, { "title": title });

                if (gui.listPlaylist == list)
                {
                    pageTracks.set(2, { "title": qsTr("Remove") + " " + title });

                    pageTracks.setItemVisible(2, true);
                }
                else pageTracks.setItemVisible(2, false);

                listContextual.currentPage = pageTracks;
            }
            else
            {
                pData = playlist.trackData(index);

                pSource = pData.source;
                pFeed   = pData.feed;

                pAuthor = gui.getTrackAuthor(pData.author, pFeed);

                if (pData.title)
                {
                     pageTrack.setItemEnabled(2, true);
                }
                else pageTrack.setItemEnabled(2, false);

                if (pSource)
                {
                    pageTrack.set(3, { "title": gui.getOpenTitle(pSource) });

                    pageTrack.setItemVisible(3, true);
                }
                else pageTrack.setItemVisible(3, false);

                if (playlist.isLocal)
                {
                    pageTrack.setItemVisible(4, true);
                    pageTrack.setItemVisible(5, true);
                }
                else
                {
                    pageTrack.setItemVisible(4, false);
                    pageTrack.setItemVisible(5, false);
                }

                listContextual.currentPage = pageTrack;
            }
        }

        //-----------------------------------------------------------------------------------------

        function loadPageTab(tab)
        {
            pItem = tab;

            if (tab.title)
            {
                 pageTab.setItemEnabled(2, true);
            }
            else pageTab.setItemEnabled(2, false);

            if (tabs.count > 1)
            {
                pageTab.setItemEnabled(4, true);
                pageTab.setItemEnabled(5, true);
            }
            else if (currentTab.isValid)
            {
                pageTab.setItemEnabled(4, false);
                pageTab.setItemEnabled(5, true);
            }
            else
            {
                pageTab.setItemEnabled(4, false);
                pageTab.setItemEnabled(5, false);
            }

            if (tab.isValid)
            {
                pData = tab.trackData;

                pSource = pData.source;
                pFeed   = pData.feed;

                pAuthor = gui.getTrackAuthor(pData.author, pFeed);

                pageTab.setItemEnabled(1, true);

                if (pSource)
                {
                    pageTab.set(3, { "title": gui.getOpenTitle(pSource) });

                    pageTab.setItemVisible(3, true);
                }
                else pageTab.setItemVisible(3, false);
            }
            else
            {
                pSource = "";
                pAuthor = "";
                pFeed   = "";

                pageTab.setItemEnabled(1, false);

                pageTab.setItemVisible(3, false);
            }

            listContextual.currentPage = pageTab;
        }

        //-----------------------------------------------------------------------------------------

        function loadPageBrowse()
        {
            pageBrowse.setItemEnabled(3, local.cache);

            listContextual.currentPage = pageBrowse;
        }

        //-----------------------------------------------------------------------------------------
        // Events

        function onFolderClicked(id)
        {
            if (id == 0) // Play
            {
                gui.playItem(pItem.folder, pIndex);
            }
            else if (id == 1) // Add to ...
            {
                panelAdd.setSource(1, pItem.folder, pIndex);

                pShowPanelAdd();

                return false;
            }
            else if (id == 2) // Webpage
            {
                var source = pItem.folder.itemSource(pIndex);

                gui.openSource(source);
            }
            else if (id == 3) // Rename
            {
                pItem.renameItem(pIndex);
            }
            else if (id == 4) // Move to ...
            {
                panelAdd.setSource(2, pItem.folder, pIndex);

                pShowPanelAdd();

                return false;
            }
            else if (id == 5) // Remove
            {
                pItem.removeItem(pIndex, true);
            }

            return true;
        }

        //-----------------------------------------------------------------------------------------

        function onTrackClicked(id)
        {
            if (id == 0) // Add to ...
            {
                var playlist = pItem.playlist;

                if (playlist.indexSelected(pIndex))
                {
                     panelAdd.setSource(0, playlist, -1);
                }
                else panelAdd.setSource(0, playlist, pIndex);

                pShowPanelAdd();

                return false;
            }
            else if (id == 1) // Browse
            {
                var title = pItem.playlist.trackTitle(pIndex);

                pBrowse(core.getQuery(title));
            }
            else if (id == 2) // Webpage
            {
                var source = pItem.playlist.trackSource(pIndex);

                gui.openSource(source);
            }
            else if (id == 3) // Set as Cover
            {
                /* var */ playlist = pItem.playlist;

                var cover = playlist.trackCover(pIndex);

                if (cover != "")
                {
                    playlist.cover = cover;
                }

            }
            else if (id == 4) // Remove
            {
                pItem.removeTrack(pIndex, true);
            }

            return true;
        }

        function onTracksClicked(id)
        {
            if (id == 0) // Add to ...
            {
                panelAdd.setSource(0, pItem.playlist, -1);

                pShowPanelAdd();

                return false;
            }
            else if (id == 1) // Remove selected
            {
                pItem.removeSelected(true);
            }

            return true;
        }

        //-----------------------------------------------------------------------------------------

        function onTabClicked(id)
        {
            if (id == 0) // Add to ...
            {
                var playlist = pItem.playlist;

                if (playlist == null)
                {
                    playlistTemp.clearTracks();

                    pItem.copyTrackTo(playlistTemp);

                    panelAdd.setSource(0, playlistTemp, 0);
                }
                else panelAdd.setSource(0, playlist, pItem.trackIndex);

                pShowPanelAdd();

                return false;
            }
            else if (id == 1) // Browse
            {
                pBrowse(pItem.title);
            }
            else if (id == 2) // Webpage
            {
                gui.openSource(pItem.source);
            }
            else if (id == 3) // Close other tabs
            {
                wall.enableAnimation = false;

                tabs.closeOtherTabs(pItem);

                wall.enableAnimation = true;
            }
            else if (id == 4) // Close all tabs
            {
                wall.enableAnimation = false;

                tabs.closeTabs();

                wall.enableAnimation = true;
            }

            return true;
        }

        //-----------------------------------------------------------------------------------------

        function onBrowseClicked(id)
        {
            if (id == 0) // Open File
            {
                listContextual.setCurrentId(0);

                var path = core.openFile("Select File");

                panelBrowse.browse(path);
            }
            else if (id == 1) // Open Folder
            {
                listContextual.setCurrentId(1);

                /* var */ path = core.openFolder("Select Folder");

                panelBrowse.browse(path);
            }
            else if (id == 2) // Clear cache
            {
                panelBrowse.clearEdit();

                core.clearCache();
            }

            return true;
        }

        //-----------------------------------------------------------------------------------------
        // Private

        function pGetPreferredHeight()
        {
            if (pButtonsVisible)
            {
                 return listContextual.height + borderSizeHeight + buttonFeed.height;
            }
            else return listContextual.height + borderSizeHeight - borderBottom;
        }

        //-----------------------------------------------------------------------------------------
        // Childs
        //-----------------------------------------------------------------------------------------

        ListContextual
        {
            id: listContextual

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.left : parent.left
            anchors.right: parent.right

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onItemClicked:
            {
                var clear;

                if      (currentPage == pageFolder) clear = panelContextual.onFolderClicked(id);
                else if (currentPage == pageTrack)  clear = panelContextual.onTrackClicked (id);
                else if (currentPage == pageTracks) clear = panelContextual.onTracksClicked(id);
                else if (currentPage == pageTab)    clear = panelContextual.onTabClicked   (id);
                else if (currentPage == pageBrowse) clear = panelContextual.onBrowseClicked(id);
                else                                clear = true;

                if (clear) areaContextual.hidePanels();
            }

            //-------------------------------------------------------------------------------------
            // Pages
            //-------------------------------------------------------------------------------------

            ContextualPage
            {
                id: pageFolder

                values:
                [
                    { "type": ContextualPage.Category },

                    { "id": 0, "icon"    : st.icon24x24_play,
                               "iconSize": st.size24x24, "title": qsTr("Play") },

                    { "id": 1, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Add to ...") },

                    { "id": 2, "icon"    : st.icon16x16_external,
                               "iconSize": st.size16x16 },

                    { "id": 3, "title": qsTr("Rename")      },
                    { "id": 4, "title": qsTr("Move to ...") },

                    { "id": 5, "type": ContextualPage.ItemConfirm }
                ]
            }

            //-------------------------------------------------------------------------------------

            ContextualPage
            {
                id: pageTrack

                values:
                [
                    { "type": ContextualPage.Category, "title": qsTr("Track") },

                    { "id": 0, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Add to ...") },

                    { "id": 1, "icon"    : st.icon24x24_addBold,
                               "iconSize": st.size24x24, "title": qsTr("Browse") },

                    { "id": 2, "icon"    : st.icon16x16_external,
                               "iconSize": st.size16x16 },

                    { "id": 3, "title": qsTr("Set as Cover") },
                    { "id": 4, "title": qsTr("Remove Track") }
                ]
            }

            ContextualPage
            {
                id: pageTracks

                values:
                [
                    { "type": ContextualPage.Category },

                    { "id": 0, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Add to ...") },

                    { "id": 1, "type" : ContextualPage.ItemConfirm }
                ]
            }

            //-------------------------------------------------------------------------------------

            ContextualPage
            {
                id: pageTab

                values:
                [
                    { "type": ContextualPage.Category, "title": qsTr("Tab") },

                    { "id": 0, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Add to ...") },

                    { "id": 1, "icon"    : st.icon24x24_addBold,
                               "iconSize": st.size24x24, "title": qsTr("Browse") },

                    { "id": 2, "icon"    : st.icon16x16_external,
                               "iconSize": st.size16x16 },

                    { "id": 3, "title": qsTr("Close other Tabs") },
                    { "id": 4, "title": qsTr("Close all Tabs")   }
                ]
            }

            //-------------------------------------------------------------------------------------

            ContextualPage
            {
                id: pageBrowse

                values:
                [
                    { "id": 0, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Open File") },

                    { "id": 1, "icon"    : st.icon24x24_addIn,
                               "iconSize": st.size24x24, "title": qsTr("Open Folder") },

                    { "id": 2, "title": qsTr("Clear cache") }
                ]
            }
        }

        ButtonPianoIcon
        {
            anchors.right: parent.right

            width : st.barTitle_height + borderSizeWidth
            height: st.barTitle_height

            borderLeft : borderSize
            borderRight: 0

            visible: (panelContextual.posX != -1 || panelContextual.posY != -1)

            enabled: (areaContextual.currentPanel != null)

            icon          : st.icon16x16_close
            iconSourceSize: st.size16x16

            onClicked: areaContextual.hidePanels()
        }

        ButtonPiano
        {
            id: buttonFeed

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            borderRight: 0

            visible: pButtonsVisible

            enabled: (pFeed != "")

            text: pAuthor

            itemText.horizontalAlignment: Text.AlignLeft

            onClicked:
            {
                if (currentPage == pageTab)
                {
                     gui.browseFeed(pItem);
                }
                else gui.browseFeedTrack(pSource, pFeed);

                areaContextual.hidePanels();
            }
        }
    }

    PanelAdd { id: panelAdd }
}
