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

List
{
    id: list

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool hasFolder: false

    property LibraryFolder folder: null

    property variant listFolder  : null
    property variant listPlaylist: null

    /* read */ property variant itemHovered: null

    /* read */ property int indexHover  : (itemHovered) ? itemHovered.getIndex() : -1
    /* read */ property int indexCurrent: -1

    /* read */ property int indexContextual: -1
    /* read */ property int indexDrag      : -1
    /* read */ property int indexEdit      : -1

    /* read */ property int indexActive: (indexContextual != -1) ? indexContextual
                                                                 : indexHover

    property bool enableLoad      : true
    property bool enablePreview   : true
    property bool enablePlay      : true
    property bool enableContextual: true
    property bool enableAdd       : true
    property bool enableDrag      : true
    property bool enableDragMove  : false

    property variant itemLeft  : null
    property variant itemRight : null
    property variant itemTop   : null
    property variant itemBottom: null

    //---------------------------------------------------------------------------------------------
    // Private

    property LibraryFolder pFolder: null

    property variant pCurrentItem: null

    property int pActiveType: (folder) ? core.itemType(folder, folder.activeIndex) : -1

    property int pIndex: -1

    property int pDragType: -1

    property int pDragX: -1
    property int pDragY: -1

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias lineEdit: lineEdit

    property alias overlay: overlay

    property alias buttonContextual: buttonContextual

    property alias itemWatcher: itemWatcher

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    model: ModelLibraryFolder { id: model }

    delegate: ComponentFolder {}

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onFolderChanged:
    {
        if (folder)
        {
            hasFolder = true;

            if (enableLoad && folder.count == 0) folder.loadQuery();

            pApplyFolder();

            indexCurrent = folder.currentIndex;

            if (folder == gui.dragItem)
            {
                 indexDrag = folder.indexFromId(gui.dragId);
            }
            else indexDrag = -1;

            pRestoreScroll();
        }
        else
        {
            hasFolder = false;

            pApplyFolder();

            indexCurrent = -1;
            indexDrag    = -1;
        }

        pUpdateCurrentY();
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (folder == null) return;

        if (event.key == Qt.Key_Left && event.modifiers == Qt.NoModifier)
        {
            event.accepted = true;

            if (itemLeft) itemLeft.focus();
        }
        else if (event.key == Qt.Key_Right && event.modifiers == Qt.NoModifier)
        {
            event.accepted = true;

            if (itemRight) itemRight.focus();
        }
        else if (event.key == Qt.Key_Up && event.modifiers == Qt.NoModifier)
        {
            event.accepted = true;

            if (indexCurrent == 0)
            {
                if (itemTop) itemTop.focus();

                return;
            }

            selectPreviousItem();

            areaContextual.hidePanels();
        }
        else if (event.key == Qt.Key_Down && event.modifiers == Qt.NoModifier)
        {
            event.accepted = true;

            if (indexCurrent == (count - 1))
            {
                if (itemBottom) itemBottom.focus();

                return;
            }

            selectNextItem();

            areaContextual.hidePanels();
        }
        else if ((event.key == Qt.Key_Return || event.key == Qt.Key_Enter) && enablePlay)
        {
            event.accepted = true;

            pPlay();
        }
        else if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            window.clearFocus();
        }
        else if (event.key == Qt.Key_Menu && enableContextual)
        {
            event.accepted = true;

            scrollToItem(indexCurrent);

            panelContextual.loadPageFolder(list, indexCurrent);

            pShowPanel(panelContextual, indexCurrent, -1, -1, false);
        }
        else if (event.key == Qt.Key_Plus && enableAdd)
        {
            event.accepted = true;

            scrollToItem(indexCurrent);

            panelAdd.setSource(1, folder, indexCurrent);

            pShowPanel(panelAdd, indexCurrent, -1, -1, false);
        }
        else if (event.key == Qt.Key_Delete)
        {
            event.accepted = true;

            if (folder.isFolderBase == false) return;

            scrollToItem(indexCurrent);

            showPanel(indexCurrent);

            areaContextual.currentPage.currentId = 5;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: sk

        onAboutToQuit: saveScroll()
    }

    Connections
    {
        target: window

        onDragEnded: indexDrag = -1
    }

    Connections
    {
        target: gui

        onScaleBefore: saveScroll    ()
        onScaleAfter : pRestoreScroll()
    }

    Connections
    {
        target: (hasFolder) ? folder : null

        onLoaded: pRestoreScroll()

        onCurrentIdChanged:
        {
            clearIndexEdit();

            pUpdateSelected();

            if (folder.currentId == -1 && activeFocus)
            {
                window.clearFocus();
            }
        }

        onCurrentIndexChanged:
        {
            indexCurrent = folder.currentIndex;

            pUpdateCurrentY();

            scrollToCurrentItem();
        }

        onCurrentIdUpdated: scrollToCurrentItem()

        onItemsInserted:
        {
            if      (indexContextual >= index) indexContextual += count;
            else if (indexDrag       >= index) indexDrag       += count;
            else if (indexEdit       >= index) indexEdit       += count;
        }

        onItemRemoved:
        {
            if      (indexContextual > index) indexContextual--;
            else if (indexDrag       > index) indexDrag--;
            else if (indexEdit       > index) indexEdit--;
        }

        onItemMoved:
        {
            clearIndexEdit();

            indexContextual = -1;
            indexDrag       = -1;
        }

        onItemsCleared:
        {
            timer.stop();

            pIndex = -1;

            itemHovered = null;

            indexContextual = -1;
            indexDrag       = -1;

            pUpdateCurrentY();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function focus()
    {
        if (activeFocus || count == 0) return;

        forceActiveFocus();

        if (indexCurrent == -1)
        {
            pSetCurrentItem(0);
        }
        else scrollToCurrentItem();
    }

    function focusList()
    {
        forceActiveFocus();
    }

    //---------------------------------------------------------------------------------------------

    function selectPreviousItem()
    {
        if (folder == null || indexCurrent == -1 || indexCurrent == 0) return;

        clearIndexEdit();

        pSetCurrentItem(indexCurrent - 1);
    }

    function selectNextItem()
    {
        if (folder == null || indexCurrent == -1 || indexCurrent == (count - 1)) return;

        clearIndexEdit();

        pSetCurrentItem(indexCurrent + 1);
    }

    //---------------------------------------------------------------------------------------------

    function setItemHovered(item)
    {
        itemHovered = item;

//#QT_5
        if (overlay.visible && overlay.containsMouse) pUpdatePreview();
//#END
    }

    function clearItemHovered()
    {
        itemHovered = null;
    }

    //---------------------------------------------------------------------------------------------

    function clearIndexEdit()
    {
        if (indexEdit == -1) return;

        if (visible && lineEdit.text)
        {
            folder.setItemTitle(indexEdit, lineEdit.text);
        }

        indexEdit = -1;
    }

    //---------------------------------------------------------------------------------------------

    function showPanelAt(index, x, y, isCursorChild)
    {
        if (enableContextual == false || index == -1) return;

        panelContextual.loadPageFolder(list, index);

        pShowPanel(panelContextual, index, x, y, isCursorChild);
    }

    function showPanel(index)
    {
        showPanelAt(index, -1, -1, false);
    }

    //---------------------------------------------------------------------------------------------

    function showAddAt(index, x, y, isCursorChild)
    {
        if (enableAdd == false || index == -1) return;

        panelAdd.setSource(1, folder, index);

        pShowPanel(panelAdd, index, x, y, isCursorChild);
    }

    function showAdd(index)
    {
        showAddAt(index, -1, -1, false);
    }

    //---------------------------------------------------------------------------------------------

    function insertItem(index, type, text, animate)
    {
        if (folder == null) return;

        if (index == -1) index = count;

        clearIndexEdit();

        folder.insertNewItem(index, type);

        folder.setItemTitle(index, text);

        scrollToItem(index);

        if (animate) animateAdd(index);
    }

    function insertLibraryItem(index, item, animate)
    {
        if (folder == null) return;

        if (index == -1) index = count;

        folder.insertLibraryItem(index, item);

        if (animate) animateAdd(index);
    }

    //---------------------------------------------------------------------------------------------

    function animateAdd(index)
    {
        var item = itemAt(index);

        if (item)
        {
            item.animateAdd();

            timer.start();
        }
    }

    //---------------------------------------------------------------------------------------------

    function renameItem(index)
    {
        if (folder == null) return;

        lineEdit.text = folder.itemTitle(index);

        lineEdit.textInput.selectAll();

        indexEdit = index;

        scrollToItem(index);
    }

    //---------------------------------------------------------------------------------------------

    function removeItem(index, animate)
    {
        if (index < 0 || index >= count) return;

        pRemove(index, animate);
    }

    //---------------------------------------------------------------------------------------------

    function scrollToCurrentItem()
    {
        scrollToItem(indexCurrent);
    }

    //---------------------------------------------------------------------------------------------

    function currentItemY()
    {
        return itemY(indexCurrent);
    }

    //---------------------------------------------------------------------------------------------

    function saveScroll()
    {
        if (folder) pSaveScroll(folder);
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onContextualClear()
    {
        if (indexContextual != indexHover)
        {
            areaContextual.clearLastParent();
        }

        indexContextual = -1;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pApplyFolder()
    {
        if (pFolder)
        {
            pProcessRemove((pFolder));

            pFolder.abortItems();
            pFolder.abortQuery();

            pSaveScroll(pFolder);
        }

        itemHovered = null;

        indexContextual = -1;

        pFolder = folder;

        model.folder = folder;

        clearIndexEdit();

        pUpdateSelected();
    }

    //---------------------------------------------------------------------------------------------

    function pSelectItem(index)
    {
        if (folder == library)
        {
            panelBrowse.collapse();
        }

        if (index != indexCurrent)
        {
            focusList();

            clearIndexEdit();

            pSetCurrentItem(index);
        }
        else
        {
            focusList();

            pUpdateVisible();
        }
    }

    function pSetCurrentItem(index)
    {
        indexCurrent = index;

        folder.currentIndex = index;

        scrollToCurrentItem();
    }

    //---------------------------------------------------------------------------------------------

    function pPlay()
    {
        if (listPlaylist == null) return;

        var item = folder.currentItem;

        if (item && item.isPlaylist)
        {
            listPlaylist.playFirstTrack();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pShowPanel(panel, index, x, y, isCursorChild)
    {
        clearIndexEdit();

        indexContextual = index;

        if (areaContextual.showPanelAt(panel, itemWatcher, x, y, isCursorChild))
        {
            areaContextual.parentContextual = list;
        }
        else indexContextual = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pDragInit(type, x, y)
    {
        if (type != LibraryItem.Playlist && type != LibraryItem.PlaylistFeed
            &&
            type != LibraryItem.Folder) return;

        pDragType = type;

        pDragX = x;
        pDragY = y;
    }

    function pDragCheck(x, y, index)
    {
        if (window.testDrag(Qt.point(pDragX, pDragY), Qt.point(x, y), 8) == false)
        {
            return;
        }

        folder.addDeleteLock();

        indexDrag = index;

        pDragX = -1;
        pDragY = -1;

        gui.drag      = 1;
        gui.dragList  = list;
        gui.dragItem  = folder;
        gui.dragId    = folder.idAt(index);
        gui.dragType  = pDragType;

        if (scrollArea && list != gui.listLibrary && list != gui.listFolder)
        {
            areaDrag.setItem(scrollArea);
        }

        var source = folder.itemSource(index);

        var title;
        var cover;

        if (pDragType == LibraryItem.PlaylistFeed)
        {
            pSavePlaylistScroll();

            if (core.itemState(folder, index) != LocalObject.Loading)
            {
                title = folder.itemTitle(index);

                if (title == "")
                {
                    title = qsTr("Invalid Feed");
                }
            }
            else title = qsTr("Loading Feed...");

            cover = st.icon32x32_feed;
        }
        else if (pDragType == LibraryItem.Playlist)
        {
            pSavePlaylistScroll();

            if (core.itemState(folder, index) != LocalObject.Loading)
            {
                title = folder.itemTitle(index);

                if (title == "")
                {
                    title = qsTr("Invalid Playlist");
                }
            }
            else title = qsTr("Loading Playlist...");

            cover = st.icon32x32_playlist;
        }
        else
        {
            if (core.itemState(folder, index) != LocalObject.Loading)
            {
                title = folder.itemTitle(index);

                if (title == "")
                {
                    title = qsTr("Invalid Folder");
                }
            }
            else title = qsTr("Loading Folder...");

            cover = st.icon32x32_folder;
        }

        toolTip.showIcon(title, cover, folder.itemCover(index), 32, 32);

        if (enableDragMove)
        {
             window.startDrag(source, Qt.MoveAction | Qt.CopyAction);
        }
        else window.startDrag(source, Qt.CopyAction);
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateSelected()
    {
        var oldItem = pCurrentItem;

        if (folder) pCurrentItem = folder.currentItem;
        else        pCurrentItem = null;

        if (pCurrentItem == null)
        {
            if (oldItem)
            {
                if (listPlaylist && listPlaylist.playlist == oldItem)
                {
                    listPlaylist.playlist = null;
                }
                else if (listFolder && listFolder.folder == oldItem)
                {
                    listFolder.folder = null;
                }
            }

            return;
        }

        if (pCurrentItem.isPlaylist && listPlaylist)
        {
            listPlaylist.playlist = pCurrentItem;

            if (oldItem && listFolder && listFolder.folder == oldItem)
            {
                listFolder.folder = null;
            }
        }
        else if (pCurrentItem.isFolder && listFolder)
        {
            listFolder.folder = pCurrentItem;

            if (oldItem && listPlaylist && listPlaylist.playlist == oldItem)
            {
                listPlaylist.playlist = null;
            }
        }
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateCurrentY()
    {
        if (scrollArea) scrollArea.updateCurrentY();
    }

    function pUpdateVisible()
    {
        if (scrollArea) scrollArea.updateVisible();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdatePreview()
    {
        if (itemHovered == null) return;

        panelPreview.activateFolder(list);
    }

    //---------------------------------------------------------------------------------------------

    function pRemove(index, animate)
    {
        pProcessRemove(folder);

        indexContextual = -1;

        if (animate)
        {
            var item = itemAt(index);

            if (item) item.animateRemove();

            pIndex = index;

            timer.start();
        }
        else folder.removeAt(index);
    }

    function pProcessRemove(folder)
    {
        if (pIndex == -1) return;

        timer.stop();

        folder.removeAt(pIndex);

        pIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSaveScroll(folder)
    {
        if (scrollArea == null) return;

        folder.scrollValue = scrollArea.value / itemSize;
    }

    function pRestoreScroll()
    {
        if (scrollArea == null || folder == null) return;

        if (folder.scrollValue)
        {
             scrollArea.value = folder.scrollValue * itemSize;
        }
        else scrollArea.scrollToTop();
    }

    //---------------------------------------------------------------------------------------------

    function pSavePlaylistScroll()
    {
        var item = folder.currentItem;

        if (item && item.isPlaylist)
        {
            listPlaylist.saveScroll();

            listPlaylist.playlist.saveNow();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_normal

        onTriggered: pProcessRemove(folder)
    }

    BaseButtonPiano
    {
        id: overlay

        width : st.dp32 + borderSizeWidth
        height: itemSize

        y: indexHover * itemSize

        borderBottom: borderSize

        visible: (enablePreview && itemHovered != null && itemHovered.getCover() != "")

        isHovered: false
        isPressed: (pressedButtons & Qt.LeftButton)

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        highlighted: true
        checked    : true

        borderColor:
        {
            if (itemHovered != null && itemHovered.isDefault)
            {
                 return st.itemList_colorBorderDefault;
            }
            else return st.itemList_colorBorder;
        }

        background.visible: containsMouse
        borders   .visible: background.visible

        background.opacity: 0.8

        onEntered: pUpdatePreview()

        onExited: panelPreview.clearNow()

        Behavior on background.visible
        {
            enabled: overlay.background.visible

            PropertyAnimation { duration: st.duration_faster }
        }
    }

    Icon
    {
        anchors.top: overlay.top

        visible: overlay.background.visible

        source    : st.icon32x32_search
        sourceSize: st.size32x32

        style: st.icon_raised
    }

    ButtonPushIcon
    {
        id: buttonContextual

        anchors.right: parent.right

        anchors.rightMargin: st.dp4

        y: itemWatcher.y + st.dp2

        visible: (enableContextual && gui.dragList != list && itemWatcher.visible
                  &&
                  timer.running == false && (indexEdit == -1 || indexEdit != indexHover))

        checked: (indexContextual != -1)

        width : st.dp28
        height: st.dp28

        icon          : st.icon16x16_contextualDown
        iconSourceSize: st.size16x16

        onPressed: showPanel(indexHover)
    }

    BorderVertical
    {
        id: border

        anchors.top   : lineEdit.top
        anchors.bottom: lineEdit.bottom

        x: st.dp32

        visible: lineEdit.visible
    }

    LineEditBox
    {
        id: lineEdit

        anchors.left : border.right
        anchors.right: parent.right

        height: st.dp32

        y: indexEdit * itemSize

        visible: (indexEdit != -1)

        onVisibleChanged: if (visible) focus()

        onIsFocusedChanged: if (isFocused == false) clearIndexEdit()

        function onKeyPressed(event)
        {
            if ((event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                &&
                event.modifiers == Qt.NoModifier)
            {
                event.accepted = true;

                focusList();
            }
            else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter
                     ||
                     event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                clearIndexEdit();
            }
        }
    }

    Item
    {
        id: itemWatcher

        anchors.left : parent.left
        anchors.right: parent.right

        height: itemSize

        y: (indexActive != -1) ? indexActive * itemSize : 0

        visible: (indexActive != -1)
    }
}
