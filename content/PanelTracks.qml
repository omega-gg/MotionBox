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

Item
{
    id: panelTracks

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExpanded: local.tracksExpanded

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias folder  : scrollFolder  .folder
    property alias playlist: scrollPlaylist.playlist

    //---------------------------------------------------------------------------------------------

    property alias buttonUp: buttonUp

    property alias scrollFolder  : scrollFolder
    property alias scrollPlaylist: scrollPlaylist

    property alias listFolder  : scrollFolder  .list
    property alias listPlaylist: scrollPlaylist.list

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.top: panelPlayer.bottom

    anchors.left : panelPlayer.left
    anchors.right: panelPlayer.right

    height: parent.height - (panelPlayer.y + panelPlayer.heightPlayer)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onVisibleChanged: if (visible == false) window.clearFocusItem(panelTracks)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expand()
    {
        gui.restore();

        if (isExpanded || actionCue.tryPush(gui.actionTracksExpand)) return;

        //panelDiscover.collapse();

        if (panelBrowse.visible)
        {
            gui.scrollLibrary.clearItem();
        }

        isExpanded = true;

        gui.updateScreenDim();

        gui.clearExpand();

        local.tracksExpanded = isExpanded;

        gui.startActionCue(st.duration_normal);
    }

    function restore()
    {
        if (isExpanded == false || actionCue.tryPush(gui.actionTracksRestore)) return;

        //panelDiscover.collapse();

        isExpanded = false;

        panelLibrary.visible = true;
        panelPlayer .visible = true;

        gui.updateScreenDim();

        local.tracksExpanded = isExpanded;

        gui.startActionCue(st.duration_normal);
    }

    function toggleExpand()
    {
        if (isExpanded) restore();
        else            expand ();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BorderHorizontal {}

    PanelFolder
    {
        id: panelFolder

        anchors.left : parent.left

        visible: scrollFolder.hasFolder

        BarTitle
        {
            id: barFolder

            anchors.left : parent.left
            anchors.right: parent.right

            onDoubleClicked: toggleExpand()

            ButtonPianoIcon
            {
                id: buttonFolder

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: height + borderSizeWidth

                visible: (folder != null)

                checkable: true
                checked  : (panelContextual.item == buttonFolder)

                icon          : st.icon16x16_folder
                iconSourceSize: st.size16x16

                onPressed:
                {
                    var index = folder.parentFolder.indexFromId(folder.id);

                    panelContextual.loadPageFolder(gui.listLibrary, index);

                    areaContextual.showPanelPositionMargins(panelContextual, buttonFolder,
                                                            Sk.BottomRight, -st.border_size, 0);
                }
            }

            BarTitleText
            {
                id: folderTitle

                anchors.left  : buttonFolder.right
                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                text: (folder) ? folder.title : ""
            }

            ButtonPianoIcon
            {
                id: buttonAdd

                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: st.dp32 + borderSizeWidth

                borderLeft : borderSize
                borderRight: 0

                visible: buttonFolder.visible

                checkable: true
                checked  : scrollFolder.isCreating

                dropEnabled: true

                icon          : st.icon16x16_addBold
                iconSourceSize: st.size16x16

                onPressed:
                {
                    if (checked)
                    {
                         scrollFolder.clearItem();
                    }
                    else scrollFolder.createItem(0);
                }

                onDragEntered:
                {
                    if (folder.isFull) return;

                    if (gui.drag == 0)
                    {
                        event.accepted = true;

                        bordersDrop.setItem(buttonAdd);
                    }
                    else if (gui.drag == -1)
                    {
                        var backend = controllerPlaylist.backendFromTrack(event.text);

                        if (backend == null) return;

                        backend.tryDelete();

                        event.accepted = true;

                        bordersDrop.setItem(buttonAdd);

                        toolTip.show(qsTr("Add Track"), st.icon20x20_addList, st.dp20, st.dp20);
                    }
                }

                onDragExited: bordersDrop.clearItem(buttonAdd)

                onDrop:
                {
                    scrollFolder.createItem(0);

                    if (gui.drag == 0)
                    {
                         scrollFolder.setAddTracks(gui.dragItem, gui.dragData);
                    }
                    else scrollFolder.setAddTrackSource(event.text);
                }
            }

            ButtonPianoFull
            {
                id: buttonAddPlaylist

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: Math.round((parent.width - buttonAdd.width) / 2)

                visible: scrollFolder.isCreating

                enabled: (folder != null && folder.isFull == false)

                checkable: true
                checked  : (scrollFolder.type == 0)

                checkHover: false

                icon          : st.icon16x16_playlist
                iconSourceSize: st.size16x16

                text: qsTr("Playlist")

                onPressed: scrollFolder.createItem(0)
            }

            ButtonPianoFull
            {
                anchors.left  : buttonAddPlaylist.right
                anchors.right : buttonAdd.left
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                borderRight: 0

                visible: buttonAddPlaylist.visible

                enabled: (folder != null && folder.isFull == false)

                checkable: true
                checked  : (scrollFolder.type == 1)

                checkHover: false

                icon          : st.icon16x16_feed
                iconSourceSize: st.size16x16

                text: qsTr("Feed")

                onPressed: scrollFolder.createItem(1)
            }
        }

        ScrollFolderCreate
        {
            id: scrollFolder

            anchors.top   : barFolder.bottom
            anchors.bottom: parent.bottom

            anchors.left : parent.left
            anchors.right: parent.right

            listPlaylist: scrollPlaylist.list

            mode: 1

            itemLeft : gui.listLibrary
            itemRight: listPlaylist
        }

        ScrollerList
        {
            visible: scrollFolder.dragAccepted

            opacity: (visible) ? bordersDrop.opacity : 1.0

            scrollArea: scrollFolder
        }
    }

    Rectangle
    {
        anchors.left : (panelFolder.visible) ? panelFolder.right : parent.left
        anchors.right: parent.right

        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        color: st.panel_color

        BarTitle
        {
            id: barPlaylist

            anchors.left : parent.left
            anchors.right: parent.right

            onDoubleClicked: toggleExpand()

            ButtonPianoIcon
            {
                id: buttonPlaylist

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: st.dp56 + borderSizeWidth

                visible: (playlist != null)

                highlighted: (player.isPlaying && player.playlist == playlist)

                checkable: true

                checked: (panelContextual.item == buttonPlaylist
                          ||
                          panelAdd.item == buttonPlaylist)

                icon: (playlist != null && playlist.isFeed) ? st.icon16x16_feed
                                                            : st.icon16x16_playlist

                iconSourceSize: st.size16x16

                onPressed:
                {
                    var list;

                    if (scrollFolder.visible)
                    {
                         list = scrollFolder.list;
                    }
                    else list = gui.listLibrary;

                    var folder = playlist.parentFolder;

                    var index = folder.indexFromId(playlist.id);

                    panelContextual.loadPageFolder(list, index);

                    areaContextual.showPanelPositionMargins(panelContextual, buttonPlaylist,
                                                            Sk.BottomRight, -st.border_size, 0);
                }
            }

            ButtonPianoIcon
            {
                id: buttonRefresh

                anchors.left: (buttonPlaylist.visible) ? buttonPlaylist.right
                                                       : parent.left

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: height + borderSizeWidth

                visible: (playlist != null && playlist.isOnline)

                icon          : st.icon16x16_refresh
                iconSourceSize: st.size16x16

                onClicked: playlist.reloadQuery()
            }

            ButtonPianoTitle
            {
                id: buttonTitle

                anchors.left: (buttonRefresh.visible) ? buttonRefresh.right
                                                      : buttonRefresh.left

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                visible: (itemTitle.visible && itemTitle.text != "" && playlist.isOnline)

                itemTitle: itemTitle

                itemBottom: scrollPlaylist

                onClicked:
                {
                    if (isFocused) window.clearFocus();

                    if (playlist.source == "")
                    {
                         panelBrowse.expose();
                    }
                    else panelBrowse.browse(playlist.source);
                }
            }

            BarTitleText
            {
                id: itemTitle

                anchors.left  : buttonTitle.left
                anchors.right : buttonUp.left
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                visible: (playlist != null)

                text: (playlist) ? playlist.title : ""
            }

            ButtonPianoIcon
            {
                id: buttonUp

                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                anchors.rightMargin: st.dp16

                width: height + borderSizeWidth

                borderLeft: borderSize

                checkable: true
                checked  : isExpanded

                icon          : st.icon16x16_slideUp
                iconSourceSize: st.size16x16

                onClicked: toggleExpand()
            }
        }

        ScrollPlaylistCreate
        {
            id: scrollPlaylist

            anchors.top   : barPlaylist.bottom
            anchors.bottom: parent.bottom

            anchors.left : parent.left
            anchors.right: parent.right

            itemLeft: (listFolder.visible) ? listFolder
                                           : gui.listLibrary

            itemTop: (buttonTitle.visible) ? buttonTitle : null
        }

        ScrollerList
        {
            visible: scrollPlaylist.dragAccepted

            opacity: (visible) ? bordersDrop.opacity : 1.0

            scrollArea: scrollPlaylist
        }
    }
}
