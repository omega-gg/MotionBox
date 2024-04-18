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
    id: panelPlayer

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int heightPlayer: parent.height / 1.7

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias playlistRelated: panelRelated.playlist

    //---------------------------------------------------------------------------------------------

    property alias wall: wall

    property alias player         : wall.player
    property alias playerBrowser  : wall.playerBrowser
    property alias playerMouseArea: wall.playerMouseArea

    property alias subtitle: wall.subtitle

    property alias panelRelated: panelRelated

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : panelLibrary.right
    anchors.right: parent.right

    height: heightPlayer

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "hidden"; when: panelTracks.isExpanded

            PropertyChanges
            {
                target: panelPlayer

                y: -(heightPlayer + st.border_size)
            }
        },
        State
        {
            name: "expanded"; when: gui.isExpanded

            PropertyChanges
            {
                target: panelPlayer

                height: parent.height
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                properties: "y, height"

                duration: st.duration_normal

                easing.type: st.easing
            }

            ScriptAction
            {
                script:
                {
                    if (gui.isExpanded)
                    {
                        if (panelBrowse.isExposed) panelBrowse.visible = false;
                        else                       panelTracks.visible = false;
                    }
                    else if (gui.isLoaded && panelTracks.isExpanded)
                    {
                        if (panelBrowse.isExposed)
                        {
                            panelLibrary.visible = false;
                        }

                        visible = false;
                    }
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function wallExpand(width, height)
    {
        if (st.animate && wall.isExposed)
        {
            wall.clearDrag();

            wall.isFixedSize = false;

            wall.startAnimation();

            wall.anchors.fill = undefined;

            wall.width  = width;
            wall.height = height;

            wall.updateView();

            wall.enableAnimation = false;
        }
    }

    function wallRestore()
    {
        if (wall.anchors.fill == undefined)
        {
            wall.anchors.fill = itemSplit;

            wall.enableAnimation = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pContextualTab(tab)
    {
        barWindow.showTabMenu(tab, wall, window.contentMouseX(), window.contentMouseY(), true);
    }

    function pContextualTag(text)
    {
        if (text == "") return false;

        panelContextual.loadPageTag(text);

        areaContextual.showPanelAt(panelContextual, wall, window.contentMouseX(),
                                   window.contentMouseY(), true);

        return true;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Item
    {
        id: itemSplit

        anchors.left  : parent.left
        anchors.right : panelRelated.left
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        WallVideo
        {
            id: wall

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.fill: parent

            delegate: ComponentWallBookmarkTrack
            {
                text: st.getTabTitle(item.title, item.state, item.source)
            }

            isExposed: local.macro

            itemTabs: gui.itemTabs

            loading: panelBrowse.isSelecting

            enablePress: (player.isPlaying && wall.isExposed == false)

            enableTitle: (currentTab.playlist != null)

            asynchronous: true

            player.autoPlay: local.autoPlay

            player.shuffle: (player.isPlaying) ? local.shuffle : false

            playerMouseArea.anchors.leftMargin: (gui.isExpanded) ? st.dp16 : 0

            playerMouseArea.anchors.rightMargin: (panelRelated.isExposed == false) ? st.dp16 : 0

            playerMouseArea.anchors.bottomMargin: (barTop.isExpanded) ? st.dp16 : 0

            playerMouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            playerBackground.visible: (isActive && player.visible)

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onIsActiveChanged: gui.updateColor()

            onIsExposedChanged: local.macro = isExposed

            //-------------------------------------------------------------------------------------

            onItemDoubleClicked:
            {
                if (tabs.highlightedIndex != indexHover)
                {
                    gui.playTab();
                }
            }

            //-------------------------------------------------------------------------------------

            onBrowse:
            {
                if (gui.createHistory())
                {
                    gui.addHistoryTrack(currentTab.source);
                }

                panelBrowse.searchMore(currentTab.playlist, currentTab.source, currentTab.title);
            }

            onTitleClicked : gui.selectCurrentTrack()
            onAuthorClicked: gui.browseCurrentFeed ()

            /* QML_EVENT */ onPlayerClicked: function(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    gui.expandBars();

                    window.clearFocus();
                }
                else if (mouse.button & Qt.RightButton)
                {
                    if (pContextualTag(scannerPlayer.getTextHovered())) return;

                    gui.restoreBars();

                    pContextualTab(playerTab);
                }
                else if (mouse.button & Qt.MiddleButton)
                {
                    gui.pause();
                }
            }

            /* QML_EVENT */ onPlayerDoubleClicked: function(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    gui.toggleFullScreen();
                }
            }

            /* QML_EVENT */ onTagClicked: function(mouse, text)
            {
                if (mouse.button & Qt.MiddleButton)
                {
                    barWindow.openTabCurrent();
                }

                gui.browse(text);
            }

            //-------------------------------------------------------------------------------------

            onContextual:
            {
                if (pContextualTag(scannerPlayer.getTextHovered()) || isExposed == false) return;

                var tab = tabs.tabAt(indexHover);

                panelContextual.loadPageTab(tab);

                if (areaContextual.showPanelMargins(panelContextual, buttonsItem, -st.dp4, 0))
                {
                    setIndexContextual(indexHover);

                    areaContextual.parentContextual = wall;
                }
            }

            onContextualBrowser:
            {
                if (pContextualTag(scannerBrowser.getTextHovered())) return;

                pContextualTab(currentTab);
            }

            onSubtitleLoaded: if (ok == false) panelGet.clearSubtitle()

            //-------------------------------------------------------------------------------------
            // Functions
            //-------------------------------------------------------------------------------------
            // Events

            function onBeforeItemClose(index)
            {
                return gui.onBeforeTabClose(index);
            }

            //-------------------------------------------------------------------------------------
            // Connections
            //-------------------------------------------------------------------------------------

            Connections
            {
                target: (window.fullScreen) ? wall.scannerPlayer : null

                /* QML_CONNECTION */ function onPositionChanged(mouse)
                {
                    var y = mouse.y;

                    if (y < st.dp64
                        ||
                        playerMouseArea.height - y < st.dp64) gui.restoreBars();
                }
            }
        }
    }

    PanelRelated { id: panelRelated }
}
