//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

ScrollPlaylist
{
    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property bool pDropping: false

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
        if (playlist == null || playlist.isOnline) return;

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

            toolTip.show(qsTr("Add Track"), st.icon32x32_addList, 32, 32);
        }
    }

    onDragExited:
    {
        bordersDrop.clearItem(container);

        pClearDrop();
    }

    onDragMove:
    {
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

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // ScrollFolder reimplementation

    function updateCurrentY()
    {
        if (pDropping) pSelectedY = -1;
        else           pSelectedY = currentItemY();

        if (atTop) pAtBottom = false;
        else       pAtBottom = atBottom;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearDrop()
    {
        lineDrop.visible = false;

        pDropIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSetDropping(dropping)
    {
        if (pDropping == dropping) return;

        pDropping = dropping;

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

        opacity: (visible) ? bordersDrop.opacity : 1
    }
}
