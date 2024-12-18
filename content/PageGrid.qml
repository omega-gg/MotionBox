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
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias playlist: view.playlist

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
        if (pIndex == -1 || playlist == null || playlist.isEmpty) return;

        var model = view.model;

        view.showTrackBegin(model.indexFromIndex(pIndex));

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

    function pGetModel()
    {
        if (playlist && playlist.label == "recent")
        {
             return modelFiltered;
        }
        else return modelDefault;
    }

    function pGetTitle()
    {
        if (playlist)
        {
            var title = playlist.title;

            if (title)
            {
                return title;
            }
            else return st.getItemName(playlist.type);
        }
        else return "";
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

        indexContextual: (gui.gridList) ? gui.gridList.indexContextual : -1

        itemText.font.pixelSize: st.dp16

        itemText.color: st.text2_color

        grid.onContentYChanged: areaContextual.hidePanels()

        delegate: ComponentGridTrack
        {
            /* QML_EVENT */ onPressed: function(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    if (mouse.y < border.y)
                    {
                        if (highlightedTab
                            ||
                            controllerPlaylist.cleanMatch(source, currentTab.source) == false)
                        {
                            gui.setCurrentTrack(playlist, view.model.indexAt(index));
                        }
                    }
                    // NOTE: When pressing the bar we simply select the track.
                    else playlist.selectSingleTrack(view.model.indexAt(index));

                    panelTag.collapse();
                }
                else if (mouse.button & Qt.RightButton)
                {
                    var list = gui.gridList;

                    if (list == null) return;

                    list.indexContextual = index;

                    panelContextual.loadPageTrack(list, view.model.indexAt(index));

                    if (areaContextual.showPanelAt(panelContextual, view,
                                                   window.contentMouseX(),
                                                   window.contentMouseY(), true) == false) return;

                    areaContextual.parentContextual = list;
                }
                else if (mouse.button & Qt.MiddleButton)
                {
                    barWindow.openTabCurrent();

                    playlist.selectSingleTrack(view.model.indexAt(index));
                }
            }
        }

        onCountChanged: pApplyIndex()
    }

    Rectangle
    {
        id: itemTitle

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32 + st.border_size

        color: st.itemList_colorSelectA

        TextLink
        {
            anchors.fill: parent

            anchors.leftMargin  : st.barTitleText_leftMargin
            anchors.bottomMargin: st.border_size

            verticalAlignment: Text.AlignVCenter

            text: pGetTitle()

            color: st.itemList_colorTextSelected

            style: st.text_raised

            font.pixelSize: st.dp16

            onClicked:
            {
                if (panelRelated.playlist == playlist)
                {
                    panelRelated.expose();

                    return;
                }

                if (panelBrowse.playlist == playlist)
                {
                    panelBrowse.expose();
                }
                else panelBrowse.collapse();

                gui.restore();
            }
        }
    }

    ButtonPianoIcon
    {
        id: buttonTag

        anchors.right : buttonClose.left
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        borderLeft  : borderSize
        borderRight : 0
        borderBottom: borderSize

        visible: (playlist != null)

        icon          : st.icon16x16_tag
        iconSourceSize: st.size16x16

        onClicked:
        {
            var folder = playlist.parentFolder;

            gui.showTagPlaylist(folder, folder.currentIndex);
        }
    }

    ButtonPianoIcon
    {
        id: buttonClose

        anchors.right : bar.left
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        borderLeft: (buttonTag.visible) ? 0 : borderSize

        borderBottom: borderSize

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

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
