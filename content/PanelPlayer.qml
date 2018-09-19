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

            AnchorChanges
            {
                target: panelPlayer

                anchors.bottom: undefined
            }
            PropertyChanges
            {
                target: panelPlayer

                y: -(heightPlayer + st.border_size)
            }
        },
        State
        {
            name: "mini"; when: gui.isMini

            AnchorChanges
            {
                target: panelPlayer

                anchors.bottom: parent.bottom
            }
            PropertyChanges
            {
                target: panelPlayer

                height: Math.max(st.dp270, parent.height)
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
        if (gui.isMini)
        {
             barTop.showCurrentTabMenu();
        }
        else barTop.showTabMenu(tab, wall, window.contentMouseX(), window.contentMouseY(), true);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
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
                text: gui.getTabTitle(item.title, item.state, item.source)
            }

            isExposed: local.macro

            itemTabs: gui.itemTabs

            loading: panelBrowse.isSelecting

            enablePress: (player.isPlaying && wall.isExposed == false)

            enableTitle: (currentTab.playlist != null)

            asynchronous: true

            player.hook: core.createHook(player.backend)

            player.shuffle: (player.isPlaying) ? local.shuffle : false

            playerMouseArea.anchors.leftMargin: (gui.isExpanded) ? st.dp16 : 0

            playerMouseArea.anchors.rightMargin: (panelRelated.isExposed == false) ? st.dp16 : 0

            playerMouseArea.anchors.bottomMargin: (barTop.isExpanded) ? st.dp16 : 0

            playerMouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            playerBackground.visible: (isActive && player.visible)

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onIsActiveChanged:
            {
                if (isActive)
                {
                     window.color = st.window_color;
                }
                else window.color = "black";
            }

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

            onTitleClicked : gui.selectCurrentTrack()
            onAuthorClicked: gui.browseCurrentFeed ()

            onPlayerPressed:
            {
                if (mouse.button & Qt.LeftButton)
                {
                    gui.toggleBars();

                    window.clearFocus();
                }
                else if (mouse.button & Qt.RightButton)
                {
                    gui.restoreBars();

                    pContextualTab(playerTab);
                }
                else if (mouse.button & Qt.MiddleButton)
                {
                    gui.pause();
                }
            }

            //-------------------------------------------------------------------------------------

            onContextual:
            {
                if (isExposed == false) return;

                var tab = tabs.tabAt(indexHover);

                panelContextual.loadPageTab(tab);

                if (areaContextual.showPanelMargins(panelContextual, buttonsItem, -st.dp4, 0))
                {
                    setIndexContextual(indexHover);

                    areaContextual.parentContextual = wall;
                }
            }

            onContextualBrowser: pContextualTab(currentTab)

            //-------------------------------------------------------------------------------------
            // Functions events
            //-------------------------------------------------------------------------------------

            function onBeforeCloseItem(index)
            {
                return gui.onBeforeCloseTab(index);
            }
        }
    }

    PanelRelated { id: panelRelated }
}
