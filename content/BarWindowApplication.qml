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
    // Private

    property int pMargin: buttonAdd.width - st.border_size

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

            buttonUpdate.setFocus();
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
        if (actionCue.tryPush(actionTabOpen) || itemTabs.openTab() == false) return;

        startActionCue(st.duration_normal);
    }

    function openTabCurrent()
    {
        if (actionCue.tryPush(actionTabOpen)) return;

        var index = tabs.indexOf(currentTab) + 1;

        if (itemTabs.openTabAt(index) == false) return;

        startActionCue(st.duration_normal);
    }

    function openTabPlaylist()
    {
        if (tabs.isFull) return;

        pOpenTabPlaylist(currentPlaylist);
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
        if (actionCue.tryPush(actionTabOpen)) return;

        //panelDiscover.collapse();

        if (playlist)
        {
            var index = tabs.indexOf(currentTab) + 1;

            if (itemTabs.openTabAt(index) == false) return;

            if (playlist.isEmpty == false)
            {
                wall.asynchronous = false;

                index = playlist.lastSelected;

                if (index != -1)
                {
                    gui.setCurrentTrack(playlist, index);
                }
                else if (playlist.currentIndex != -1)
                {
                    gui.setCurrentTrack(playlist, playlist.currentIndex);
                }
                else gui.setCurrentTrack(playlist, 0);

                wall.asynchronous = true;
            }
        }
        else if (itemTabs.openTab() == false) return;

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
    // Children
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

    ButtonPiano
    {
        id: buttonVersion

        anchors.top: border.top

        borderTop: borderSize

//#WINDOWS
        visible: (sk.isUwp == false && pVersion)
//#ELSE
        visible: pVersion
//#END

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

        onPressed: pUpdate = !(pUpdate)
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

            gui.openUrl("https://omega.gg/MotionBox/get");

            window.clearFocus();
        }

        /* QML_EVENT */ Keys.onPressed: function(event)
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

        anchors.left: (buttonVersion.visible) ? buttonVersion.right
                                              : parent.left

        anchors.top: border.top

        height: buttonVersion.height

        maximumWidth: buttonIconify.x - x + borderRight

        borderTop: borderSize

        visible: pMessage

        icon: online.messageIcon

        iconDefault   : st.icon20x20_love
        iconSourceSize: st.size20x20

        enableFilter: isIconDefault

        text: online.messageTitle

        font.pixelSize: st.dp14

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

        anchors.leftMargin: -(st.border_size)

        anchors.rightMargin: (window.fullScreen) ? pMargin + st.dp16
                                                 : pMargin + st.dp32

        tabs: core.tabs

        delegate: ComponentTabTrack
        {
            text: st.getTabTitle(item.title, item.state, item.source)
        }

        player: gui.player

        iconDefault: st.icon16x16_track

        asynchronous: true

        //-------------------------------------------------------------------------------------
        // Events
        //-------------------------------------------------------------------------------------

        /* QML_EVENT */ onTabPressed: function(index)
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

        x: itemTabs.x + itemTabs.tabsWidth - borderLeft

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

        /* QML_EVENT */ onPressed: function(mouse)
        {
            window.clearFocus();

            if (window.resizer.visible && window.isTouching
                &&
                (viewDrag.x + mouse.x) < buttonIconify.x)
            {
                window.toggleTouch();
            }
        }

        /* QML_EVENT */ onDoubleClicked: function(mouse)
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
        borderRight : 0
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

        borderRight : 0
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
