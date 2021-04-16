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
    id: barWindow

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property variant playlist: null

    //---------------------------------------------------------------------------------------------
    // Private

    property int pMargin: buttonAdd.width - buttonApplication.borderRight

    property bool pVersion: (online.version && online.version != sk.version)

    property bool pUpdate: false

    property bool pMessage: (online.messageUrl != "")

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

    property alias buttonIconify : buttonIconify
    property alias buttonMaximize: buttonMaximize
    property alias buttonClose   : buttonClose

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    anchors.bottomMargin: barTop.height

    height: st.dp32 + border.size

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: (window.fullScreen && barTop.isExpanded)

        AnchorChanges
        {
            target: barWindow

            anchors.bottom: parent.top
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------
    // Private

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
        if (pContextualTab)
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
        panelSearch.setText(currentTab.source);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pOpenTabPlaylist(playlist)
    {
        if (actionCue.tryPush(actionTabOpen))
        {
            barWindow.playlist = playlist;

            return;
        }

        //panelDiscover.collapse();

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
                playlistIndex = playlist.currentIndex;

                /*if (playlist.isFeed)
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
                }*/
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

    function pRestoreMaximize()
    {
        if (window.fullScreen)
        {
            gui.restoreFullScreen();

//#!MAC+!MOBILE
            // FIXME macOS: We can't go from full screen to normal window right away.
            //              This could be related to the animation.
            gui.restoreMaximize();
//#END
        }
        else gui.toggleMaximize();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: border.top

        gradient: Gradient
        {
            GradientStop
            {
                position: 0.0

                color: (window.isActive) ? st.barWindow_colorA
                                         : st.barWindow_colorDisableA
            }

            GradientStop
            {
                position: 1.0

                color: (window.isActive) ? st.barWindow_colorB
                                         : st.barWindow_colorDisableB
            }
        }

        BorderHorizontal
        {
            color: st.barWindow_colorBorderLine

            visible: (st.barWindow_colorA != st.barWindow_colorB)
        }
    }

    ButtonPianoIcon
    {
        id: buttonApplication

        checkable: true
        checked  : panelApplication.isExposed

        icon          : st.icon
        iconSourceSize: st.size24x24

        enableFilter: false

        onPressed:
        {
            gui.restoreBars();

            panelApplication.toggleExpose();
        }
    }

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
                AnchorAnimation
                {
                    duration: st.duration_normal

                    easing.type: st.easing
                }

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
                AnchorAnimation
                {
                    duration: st.duration_faster

                    easing.type: st.easing
                }

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
            if (core.updateVersion())
            {
                window.close();

                return;
            }

            gui.openUrl("http://omega.gg/MotionBox/get");

            window.clearFocus();
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

        maximumWidth: buttonIconify.x - x + borderRight

        borderTop: borderSize

        visible: pMessage

        checked: (panelApplication.isExposed && panelApplication.indexCurrent == 1
                  &&
                  panelApplication.sourceAbout == Qt.resolvedUrl("PageAboutMessage.qml"))

        icon: online.messageIcon

        iconDefault   : st.icon20x20_love
        iconSourceSize: st.size20x20

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
                AnchorAnimation
                {
                    duration: st.duration_normal

                    easing.type: st.easing
                }

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

    TabsPlayer
    {
        id: itemTabs

        //-------------------------------------------------------------------------------------
        // Settings
        //-------------------------------------------------------------------------------------

        anchors.left: (buttonMessage.visible) ? buttonMessage.right
                                              : buttonMessage.left

        anchors.right: buttonIconify.left

        anchors.leftMargin: -(buttonApplication.borderRight)

        anchors.rightMargin: (window.fullScreen) ? pMargin + st.dp16
                                                 : pMargin + st.dp32

        tabs: core.tabs

        delegate: ComponentTabTrack
        {
            text: gui.getTabTitle(item.title, item.state, item.source)
        }

        player: gui.player

        iconDefault: st.icon16x16_track

        asynchronous: true

        //-------------------------------------------------------------------------------------
        // Events
        //-------------------------------------------------------------------------------------

        onTabPressed:
        {
            if (tabs.currentIndex == index)
            {
                gui.selectCurrentTrack();

                return;
            }

            if (player.tabIndex == index)
            {
                gui.restoreBars();
            }

            //panelDiscover.collapse();

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
            var tab = tabs.tabAt(indexHover);

            showTabMenu(tab, itemHovered, -1, -1, false);
        }

        //-------------------------------------------------------------------------------------
        // Functions
        //-------------------------------------------------------------------------------------

        function onBeforeTabClose(index)
        {
            return gui.onBeforeTabClose(index);
        }
    }

    ButtonPianoIcon
    {
        id: buttonAdd

        x: itemTabs .x + itemTabs.tabsWidth - borderLeft

        borderLeft: borderSize

        enabled: (tabs.isFull == false)

        icon          : st.icon16x16_addBold
        iconSourceSize: st.size16x16

        Behavior on x
        {
            enabled: itemTabs.isAnimated

            PropertyAnimation
            {
                duration: itemTabs.durationAnimation

                easing.type: st.easing
            }
        }

        onClicked: pOpenTabPlaylist(currentPlaylist)
    }

    ViewDrag
    {
        id: viewDrag

        anchors.left : buttonAdd.right
        anchors.right: parent.right

//#QT_4
        height: parent.height
//#ELSE
        // FIXME Qt5: Clickable area is larger than item height.
        height: parent.height - border.size
//#END

        y: -(parent.y)

        dragEnabled: (window.fullScreen == false)

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed:
        {
            window.clearFocus();

            if (window.resizer.visible && window.isTouching
                &&
                (viewDrag.x + mouse.x) < buttonIconify.x)
            {
                window.toggleTouch();
            }
        }

        onDoubleClicked:
        {
            if (mouse.button & Qt.LeftButton)
            {
                pRestoreMaximize();
            }
        }
    }

    ButtonPianoWindow
    {
        id: buttonIconify

        anchors.right : (buttonMaximize.visible) ? buttonMaximize.left
                                                 : buttonClose   .left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon12x12_iconify
        iconSourceSize: st.size12x12

        onClicked: window.minimized = true
    }

    ButtonPianoWindow
    {
        id: buttonMaximize

        anchors.right : buttonClose.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderBottom: borderSize

        highlighted: (window.maximized || window.fullScreen)

        icon: (highlighted) ? st.icon12x12_minimize
                            : st.icon12x12_maximize

        iconSourceSize: st.size12x12

        onClicked: pRestoreMaximize()
    }

    ButtonPianoWindow
    {
        id: buttonClose

        anchors.right: parent.right
        anchors.top  : parent.top

        height: st.barWindow_height + borderSizeHeight

        borderRight : 0
        borderBottom: borderSize

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

        colorHoverA: st.button_colorConfirmHoverA
        colorHoverB: st.button_colorConfirmHoverB

        colorPressA: st.button_colorConfirmPressA
        colorPressB: st.button_colorConfirmPressB

        filterIcon: (isHovered || isPressed) ? st.button_filterIconB
                                             : st.button_filterIconA

        onClicked: window.close()
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom

        color: st.border_color
    }
}
