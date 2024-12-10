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

Item
{
    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        var index = gui.gridIndex;

        if (index == -1) return;

        view.showTrackBegin(index);
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function pGetTitle()
    {
        var playlist = gui.gridPlaylist;

        if (playlist) return playlist.title;
        else          return "";
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Item
    {
        id: itemTitle

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32

        visible: (itemText.text != "")

        Rectangle
        {
            anchors.fill: parent

            color: st.itemList_colorSelectA
        }

        TextBase
        {
            id: itemText

            anchors.fill: parent

            anchors.leftMargin : st.dp8
            anchors.rightMargin: st.dp8

            verticalAlignment: Text.AlignVCenter

            text: pGetTitle()

            color: st.itemList_colorTextSelected

            style: st.text_raised

            font.pixelSize: st.dp16
        }
    }

    ButtonPianoIcon
    {
        anchors.right : parent.right
        anchors.top   : itemTitle.top
        anchors.bottom: itemTitle.bottom

        borderLeft  : borderSize
        borderRight : 0
        borderBottom: borderSize

        icon          : st.icon16x16_slideDown
        iconSourceSize: st.size16x16

        onClicked: panelTag.collapse()
    }

    ViewPlaylist
    {
        id: view

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : itemTitle.bottom
        anchors.bottom: parent.bottom

        playlist: gui.gridPlaylist
    }
}
