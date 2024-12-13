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
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property int pIndex: -1

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pIndex = gui.gridIndex;

        pApplyIndex();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pApplyIndex()
    {
        if (pIndex == -1) return;

        var playlist = gui.gridPlaylist;

        if (playlist == null || playlist.isEmpty) return;

        var model = view.model;

        view.showTrackBegin(model.indexFromIndex(pIndex));

        view.currentIndex = pIndex;

        pIndex = -1;
    }

    function pGetCoverWidth()
    {
        var size = width - view.scrollBar.width;

        var extra = st.border_size * 2 + view.spacing;

        var sizeItem = st.dp320 + extra;

        var ratio = Math.floor(size / sizeItem);

        return sizeItem + Math.floor((size - sizeItem * ratio) / ratio) - extra;
    }

    function pGetTitle()
    {
        var playlist = gui.gridPlaylist;

        if (playlist) return playlist.title;
        else          return "";
    }

    function pGetModel()
    {
        var playlist = gui.gridPlaylist;

        if (playlist && playlist.label == "recent")
        {
             return modelFiltered;
        }
        else return modelDefault;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ModelPlaylist
    {
        id: modelDefault

        playlist: view.playlist
    }

    ModelPlaylistFiltered
    {
        id: modelFiltered

        model: modelDefault

        sortRole: ModelPlaylist.RoleDate

        sortOrder: Qt.DescendingOrder
    }

    ViewPlaylist
    {
        id: view

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : itemTitle.bottom
        anchors.bottom: parent.bottom

        coverWidth: pGetCoverWidth()

        coverHeight: coverWidth * 0.5625

        spacingBottom: st.dp48

        playlist: gui.gridPlaylist

        model: pGetModel()

        currentIndex: -1

        onCountChanged: pApplyIndex()
    }

    MouseArea
    {
        id: itemTitle

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32

        onClicked: panelTag.collapse()

        Rectangle
        {
            anchors.fill: parent

            color: st.itemList_colorSelectA
        }

        BarTitleText
        {
            id: itemText

            anchors.fill: parent

            text: pGetTitle()

            color: st.itemList_colorTextSelected

            style: st.text_raised

            font.pixelSize: st.dp16
        }
    }

    ButtonPianoIcon
    {
        anchors.right : bar.left
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon16x16_slideDown
        iconSourceSize: st.size16x16

        onClicked: panelTag.collapse()
    }

    Rectangle
    {
        id: bar

        anchors.right : parent.right
        anchors.top   : itemTitle.top
        anchors.bottom: itemTitle.bottom

        width: st.dp16

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.barTitle_colorA }
            GradientStop { position: 1.0; color: st.barTitle_colorB }
        }
    }

    BorderHorizontal
    {
        anchors.left  : bar.left
        anchors.right : bar.right
        anchors.bottom: bar.bottom
    }
}
