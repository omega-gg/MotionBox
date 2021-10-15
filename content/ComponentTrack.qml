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

ComponentLibraryItem
{
    id: componentTrack

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: itemSize

    iconWidth: st.dp56

    iconDefaultSize: st.size16x16

    //---------------------------------------------------------------------------------------------

    isEnabled: (source != "")

    isHovered: (index == indexHover)

    isDefault: (loadState == LocalObject.Default || loadState > LocalObject.Loaded)

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
                 return st.icon16x16_pause;
            }
            else return st.icon16x16_play;
        }
        else return st.icon16x16_track;
    }

    text: st.getTrackTitle(title, loadState, source)

    iconFillMode: (isCurrent) ? Image.PreserveAspectFit
                              : Image.PreserveAspectCrop

    textMargin: (index == indexActive) ? width + st.border_size - checkBox.x
                                       : st.dp8

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onEntered: setItemHovered  (componentTrack)
    onExited : clearItemHovered()

    onPositionChanged: pPositionChanged(mouse)

    onPressed : pPressed (mouse)
    onReleased: pReleased(mouse)

    onClicked      : pClicked      (mouse)
    onDoubleClicked: pDoubleClicked(mouse)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pPositionChanged(mouse)
    {
        if (pDragX != -1)
        {
            pDragCheck();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pPressed(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (playlist.indexSelected(index) == false)
            {
                focusList();

                list.isSelecting = true;

                pSelectTrack(index);

                pDragInit();
            }
            else if (isFocused == false)
            {
                focusList();

                list.isSelecting = true;

                pUpdateVisible();

                pDragInit();
            }
            else if (window.keyControlPressed)
            {
                list.isSelecting = true;

                pSelectTrack(index);
            }
            else pDragInit();
        }
        else if (mouse.button & Qt.RightButton)
        {
            pShowPanel();
        }
    }

    function pReleased(mouse)
    {
        pDragX = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (list.isSelecting)
            {
                playlist.loadTracksBetween(index, 10);

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

    function pDoubleClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            pSetCurrentTrack(index);

            pPlay();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pShowPanel()
    {
        if ((width - componentTrack.mouseX) > st.dp192)
        {
             showPanelAt(index, window.contentMouseX(), -1, true);
        }
        else showPanel(index);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    RectangleLive
    {
        anchors.left  : parent.left
        anchors.bottom: background.bottom

        anchors.leftMargin: iconWidth - width

        visible: (type == Playlist.TrackLive && isCurrent == false)
    }
}
