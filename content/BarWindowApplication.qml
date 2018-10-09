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
    id: barWindow

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property variant playlist: null

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pVersion: (gui.isMini == false && online.version && online.version != sk.version)

    property bool pUpdate: false

    property bool pMessage: (gui.isMini == false && online.messageUrl != "")

    property TabTrack pContextualTab : null
    property variant  pContextualItem: null

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias tabs: itemTabs.tabs

    //---------------------------------------------------------------------------------------------

    property alias buttonApplication: buttonApplication

    property alias buttonVersion: buttonVersion
    property alias buttonMessage: buttonMessage

    property alias itemTabs: itemTabs

    property alias buttonAdd: buttonAdd

    property alias buttonMini    : buttonMini
    property alias buttonIconify : buttonIconify
    property alias buttonMaximize: buttonMaximize
    property alias buttonClose   : buttonClose

    //---------------------------------------------------------------------------------------------
    // Private

    property alias pTab: itemTab.tab

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    anchors.bottom: (window.fullScreen) ? barTop.top : undefined

    height: st.dp32 + border.size

    //---------------------------------------------------------------------------------------------
    // Events private

    onPVersionChanged:
    {
        clip = true;

        if (pVersion)
        {
            buttonVersion.visible = true;
        }
        else if (pUpdate) window.clearFocus();
    }

    onPUpdateChanged:
    {
        clip = true;

        if (pUpdate)
        {
            buttonUpdate.visible = true;

            buttonUpdate.focus();
        }
    }

    //---------------------------------------------------------------------------------------------

    onPMessageChanged:
    {
        clip = true;

        if (pMessage)
        {
            buttonMessage.visible = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function openTab()
    {
        return openTabPlaylist(currentPlaylist);
    }

    function openTabPlaylist(playlist)
    {
        if (tabs.isFull) return false;

        pOpenTabPlaylist(playlist);

        return true;
    }

    //---------------------------------------------------------------------------------------------

    function closeCurrentTab()
    {
        if (gui.isMini)
        {
            var index = tabs.indexOf(itemTab.tab);

            itemTabs.closeTab(index);

            updateTab();
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

            if (actionCue.tryPush(actionTabMenu)) return;

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
    // Private

    function pOpenTabPlaylist(playlist)
    {
        gui.restoreMicro();

        if (actionCue.tryPush(actionTabOpen))
        {
            barWindow.playlist = playlist;

            return;
        }

        panelDiscover.collapse();

        var index;

        if (playlist)
        {
             index = playlist.lastSelected;
        }
        else index = -1;

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

        if (playlist == null || playlist.isEmpty)
        {
            startActionCue(st.duration_normal);

            return;
        }

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
        else if (index != -1)
        {
             playlistIndex = index;
        }
        else playlistIndex = 0;

        wall.asynchronous = false;

        gui.setCurrentTrack(playlist, playlistIndex);

        wall.asynchronous = true;

        startActionCue(st.duration_normal);
    }

    //---------------------------------------------------------------------------------------------

    function pMaximize()
    {
        gui.toggleMaximize();
    }

    function pDoubleClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
             gui.toggleMaximize();
        }
        else gui.toggleMini();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonPiano
    {
        id: buttonVersion

        anchors.left: buttonApplication.right
        anchors.top : border.top

        height: buttonApplication.height + borderSizeHeight

        borderTop: borderSize

        visible: pVersion

        highlighted: true
        checked    : pUpdate

        text: qsTr("New Version")

        font.pixelSize: st.dp14

        states: State
        {
            name: "exposed"; when: pVersion

            AnchorChanges
            {
                target: buttonVersion

                anchors.top   : undefined
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_normal }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pVersion) return;

                        buttonVersion.visible = false;
                    }
                }
            }
        }

        onPressed:
        {
            panelApplication.collapse();

            pUpdate = !(pUpdate);
        }
    }

    ButtonPiano
    {
        id: buttonUpdate

        anchors.left : buttonVersion.left
        anchors.right: buttonVersion.right
        anchors.top  : border.top

        height: buttonVersion.height

        borderTop: borderSize

        visible: false

        text: qsTr("Update")

        font.pixelSize: st.dp14

        states: State
        {
            name: "active"; when: pUpdate

            AnchorChanges
            {
                target: buttonUpdate

                anchors.top   : undefined
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_faster }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pUpdate) return;

                        buttonUpdate.visible = false;
                    }
                }
            }
        }

        onIsFocusedChanged: pUpdate = isFocused

        onClicked:
        {
            if (core.updateVersion() == false)
            {
                gui.openUrl("http://omega.gg/MotionBox/get");

                window.clearFocus();
            }
            else window.close();
        }

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                window.clearFocus();
            }
        }
    }

    ButtonPianoFull
    {
        id: buttonMessage

        anchors.left: (buttonVersion.visible) ? buttonVersion    .right
                                              : buttonApplication.right

        anchors.top: border.top

        height: buttonVersion.height

        maximumWidth: buttonMini.x - x + borderRight

        borderTop: borderSize

        visible: pMessage

        checked: (panelApplication.isExposed && panelApplication.itemTabs.indexCurrent == 1
                  &&
                  panelApplication.sourceAbout == Qt.resolvedUrl("PageAboutMessage.qml"))

        icon: online.messageIcon

        iconDefault   : st.icon24x24_love
        iconSourceSize: st.size24x24

        enableFilter: isIconDefault

        text: online.messageTitle

        font.pixelSize: st.dp14

        onClicked:
        {
            if (checked)
            {
                 panelApplication.collapse();
            }
            else panelApplication.setAboutPage("PageAboutMessage.qml");
        }

        states: State
        {
            name: "exposed"; when: pMessage

            AnchorChanges
            {
                target: buttonMessage

                anchors.top   : undefined
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_normal }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pMessage) return;

                        buttonMessage.visible = false;
                    }
                }
            }
        }
    }

    ButtonPianoIcon
    {
        id: buttonBackward

        anchors.left: (buttonMessage.visible) ? buttonMessage.right
                                              : buttonMessage.left

        enabled: (currentTab != null && currentTab.hasPreviousBookmark)

        highlighted: enabled

        icon          : st.icon32x32_goBackward
        iconSourceSize: st.size32x32

        onClicked:
        {
            panelDiscover.collapse();

            currentTab.setPreviousBookmark();
        }
    }

    ButtonPianoIcon
    {
        id: buttonForward

        anchors.left: buttonBackward.right

        enabled: (currentTab != null && currentTab.hasNextBookmark)

        highlighted: enabled

        icon          : st.icon32x32_goForward
        iconSourceSize: st.size32x32

        onClicked:
        {
            panelDiscover.collapse();

            currentTab.setNextBookmark();
        }
    }

    TabsPlayer
    {
        id: itemTabs

        //-------------------------------------------------------------------------------------
        // Settings
        //-------------------------------------------------------------------------------------

        anchors.left : buttonForward.right
        anchors.right: buttonMini.left

        anchors.leftMargin: -(buttonForward.borderRight)

        anchors.rightMargin: buttonAdd.width - buttonAdd.borderSizeWidth + st.dp32

        visible: (gui.isMini == false)

        tabs: core.tabs

        delegate: ComponentTabTrack
        {
            text: gui.getTabTitle(item.title, item.state, item.source)
        }

        player: gui.player

        iconDefault: st.icon56x32_track

        asynchronous: true

        //-------------------------------------------------------------------------------------
        // Events
        //-------------------------------------------------------------------------------------

        onTabClicked:
        {
            panelDiscover.collapse();

            wall.updateCurrentPage();
        }

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
                if (actionCue.tryPush(actionTabMenu)) return;

                startActionCue(st.duration_faster);

                pContextualTab  = tab;
                pContextualItem = itemHovered;

                actionCue.tryPush(actionTabMenu);

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

        anchors.left  : buttonForward.right
        anchors.right : buttonMini.left
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        anchors.rightMargin: buttonAdd.width - buttonAdd.borderSizeWidth + st.dp16

        visible: gui.isMini

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
                    if (isHighlighted)
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
                if ((mouse.button & Qt.LeftButton) == false) return;

                if (gui.isMicro)
                {
                     gui.restoreMicro();
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

    ViewDrag
    {
        anchors.left : buttonAdd.right
        anchors.right: parent.right

        // FIXME Qt5: Clickable area is larger than item height.
        height: parent.height - border.size

        y: -(parent.y)

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: window.clearFocus()

        onDoubleClicked:
        {
            if (mouse.button & Qt.LeftButton)
            {
                 gui.toggleMaximize();
            }
            else gui.toggleMini();
        }
    }

    ButtonPianoIcon
    {
        id: buttonMini

        anchors.right : buttonIconify.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft  : borderSize
        borderRight : 0
        borderBottom: borderSize

        highlighted: gui.pMini

        checkable: true
        checked  : gui.isMini

        icon: (gui.isMini) ? st.icon16x16_maxi
                           : st.icon16x16_mini

        iconSourceSize: st.size16x16

        onClicked: gui.toggleMini();
    }

    ButtonPianoIcon
    {
        id: buttonIconify

        anchors.right : (buttonMaximize.visible) ? buttonMaximize.left
                                                 : buttonClose   .left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon16x16_iconify
        iconSourceSize: st.size16x16

        onClicked: window.minimized = true
    }

    ButtonPianoIcon
    {
        id: buttonMaximize

        anchors.right : buttonClose.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderBottom: borderSize

        visible: (gui.isMini == false)

        highlighted: window.maximized

        icon: (window.maximized) ? st.icon16x16_minimize
                                 : st.icon16x16_maximize

        iconSourceSize: st.size16x16

        onClicked: gui.toggleMaximize()
    }

    ButtonPianoIcon
    {
        id: buttonClose

        anchors.right: parent.right
        anchors.top  : parent.top

        height: st.barWindow_height + borderSizeHeight

        anchors.rightMargin : st.dp16
        anchors.bottomMargin: st.dp6
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom

        color: st.border_color
    }
}
