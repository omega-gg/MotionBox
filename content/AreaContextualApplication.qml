//=================================================================================================
/*
    Copyright (C) 2015-2026 MotionBox authors united with omega. <http://omega.gg/about>

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

AreaContextual
{
    id: areaContextual

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int currentId: -1
    // 0: Folder
    // 1: Track
    // 2: Tracks
    // 3: Tab
    // 4: Browse
    // 5: Tag
    // 6: Mode
    // 7: Links
    // 8: Download
    // 9: Settings

    /* read */ property variant item: null

    // NOTE: The page of a list scenario.
    /* read */ property variant currentPage: (pIsList) ? pItem.currentPage : null

    //---------------------------------------------------------------------------------------------
    // Private

    property variant pItem: panelContextual.loader.item

    // NOTE: A list scenario has a title, the border of its last item goes under the panel border.
    property bool pIsList: (pItem != null && pItem.title !== undefined)

    property bool pHeader: (pIsList && pItem.title != "")

    property bool pFeed: (pItem != null && pItem.feed !== undefined)

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias panelContextual: panelContextual
    property alias panelAdd       : panelAdd

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    z: 1

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onIsActiveChanged:
    {
        if (isActive) return;

        currentId = -1;

        areaContextual.item = null;
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showPanelSettings(item, marginY, settings, currentIndex, activeIndex)
    {
        // NOTE: We don't want to show the same panel twice.
        if (checkPanel(panelContextual, item)) return;

        areaContextual.item = item;

        pLoad(9).load(settings, currentIndex, activeIndex);

        var panel = pGetPanel();

        if (panel.height < panelContextual.preferredHeight)
        {
             showPanelPositionMargins(panelContextual, panel,
                                      Sk.TopLeftCorner, st.border_size, st.border_size);
        }
        else showPanelPositionMargins(panelContextual, item,
                                      Sk.BottomLeftCorner, 0, marginY - st.border_size);
    }

    function showPanelMode(button, marginY)
    {
        item = button;

        pLoad(6);

        showPanelPositionMargins(panelContextual, button, Sk.BottomLeftCorner, -(button.x),
                                 marginY);
    }

    function showPanelVideo(source, button, marginY)
    {
        item = button;

        pLoad(7).load(gui.applyTime(source));

        showPanelPositionMargins(panelContextual, button, Sk.BottomLeftCorner, -(button.x),
                                 marginY);
    }

    //---------------------------------------------------------------------------------------------
    // NOTE: These are called from a scenario, the panel stays where it is.

    function showPanelLinks(source)
    {
        pLoad(7).load(source);
    }

    function showPanelDownload(track)
    {
        pLoad(8).loadTrack(track);
    }

    function showPanelAdd(type, target, index)
    {
        panelAdd.setSource(type, target, index);

        showPanel(panelAdd, currentItem, panelContextual.position,
                                         panelContextual.posX,
                                         panelContextual.posY,
                                         panelContextual.marginX,
                                         panelContextual.marginY,
                                         panelContextual.isCursorChild);
    }

    //---------------------------------------------------------------------------------------------

    function searchMore(playlist, source, title)
    {
        gui.restore();

        panelBrowse.searchMore(playlist, source, title);
    }

    function checkContext(source)
    {
        return (controllerNetwork.hasFragment(source, 't')   ||
                controllerNetwork.hasFragment(source, 'ctx') ||
                controllerNetwork.hasFragment(source, 'id')  ||
                controllerNetwork.hasFragment(source, 'sid'));
    }

    function checkDownload(data)
    {
        return (core.canDownload && data.source != ""
                                 && st.getTrackActive(data.type) == false
                                 && controllerNetwork.urlIsFile(data.source) == false);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    // NOTE: We reload the scenario, the same one can come again for another item.
    function pLoad(id)
    {
        currentId = -1;
        currentId = id;

        panelContextual.area.scrollToTop();

        if (pIsList && panelContextual.isActive) pItem.setFocus();

        return pItem;
    }

    //---------------------------------------------------------------------------------------------

    function pGetSource()
    {
        if      (currentId == 0) return "ContextualFolder.qml";
        else if (currentId == 1) return "ContextualTrack.qml";
        else if (currentId == 2) return "ContextualTracks.qml";
        else if (currentId == 3) return "ContextualTab.qml";
        else if (currentId == 4) return "ContextualBrowse.qml";
        else if (currentId == 5) return "ContextualTag.qml";
        else if (currentId == 6) return "ContextualMode.qml";
        else if (currentId == 7) return "ContextualLinks.qml";
        else if (currentId == 8) return "ContextualDownload.qml";
        else if (currentId == 9) return "ContextualSettings.qml";
        else                     return "";
    }

    function pGetPanel()
    {
        if      (panelSubtitles.visible) return panelSubtitles;
        else if (panelSettings.visible)  return panelSettings;
        else                             return panelOutput;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    PanelContextualLoader
    {
        id: panelContextual

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        minimumWidth : ((pIsList) ? st.dp160 : st.dp192) + borderSizeWidth
        minimumHeight: st.list_itemHeight

        preferredHeight: area.contentHeight + borderSizeHeight + area.anchors.topMargin
                         +
                         area.anchors.bottomMargin

        clip: true

        source: pGetSource()

        // NOTE: The header and the author don't scroll with the items.
        area.anchors.topMargin   : (pHeader) ? header.height : 0
        area.anchors.bottomMargin: pGetBottomMargin()

        //-----------------------------------------------------------------------------------------
        // Events
        //-----------------------------------------------------------------------------------------

        onIsActiveChanged: if (isActive && pIsList) pItem.setFocus()

        //-----------------------------------------------------------------------------------------
        // Functions
        //-----------------------------------------------------------------------------------------

        function loadPageFolder(list, index)
        {
            pLoad(0).load(list, index);
        }

        function loadPageTrack(list, index)
        {
            var playlist = list.playlist;

            if (playlist.selectedCount > 1 && playlist.indexSelected(index))
            {
                 pLoad(2).load(list);
            }
            else pLoad(1).load(list, index);
        }

        function loadPageTab(tab)
        {
            pLoad(3).load(tab);
        }

        function loadPageBrowse()
        {
            pLoad(4);
        }

        function loadPageTag(text)
        {
            pLoad(5).load(text);
        }

        //-----------------------------------------------------------------------------------------
        // Private

        function pGetBottomMargin()
        {
            if (pFeed)
            {
                return buttonFeed.height - buttonFeed.borderTop;
            }
            // NOTE: The border of the last item goes under the panel border.
            else if (pIsList)
            {
                return -borderBottom;
            }
            else return 0;
        }

        //-----------------------------------------------------------------------------------------
        // Children
        //-----------------------------------------------------------------------------------------

        ContextualCategory
        {
            id: header

            visible: pHeader

            itemText.text: (pHeader) ? pItem.title : ""
        }

        ButtonPianoIcon
        {
            anchors.right: parent.right

            height: st.barTitle_height

            borderLeft: borderSize

            visible: (panelContextual.posX != -1 || panelContextual.posY != -1)

            enabled: (areaContextual.currentPanel != null)

            icon          : st.icon12x12_close
            iconSourceSize: st.size12x12

            onClicked: areaContextual.hidePanels()
        }

        ButtonPiano
        {
            id: buttonFeed

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            borderTop: borderSize

            visible: pFeed

            enabled: (pFeed && pItem.feed != "")

            text: (pFeed) ? pItem.author : ""

            itemText.horizontalAlignment: Text.AlignLeft

            onClicked:
            {
                pItem.browseFeed();

                areaContextual.hidePanels();
            }
        }
    }

    PanelAdd { id: panelAdd }
}
