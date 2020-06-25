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

ScrollFolder
{
    id: scrollFolder

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isCreating: false
    /* read */ property bool isDropping: false

    property bool enableAnimation: true

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

    property variant pDropItem : null
    property int     pDropIndex: -1
    property int     pDropType : -1

    property int pAdd: -1

    property int pAddAction: -1

    property variant pAddItem: null
    property int     pAddId  : -1
    property variant pAddData

    property int pAddType: -1

    property string pAddSource

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias type: itemNew.type
    property alias mode: itemNew.mode

    property alias text: itemNew.text

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal create
    signal clear

    signal finished

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    contentHeight: list.y + list.height

    dropEnabled: true

    enableDrag    : true
    enableDragMove: true

    textVisible: (count == 0 && folder != null && folder.queryIsLoading == false
                  &&
                  itemNew.visible == false)

    list.anchors.top: itemNew.bottom

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onDragEntered:
    {
        if (folder == null) return;

        if (gui.drag == 0)
        {
            pAcceptDrop(event);

            pDropType = 0;
        }
        else if (gui.drag == 1)
        {
            if (folder.isFull) return;

            var type = gui.dragType;

            if (event.actions & Qt.MoveAction)
            {
                if (folder == gui.dragItem)
                {
                    if (count == 1) return;

                    pAcceptDrop(event);

                    event.action = Qt.MoveAction;
                }
                else if (type == LibraryItem.Playlist || type == LibraryItem.PlaylistFeed)
                {
                    pAcceptDrop(event);

                    event.action = Qt.MoveAction;
                }
            }
            else if (type == LibraryItem.Playlist || type == LibraryItem.PlaylistFeed)
            {
                pAcceptDrop(event);
            }
        }
        else // if (gui.drag == -1)
        {
            if (folder.isFull) return;

            var url = event.text;

            if (controllerPlaylist.urlIsSubtitle(url)) return;

            pAcceptDrop(event);

            if (controllerPlaylist.urlIsTrack(url))
            {
                pDropType = 0;

                toolTip.show(qsTr("Add Track"), st.icon32x32_addList, st.dp32, st.dp32);

                return;
            }

            var backend = controllerPlaylist.backendFromPlaylist(url);

            if (backend)
            {
                pDropType = core.getPlaylistType(backend, url);

                backend.tryDelete();

                if (pDropType == LibraryItem.PlaylistFeed)
                {
                     toolTip.show(qsTr("Add Feed"), st.icon32x32_addList, st.dp32, st.dp32);
                }
                else toolTip.show(qsTr("Add Playlist"), st.icon32x32_addList, st.dp32, st.dp32);
            }
            else
            {
                pDropType = LibraryItem.Playlist;

                toolTip.show(qsTr("Add Playlist"), st.icon32x32_addList, st.dp32, st.dp32);
            }
        }
    }

    onDragExited: pClearDrag()

    onDragMove:
    {
        if (pDropType) pOnDragItem (event);
        else           pOnDragTrack(event);
    }

    onDrop:
    {
        timerSelect.stop();

        pSetDropping(true);

        if (pDropType) pOnDropItem (event);
        else           pOnDropTrack(event);

        pClearDrop();

        timerAdd.restart();
    }

    onFolderChanged: if (folder == null) pClearDrag()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function createItem(type)
    {
        if (scrollFolder.type == type) return;

        scrollFolder.type = type;

        list.enableContextual = false;

        pSetDropping(true);

        scrollToTop();

        itemNew.visible = true;

        itemNew.focus();
    }

    function clearItem()
    {
        if (isCreating == false) return;

        text = "";

        window.clearFocus();
    }

    //---------------------------------------------------------------------------------------------

    function switchType()
    {
        itemNew.switchType();
    }

    //---------------------------------------------------------------------------------------------

    function setAddTracks(item, data)
    {
        pAdd = 0;

        pSetAddItem(item);

        pAddData = data;
    }

    function setAddTrackSource(source)
    {
        pAdd = 1;

        pClearAddItem();

        pAddSource = source;
    }

    //---------------------------------------------------------------------------------------------

    function setAddItem(action, item, id)
    {
        pAdd = 2;

        pAddAction = action;

        pSetAddItem(item);

        pAddId = id;
    }

    function setAddItemSource(action, type, source)
    {
        pAdd = 3;

        pAddAction = action;

        pClearAddItem();

        pAddType   = type;
        pAddSource = source;
    }

    //---------------------------------------------------------------------------------------------
    // ScrollFolder reimplementation

    function updateCurrentY()
    {
        if (isDropping)
        {
            pSelectedY = -1;

            pAtBottom = false;
        }
        else
        {
            pSelectedY = currentItemY();

            if (atTop) pAtBottom = false;
            else       pAtBottom = atBottom;
        }
    }

    //---------------------------------------------------------------------------------------------

    function onValueUpdated()
    {
        updateView();

        clearItem();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pSetDropItem(index, enabled, text)
    {
        pDropItem = list.itemAt(index);

        pDropItem.itemText.visible = false;

        label.enabled = enabled;
        label.text    = text;
    }

    function pClearDropItem()
    {
        if (pDropItem)
        {
            pDropItem.itemText.visible = true;

            pDropItem = null;
        }

        label.text = "";
    }

    //---------------------------------------------------------------------------------------------

    function pSetAddItem(item)
    {
        if (pAddItem) pAddItem.tryDelete();

        pAddItem = item;

        if (item) item.addDeleteLock();
    }

    function pClearAddItem()
    {
        if (pAddItem == null) return;

        pAddItem.tryDelete();

        pAddItem = null;
    }

    //---------------------------------------------------------------------------------------------

    function pSetDropping(dropping)
    {
        if (isDropping == dropping) return;

        isDropping = dropping;

        updateCurrentY();
    }

    //---------------------------------------------------------------------------------------------

    function pAcceptDrop(event)
    {
        event.accepted = true;

        panelApplication.collapse();

        clearItem();

        bordersDrop.setItem(container);
    }

    function pClearDrag()
    {
        timerSelect.stop();

        bordersDrop.clearItem(container);

        pClearDrop();
    }

    function pClearDrop()
    {
        lineDrop     .visible = false;
        rectangleDrop.visible = false;

        pDropIndex = -1;
        pDropType  = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pCreateItem()
    {
        if (type == 0)
        {
            list.insertItem(0, LibraryItem.Playlist, text, false);

            if (core.checkUrl(text))
            {
                folder.setItemSource(0, text);

                folder.currentIndex = 0;
            }
            else pAddTracks();
        }
        else if (type == 1)
        {
            list.insertItem(0, LibraryItem.PlaylistFeed, text, false);

            if (core.checkUrl(text))
            {
                folder.setItemSource(0, text);

                folder.currentIndex = 0;
            }
            else pAddTracks();
        }
        else // if (type == 2)
        {
            list.insertItem(0, LibraryItem.Folder, text, false);

            folder.currentIndex = 0;

            if (pAdd == -1) return;

            if (pAdd == 2)
            {
                var index = pAddItem.indexFromId(pAddId);

                if (index == -1) return;

                if (pAddAction == Qt.MoveAction)
                {
                    gui.movePlaylistToFolder(pAddItem, index, folder, 0);

                    pSetDropItem(0, true, qsTr("Playlist moved"));
                }
                else
                {
                    gui.copyPlaylistToFolder(pAddItem, index, folder, 0);

                    pSetDropItem(0, true, qsTr("Playlist added"));
                }

                timerAdd.restart();
            }
            else if (pAdd == 3)
            {
                gui.copyPlaylistUrlToFolder(pAddType, pAddSource, folder, 0);

                pSetDropItem(0, true, qsTr("Playlist added"));

                timerAdd.restart();
            }
        }
    }

    function pAddTracks()
    {
        folder.currentIndex = 0;

        if (pAdd == -1) return;

        if (pAdd == 0)
        {
            gui.copyTracksToPlaylist(pAddItem, pAddData, folder, 0);

            var length = pAddData.length;

            if (length == 1)
            {
                 pSetDropItem(0, true, qsTr("Track added"));
            }
            else pSetDropItem(0, true, length + " " + qsTr("Tracks added"));

            timerAdd.restart();
        }
        else if (pAdd == 1)
        {
            gui.insertTrackToPlaylist(pAddSource, folder, 0);

            pSetDropItem(0, true, qsTr("Track added"));

            timerAdd.restart();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Private events

    function pOnDragTrack(event)
    {
        if (count == 0)
        {
            if (pDropIndex)
            {
                timerSelect.stop();

                pDropIndex = -1;

                rectangleDrop.visible = false;
            }

            return;
        }

        var pos = mapToItem(list, event.x, event.y);

        var y = pos.y;

        if (y < list.height)
        {
            var index = Math.floor(y / list.itemSize);

            if (pDropIndex == index) return;

            if (folder.itemIsLocal(index))
            {
                if (folder.getLibraryItemAt(index) != gui.dragItem)
                {
                    pDropIndex = index;

                    rectangleDrop.y = index * list.itemSize;

                    rectangleDrop.visible = true;

                    if (pDropIndex != folder.currentIndex || panelBrowse.visible)
                    {
                         timerSelect.restart();
                    }
                    else timerSelect.stop();

                    return;
                }
            }
        }

        timerSelect.stop();

        pDropIndex = -1;

        rectangleDrop.visible = false;
    }

    function pOnDragItem(event)
    {
        if (count == 0)
        {
            if (pDropIndex)
            {
                timerSelect.stop();

                pDropIndex = 0;

                lineDrop     .visible = false;
                rectangleDrop.visible = false;
            }

            return;
        }

        var pos = mapToItem(list, event.x, event.y);

        var y = pos.y;

        var index;

        if (gui.dragType != LibraryItem.Folder && pos.x < st.dp32 && y < list.height)
        {
            index = Math.floor(y / list.itemSize);

            if (rectangleDrop.visible && pDropIndex == index) return;

            var type = core.itemType(folder, index);

            if (type == LibraryItem.Folder)
            {
                if (folder.getLibraryItemAt(index) != gui.dragItem)
                {
                    pDropIndex = index;

                    rectangleDrop.y = index * list.itemSize;

                    lineDrop     .visible = false;
                    rectangleDrop.visible = true;

                    if (pDropIndex != folder.currentIndex)
                    {
                        timerSelect.restart();
                    }

                    return;
                }
            }
        }

        timerSelect.stop();

        index = Math.round(y / list.itemSize);

        if      (index < 0)     index = 0;
        else if (index > count) index = count;

        if (lineDrop.visible && pDropIndex == index) return;

        pDropIndex = index;

        y = index * list.itemSize;

        var min = rectangleDrop.size;
        var max;

        if (isScrollable) max = contentHeight - rectangleDrop.sizeHeight;
        else              max = contentHeight - rectangleDrop.size;

        if      (y < min) y = min;
        else if (y > max) y = max;

        lineDrop.y = y;

        rectangleDrop.visible = false;
        lineDrop     .visible = true;
    }

    //---------------------------------------------------------------------------------------------

    function pOnDropTrack(event)
    {
        if (pDropIndex == -1)
        {
            if (folder.isFull) return;

            createItem(0);

            if (gui.drag == 0)
            {
                 setAddTracks(gui.dragItem, gui.dragData);
            }
            else setAddTrackSource(event.text);
        }
        else if (gui.drag == 0)
        {
            var playlist = gui.dragItem;

            if (folder.itemIsPlaylist(pDropIndex))
            {
                if (folder.getLibraryItemAt(pDropIndex) == playlist) return;

                if (gui.copyTracksToPlaylist(playlist, gui.dragData, folder, pDropIndex))
                {
                    var length = gui.dragData.length;

                    if (length == 1)
                    {
                         pSetDropItem(pDropIndex, true, qsTr("Track added"));
                    }
                    else pSetDropItem(pDropIndex, true, length + " " + qsTr("Tracks added"));
                }
                else pSetDropItem(pDropIndex, false, qsTr("Playlist is full"));
            }
            else gui.copyTracksToFolder(playlist, gui.dragData, folder, pDropIndex);
        }
        else if (folder.itemIsPlaylist(pDropIndex))
        {
            if (gui.insertTrackToPlaylist(event.text, folder, pDropIndex))
            {
                 pSetDropItem(pDropIndex, true, qsTr("Track added"));
            }
            else pSetDropItem(pDropIndex, false, qsTr("Playlist is full"));
        }
        else gui.copyTrackToFolder(event.text, folder, pDropIndex);
    }

    function pOnDropItem(event)
    {
        if (gui.drag == 1)
        {
            var item = gui.dragItem;

            var index = item.indexFromId(gui.dragId);

            if (index != -1)
            {
                if (event.action == Qt.MoveAction)
                {
                    if (rectangleDrop.visible)
                    {
                        if (folder.getLibraryItemAt(pDropIndex) == item) return;

                        if (gui.movePlaylistToFolder(item, index, folder, pDropIndex))
                        {
                             pSetDropItem(pDropIndex, true, qsTr("Playlist moved"));
                        }
                        else pSetDropItem(pDropIndex, false, qsTr("Folder is full"));
                    }
                    else if (folder == item)
                    {
                        folder.moveAt(index, pDropIndex);
                    }
                    else if (item == feeds)
                    {
                        gui.copyPlaylist(item, index, folder, pDropIndex);
                    }
                    else gui.movePlaylist(item, index, folder, pDropIndex);
                }
                else if (rectangleDrop.visible)
                {
                    if (gui.copyPlaylistToFolder(item, index, folder, pDropIndex))
                    {
                         pSetDropItem(pDropIndex, true, qsTr("Playlist added"));
                    }
                    else pSetDropItem(pDropIndex, false, qsTr("Folder is full"));
                }
                else gui.copyPlaylist(item, index, folder, pDropIndex);
            }
        }
        else if (rectangleDrop.visible)
        {
            if (gui.copyPlaylistUrlToFolder(pDropType, event.text, folder, pDropIndex))
            {
                 pSetDropItem(pDropIndex, true, qsTr("Playlist added"));
            }
            else pSetDropItem(pDropIndex, false, qsTr("Folder is full"));
        }
        else gui.copyPlaylistUrl(pDropType, event.text, folder, pDropIndex);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timerSelect

        interval: st.scrollFolderCreate_durationSelect

        onTriggered:
        {
            folder.currentIndex = pDropIndex;

            areaDrag.collapse();
        }
    }

    Timer
    {
        id: timerAdd

        interval: st.scrollFolderCreate_durationAdd

        onTriggered:
        {
            pSetDropping(false);

            pClearDropItem();
        }
    }

    ItemNew
    {
        id: itemNew

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.top

        visible: false

        states: State
        {
            name: "active"; when: isCreating

            AnchorChanges
            {
                target: itemNew

                anchors.top   : parent.top
                anchors.bottom: undefined
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation
                {
                    duration: (enableAnimation && pAnimate) ? st.duration_faster : 0

                    easing.type: st.easing
                }

                ScriptAction
                {
                    script:
                    {
                        if (isCreating) return;

                        itemNew.visible = false;

                        type = -1;

                        list.enableContextual = true;

                        pSetDropping(false);

                        updateVisible();

                        if (pAdd != -1)
                        {
                            pAdd = -1;

                            pClearAddItem();
                        }

                        finished();
                    }
                }
            }
        }

        onIsFocusedChanged:
        {
            if (isFocused)
            {
                itemNew.visible = true;

                pAnimate = true;

                isCreating = true;

                return;
            }

            if (window.isActive == false || visible == false)
            {
                text = "";

                clear();
            }
            else if (text != "")
            {
                pCreateItem();

                text = "";

                pAnimate = false;

                create();
            }
            else clear();

            isCreating = false;
        }

        onModeChanged: type = -1

        function onKeyPressed(event)
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                window.clearFocus();
            }
            else if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                text = "";

                window.clearFocus();
            }
        }
    }

    LabelRoundAnimated
    {
        id: label

        height: st.dp32

        x: st.dp32

        y: (pDropItem) ? list.y + pDropItem.y : 0

        maximumWidth: (pDropItem) ? pDropItem.itemText.width : 0

        visible: (pDropItem != null)

        enableAnimation: (pDropItem != null)
    }

    LineHorizontalDrop
    {
        id: lineDrop

        opacity: (visible) ? bordersDrop.opacity : 1.0
    }

    RectangleBordersDrop
    {
        id: rectangleDrop

        width:
        {
            if (pDropType)
            {
                return st.itemList_iconWidth;
            }
            else if (isScrollable)
            {
                 return parent.width - size;
            }
            else return parent.width - sizeWidth;
        }

        height: (pDropType) ? st.itemList_iconHeight
                            : st.itemList_height

        x: (pDropType) ? 0 : size

        opacity: (visible) ? bordersDrop.opacity : 1.0
    }
}
