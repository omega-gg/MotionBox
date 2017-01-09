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
    id: componentFolder

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property bool isActive: (isCurrent && (pActiveType == LibraryItem.PlaylistNet
                                           ||
                                           pActiveType == LibraryItem.PlaylistFeed))

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: itemSize

    iconHeight: (isActive) ? st.dp24 : st.dp32

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
                 return st.icon24x24_pause;
            }
            else return st.icon24x24_play;
        }
        else if (type == LibraryItem.PlaylistNet)
        {
            return st.icon32x32_playlist;
        }
        else if (type == LibraryItem.PlaylistFeed || type == LibraryItem.FolderSearch)
        {
            return st.icon32x32_feed;
        }
        else if (type == LibraryItem.PlaylistSearch)
        {
            return st.icon32x32_track;
        }
        else return st.icon32x32_folder;
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
            return gui.getUrlTitle(source, gui.getItemName(type));
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

    onPositionChanged: componentFolder.onPositionChanged(mouse)

    onPressed : componentFolder.onPressed (mouse)
    onReleased: componentFolder.onReleased(mouse)

    onClicked      : componentFolder.onClicked      (mouse)
    onDoubleClicked: componentFolder.onDoubleClicked(mouse)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function getCover()
    {
        return cover;
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onPositionChanged(mouse)
    {
        if (pDragX != -1)
        {
            pDragCheck(mouse.x, mouse.y, index);
        }
    }

    //---------------------------------------------------------------------------------------------

    function onPressed(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
            if (enableDrag)
            {
                pDragInit(type, mouse.x, mouse.y);
            }
            else pSelectItem(index);
        }
        else pShowPanel();
    }

    function onReleased(mouse)
    {
        pDragX = -1;
    }

    //---------------------------------------------------------------------------------------------

    function onClicked(mouse)
    {
        if ((mouse.button & Qt.LeftButton) && enableDrag)
        {
            pSelectItem(index);
        }
    }

    function onDoubleClicked(mouse)
    {
        if (mouse.button & Qt.RightButton) return;

        if (index == folder.currentIndex)
        {
            pPlay();
        }
        else gui.playItem(folder, index);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pShowPanel()
    {
        if ((width - componentFolder.mouseX) > st.dp200)
        {
             showPanelAt(index, window.contentMouseX(), -1, true);
        }
        else showPanel(index);
    }
}
