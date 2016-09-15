//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

MouseArea
{
    id: barTop

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExpanded: false

    //---------------------------------------------------------------------------------------------
    // Private

    property TabTrack pContextualTab : null
    property variant  pContextualItem: null

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias tabs: itemTabs.tabs

    //---------------------------------------------------------------------------------------------

    property alias buttonApplication: buttonApplication

    property alias buttonBackward: buttonBackward
    property alias buttonForward : buttonForward

    property alias lineEditSearch: lineEditSearch

    property alias itemTabs: itemTabs

    property alias buttonAdd: buttonAdd

    property alias buttonExpand : buttonExpand
    property alias buttonWall   : buttonWall
    property alias buttonRelated: buttonRelated

    property alias border: border

    //---------------------------------------------------------------------------------------------
    // Private

    property alias pTab: itemTab.tab

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    anchors.top: (barWindow.visible) ? barWindow.bottom
                                     : parent.top

    height: st.dp32 + border.size

    z: (window.fullScreen) ? 1 : 0

    acceptedButtons: Qt.NoButton

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: isExpanded

        AnchorChanges
        {
            target: barTop

            anchors.top: undefined

            anchors.bottom: (barWindow.visible) ? barWindow.bottom
                                                : parent.top
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_normal }

            ScriptAction
            {
                script: if (isExpanded) visible = false
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expand()
    {
        if (isExpanded) return;

        isExpanded = true;
    }

    function restore()
    {
        if (isExpanded == false) return;

        isExpanded = false;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------

    function openTabPlaylist(playlist)
    {
        if (tabs.isFull) return false;

        pOpenTabPlaylist(playlist);

        return true;
    }

    function closeCurrentTab()
    {
        if (gui.isMini)
        {
            var index = tabs.indexOf(itemTab.tab);

            itemTabs.closeTab(index);
        }
        else itemTabs.closeCurrentTab();
    }

    //---------------------------------------------------------------------------------------------

    function showTabMenu(tab, item, x, y, isCursorChild)
    {
        panelContextual.loadPageTab(tab);

        if (areaContextual.showPanelAt(panelContextual, item, x, y, isCursorChild)
            &&
            x == -1 && y == -1)
        {
            var index = tabs.indexOf(tab);

            itemTabs.setIndexContextual(index);

            areaContextual.parentContextual = itemTabs;
        }
    }

    function showCurrentTabMenu()
    {
        if (gui.isMini)
        {
            gui.restoreMicro();

            if (actionCue.tryPush(actionTabContextual)) return;

            panelContextual.loadPageTab(itemTab.tab);

            areaContextual.showPanelFrom(panelContextual, itemTab);

            startActionCue(st.duration_faster);
        }
        else if (pContextualTab)
        {
            showTabMenu(pContextualTab, pContextualItem, -1, -1, false);

            pContextualTab = null;
        }
        else
        {
            var index = tabs.currentIndex;

            var item = itemTabs.itemAt(index);

            showTabMenu(currentTab, item, -1, -1, false);
        }
    }

    //---------------------------------------------------------------------------------------------

    function updateTab()
    {
        if (gui.isMicro)
        {
            var indexA = tabs.indexOf(pTab);

            var indexB = player.tabIndex;

            if (indexA == indexB) return;

            if (indexA < indexB)
            {
                 itemSlide.slideLeft();
            }
            else itemSlide.slideRight();

            pTab = playerTab;
        }
        else if (gui.isMini)
        {
            /* var */ indexA = tabs.indexOf(pTab);

            /* var */ indexB = tabs.currentIndex;

            if (indexA == indexB) return;

            if (indexA < indexB)
            {
                 itemSlide.slideLeft();
            }
            else itemSlide.slideRight();

            pTab = currentTab;
        }
        else pTab = currentTab;
    }

    //---------------------------------------------------------------------------------------------
    // Functions

    function pOpenTabPlaylist(playlist)
    {
        var index;

        if (playlist) index = playlist.lastSelected;
        else          index = -1;

        var samePlaylist;

        if (playlist && currentTab.playlist == playlist)
        {
             samePlaylist = true;
        }
        else samePlaylist = false;

        if (samePlaylist)
        {
            var indexTab = tabs.indexOf(currentTab) + 1;

            if (itemTabs.openTabAt(indexTab) == false) return;
        }
        else if (itemTabs.openTab() == false) return;

        if (playlist == null || playlist.isEmpty) return;

        var playlistIndex;

        if (samePlaylist)
        {
            if (index != -1 && index != playlist.currentIndex)
            {
                playlistIndex = index;
            }
            else if (playlist.currentIndex != -1)
            {
                if (playlist.isFeed)
                {
                    if (playlist.currentIndex > 0)
                    {
                         playlistIndex = playlist.currentIndex - 1;
                    }
                    else playlistIndex = playlist.currentIndex;
                }
                else
                {
                    if (playlist.currentIndex < (playlist.count - 1))
                    {
                         playlistIndex = playlist.currentIndex + 1;
                    }
                    else playlistIndex = playlist.currentIndex;
                }
            }
            else playlistIndex = 0;
        }
        else
        {
            if (index != -1) playlistIndex = index;
            else             playlistIndex = 0;
        }

        wall.asynchronous = Image.AsynchronousOff;

        gui.setCurrentTrack(playlist, playlistIndex);

        wall.asynchronous = Image.AsynchronousOn;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        id: bar

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: border.top

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.barTitle_colorA }
            GradientStop { position: 1.0; color: st.barTitle_colorB }
        }

        BorderHorizontal { color: st.barTitle_colorBorderLine }

        ButtonPianoIcon
        {
            id: buttonApplication

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            visible: window.fullScreen

            checkable: true
            checked  : panelApplication.isExposed

            icon: window.icon

            iconSourceSize: st.size24x24

            enableFilter: false

            onPressed:
            {
                gui.restoreBars();

                panelApplication.toggleExpose();
            }
        }

        ButtonPianoIcon
        {
            id: buttonBackward

            anchors.left: (buttonApplication.visible) ? buttonApplication.right
                                                      : parent.left

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            visible: (gui.isMini == false || lineEditSearch.visible == false)

            enabled: (currentTab != null && currentTab.hasPreviousBookmark)

            highlighted: enabled

            icon: st.icon32x32_goBackward

            onClicked: currentTab.setPreviousBookmark()
        }

        ButtonPianoIcon
        {
            id: buttonForward

            anchors.left  : buttonBackward.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            visible: buttonBackward.visible

            enabled: (currentTab != null && currentTab.hasNextBookmark)

            highlighted: enabled

            icon: st.icon32x32_goForward

            onClicked: currentTab.setNextBookmark()
        }

        ButtonPianoIcon
        {
            id: buttonSearch

            anchors.left  : buttonForward.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            visible: (gui.isMini && lineEditSearch.visible == false)

            icon: st.icon32x32_search

            itemIcon.visible: (panelBrowse.isSearching == false)

            onClicked: lineEditSearch.showAndFocus()

            IconLoading
            {
                anchors.centerIn: parent

                visible: panelBrowse.isSearching
            }
        }

        LineEditSearch
        {
            id: lineEditSearch

            anchors.left: (gui.isMini) ? parent.left
                                       : buttonForward.right

            widthMinimum: st.dp320 - x

            widthMaximum: (gui.isMini) ? borderItem.x : st.dp300

            onIsFocusedChanged:
            {
                if (gui.isMini && isFocused == false)
                {
                    visible = false;
                }
            }
        }

        TabsPlayer
        {
            id: itemTabs

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.left : lineEditSearch.right
            anchors.right: buttons.left

            anchors.rightMargin: buttonAdd.width - buttonAdd.borderSizeWidth

            visible: (gui.isMini == false)

            tabs: core.tabs

            delegate: ComponentTabTrack
            {
                text: gui.getTabTitle(item.title, item.state, item.source)
            }

            player: gui.player

            iconDefault: st.icon42x32_track

            asynchronous: Image.AsynchronousOn

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onTabClicked: wall.updateCurrentPage()

            onTabDoubleClicked:
            {
                if (tabs.highlightedIndex == indexHover) return;

                if (panelTracks.isExpanded)
                {
                    panelTracks.restore();
                }
                else gui.playTab();
            }

            //-------------------------------------------------------------------------------------

            onContextual:
            {
                window.clearFocus();

                var tab = tabs.tabAt(indexHover);

                if (lineEditSearch.width != lineEditSearch.widthMinimum)
                {
                    if (actionCue.tryPush(actionTabContextual)) return;

                    startActionCue(st.duration_faster);

                    pContextualTab  = tab;
                    pContextualItem = itemHovered;

                    actionCue.tryPush(actionTabContextual);

                    return;
                }
                else showTabMenu(tab, itemHovered, -1, -1, false);
            }

            //-------------------------------------------------------------------------------------
            // Functions
            //-------------------------------------------------------------------------------------

            function onBeforeCloseTab(index)
            {
                return gui.onBeforeCloseTab(index);
            }
        }

        ItemSlide
        {
            id: itemSlide

            anchors.left  : buttonSearch.right
            anchors.right : buttons.left
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.rightMargin: buttonAdd.width - buttonAdd.borderSizeWidth

            visible: (gui.isMini && lineEditSearch.isFocused == false)

            ItemTabMini
            {
                id: itemTab

                anchors.fill: parent

                textMargin: (buttonsItem.visible) ? st.dp60 : st.dp8

                onPressed:
                {
                    if (mouse.button & Qt.LeftButton)
                    {
                        window.clearFocus();
                    }
                    else if (mouse.button & Qt.RightButton)
                    {
                        showCurrentTabMenu();
                    }
                }

                onClicked:
                {
                    if (mouse.button & Qt.LeftButton)
                    {
                        if (gui.isMicro)
                        {
                            gui.restoreMicro();
                        }
                    }
                    else if (mouse.button & Qt.MiddleButton)
                    {
                        itemTabs.closeTab(tabs.currentIndex);
                    }
                }

                onDoubleClicked:
                {
                    if ((mouse.button & Qt.LeftButton) == false || isMicro) return;

                    if (highlightedTab)
                    {
                        playerBrowser.play();
                    }
                    else gui.playTab();
                }
            }

            ButtonsItem
            {
                id: buttonsItem

                anchors.right: parent.right

                anchors.rightMargin: st.dp4

                anchors.verticalCenter: parent.verticalCenter

                visible: (itemTab.isHovered || checked)

                checked: (panelContextual.item == itemTab || panelAdd.item == barTop)

                buttonClose.enabled: (itemTabs.count > 1 || pTab.isValid)

                onContextual: showCurrentTabMenu()

                onClose: closeCurrentTab()
            }
        }

        BorderVertical
        {
            id: borderItem

            anchors.right: itemSlide.right

            visible: ((gui.isMini && lineEditSearch.visible) || itemSlide.isAnimated)
        }

        ButtonPianoIcon
        {
            id: buttonAdd

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            x: (gui.isMini) ? itemSlide.x + itemSlide.width    - borderLeft
                            : itemTabs .x + itemTabs.tabsWidth - borderLeft

            borderLeft: borderSize

            enabled: (tabs.isFull == false)

            icon          : st.icon24x24_addBold
            iconSourceSize: st.size24x24

            Behavior on x
            {
                enabled: itemTabs.isAnimated

                PropertyAnimation { duration: itemTabs.durationAnimation }
            }

            onClicked:
            {
                if (gui.isMini) window.clearFocus();

                pOpenTabPlaylist(currentPlaylist);
            }
        }

        Item
        {
            id: buttons

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.rightMargin: st.dp16

            width: (gui.isMini) ? buttonExpand.width + buttonWall.width
                                : buttonExpand.width + buttonWall.width + buttonRelated.width

            states: State
            {
                name: "hidden"; when: panelTracks.isExpanded

                AnchorChanges
                {
                    target: buttons

                    anchors.left : parent.right
                    anchors.right: undefined
                }
            }

            transitions: Transition
            {
                AnchorAnimation { duration: st.duration_normal }
            }

            ButtonPianoIcon
            {
                id: buttonExpand

                anchors.right : buttonWall.left
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                borderLeft: borderSize

                checkable: true

                checked: (gui.isMini) ? gui.isMicro
                                      : gui.isExpanded

                icon: (gui.isMini) ? st.icon24x24_goUp
                                   : st.icon24x24_expand

                iconSourceSize: st.size24x24

                onClicked:
                {
                    if (gui.isMini) gui.toggleMicro ();
                    else            gui.toggleExpand();
                }
            }

            ButtonPianoIcon
            {
                id: buttonWall

                anchors.right: (gui.isMini) ? parent.right
                                            : buttonRelated.left

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                checkable: true
                checked  : wall.isExposed

                icon          : st.icon24x24_wall
                iconSourceSize: st.size24x24

                onClicked: gui.toggleWall()
            }

            ButtonPianoIcon
            {
                id: buttonRelated

                anchors.right : parent.right
                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                visible: (gui.isMini == false)

                checkable: true
                checked  : panelRelated.isExposed

                icon          : st.icon24x24_related
                iconSourceSize: st.size24x24

                onClicked: panelRelated.toggleExpose()
            }
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom
    }
}
