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

Item
{
    id: panelPlayer

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int heightPlayer: parent.height / 1.7

    //---------------------------------------------------------------------------------------------
    // Private

    property int pAreaWidth: player.width / 8

    property int pButton: Qt.NoButton

    property variant pPosition

    property bool pAudio: (player.output == AbstractBackend.OutputAudio
                           ||
                           player.outputActive == AbstractBackend.OutputAudio
                           ||
                           player.isAudio || player.hasOutput)

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias playlistRelated: panelRelated.playlist

    //---------------------------------------------------------------------------------------------

    property alias player         : player
    property alias playerBrowser  : playerBrowser
    property alias playerMouseArea: playerMouseArea

    property alias subtitle: subtitle

    property alias scanner: scanner

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
    // Connections
    //---------------------------------------------------------------------------------------------

//#DESKTOP
    Connections
    {
        target: window

        /* QML_CONNECTION */ function onMousePosChanged() { pCheckAreaHover() }
    }

    Connections
    {
        target: (window.fullScreen) ? scanner : null

        /* QML_CONNECTION */ function onPositionChanged(mouse)
        {
            var y = mouse.y;

            if (y < st.dp64
                ||
                playerMouseArea.height - y < st.dp64) gui.restoreBars();
        }
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showContextual(x, y)
    {
        panelContextual.loadPageTab(currentTab);

        areaContextual.showPanelAt(panelContextual, itemPlayer, x, y, true);
    }

    function showContextualPlayer()
    {
        var position = itemPlayer.mapToItem(gui, 0, 0);

        showContextual(position.x, position.y);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pPlayerClicked()
    {
        if (player.hasStarted == false)
        {
            window.clearFocus();

            return;
        }

        if (pButton & Qt.LeftButton)
        {
            gui.expandBars();

            window.clearFocus();
        }
        else if (pButton & Qt.RightButton)
        {
            if (pContextualTag(scanner.getTextHovered())) return;

            showContextual(window.contentMouseX(), window.contentMouseY());
        }
        else if (pButton & Qt.MiddleButton)
        {
            gui.stop();
        }
    }

    function pPlayerDoubleClicked(mouse)
    {
        if (player.hasStarted == false || (mouse.button & Qt.LeftButton) == 0) return;

        pPosition = pGetPosition();

        if (pCheckAreaClick()) return;

//#MAC
        // FIXME macOS: Setting fullscreen from the double click event seems to skip the mouse
        //              release event. So we wait a bit.
        sk.wait(200);
//#END

        gui.toggleFullScreen();
    }

    function pContextualTag(text)
    {
        if (text == "") return false;

        panelContextual.loadPageTag(text);

        areaContextual.showPanelAt(panelContextual, itemPlayer, window.contentMouseX(),
                                   window.contentMouseY(), true);

        return true;
    }

    //---------------------------------------------------------------------------------------------

    function pCheckArea(mouseX, mouseY)
    {
        if (mouseX < 0 || mouseX >= player.width) return 0;

        var mouseArea = areaBackward.mouseArea;

        var y = mouseArea.y;

        if (mouseY < y || mouseY >= y + mouseArea.height) return 0;

        if (mouseX < areaBackward.width)
        {
            return 1;
        }
        else if (mouseX >= areaForward.x)
        {
            return 2;
        }
        else return 0;
    }

//#DESKTOP
    function pCheckAreaHover()
    {
        if (areaBackward.visible == false || scanner.isHovered)
        {
            areaBackward.hovered = false;
            areaForward .hovered = false;

            return;
        }

        var position = pGetPosition();

        var index = pCheckArea(position.x, position.y);

        if (index == 0)
        {
            areaBackward.hovered = false;
            areaForward .hovered = false;
        }
        else if (index == 1)
        {
            areaBackward.hovered = true;
            areaForward .hovered = false;
        }
        else // if (index == 2)
        {
            areaBackward.hovered = false;
            areaForward .hovered = true;
        }
    }
//#END

    function pCheckAreaClick()
    {
        if (areaBackward.visible == false) return false;

        var index = pCheckArea(pPosition.x, pPosition.y);

        if (index == 0)
        {
            return false;
        }
        else if (index == 1)
        {
            areaBackward.flash();

            player.seek(player.currentTime - st.panelPlayer_interval);

            return true;
        }
        else // if (index == 2)
        {
            areaForward.flash();

            player.seek(player.currentTime + st.panelPlayer_interval);

            return true;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pGetPosition()
    {
        return window.mapToItem(itemPlayer, window.mouseX, window.mouseY);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Item
    {
        id: itemPlayer

        anchors.left  : parent.left
        anchors.right : panelRelated.left
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        SkyMouseArea
        {
            id: playerMouseArea

            anchors.fill: parent

            anchors.leftMargin: (gui.isExpanded) ? st.dp16 : 0

            anchors.rightMargin: (panelRelated.isExposed == false) ? st.dp16 : 0

            anchors.bottomMargin: (barTop.isExpanded) ? st.dp16 : 0

            hoverEnabled: player.hasStarted
            hoverRetain : true

            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            cursor: (player.hasStarted) ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor

            /* QML_EVENT */ onClicked: function(mouse)
            {
                pButton = mouse.button;

                pPosition = pGetPosition();

                // NOTE: If it's a RightButton we skip the tags and the seek areas.
                if ((pButton & Qt.RightButton) == 0
                    &&
                    ((scanner.visible && scanner.click()) || pCheckAreaClick())) return;

                pPlayerClicked();
            }

            /* QML_EVENT */ onDoubleClicked: function(mouse) { pPlayerDoubleClicked(mouse); }
        }

        Player
        {
            id: player

            anchors.fill: parent

            visible: hasStarted

            tabs: core.tabs

            autoPlay: local.autoPlay

            shuffle: (isPlaying) ? local.shuffle : false

            pauseTimeout: 600000 // 10 minutes
        }

        Rectangle
        {
            id: back

            anchors.fill: parent

            visible: (player.isStopped || player.isStarting || player.isResuming || pAudio)

            gradient: Gradient
            {
                GradientStop
                {
                    position: 0.0

                    color: (cover.isSourceDefault) ? st.logo_colorA
                                                   : st.panelPlayer_color
                }

                GradientStop
                {
                    position: 1.0

                    color: (cover.isSourceDefault) ? st.logo_colorB
                                                   : st.panelPlayer_color
                }
            }

            ImageScale
            {
                id: cover

                anchors.fill: parent

                anchors.leftMargin: (isSourceDefault) ? parent.width / st.logoRatio : 0

                anchors.rightMargin: anchors.leftMargin

                clip: (fillMode == SkyImage.PreserveAspectCrop)

                source: (pAudio) ? currentTab.cover
                                 : currentTab.coverShot

                sourceDefault: st.logo

                fillMode: (isSourceDefault) ? SkyImage.PreserveAspectFit
                                            : player.fillMode

                asynchronous: gui.asynchronous

                cache: false

                scaling: isSourceDefault

                onVisibleChanged: if (visible) loadNow()
            }
        }

        RectangleShadowClick
        {
            id: areaBackward

            anchors.left  : player.left
            anchors.top   : player.top
            anchors.bottom: player.bottom

            width: pAreaWidth

            visible: (sk.cursorVisible && player.isPlaying && player.duration != -1)

            interactive: false

            direction: Sk.Right

            filter: st.icon_filterActive
        }

        RectangleShadowClick
        {
            id: areaForward

            anchors.right : player.right
            anchors.top   : player.top
            anchors.bottom: player.bottom

            width: pAreaWidth

            visible: areaBackward.visible

            interactive: false

            filter: st.icon_filterActive
        }

        Subtitle
        {
            id: subtitle

            player: player

            /* QML_EVENT */ onLoaded: function(ok)
            {
                if (ok == false) panelSubtitles.clearSubtitle();
            }

            function onUpdateMargin()
            {
                margin = applySize(player, cover);
            }
        }

        AnimatedLoader
        {
            anchors.left  : player.left
            anchors.right : player.right
            anchors.bottom: player.bottom

            height: Math.max(st.dp3, player.height / 128)

            opacity: (player.isPlaying && player.isLoading)
        }

        ItemScan
        {
            id: scanner

            anchors.fill: parent

            visible: (player.visible || (back.visible && cover.isSourceDefault == false))

            player: player
            cover : cover

//#DESKTOP
            cursor: (areaBackward.hovered || areaForward.hovered) ? Qt.PointingHandCursor
                                                                  : Qt.ArrowCursor
//#END

            /* QML_EVENT */ onClicked: function(text)
            {
                if (text)
                {
                    gui.browse(text);
                }
                else if (pCheckAreaClick() == false)
                {
                    pPlayerClicked();
                }
            }

//#DESKTOP+QT_NEW
            onIsHoveredChanged:
            {
                // NOTE: This prevents a binding loop on sk.cursorVisible.
                Qt.callLater(gui.onScannerHoveredChanged);

                pCheckAreaHover();
            }
//#ELIF DESKTOP
            onIsHoveredChanged:
            {
                gui.onScannerHoveredChanged();

                pCheckAreaHover();
            }
//#END
        }

        PlayerBrowser
        {
            id: playerBrowser

            anchors.fill: parent

            visible: (player.hasStarted == false)

            opacity: (visible)

            player: player

            tab: currentTab

            loading: panelBrowse.isSelecting

            enableTitle: (currentTab.playlist != null)

            barTitle.visible: (buttonPlay.visible && title)

            barDetails.visible: (barTitle.visible && tab && tab.isLoaded)

            areaForward.anchors.top: barTitle.bottom

            Behavior on opacity
            {
                PropertyAnimation
                {
                    duration: (visible) ? st.duration_fast : 0

                    easing.type: st.easing
                }
            }

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

            onContextual:
            {
                if (pContextualTag(scanner.getTextHovered())) return;

                showContextual(window.contentMouseX(), window.contentMouseY());
            }
        }
    }

    PanelRelated { id: panelRelated }
}
