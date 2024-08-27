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

ScrollPlaylist
{
    id: scrollPlaylistCreate

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isDroppable: (playlist != null && playlist.isOnline == false)

    /* read */ property bool isCreating: false
    /* read */ property bool isDropping: false

    property bool enableAnimation: true

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

    property int pDropIndex: -1

    property bool pUpdateText: true

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

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

    contentHeight: (listCompletion.visible) ? listCompletion.y + listCompletion.height
                                            : list.y + list.height

    dropEnabled: true

    enableDrag    : true
    enableDragMove: true

    textVisible: (count == 0 && playlist != null && playlist.queryIsLoading == false
                  &&
                  itemNew.visible == false)

    list.visible: (listCompletion.visible == false)

    list.anchors.top: itemNew.bottom

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ onDragEntered: function(event)
    {
        if (isDroppable == false) return;

        if (gui.drag == 0)
        {
            if (playlist.checkFull(gui.dragData.length)) return;

            event.accepted = true;

            if ((event.actions & Qt.MoveAction) && playlist == gui.dragItem)
            {
                event.action = Qt.MoveAction;
            }

            bordersDrop.setItem(scrollPlaylistCreate);
        }
        else if (gui.drag == -1)
        {
            if (playlist.isFull || controllerPlaylist.urlIsTrack(event.text) == false) return;

            event.accepted = true;

            bordersDrop.setItem(scrollPlaylistCreate);

            toolTip.show(qsTr("Add Track"), st.icon20x20_addList, st.dp20, st.dp20);
        }
    }

    onDragExited: pClearDrag()

    /* QML_EVENT */ onDragMove: function(event)
    {
        if (isDroppable == false) return;

        if (count == 0)
        {
            if (pDropIndex)
            {
                pDropIndex = 0;

                lineDrop.visible = false;
            }

            return;
        }

        var y = mapToItem(list, event.x, event.y).y;

        var index = Math.round(y / list.itemSize);

        if      (index < 0)     index = 0;
        else if (index > count) index = count;

        if (pDropIndex == index) return;

        pDropIndex = index;

        y = index * list.itemSize;

        var min = 2;
        var max;

        if (isScrollable) max = contentHeight - 4;
        else              max = contentHeight - 2;

        if      (y < min) y = min;
        else if (y > max) y = max;

        lineDrop.y = y;

        lineDrop.visible = true;
    }

    /* QML_EVENT */ onDrop: function(event)
    {
        if (isDroppable == false) return;

        pSetDropping(true);

        if (gui.drag == 0)
        {
            var item = gui.dragItem;

            if (playlist == item && event.action == Qt.MoveAction)
            {
                item.moveSelectedTo(pDropIndex);
            }
            else list.copyTracksFrom(item, gui.dragData, pDropIndex, true);
        }
        else if (gui.drag == -1)
        {
            list.insertSources(pDropIndex, event.text, true);
        }

        pClearDrop();

        timerAdd.restart();
    }

    onIsDroppableChanged:
    {
        if (isDroppable) return;

        pClearDrag();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function createItem()
    {
        list.enableContextual = false;

        pSetDropping(true);

        scrollToTop();

        itemNew.visible = true;

        itemNew.setFocus();
    }

    function clearItem()
    {
        if (isCreating == false) return;

        text = "";

        window.clearFocus();
    }

    function applyText(text)
    {
        pUpdateText = false;

        itemNew.text = text;

        pUpdateText = true;
    }

    //---------------------------------------------------------------------------------------------
    // ScrollFolder reimplementation

    function updateCurrentY()
    {
        if (isDropping) pSelectedY = -1;
        else            pSelectedY = currentItemY();

        if (atTop) pAtBottom = false;
        else       pAtBottom = atBottom;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearDrag()
    {
        bordersDrop.clearItem(scrollPlaylistCreate);

        pClearDrop();
    }

    function pClearDrop()
    {
        lineDrop.visible = false;

        pDropIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSetDropping(dropping)
    {
        if (isDropping == dropping) return;

        isDropping = dropping;

        updateCurrentY();
    }

    //---------------------------------------------------------------------------------------------

    function pCreateItem()
    {
        core.loadTrack(playlist, text);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timerAdd

        interval: st.scrollPlaylistCreate_durationAdd

        onTriggered: pSetDropping(false)
    }

    ItemNew
    {
        id: itemNew

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.top

        visible: false

        button.visible: false

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

                        list.enableContextual = true;

                        pSetDropping(false);

                        updateVisible();

                        // NOTE: We must call the signal from scrollPlaylist otherwise it does not
                        //       work.
                        scrollPlaylist.finished();
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

        onTextChanged: if (pUpdateText) listCompletion.runCompletion(text)

        function onKeyPressed(event)
        {
            if (event.key == Qt.Key_Up)
            {
                event.accepted = true;

                listCompletion.selectPrevious();

                if (listCompletion.currentIndex == -1)
                {
                    scrollToTop();
                }
            }
            else if (event.key == Qt.Key_Down)
            {
                event.accepted = true;

                listCompletion.selectNext();

                if (listCompletion.currentIndex == -1)
                {
                    scrollToTop();
                }
            }
            else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
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

    ListCompletion
    {
        id: listCompletion

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : itemNew.bottom

        scrollArea: scrollPlaylist

        visible: (count != 0)

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                applyText(completion);

                itemNew.moveCursorAtEnd();
            }
            else scrollTo(0);
        }

        onItemClicked: window.clearFocus()

        onCurrentIndexChanged: scrollToItem(currentIndex)
    }

    LineHorizontalDrop
    {
        id: lineDrop

        opacity: (visible) ? bordersDrop.opacity : 1.0
    }
}
