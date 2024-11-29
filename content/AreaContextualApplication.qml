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

AreaContextual
{
    id: areaContextual

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int currentId: -1
    // 0: Folder
    // 1: Track
    // 2: Tracks
    // 3: Tab
    // 4: Browse
    // 5: Tag
    // 6: Mode

    /* read */ property variant item: null

    //---------------------------------------------------------------------------------------------
    // Private

    property variant pItem : null
    property int     pIndex: -1

    property string pSource
    property string pAuthor
    property string pFeed

    property string pText

    property bool pButtonsVisible: (currentId == 1 || currentId == 3) // Track or Tab

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
    // Events
    //---------------------------------------------------------------------------------------------

    onIsActiveChanged:
    {
        if (isActive) return;

        currentId = -1;

        areaContextual.item = null;
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showPanelSettings(item, marginY, settings, currentIndex, activeIndex)
    {
        // NOTE: We don't want to show the same panel twice.
        if (checkPanel(panelContextual, item)) return;

        areaContextual.item = item;

        var array = new Array;

        for (var i = 0; i < settings.length; i++)
        {
            var data = settings[i];

            var icon = data.icon;

            // NOTE: We make sure id(s) are equivalent to index(es).
            if (icon)
            {
                 array.push({ "id": i, "title": data.title, "icon": icon,
                              "iconSize": data.iconSize });
            }
            else array.push({ "id": i, "title": data.title });
        }

        page.values = array;

        // NOTE: We make sure id(s) are equivalent to index(es).
        page.selectedId = currentIndex;
        page.currentId  = activeIndex;

        currentId = -1;

        var panel = pGetPanel();

        if (panel.height < panelContextual.preferredHeight)
        {
             showPanelPositionMargins(panelContextual, panel,
                                      Sk.TopLeftCorner, st.border_size, st.border_size);
        }
        else showPanelPositionMargins(panelContextual, item,
                                      Sk.BottomLeftCorner, 0, marginY - st.border_size);
    }

    function showPanelMode(button, marginY)
    {
        currentId = 6;

        item = button;

        showPanelPositionMargins(panelLoader, button, Sk.BottomLeftCorner, -(button.x), marginY);
    }

    function showPanelVideo(source, button, marginY)
    {
        currentId = 7;

        item = button;

        showPanelPositionMargins(panelLoader, button, Sk.BottomLeftCorner, -(button.x), marginY);

        panelLoader.item.load(gui.applyTime(source));
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pShowPanel(panel)
    {
        showPanel(panel, panelContextual.item,
                         panelContextual.position,
                         panelContextual.posX,
                         panelContextual.posY,
                         panelContextual.marginX,
                         panelContextual.marginY,
                         panelContextual.isCursorChild);
    }

    function pCheckContext(source)
    {
        return (controllerNetwork.hasFragment(source, 't')   ||
                controllerNetwork.hasFragment(source, 'ctx') ||
                controllerNetwork.hasFragment(source, 'id')  ||
                controllerNetwork.hasFragment(source, 'sid'));
    }

    function pClearContext(playlist, index)
    {
        var source = gui.clearContext(playlist.trackSource(index));

        playlist.setTrackSource(index, source);

        // NOTE: We reload the track to ensure that the duration is accurate.
        gui.reload(playlist, index);
    }

    function pClearContextTab(tab)
    {
        tab.source = gui.clearContext(tab.source);

        // NOTE: We reload the track to ensure that the duration is accurate.
        gui.reloadTab(tab);
    }

    //---------------------------------------------------------------------------------------------

    function pCheckPlay(folder, index)
    {
        if (folder.currentIndex != index)
        {
            return false;
        }

        var item = folder.currentItem;

        return (item.isPlaylist && item.count)
    }

    //---------------------------------------------------------------------------------------------

    function pSearchMore(playlist, source, title)
    {
        gui.restore();

        panelBrowse.searchMore(playlist, source, title);
    }

    //---------------------------------------------------------------------------------------------

    function pGetSource()
    {
        if      (currentId == 6) return "ContextualMode.qml";
        else if (currentId == 7) return "ContextualLinks.qml";
        else                     return "";
    }

    function pGetPanel()
    {
        if      (panelGet.visible)      return panelGet;
        else if (panelSettings.visible) return panelSettings;
        else                            return panelOutput;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    PanelContextual
    {
        id: panelContextual

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        minimumWidth : st.dp160
        minimumHeight: st.list_itemHeight

        preferredWidth : st.dp160
        preferredHeight: pGetPreferredHeight()

        //-----------------------------------------------------------------------------------------
        // Events
        //-----------------------------------------------------------------------------------------

        onIsActiveChanged:
        {
            if (isActive)
            {
                listContextual.setFocus();
            }
            else currentPage.clearItems();
        }

        //-----------------------------------------------------------------------------------------
        // Functions
        //-----------------------------------------------------------------------------------------

        function loadPageFolder(list, index)
        {
            pItem  = list;
            pIndex = index;

            var array = new Array;

            var folder = list.folder;

            var type = core.itemType(folder, index);

            if (folder.isFolderBase)
            {
                if (type == LibraryItem.Playlist)
                {
                    array.push({ "type": ContextualPage.Category, "title": qsTr("Playlist") });

                    var play = pCheckPlay(folder, index);

                    if (play)
                    {
                        array.push({ "id": 0, "icon": st.icon16x16_play, "iconSize": st.size16x16,
                                     "title": qsTr("Play") });
                    }

                    if (folder.itemIsLocal(index))
                    {
                        if (folder != feeds)
                        {
                            array.push
                            (
                                { "id": 6, "title": qsTr("Rename")      },
                                { "id": 7, "title": qsTr("Move to ...") },
                                { "id": 8, "title": qsTr("Save VBML")   }
                            );
                        }
                        else array.push
                        (
                            { "id": 8, "title": qsTr("Save VBML") }
                        );

                        array.push({ "id": 9, "type": ContextualPage.ItemConfirm,
                                     "title": qsTr("Delete Playlist") });
                    }
                    else if (folder == feeds)
                    {
                        array.push
                        (
                            { "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                              "title": qsTr("Add to ...") },

                            { "id": 2, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                               "title": qsTr("More like this") },

                            { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                              "title": qsTr("Open link") },

                            { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                              "title": qsTr("Copy link") }
                        );

                        if (play)
                        {
                            array.push({ "id": 5, "icon": st.icon16x16_refresh,
                                         "iconSize": st.size16x16, "title": qsTr("Reload") });
                        }

                        array.push
                        (
                            { "id": 8, "title": qsTr("Save VBML") },

                            { "id": 9, "type": ContextualPage.ItemConfirm,
                              "title": qsTr("Remove Playlist") }
                        );
                    }
                    else
                    {
                        array.push
                        (
                            { "id": 2, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                              "title": qsTr("More like this") },

                            { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                              "title": qsTr("Open link") },

                            { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                              "title": qsTr("Copy link") }
                        );

                        if (play)
                        {
                            array.push({ "id": 5, "icon": st.icon16x16_refresh,
                                         "iconSize": st.size16x16, "title": qsTr("Reload") });
                        }

                        array.push
                        (
                            { "id": 8, "title": qsTr("Save VBML") },

                            { "id": 9, "type": ContextualPage.ItemConfirm,
                              "title": qsTr("Remove Playlist") }
                        );
                    }
                }
                else if (type == LibraryItem.PlaylistFeed)
                {
                    array.push({ "type": ContextualPage.Category, "title": qsTr("Feed") });

                    var play = pCheckPlay(folder, index);

                    if (play)
                    {
                        array.push({ "id": 0, "icon": st.icon16x16_play, "iconSize": st.size16x16,
                                     "title": qsTr("Play") });
                    }

                    if (folder.itemIsLocal(index))
                    {
                        if (folder != feeds)
                        {
                            array.push
                            (
                                { "id": 6, "title": qsTr("Rename")      },
                                { "id": 7, "title": qsTr("Move to ...") },
                                { "id": 8, "title": qsTr("Save VBML")   }
                            );
                        }
                        else array.push
                        (
                            { "id": 8, "title": qsTr("Save VBML") }
                        );

                        array.push({ "id": 9, "type": ContextualPage.ItemConfirm,
                                     "title": qsTr("Delete Feed") });
                    }
                    else
                    {
                        if (folder == feeds)
                        {
                            array.push
                            (
                                { "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                                  "title": qsTr("Add to ...") },

                                { "id": 2, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                                  "title": qsTr("More like this") },

                                { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                                  "title": qsTr("Open link") },

                                { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                                  "title": qsTr("Copy link") }
                            );

                            if (play)
                            {
                                array.push({ "id": 5, "icon": st.icon16x16_refresh,
                                             "iconSize": st.size16x16, "title": qsTr("Reload") });
                            }

                            array.push
                            (
                                { "id": 8, "title": qsTr("Save VBML") }
                            );
                        }
                        else
                        {
                            array.push
                            (
                                { "id": 2, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                                  "title": qsTr("More like this") },

                                { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                                  "title": qsTr("Open link") },

                                { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                                  "title": qsTr("Copy link") }
                             );

                            if (play)
                            {
                                array.push({ "id": 5, "icon": st.icon16x16_refresh,
                                             "iconSize": st.size16x16, "title": qsTr("Reload") });
                            }

                            array.push
                            (
                                { "id": 7, "title": qsTr("Move to ...") },

                                { "id": 8, "title": qsTr("Save VBML") }
                            );
                        }

                        array.push({ "id": 9, "type": ContextualPage.ItemConfirm,
                                     "title": qsTr("Remove Feed") });
                    }
                }
                else
                {
                    array.push
                    (
                        { "type": ContextualPage.Category, "title": qsTr("Folder") },

                        { "id": 6, "title": qsTr("Rename") },

                        { "id": 9, "type": ContextualPage.ItemConfirm,
                          "title": qsTr("Delete Folder") }
                    );
                }
            }
            else
            {
                if (type == LibraryItem.Playlist)
                {
                    array.push({ "type": ContextualPage.Category, "title": qsTr("Playlist") });

                    if (pCheckPlay(folder, index))
                    {
                        array.push({ "id": 0, "icon": st.icon16x16_play, "iconSize": st.size16x16,
                                     "title": qsTr("Play") });
                    }

                    array.push({ "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                                 "title": qsTr("Add to ...") });
                }
                else if (type == LibraryItem.PlaylistFeed)
                {
                    array.push({ "type": ContextualPage.Category, "title": qsTr("Feed") });

                    if (pCheckPlay(folder, index))
                    {
                        array.push({ "id": 0, "icon": st.icon16x16_play, "iconSize": st.size16x16,
                                     "title": qsTr("Play") });
                    }

                    array.push({ "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                                 "title": qsTr("Add to ...") });
                }
                else array.push({ "type": ContextualPage.Category, "title": qsTr("Folder") });

                if (folder.itemIsLocal(index) == false)
                {
                    array.push
                    (
                        { "id": 2, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                          "title": qsTr("More like this") },

                        { "id": 3, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                          "title": qsTr("Open link") },

                        { "id": 4, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                          "title": qsTr("Copy link") }
                    );
                }
            }

            page.values = array;

            currentId = 0;
        }

        function loadPageTrack(list, index)
        {
            pItem  = list;
            pIndex = index;

            var array = new Array;

            var playlist = list.playlist;

            var selectedCount = playlist.selectedCount;

            if (selectedCount > 1 && playlist.indexSelected(index))
            {
                var title = selectedCount + " " + qsTr("Tracks");

                array.push
                (
                    { "type": ContextualPage.Category, "title": title },

                    { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                      "title": qsTr("Add to ...") }
                );

                if (gui.listPlaylist == list)
                {
                    title = qsTr("Remove") + " " + title;

                    array.push({ "id": 1, "type" : ContextualPage.ItemConfirm, "title": title });
                }

                page.values = array;

                currentId = 2;
            }
            else
            {
                var data = playlist.trackData(index);

                pSource = data.source;
                pFeed   = data.feed;

                pAuthor = gui.getTrackAuthor(data.author, pFeed);

                array.push
                (
                    { "type": ContextualPage.Category, "title": qsTr("Track") },

                    { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                      "title": qsTr("Add to ...") },

                    { "id": 1, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                      "title": qsTr("More like this") },

                    { "id": 2, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                      "title": qsTr("Open link") },

                    { "id": 3, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                      "title": qsTr("Copy link") },

                    { "id": 4, "icon": st.icon16x16_list, "iconSize": st.size16x16,
                      "title": qsTr("Sources") },

                    { "id": 5, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
                      "title": qsTr("Reload") },

                    { "id": 6, "icon": st.icon16x16_recent, "iconSize": st.size16x16,
                      "title": qsTr("Reset timeline") },

                    { "id": 7, "title": qsTr("Save VBML") }
                );

                if (playlist.isLocal)
                {
                    array.push
                    (
                        { "id": 8, "title": qsTr("Set as Cover") },
                        { "id": 9, "title": qsTr("Remove Track") }
                    );
                }

                page.values = array;

                if (data.title == "")
                {
                    page.setItemEnabled(2, false); // More like this
                }

                if (pSource == "")
                {
                    page.setItemEnabled(3, false); // Open link
                    page.setItemEnabled(4, false); // Copy link
                    page.setItemEnabled(5, false); // Sources
                    page.setItemEnabled(6, false); // Reload
                    page.setItemEnabled(7, false); // Reset timeline
                }
                else if (pCheckContext(playlist.trackSource(index)) == false)
                {
                    page.setItemEnabled(7, false); // Reset timeline
                }

                currentId = 1;
            }
        }

        //-----------------------------------------------------------------------------------------

        function loadPageTab(tab)
        {
            pItem = tab;

            var array = new Array;

            array.push
            (
                { "type": ContextualPage.Category, "title": qsTr("Tab") },

                { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                  "title": qsTr("Add to ...") },

                { "id": 1, "icon": st.icon16x16_addBold, "iconSize": st.size16x16,
                  "title": qsTr("More like this") },

                { "id": 2, "icon": st.icon16x16_external, "iconSize": st.size16x16,
                  "title": qsTr("Open link") },

                { "id": 3, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                  "title": qsTr("Copy link") },

                { "id": 4, "icon": st.icon16x16_list, "iconSize": st.size16x16,
                  "title": qsTr("Sources") },

                { "id": 5, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
                  "title": qsTr("Reload") },

                { "id": 6, "icon": st.icon16x16_recent, "iconSize": st.size16x16,
                  "title": qsTr("Reset timeline") },

                { "id": 7, "title": qsTr("Save VBML") },

                { "id": 8, "title": qsTr("Close other Tabs") },

                { "id": 9, "title": qsTr("Close all Tabs") }
            );

            page.values = array;

            if (tab.isValid)
            {
                var data = tab.trackData;

                pSource = data.source;
                pFeed   = data.feed;

                pAuthor = gui.getTrackAuthor(data.author, pFeed);

                if (tab.title == "")
                {
                    page.setItemEnabled(2, false); // More like this
                }

                if (pSource == "")
                {
                    page.setItemEnabled(3, false); // Open link
                    page.setItemEnabled(4, false); // Copy link
                    page.setItemEnabled(5, false); // Sources
                }
                else if (pCheckContext(tab.source) == false)
                {
                    page.setItemEnabled(7, false); // Reset timeline
                }
            }
            else
            {
                pSource = "";
                pAuthor = "";
                pFeed   = "";

                page.setItemEnabled(1, false); // Add to ...
                page.setItemEnabled(2, false); // More like this
                page.setItemEnabled(3, false); // Open link
                page.setItemEnabled(4, false); // Copy link
                page.setItemEnabled(5, false); // Sources
                page.setItemEnabled(6, false); // Reload
                page.setItemEnabled(7, false); // Reset timeline

                if (tabs.count == 1)
                {
                    page.setItemEnabled(8, false); // Close other Tabs
                }
            }

            currentId = 3;
        }

        //-----------------------------------------------------------------------------------------

        function loadPageBrowse()
        {
            var array = new Array;

            array.push
            (
                { "id": 0, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                  "title": qsTr("Open File") },

                { "id": 1, "icon": st.icon18x18_addIn, "iconSize": st.size18x18,
                  "title": qsTr("Open Folder") },

                { "id": 2, "icon": st.icon16x16_refresh, "iconSize": st.size16x16,
                  "title": qsTr("Update Backends") },

                { "id": 3, "title": qsTr("Reset Backends") }
            );

            page.values = array;

            currentId = 4;
        }

        function loadPageTag(text)
        {
            pText = text;

            var array = new Array;

            array.push
            (
                { "type": ContextualPage.Category, "title": qsTr("VideoTag") },

                { "id": 0, "iconSize": st.size18x18, "title": qsTr("Open in a new tab") },

                { "id": 1, "icon": st.icon16x16_link, "iconSize": st.size16x16,
                  "title": qsTr("Copy link") }
            );

            page.values = array;

            currentId = 5;
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

                pShowPanel(panelAdd);

                return false;
            }
            else if (id == 2) // More like this
            {
                var folder = pItem.folder;

                pSearchMore(null, folder.itemSource(pIndex), folder.itemTitle(pIndex));
            }
            else if (id == 3) // Open link
            {
                var source = pItem.folder.itemSource(pIndex);

                gui.openSource(source);
            }
            else if (id == 4) // Copy link
            {
                /* var */ source = pItem.folder.itemSource(pIndex);

                gui.applyLink(source);
            }
            else if (id == 5) // Reload
            {
                pItem.folder.currentItem.reloadQuery();
            }
            else if (id == 6) // Rename
            {
                pItem.renameItem(pIndex);
            }
            else if (id == 7) // Move to ...
            {
                panelAdd.setSource(2, pItem.folder, pIndex);

                pShowPanel(panelAdd);

                return false;
            }
            else if (id == 8) // Save VBML
            {
                var playlist = gui.createItemAt(pItem.folder, pIndex);

                core.saveVbml(playlist.title, playlist.toVbml(2));

                playlist.tryDelete();
            }
            else if (id == 9) // Remove
            {
                pItem.removeItem(pIndex, true);

                if (pItem.folder == feeds && pIndex == 0 && history)
                {
                    history.tryDelete();

                    history = null;
                }
            }

            return true;
        }

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

                pShowPanel(panelAdd);

                return false;
            }
            else if (id == 1) // More like this
            {
                /* var */ playlist = pItem.playlist;

                pSearchMore(playlist, playlist.trackSource(pIndex), playlist.trackTitle(pIndex));
            }
            else if (id == 2) // Open link
            {
                var source = pItem.playlist.trackSource(pIndex);

                gui.openSource(source);
            }
            else if (id == 3) // Copy link
            {
                /* var */ source = pItem.playlist.trackSource(pIndex);

                gui.applyLink(source);
            }
            else if (id == 4) // Sources
            {
                currentId = 7;

                pShowPanel(panelLoader);

                panelLoader.item.load(pItem.playlist.trackSource(pIndex));

                return false;
            }
            else if (id == 5) // Reload
            {
                gui.reload(pItem.playlist, pIndex);
            }
            else if (id == 6) // Reset timeline
            {
                pClearContext(pItem.playlist, pIndex);

                currentTab.currentTime = -1;
            }
            else if (id == 7) // Save VBML
            {
                /* var */ playlist = pItem.playlist;

                core.saveVbml(playlist.trackTitle(pIndex), playlist.trackVbml(pIndex));
            }
            else if (id == 8) // Set as Cover
            {
                /* var */ playlist = pItem.playlist;

                var cover = playlist.trackCover(pIndex);

                if (cover != "")
                {
                    playlist.cover = cover;
                }

            }
            else if (id == 9) // Remove
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

                pShowPanel(panelAdd);

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

                pShowPanel(panelAdd);

                return false;
            }
            else if (id == 1) // More like this
            {
                pSearchMore(pItem.playlist, pItem.source, pItem.title);
            }
            else if (id == 2) // Open link
            {
                gui.openSource(pItem.source);
            }
            else if (id == 3) // Copy link
            {
                gui.applyLink(pItem.source);
            }
            else if (id == 4) // Sources
            {
                currentId = 7;

                pShowPanel(panelLoader);

                panelLoader.item.load(pItem.source);

                return false;
            }
            else if (id == 5) // Reload
            {
                gui.reload(pItem.playlist, pItem.trackIndex);
            }
            else if (id == 6) // Reset timeline
            {
                // NOTE: When clearing the player tab we want to stop playback first.
                if (player.tab == pItem)
                {
                    player.stop();

                    pClearContextTab(pItem);

                    currentTab.currentTime = -1;

                    player.reloadSource();
                }
                else
                {
                    pClearContextTab(pItem);

                    currentTab.currentTime = -1;
                }
            }
            else if (id == 7) // Save VBML
            {
                core.saveVbml(pItem.title, pItem.toVbml());
            }
            else if (id == 8) // Close other tabs
            {
                wall.enableAnimation = false;

                tabs.closeOtherTabs(pItem);

                wall.enableAnimation = true;
            }
            else if (id == 9) // Close all tabs
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
                listContextual.setSelectedId(0);

//#QT_4
                gui.browseFile();
//#ELSE
                // NOTE: We call this later to avoid a crash when the ContextualItem gets deleted.
                Qt.callLater(gui.browseFile);
//#END
            }
            else if (id == 1) // Open Folder
            {
                listContextual.setSelectedId(1);

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

            return true;
        }

        function onTagClicked(id)
        {
            if (id == 0) // Open in new tab
            {
                barWindow.openTab();

                gui.browse(pText);
            }
            else if (id == 1) // Copy link
            {
                gui.applyLink(pText);
            }

            return true;
        }

        //-----------------------------------------------------------------------------------------
        // Private

        function pGetPreferredHeight()
        {
            if (pButtonsVisible)
            {
                 return listContextual.height + borderSizeHeight + buttonFeed.height
                        -
                        buttonFeed.borderTop;
            }
            else return listContextual.height + borderSizeHeight - borderBottom;
        }

        //-----------------------------------------------------------------------------------------
        // Children
        //-----------------------------------------------------------------------------------------

        ListContextual
        {
            id: listContextual

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.left : parent.left
            anchors.right: parent.right

            currentPage: ContextualPage { id: page }

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            /* QML_EVENT */ onItemClicked: function(id)
            {
                var clear;

                if (currentId == -1)
                {
                    var item = areaContextual.item;

                    if (item) item.onSelect(id);

                    areaContextual.hidePanels();
                }

                if      (currentId == 0) clear = panelContextual.onFolderClicked(id);
                else if (currentId == 1) clear = panelContextual.onTrackClicked (id);
                else if (currentId == 2) clear = panelContextual.onTracksClicked(id);
                else if (currentId == 3) clear = panelContextual.onTabClicked   (id);
                else if (currentId == 4) clear = panelContextual.onBrowseClicked(id);
                else if (currentId == 5) clear = panelContextual.onTagClicked   (id);
                else                     clear = true;

                if (clear) areaContextual.hidePanels();
            }
        }

        ButtonPianoIcon
        {
            anchors.right: parent.right

            height: st.barTitle_height

            borderLeft : borderSize
            borderRight: 0

            visible: (panelContextual.posX != -1 || panelContextual.posY != -1)

            enabled: (areaContextual.currentPanel != null)

            icon          : st.icon12x12_close
            iconSourceSize: st.size12x12

            onClicked: areaContextual.hidePanels()
        }

        ButtonPiano
        {
            id: buttonFeed

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            borderRight: 0
            borderTop  : borderSize

            visible: pButtonsVisible

            enabled: (pFeed != "")

            text: pAuthor

            itemText.horizontalAlignment: Text.AlignLeft

            onClicked:
            {
                if (currentId == 3) // Tab
                {
                     gui.browseFeed(pItem);
                }
                else gui.browseFeedTrack(pFeed, pSource);

                areaContextual.hidePanels();
            }
        }
    }

    PanelContextualLoader
    {
        id: panelLoader

        minimumWidth: st.dp192 + borderSizeWidth

        source: pGetSource()
    }

    PanelAdd { id: panelAdd }
}
