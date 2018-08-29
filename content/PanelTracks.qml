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

import QtQuick 1.1
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

        if (panelBrowse.visible)
        {
            gui.scrollLibrary.clearItem();
        }

        isExpanded = true;

        panelCover.updatePanel();

        gui.updateScreenDim();

        gui.clearExpand();

        local.tracksExpanded = isExpanded;

        gui.startActionCue(st.duration_normal);
    }

    function restore()
    {
        if (isExpanded == false || actionCue.tryPush(gui.actionTracksRestore)) return;

        isExpanded = false;

        panelLibrary.visible = true;
        panelPlayer .visible = true;

        panelCover.updatePanel();

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

                width: st.dp32 + borderSizeWidth

                visible: (folder != null)

                checkable: true
                checked  : (panelContextual.item == buttonFolder)

                icon: st.icon28x28_folder

                onPressed:
                {
                    var index = library.indexFromId(folder.id);

                    panelContextual.loadPageFolder(gui.listLibrary, index);

                    areaContextual.showPanelPositionMargins(panelContextual, buttonFolder,
                                                            Sk.BottomRight, -st.dp2, 0);
                }
            }

            ButtonPianoIcon
            {
                id: buttonAdd

                anchors.left  : buttonFolder.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: height + borderSizeWidth

                visible: (folder != null && folder.isFull == false)

                checkable: true
                checked  : (scrollFolder.createType == 0)

                dropEnabled: true

                icon          : st.icon24x24_addBold
                iconSourceSize: st.size24x24

                onPressed:
                {
                    if (mouse.button & Qt.RightButton)
                    {
                        return;
                    }
                    else if (checked)
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

                        event.accepted = true;

                        bordersDrop.setItem(buttonAdd);

                        toolTip.show(qsTr("Add Track"), st.icon32x32_addList, 32, 32);
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

            BarTitleText
            {
                id: folderTitle

                anchors.left: (buttonAdd.visible) ? buttonAdd   .right
                                                  : buttonFolder.right

                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                text: (folder) ? folder.title : ""
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

                width: st.dp42 + borderSizeWidth

                visible: (playlist != null)

                highlighted: (player.isPlaying && player.playlist == playlist)

                checkable: true

                checked: (panelContextual.item == buttonPlaylist
                          ||
                          panelAdd.item == buttonPlaylist)

                icon: (playlist != null && playlist.isFeed) ? st.icon28x28_feed
                                                            : st.icon28x28_playlist

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
                                                            Sk.BottomRight, -st.dp2, 0);
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

                icon          : st.icon24x24_refresh
                iconSourceSize: st.size24x24

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

                anchors.right : buttonBrowse.left
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                width: height + borderSizeWidth

                borderLeft: borderSize

                checkable: true
                checked  : isExpanded

                icon          : st.icon24x24_slideUp
                iconSourceSize: st.size24x24

                onClicked: toggleExpand()
            }

            ButtonPianoIcon
            {
                id: buttonBrowse

                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                anchors.rightMargin: st.dp16

                width: height + borderSizeWidth

                checkable: true
                checked  : panelBrowse.isExposed

                icon          : st.icon24x24_addBold
                iconSourceSize: st.size24x24

                onClicked:
                {
                    if (playlist && playlist.isLocal)
                    {
                        panelAdd.setTarget(playlist);
                    }

                    panelBrowse.expose();
                }
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
