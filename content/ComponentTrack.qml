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

ComponentLibraryItem
{
    id: componentTrack

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: itemSize

    iconWidth: st.dp42

    iconHeight: (isCurrent) ? st.dp24 : st.dp32

    //---------------------------------------------------------------------------------------------

    isEnabled: (source != "")

    isHovered: (index == indexHover)

    isDefault: (loadState == LocalObject.Default)

    isSelected: (selected)

    isCurrent: (index == indexPlayer)

    isContextual: (index == indexContextual)

    isFocused: (list.activeFocus)

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    icon: (visible && isCurrent == false) ? cover : ""

    iconDefault:
    {
        if (isCurrent)
        {
            if (player.isPaused)
            {
                 return st.icon24x24_pause;
            }
            else return st.icon24x24_play;
        }
        else return st.icon42x32_track;
    }

    text: gui.getTrackTitle(title, loadState, source)

    iconFillMode: (isCurrent) ? Image.PreserveAspectFit
                              : Image.PreserveAspectCrop

    textMargin: (index == indexActive) ? width + st.dp2 - checkBox.x
                                       : st.dp8

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onEntered: setItemHovered  (componentTrack)
    onExited : clearItemHovered()

    onPositionChanged: componentTrack.onPositionChanged(mouse)

    onPressed : componentTrack.onPressed (mouse)
    onReleased: componentTrack.onReleased(mouse)

    onClicked      : componentTrack.onClicked      (mouse)
    onDoubleClicked: componentTrack.onDoubleClicked(mouse)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Events

    function onPositionChanged(mouse)
    {
        if (pDragX != -1)
        {
            pDragCheck(mouse.x, mouse.y);
        }
    }

    //---------------------------------------------------------------------------------------------

    function onPressed(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (playlist.indexSelected(index) == false)
            {
                focusList();

                list.isSelecting = true;

                pSelectTrack(index);

                pDragInit(mouse.x, mouse.y);
            }
            else if (isFocused == false)
            {
                focusList();

                list.isSelecting = true;

                pUpdateVisible();

                pDragInit(mouse.x, mouse.y);
            }
            else if (window.keyControlPressed)
            {
                list.isSelecting = true;

                pSelectTrack(index);
            }
            else pDragInit(mouse.x, mouse.y);
        }
        else if (mouse.button & Qt.RightButton)
        {
            pShowPanel();
        }
    }

    function onReleased(mouse)
    {
        pDragX = -1;
    }

    //---------------------------------------------------------------------------------------------

    function onClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (list.isSelecting)
            {
                playlist.loadTracks(index, 10);

                list.isSelecting = false;
            }
            else if (window.keyShiftPressed == false)
            {
                pSelectSingleTrack(index);
            }
        }
        else if (mouse.button & Qt.MiddleButton)
        {
            focusList();

            openInTab(index);
        }
    }

    function onDoubleClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            pSetCurrentTrack(index);

            pPlay();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pShowPanel()
    {
        if ((width - componentTrack.mouseX) > st.dp200)
        {
             showPanelAt(index, window.contentMouseX(), -1, true);
        }
        else showPanel(index);
    }
}
