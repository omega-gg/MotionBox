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
    id: componentFolder

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isActive: (isCurrent && (pActiveType == LibraryItem.Playlist
                                        ||
                                        pActiveType == LibraryItem.PlaylistFeed))

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: itemSize

    iconDefaultSize: st.size16x16

    //---------------------------------------------------------------------------------------------

    isHovered: (index == indexHover || index == indexDrag)

    isDefault: (loadStateQuery == LocalObject.Default)

    isSelected: (index == indexCurrent)

    isCurrent: (player.hasStarted && folder != null && index == folder.activeIndex)

    isContextual: (index == indexContextual || index == indexEdit)

    isFocused: (list.activeFocus)

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    icon: (visible && isActive == false) ? cover : ""

    iconDefault:
    {
        if (isActive)
        {
            if (player.isPaused)
            {
                 return st.icon16x16_pause;
            }
            else return st.icon16x16_play;
        }
        else if (type == LibraryItem.Playlist)
        {
            return st.icon16x16_playlist;
        }
        else if (type == LibraryItem.PlaylistFeed || type == LibraryItem.FolderSearch)
        {
            return st.icon16x16_feed;
        }
        else if (type == LibraryItem.PlaylistSearch)
        {
            return st.icon16x16_track;
        }
        else return st.icon16x16_folder;
    }

    text:
    {
        if (title)
        {
            return title;
        }
        else if (loadState == LocalObject.Loading)
        {
            if (loadState == LocalObject.Loading)
            {
                 return qsTr("Loading " + gui.getItemName(type) + "...");
            }
            else return qsTr("Invalid " + gui.getItemName(type));
        }
        else if (source != "")
        {
            return st.getUrlTitle(source, gui.getItemName(type));
        }
        else return qsTr("Invalid Item");
    }

    iconFillMode: (isActive) ? Image.PreserveAspectFit
                             : Image.PreserveAspectCrop

    textMargin:
    {
        if (index == indexActive && buttonContextual.visible)
        {
             return st.dp8 + buttonContextual.width + buttonContextual.anchors.rightMargin;
        }
        else return st.dp8;
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onEntered: setItemHovered  (componentFolder)
    onExited : clearItemHovered()

    onPositionChanged: pPositionChanged(mouse)

    onPressed : pPressed (mouse)
    onReleased: pReleased(mouse)

    onClicked      : pClicked      (mouse)
    onDoubleClicked: pDoubleClicked(mouse)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function getCover()
    {
        return cover;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pPositionChanged(mouse)
    {
        if (pDragX != -1)
        {
            pDragCheck(index);
        }
    }

    //---------------------------------------------------------------------------------------------

    function pPressed(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (enableDrag)
            {
                pDragInit(type);
            }
            else pSelectItem(index);
        }
        else pShowPanel();
    }

    function pReleased(mouse)
    {
        pDragX = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pClicked(mouse)
    {
        if ((mouse.button & Qt.LeftButton) && enableDrag)
        {
            pSelectItem(index);
        }
    }

    function pDoubleClicked(mouse)
    {
        if (mouse.button & Qt.RightButton) return;

        if (index == folder.currentIndex)
        {
            pPlay();
        }
        else gui.playItem(folder, index);
    }

    //---------------------------------------------------------------------------------------------

    function pShowPanel()
    {
        if ((width - componentFolder.mouseX) > st.dp192)
        {
             showPanelAt(index, window.contentMouseX(), -1, true);
        }
        else showPanel(index);
    }
}
