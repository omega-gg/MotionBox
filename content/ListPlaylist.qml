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

BaseList
{
    id: list

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool hasPlaylist: false

    property Playlist playlist: null

    /* read */ property bool isSelecting: false

    /* read */ property variant itemHovered: null

    /* read */ property int indexHover: (itemHovered) ? itemHovered.getIndex() : -1

    /* read */ property int indexPreview   : -1
    /* read */ property int indexContextual: -1
    /* read */ property int indexPlayer    : -1

    /* read */ property int indexActive: (indexContextual != -1) ? indexContextual
                                                                 : indexHover

    property bool enableLoad      : true
    property bool enablePreview   : true
    property bool enableContextual: true
    property bool enableAdd       : true
    property bool enableLink      : false
    property bool enableDrag      : true
    property bool enableDragMove  : false

    property variant itemLeft  : null
    property variant itemRight : null
    property variant itemTop   : null
    property variant itemBottom: null

    //---------------------------------------------------------------------------------------------
    // Private

    property Playlist pPlaylist: null

    property bool pSelect: true
    property bool pScroll: true

    property variant pIndexes: null

    property int pDragX: -1
    property int pDragY: -1

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias linkIcon          : buttonLink.icon
    property alias linkIconSourceSize: buttonLink.iconSourceSize

    //---------------------------------------------------------------------------------------------

    property alias overlay: overlay

    property alias checkBox        : checkBox
    property alias buttonContextual: buttonContextual
    property alias buttonLink      : buttonLink

    property alias itemWatcher: itemWatcher

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal link(int index)

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    model: ModelPlaylist { id: model }

    delegate: ComponentTrack {}

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onPlaylistChanged:
    {
        if (playlist)
        {
            hasPlaylist = true;

            if (enableLoad && playlist.count == 0) playlist.loadQuery();

            pApplyPlaylist();

            pUpdateSelected();

            pUpdatePlayerOverlay();

            pRestoreScroll();
        }
        else
        {
            hasPlaylist = false;

            pApplyPlaylist();
        }

        pUpdateCurrentY();
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ Keys.onPressed: function(event)
    {
        if (playlist == null) return;

        var index;

        if (event.key == Qt.Key_Left && event.modifiers == sk.keypad(Qt.NoModifier))
        {
            event.accepted = true;

            if (itemLeft) itemLeft.setFocus();
        }
        else if (event.key == Qt.Key_Right && event.modifiers == sk.keypad(Qt.NoModifier))
        {
            event.accepted = true;

            if (itemRight) itemRight.setFocus();
        }
        else if (event.key == Qt.Key_Up && (event.modifiers == sk.keypad(Qt.NoModifier)
                                            ||
                                            event.modifiers == sk.keypad(Qt.ShiftModifier)))
        {
            event.accepted = true;

            selectPreviousTrack();

            areaContextual.hidePanels();
        }
        else if (event.key == Qt.Key_Down && (event.modifiers == sk.keypad(Qt.NoModifier)
                                              ||
                                              event.modifiers == sk.keypad(Qt.ShiftModifier)))
        {
            event.accepted = true;

            selectNextTrack();

            areaContextual.hidePanels();
        }
        else if ((event.key == Qt.Key_Return || event.key == Qt.Key_Enter))
        {
            event.accepted = true;

            index = playlist.lastSelected;

            pSetCurrentTrack(index);

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

            index = playlist.lastSelected;

            scrollToItem(index);

            panelContextual.loadPageTrack(list, index);

            pShowPanel(panelContextual, index, -1, -1, false);
        }
        else if (event.key == Qt.Key_Plus && enableAdd)
        {
            event.accepted = true;

            index = playlist.lastSelected;

            scrollToItem(index);

            panelAdd.setSource(0, playlist, -1);

            pShowPanel(panelAdd, index, -1, -1, false);
        }
        else if (event.key == Qt.Key_Delete)
        {
            event.accepted = true;

            if (list != gui.listPlaylist) return;

            index = playlist.lastSelected;

            if (index == -1) return;

            if (playlist.selectedCount == 1)
            {
                var item = itemAt(index);

                if (item)
                {
                    removeTrack(index, true);
                }
                else scrollToItem(index);
            }
            else
            {
                scrollToItem(index);

                showPanel(index);

                areaContextual.currentPage.selectedId = 1; // Tracks remove
            }
        }
        else if (event.key == Qt.Key_A && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            playlist.selectAll();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: sk

        /* QML_CONNECTION */ function onAboutToQuit() { saveScroll(); }
    }

    Connections
    {
        target: gui

        /* QML_CONNECTION */ function onScaleBefore() { saveScroll    (); }
        /* QML_CONNECTION */ function onScaleAfter () { pRestoreScroll(); }
    }

    Connections
    {
        target: (hasPlaylist) ? playlist : null

        /* QML_CONNECTION */ function onSelectedTracksChanged()
        {
            pUpdateCurrentY();

            pUpdateCheckBox(indexHover);

            if (playlist.selectedCount != 1) return;

            setPlaylistFocus(playlist);

            var index = playlist.lastSelected;

            if (player.isPlaying == false || highlightedTab)
            {
                pSetCurrentTrack(index);
            }

            if (index != -1 && pScroll)
            {
                scrollToItem(index);
            }
        }

        /* QML_CONNECTION */ function onTracksInserted(index)
        {
            if      (indexPreview    >= index) indexPreview    += count;
            if      (indexContextual >= index) indexContextual += count;
            else if (indexPlayer     >= index) indexPlayer     += count;
        }

        /* QML_CONNECTION */ function onTracksRemoved(indexes)
        {
            var countPreview    = 0;
            var countContextual = 0;
            var countPlayer     = 0;

            for (var i = 0; i < indexes.length; i++)
            {
                var index = indexes[i];

                if      (indexPreview    > index) countPreview++;
                if      (indexContextual > index) countContextual++;
                else if (indexPlayer     > index) countPlayer++;
            }

            indexPreview    -= countPreview;
            indexContextual -= countContextual;
            indexPlayer     -= countPlayer;
        }

        /* QML_CONNECTION */ function onTracksMoved()
        {
            indexPreview    = -1;
            indexContextual = -1;

            pUpdatePlayerOverlay();
        }

        /* QML_CONNECTION */ function onTracksCleared()
        {
            timer.stop();

            pIndexes = null;

            pClearPreview();

            itemHovered = null;

            indexPreview    = -1;
            indexContextual = -1;
            indexPlayer     = -1;

            pUpdateCurrentY();
        }
    }

    Connections
    {
        target: tabs

        /* QML_CONNECTION */ function onCurrentTabChanged() { pUpdateSelected(); }
    }

    Connections
    {
        target: currentTab

        /* QML_CONNECTION */ function onCurrentBookmarkChanged()
        {
            if (playlist && pSelect && (player.isPlaying == false || highlightedTab))
            {
                if (currentTab.playlist == playlist)
                {
                     playlist.selectSingleTrack(playlist.currentIndex);
                }
                else playlist.unselectTracks();
            }
        }
    }

    Connections
    {
        target: player

        /* QML_CONNECTION */ function onCurrentTrackUpdated() { pUpdatePlayerOverlay(); }
        /* QML_CONNECTION */ function onHasStartedChanged  () { pUpdatePlayerOverlay(); }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        if (activeFocus || count == 0) return;

        forceActiveFocus();

        if (playlist.selectedCount == 0)
        {
            var index = playlist.currentIndex;

            if (index == -1) index = 0;

            playlist.selectSingleTrack(index);

            scrollToItem(index);
        }
        else scrollToItem(playlist.lastSelected);
    }

    function focusList()
    {
        forceActiveFocus();
    }

    //---------------------------------------------------------------------------------------------

    function selectTrack(index)
    {
        if (count) pSelectTrack(index);
    }

    function selectSingleTrack(index)
    {
        if (count) pSelectSingleTrack(index);
    }

    //---------------------------------------------------------------------------------------------

    function unselectTrack(index)
    {
        if (count) playlist.unselectTrack(index);
    }

    //---------------------------------------------------------------------------------------------

    function selectPreviousTrack()
    {
        if (playlist == null) return;

        var last = playlist.lastSelected;

        var index;

        if (last == -1 || last == 0)
        {
            if (itemTop) itemTop.setFocus();

            return;
        }
        else index = last - 1;

        if (window.keyShiftPressed)
        {
            if (playlist.selectedCount > 1)
            {
                if (playlist.selectedAligned)
                {
                    var first = playlist.firstSelected;

                    if (first > index)
                    {
                         playlist.selectTrack(index);
                    }
                    else playlist.unselectTrack(last);

                    scrollToItem(index);
                }
                else
                {
                    playlist.selectSingleTrack(last);

                    if (last > 0)
                    {
                        last--;

                        playlist.selectTrack(last);

                        scrollToItem(last);
                    }
                }
            }
            else
            {
                playlist.selectTrack(index);

                scrollToItem(index);
            }
        }
        else playlist.selectSingleTrack(index);
    }

    function selectNextTrack()
    {
        if (playlist == null) return;

        var last = playlist.lastSelected;

        var index;

        if (last == -1 || last == (count - 1))
        {
            if (itemBottom) itemBottom.setFocus();

            return;
        }
        else index = last + 1;

        if (window.keyShiftPressed)
        {
            if (playlist.selectedCount > 1)
            {
                if (playlist.selectedAligned)
                {
                    var first = playlist.firstSelected;

                    if (first < index)
                    {
                         playlist.selectTrack(index);
                    }
                    else playlist.unselectTrack(last);

                    scrollToItem(index);
                }
                else
                {
                    playlist.selectSingleTrack(last);

                    if (last != -1 && last != (count - 1))
                    {
                        last++;

                        playlist.selectTrack(last);

                        scrollToItem(last);
                    }
                }
            }
            else
            {
                playlist.selectTrack(index);

                scrollToItem(index);
            }
        }
        else playlist.selectSingleTrack(index);
    }

    //---------------------------------------------------------------------------------------------

    function playAt(index)
    {
        if (index < 0 || index >= count) return;

        gui.playTrack(playlist, index, false);
    }

    function playFirstTrack()
    {
        if (count == 0) return;

        if (indexPlayer == -1)
        {
            var index;

            if (playlist.currentId == -1)
            {
                 index = 0;
            }
            else index = playlist.currentIndex

            gui.playTrack(playlist, index, true);
        }
        else player.play();

        playlist.selectCurrentTrack();
    }

    //---------------------------------------------------------------------------------------------

    function setItemHovered(item)
    {
        if (itemHovered == item) return;

        itemHovered = item;

        if (indexContextual == -1)
        {
            pUpdateCheckBox(indexHover);
        }

//#QT_NEW
        if (overlay.visible && overlay.hoverActive) pUpdatePreview();
//#END
    }

    function clearItemHovered()
    {
        itemHovered = null;
    }

    //---------------------------------------------------------------------------------------------

    function showPanelAt(index, x, y, isCursorChild)
    {
        if (enableContextual == false || index == -1) return;

        panelContextual.loadPageTrack(list, index);

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

        panelAdd.setSource(0, playlist, -1);

        pShowPanel(panelAdd, index, x, y, isCursorChild);
    }

    function showAdd(index)
    {
        showAddAt(index, -1, -1, false);
    }

    //---------------------------------------------------------------------------------------------

    function insertSource(index, url, animate)
    {
        if (playlist == null || playlist.isFull)
        {
            return false;
        }

        if (index == -1)
        {
            if (playlist.isFeed) index = 0;
            else                 index = count;
        }

        var size = playlist.insertSource(index, url);

        if (animate)
        {
            var array = new Array;

            while (size)
            {
                array.push(index);

                index++;

                size--;
            }

            animateAdd(array);
        }

        return true;
    }

    //---------------------------------------------------------------------------------------------

    function copyTracksFrom(source, indexes, to, animate)
    {
        var length = indexes.length;

        if (playlist == null || playlist.checkFull(length))
        {
            return false;
        }

        if (to == -1)
        {
            if (playlist.isFeed) to = 0;
            else                 to = count;
        }

        source.copyTracksTo(indexes, playlist, to);

        if (animate)
        {
            var array = new Array;

            for (var i = 0; i < length; i++)
            {
                array.push(to);

                to++;
            }

            animateAdd(array);
        }

        return true;
    }

    function copyTrackFrom(source, from, to, animate)
    {
        if (from == -1)
        {
            return copyTracksFrom(source, source.selectedTracks, to, animate);
        }
        else if (playlist == null || playlist.isFull)
        {
            return false;
        }

        if (to == -1)
        {
            if (playlist.isFeed) to = 0;
            else                 to = count;
        }

        source.copyTrackTo(from, playlist, to);

        if (animate)
        {
            var array = new Array;

            array.push(to);

            animateAdd(array);
        }

        return true;
    }

    function copySelectedFrom(source, to, animate)
    {
        return copyTracksFrom(source, source.selectedTracks, to, animate);
    }

    //---------------------------------------------------------------------------------------------

    function animateAdd(indexes)
    {
        var animate = false;

        var count = Math.min(indexes.length, 20);

        for (var i = 0; i < count; i++)
        {
            var item = itemAt(indexes[i]);

            if (item)
            {
                item.animateAdd();

                animate = true;
            }
        }

        if (animate) timer.start();
    }

    //---------------------------------------------------------------------------------------------

    function removeTrack(index, animate)
    {
        if (index < 0 || index >= count) return;

        var array = new Array;

        array.push(index);

        pRemove(array, animate);
    }

    function removeSelected(animate)
    {
        if (playlist == null) return;

        pRemove(playlist.selectedTracks, animate);
    }

    //---------------------------------------------------------------------------------------------

    function openInTab(index)
    {
        if (index < 0 || index >= count) return;

        if (currentTab.playlist == playlist)
        {
            var indexTab = tabs.indexOf(currentTab) + 1;

            if (itemTabs.openTabAt(indexTab) == false) return;
        }
        else if (itemTabs.openTab() == false) return;

        wall.asynchronous = false;

        playlist.selectSingleTrack(index);

        wall.asynchronous = true;
    }

    //---------------------------------------------------------------------------------------------

    function scrollToCurrentItem()
    {
        if (playlist) scrollToItem(playlist.currentIndex);
    }

    //---------------------------------------------------------------------------------------------

    function currentItemY()
    {
        if (playlist)
        {
             return itemY(playlist.currentIndex);
        }
        else return -1;
    }

    function selectedItemY()
    {
        if (playlist == null) return -1;

        var index = playlist.lastSelected;

        if (index == -1)
        {
             return -1;
        }
        else return itemY(index);
    }

    //---------------------------------------------------------------------------------------------

    function saveScroll()
    {
        if (playlist) pSaveScroll(playlist);
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

    function pApplyPlaylist()
    {
        if (pPlaylist)
        {
            pProcessRemove(pPlaylist);

            pPlaylist.unselectTracks();

            pPlaylist.abortTracks();
            pPlaylist.abortQuery ();

            pSaveScroll(pPlaylist);
        }

        pClearPreview();

        itemHovered = null;

        indexPreview    = -1;
        indexContextual = -1;
        indexPlayer     = -1;

        pPlaylist = playlist;

        model.playlist = playlist;
    }

    //---------------------------------------------------------------------------------------------

    function pSetCurrentTrack(index)
    {
        gui.setCurrentTrack(playlist, index);
    }

    function pUpdateCurrentTrack(index)
    {
        if (player.isPlaying == false || highlightedTab)
        {
            pSelect = false;

            playlist.currentIndex = index;

            pSelect = true;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pSelectTrack(index)
    {
        if (playlist.indexSelected(index))
        {
            if (window.keyControlPressed)
            {
                pScroll = false;

                if (playlist.currentIndex == index)
                {
                    playlist.unselectTrack(index);

                    pSelect = false;

                    playlist.currentIndex = playlist.lastSelected;

                    pSelect = true;
                }
                else playlist.unselectTrack(index);

                pScroll = true;

                scrollToItem(index);
            }
            else if (window.keyShiftPressed == false)
            {
                playlist.selectSingleTrack(index);
            }
        }
        else
        {
            if (window.keyShiftPressed)
            {
                if (playlist.selectedAligned == false)
                {
                    var last = playlist.lastSelected;

                    playlist.selectSingleTrack(last);
                }

                var closest = playlist.closestSelected(index);

                if (closest != -1)
                {
                    playlist.selectTracks(closest, index);

                    scrollToItem(index);

                    pUpdateCurrentTrack(index);
                }
                else playlist.selectSingleTrack(index);
            }
            else if (window.keyControlPressed)
            {
                playlist.selectTrack(index);

                scrollToItem(index);

                pUpdateCurrentTrack(index);
            }
            else playlist.selectSingleTrack(index);
        }
    }

    function pSelectSingleTrack(index)
    {
        playlist.selectSingleTrack(index);
    }

    //---------------------------------------------------------------------------------------------

    function pPlay()
    {
        if (highlightedTab) tabs.highlightedTab = null;

        player.replay();

        window.clearFocus();
    }

    //---------------------------------------------------------------------------------------------

    function pShowPanel(panel, index, x, y, isCursorChild)
    {
        indexContextual = index;

        if (areaContextual.showPanelAt(panel, itemWatcher, x, y, isCursorChild))
        {
            areaContextual.parentContextual = list;

            pUpdateCheckBox(index);
        }
        else indexContextual = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pDragInit()
    {
        if (enableDrag == false) return;

        pDragX = window.mouseX;
        pDragY = window.mouseY;
    }

    function pDragCheck()
    {
        if (window.testDrag(Qt.point(pDragX, pDragY),
                            Qt.point(window.mouseX, window.mouseY), st.dp10) == false) return;

        isSelecting = false;

        playlist.addDeleteLock();

        pDragX = -1;
        pDragY = -1;

        gui.drag      = 0;
        gui.dragList  = list;
        gui.dragItem  = playlist;
        gui.dragIndex = panelLibrary.index;
        gui.dragData  = playlist.selectedTracks;

        if (scrollArea && list != gui.listPlaylist)
        {
            areaDrag.setItem(scrollArea);
        }

        var source;

        var count = playlist.selectedCount;

        if (count == 1)
        {
            var index = playlist.lastSelected;

            var data = playlist.trackData(index);

            source = data.source;

            toolTip.showIcon(data.title, st.icon16x16_track, st.dp16, st.dp16,
                             data.cover, st.dp56, st.dp32);
        }
        else
        {
            source = playlist.selectedSources;

            toolTip.show(count + " " + qsTr("Tracks"), st.icon16x16_track, st.dp16, st.dp16);
        }

        if (enableDragMove)
        {
             window.startDrag(source, Qt.MoveAction | Qt.CopyAction);
        }
        else window.startDrag(source, Qt.CopyAction);

        panelLibrary.select(1);
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateSelected()
    {
        if (playlist == null) return;

        if (currentTab.playlist == playlist)
        {
            pScroll = false;

            playlist.selectSingleTrack(playlist.currentIndex);

            pScroll = true;
        }
        else playlist.unselectTracks();
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

    function pUpdatePlayerOverlay()
    {
        if (player.hasStarted && playlist && player.playlist == playlist)
        {
             indexPlayer = player.trackIndex;
        }
        else indexPlayer = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateCheckBox(index)
    {
        if (playlist && playlist.indexSelected(index))
        {
             checkBox.checked = true;
        }
        else checkBox.checked = false;
    }

    //---------------------------------------------------------------------------------------------

    function pUpdatePreview()
    {
        if (itemHovered == null) return;

        indexPreview = indexHover;

        panelPreview.activatePlaylist(list);

        /*if (panelCover.isExpanded)
        {
            panelCover.setItem(list);
        }
        else panelPreview.activatePlaylist(list);*/
    }

    function pClearPreview()
    {
        if (panelPreview.list != list) return;

        panelPreview.clearInstant();

        /*if (panelPreview.list == list)
        {
            panelPreview.clearInstant();
        }
        else if (panelCover.list == list)
        {
            panelCover.clearItem();
        }*/
    }

    //---------------------------------------------------------------------------------------------

    function pIndexFromPosition(pos)
    {
        return pos / itemSize;
    }

    //---------------------------------------------------------------------------------------------

    function pRemove(indexes, animate)
    {
        pProcessRemove(playlist);

        indexContextual = -1;

        if (animate)
        {
            for (var i = 0; i < indexes.length; i++)
            {
                var item = itemAt(indexes[i]);

                if (item) item.animateRemove();
            }

            pIndexes = indexes;

            timer.start();
        }
        else playlist.removeTracks(indexes);
    }

    function pProcessRemove(playlist)
    {
        if (pIndexes == null) return;

        timer.stop();

        playlist.removeTracks(pIndexes);

        pIndexes = null;
    }

    //---------------------------------------------------------------------------------------------

    function pSaveScroll(playlist)
    {
        if (scrollArea == null) return;

        playlist.scrollValue = scrollArea.value / itemSize;
    }

    function pRestoreScroll()
    {
        if (scrollArea == null || playlist == null) return;

        if (playlist.scrollValue)
        {
             scrollArea.value = Math.round(playlist.scrollValue * itemSize);
        }
        else scrollArea.scrollToTop();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_normal

        onTriggered: pProcessRemove(playlist)
    }

    BaseButtonPiano
    {
        id: overlay

        width : st.dp56 + borderSizeWidth
        height: itemSize

        y: indexHover * itemSize

        borderBottom: borderSize

        visible: (enablePreview && itemHovered != null && playlist.trackIsValid(indexHover))

        isHovered: false
        isPressed: false

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

        onHoverEntered: pUpdatePreview()

        onHoverExited: panelPreview.clear()

        /* QML_EVENT */ onPressed: function(mouse)
        {
            if ((mouse.button & Qt.LeftButton) == false
                ||
                playlist.trackIsDefault(indexHover)) return;

            indexPreview = indexHover;
        }

        Behavior on background.visible
        {
            enabled: overlay.background.visible

            PropertyAnimation
            {
                duration: st.duration_faster

                easing.type: st.easing
            }
        }

        Icon
        {
            anchors.centerIn: parent

            source    : st.icon20x20_search
            sourceSize: st.size20x20

            style: st.icon_raised

            filter: st.icon2_filter
        }
    }

    CheckBox
    {
        id: checkBox

        anchors.right:
        {
            if (buttonContextual.visible)
            {
                return buttonContextual.left;
            }
            else if (buttonLink.visible)
            {
                return buttonLink.left;
            }
            else return parent.right;
        }

        anchors.top: buttonContextual.top

        anchors.rightMargin: 0
        anchors.topMargin  : st.dp3

        visible: (gui.dragList != list && itemWatcher.visible && timer.running == false)

        onCheckClicked:
        {
            if (playlist == null) return;

            if (checked)
            {
                focusList();

                playlist.selectTrack(indexHover);

                pUpdateCurrentTrack(indexHover);
            }
            else
            {
                if (playlist.selectedCount == 1)
                {
                    window.clearFocus();
                }

                playlist.unselectTrack(indexHover);
            }
        }
    }

    ButtonPushIcon
    {
        id: buttonContextual

        anchors.right: (buttonLink.visible) ? buttonLink.left
                                            : parent.right

        anchors.rightMargin: st.dp4

        width : st.dp28
        height: st.dp28

        y: itemWatcher.y + st.border_size

        visible: (enableContextual && checkBox.visible)

        checked: (indexContextual != -1)

        icon          : st.icon12x12_contextualDown
        iconSourceSize: st.size12x12

        onPressed: showPanel(indexHover)
    }

    ButtonPianoIcon
    {
        id: buttonLink

        anchors.right: parent.right

        anchors.rightMargin: (scrollArea && scrollArea.isScrollable) ? 0 : st.dp16

        height: st.list_itemHeight

        y: itemWatcher.y

        borderLeft: borderSize

        borderRight: (anchors.rightMargin) ? borderSize : 0

        visible: (enableLink && checkBox.visible)

        icon          : st.icon16x16_goRelated
        iconSourceSize: st.size16x16

        borderColor: overlay.borderColor

        onClicked: link(indexActive)
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
