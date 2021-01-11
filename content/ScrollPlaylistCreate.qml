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
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isDroppable: (playlist && playlist.isOnline == false)

    /* read */ property bool isDropping: false

    //---------------------------------------------------------------------------------------------
    // Private

    property int pDropIndex: -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    contentHeight: list.y + list.height

    dropEnabled: true

    enableDrag    : true
    enableDragMove: true

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onDragEntered:
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

            bordersDrop.setItem(container);
        }
        else if (gui.drag == -1)
        {
            if (playlist.isFull || controllerPlaylist.urlIsTrack(event.text) == false) return;

            event.accepted = true;

            bordersDrop.setItem(container);

            toolTip.show(qsTr("Add Track"), st.icon32x32_addList, st.dp32, st.dp32);
        }
    }

    onDragExited: pClearDrag()

    onDragMove:
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

    onDrop:
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
            list.insertSource(pDropIndex, event.text, true);
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
        bordersDrop.clearItem(container);

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
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timerAdd

        interval: st.scrollPlaylistCreate_durationAdd

        onTriggered: pSetDropping(false)
    }

    LineHorizontalDrop
    {
        id: lineDrop

        opacity: (visible) ? bordersDrop.opacity : 1.0
    }
}
