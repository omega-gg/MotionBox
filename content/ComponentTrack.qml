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
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int time    : -1
    /* read */ property int duration: -1

    //---------------------------------------------------------------------------------------------
    // Private

    // NOTE: This is required for the onPSourceChanged event.
    property string pSource: source

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: itemSize

    iconWidth: st.dp56

    // NOTE: We want smaller play and pause icons to keep it subtle.
    iconDefaultSize: (isCurrent) ? st.size14x14
                                 : st.size16x16

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

    onHoverEntered: setItemHovered  (componentTrack)
    onHoverExited : clearItemHovered()

    /* QML_EVENT */ onPositionChanged: function(mouse) { pPositionChanged(mouse) }

    /* QML_EVENT */ onPressed : function(mouse) { pPressed (mouse) }
    /* QML_EVENT */ onReleased: function(mouse) { pReleased(mouse) }

    /* QML_EVENT */ onClicked      : function(mouse) { pClicked      (mouse) }
    /* QML_EVENT */ onDoubleClicked: function(mouse) { pDoubleClicked(mouse) }

    onPSourceChanged: pUpdateTime()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateTime()
    {
        duration = playlist.trackDuration(indexAt(index));

        if (duration < 1)
        {
             componentTrack.time = -1;
        }

        var time = controllerPlaylist.extractTime(source);

        if (time == 0 || time > duration)
        {
             componentTrack.time = -1;
        }
        else componentTrack.time = time;
    }

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
            if (playlist.indexSelected(indexAt(index)) == false)
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

    function pGetBarWidth()
    {
        if (bar.visible == false) return 0;

        if (time < duration)
        {
            return time * (width - itemIcon.width) / duration;
        }
        else return width - itemIcon.x - itemIcon.width;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BarProgress
    {
        id: bar

        anchors.left  : parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: itemIcon.width

        width: pGetBarWidth()

        height: st.border_size

        visible: (time > 0)

        colorA: st.itemList_colorBorderBar
        colorB: st.itemList_colorBorderBar
    }

    RectangleLive
    {
        anchors.left  : parent.left
        anchors.bottom: background.bottom

        anchors.leftMargin: iconWidth - width

        visible: (st.getTrackActive(type) && isCurrent == false)

        trackType: type
    }
}
