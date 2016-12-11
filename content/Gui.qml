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

Item
{
    id: gui

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isLoaded: false

    /* read */ property bool isMini : false
    /* read */ property bool isMicro: false

    /* read */ property bool isMinified: false

    /* read */ property bool isExpanded: local.expanded

    property int itemAsynchronous: Image.AsynchronousOn

    /* read */ property TabTrack currentTab    : tabs.currentTab
    /* read */ property TabTrack highlightedTab: tabs.highlightedTab

    /* read */ property TabTrack playerTab: player.tab

    /* read */ property LibraryFolder library: core.library
    /* read */ property LibraryFolder hubs   : core.hubs
    /* read */ property LibraryFolder related: core.related

    /* read */ property variant currentPlaylist: pGetCurrentPlaylist()

    /* read */ property PlaylistNet playlistTemp: core.createPlaylist()

    //---------------------------------------------------------------------------------------------
    // Drag

    property int     drag     : -1
    property variant dragList : null
    property variant dragItem : null
    property int     dragId   : -1
    property int     dragType : -1
    property variant dragData

    //---------------------------------------------------------------------------------------------
    // Actions

    /* read */ property int actionExpand : 0
    /* read */ property int actionRestore: 1

    /* read */ property int actionWallExpose : 2
    /* read */ property int actionWallRestore: 3

    /* read */ property int actionRelatedExpose  : 4
    /* read */ property int actionRelatedCollapse: 5

    /* read */ property int actionRelatedExpand : 6
    /* read */ property int actionRelatedRestore: 7

    /* read */ property int actionBarsExpand : 8
    /* read */ property int actionBarsRestore: 9

    /* read */ property int actionTracksExpand : 10
    /* read */ property int actionTracksRestore: 11

    /* read */ property int actionBrowseExpose  : 12
    /* read */ property int actionBrowseCollapse: 13

    /* read */ property int actionAddShow: 14
    /* read */ property int actionAddHide: 15

    /* read */ property int actionSettingsExpose  : 16
    /* read */ property int actionSettingsCollapse: 17

    /* read */ property int actionShareExpose  : 18
    /* read */ property int actionShareCollapse: 19

    /* read */ property int actionSearchExpose: 20

    /* read */ property int actionMaximizeExpose : 21
    /* read */ property int actionMaximizeRestore: 22

    /* read */ property int actionFullScreenExpose : 23
    /* read */ property int actionFullScreenRestore: 24

    /* read */ property int actionMiniExpose : 25
    /* read */ property int actionMiniRestore: 26

    /* read */ property int actionMicroExpose : 27
    /* read */ property int actionMicroRestore: 28

    /* read */ property int actionTabOpen: 29
    /* read */ property int actionTabMenu: 30

    /* read */ property int actionZoom: 31

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pReady: (isLoaded && library.isLoading == false && hubs.isLoading == false
                                       &&
                                       related.isLoading == false)


    property bool pMini     : false
    property bool pMiniMicro: local.micro

    property bool pMiniSize: true

    property bool pMiniVisible: false

    property bool pMiniExpanded: false
    property bool pMiniTracks  : false

    property bool pMiniWall: false

    property bool pMiniRelated        : false
    property bool pMiniRelatedExpanded: false

    //---------------------------------------------------------------------------------------------

    property PlaylistNet pLoadPlaylist: null

    property int pLoadIndex: -1

    //---------------------------------------------------------------------------------------------

    property int pEditStart: -1
    property int pEditEnd  : -1

    property bool pEditAtEnd: false

    //---------------------------------------------------------------------------------------------

    property real pZoomScale: -1

    property int pZoomX: -1
    property int pZoomY: -1

    property int pZoomDuration: -1
    property int pZoomEasing  : -1

    property bool pZoomAfter: false
    property bool pZoomLater: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias barWindow: barWindow
    property alias barTop   : barTop

    property alias itemContent: itemContent

    property alias areaDrag: areaDrag

    property alias bordersDrop: bordersDrop

    property alias toolTip: toolTip

    //---------------------------------------------------------------------------------------------
    // BarWindow

    property alias buttonMaximize: barWindow.buttonMaximize

    //---------------------------------------------------------------------------------------------
    // BarTop

    property alias tabs: barTop.tabs

    //---------------------------------------------------------------------------------------------

    property alias buttonBackward: barTop.buttonBackward
    property alias buttonForward : barTop.buttonForward

    property alias lineEditSearch: barTop.lineEditSearch

    property alias itemTabs: barTop.itemTabs

    property alias buttonExpand : barTop.buttonExpand
    property alias buttonWall   : barTop.buttonWall
    property alias buttonRelated: barTop.buttonRelated

    //---------------------------------------------------------------------------------------------
    // PanelLibrary

    property alias scrollLibrary: panelLibrary.scrollLibrary

    property alias listLibrary: panelLibrary.listLibrary

    //---------------------------------------------------------------------------------------------
    // PanelPlayer

    property alias playlistRelated: panelPlayer.playlistRelated

    property alias wall: panelPlayer.wall

    property alias player         : panelPlayer.player
    property alias playerBrowser  : panelPlayer.playerBrowser
    property alias playerMouseArea: panelPlayer.playerMouseArea

    property alias panelRelated: panelPlayer.panelRelated

    //---------------------------------------------------------------------------------------------
    // PanelTracks

    property alias folder  : panelTracks.folder
    property alias playlist: panelTracks.playlist

    //---------------------------------------------------------------------------------------------

    property alias scrollFolder  : panelTracks.scrollFolder
    property alias scrollPlaylist: panelTracks.scrollPlaylist

    property alias listFolder  : panelTracks.listFolder
    property alias listPlaylist: panelTracks.listPlaylist

    //---------------------------------------------------------------------------------------------
    // PanelBrowse

    property alias playlistBrowse: panelBrowse.playlist

    //---------------------------------------------------------------------------------------------
    // BarControls

    property alias buttonPlay: barControls.buttonPlay

    property alias buttonPrevious: barControls.buttonPrevious
    property alias buttonNext    : barControls.buttonNext

    property alias buttonAdd: barControls.buttonAdd

    property alias buttonSettings  : barControls.buttonSettings
    property alias buttonShare     : barControls.buttonShare
    property alias buttonFullScreen: barControls.buttonFullScreen

    property alias sliderVolume: barControls.sliderVolume
    property alias sliderStream: barControls.sliderStream

    //---------------------------------------------------------------------------------------------
    // ContextualArea

    property alias areaContextual: areaContextual

    property alias panelContextual: areaContextual.panelContextual
    property alias panelAdd       : areaContextual.panelAdd

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal scaleBefore
    signal scaleAfter

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State { name: "micro"; when: isMicro }

    transitions: Transition
    {
        SequentialAnimation
        {
            PauseAnimation { duration: st.duration_fast }

            ScriptAction
            {
                script: if (isMicro) panelPlayer.visible = false
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        loadTabItems(currentTab);

        if (local.browserVisible)
        {
            panelBrowse.expose();
        }

        if (local.related)
        {
            panelRelated.expose();

            if (local.relatedExpanded)
            {
                panelRelated.expand();
            }
        }

        if (panelTracks.isExpanded)
        {
            panelPlayer.visible = false;
        }

        player.speed = local.speed;

        player.volume = local.volume;

        player.repeat = local.repeat;

        player.output  = local.output;
        player.quality = local.quality;

        if      (local.networkCache == 0) player.backend.networkCache = 5000;
        else if (local.networkCache == 1) player.backend.networkCache = 1000;
        else if (local.networkCache == 2) player.backend.networkCache = 500;
        else                              player.backend.networkCache = 200;

        if (local.proxyActive)
        {
            var backend = player.backend;

            backend.setProxy(local.proxyHost, local.proxyPort, local.proxyPassword);
        }

        barTop      .updateTab();
        panelRelated.updateTab();

        window.resizable = true;

        window.clearFocus();

        isLoaded = true;
    }

    //---------------------------------------------------------------------------------------------

    onPReadyChanged:
    {
        if (pReady == false) return;

        pReady = false;

        st.animate = true;

        splash.hide();
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        onCacheEmptyChanged:
        {
            if (core.cacheIsEmpty == false)
            {
                local.cache = true;
            }
        }
    }

    Connections
    {
        target: st

        onRatioChanged:
        {
            panelApplication.updateTabs();

            areaDrag   .updatePosition();
            bordersDrop.updatePosition();
        }
    }

    Connections
    {
        target: window

        onStateChanged:
        {
            if (state != Qt.WindowNoState || pMini == false) return;

            pMiniSize = false;

            exposeMini();

            pMiniSize = true;
        }

        onActiveChanged: updateScreenDim()

        onIdleChanged:
        {
            if (window.idle)
            {
                if (playerMouseArea.containsMouse)
                {
                    sk.cursorVisible = false;
                }
            }
            else sk.cursorVisible = true;
        }

        onMousePressed : onMousePressed (event)
        onMouseReleased: onMouseReleased(event)

        onDragEntered: onDragEntered(event)
        onDragExited : onDragExited (event)
        onDrop       : onDrop       (event)

        onDragEnded: onDragEnded()

        onKeyPressed : onKeyPressed (event)
        onKeyReleased: onKeyReleased(event)

        onZoomChanged:
        {
            if (pZoomLater)
            {
                pZoomLater = false;

                scaleAfter();

                itemAsynchronous = Image.AsynchronousOn;
            }
        }

        onBeforeClose:
        {
            if (player.isStopped) return;

            playerBrowser.visible = false;

            st.animate = false;

            player.stop();

            st.animate = true;
        }

        onFadeOut:
        {
            if (isMini)
            {
                local.maximized = false;

                restoreMini();
            }
            else
            {
                local.maximized = window.maximized;

                restoreFullScreen();
            }

            local.setMiniPos(-1, -1);

            st.animate = false;

            areaContextual.hidePanels();

            collapsePanels();

            panelLibrary.buttonsUpdater.visible = false;

            playerBrowser.visible = true;

            var playlist = currentTab.playlist;

            setPlaylistFocus(playlist);

            if (playlist && playlist.selectedCount)
            {
                var list = getListPlaylist(playlist);

                if (list)
                {
                    list.hasPlaylist = false;

                    playlist.selectCurrentTrack();
                }
            }

            window.clearFocus();
            window.clearHover();

            window.hoverEnabled = false;

            sk.processEvents();

            core.saveSplash(window, window.borderSize);

            controllerPlaylist.abortFolderItems();

            pSaveSize();

            local.save();
        }
    }

    Connections
    {
        target: tabs

        onCurrentTabChanged:
        {
            barTop      .updateTab();
            panelRelated.updateTab();

            loadTabItems(currentTab);

            pUpdateCache();

            panelRelated.refreshLater();
        }
    }

    Connections
    {
        target: currentTab

        onCurrentBookmarkChanged:
        {
            var playlist = currentTab.playlist;

            if (playlist == null) return;

            var index = playlist.currentIndex;

            core.updateCache(playlist, index);

            loadTracksLater(playlist, index);

            panelRelated.refreshLater();
        }
    }

    Connections
    {
        target: (currentTab && currentTab.playlist) ? currentTab.playlist : null

        onTrackUpdated:
        {
            var currentIndex = currentTab.playlist.currentIndex;

            if (currentIndex != -1
                &&
                (currentIndex == index - 1 || currentIndex == index + 1))
            {
                pUpdateCache();
            }
        }
    }

    Connections
    {
        target: player

        onHasStartedChanged: restoreBars()

        onSpeedChanged: local.speed = player.speed

        onVolumeChanged: local.volume = player.volume

        onRepeatChanged: local.repeat = player.repeat

        onOutputChanged : local.output  = player.output
        onQualityChanged: local.quality = player.quality

        onIsPlayingChanged:
        {
            panelCover.updatePanel();

            updateScreenDim();

            if (player.isPlaying == false)
            {
                restoreBars();

                sk.screenSaverEnabled = true;
            }
            else sk.screenSaverEnabled = false;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function scale(scale)
    {
        if (st.scale == scale) return;

        restoreMini();

        st.animate = false;

        wall.enableAnimation = false;

        scaleBefore();

        st.scale = scale;

        scaleAfter();

        sk.defaultScreen = window.getScreenNumber();

        sk.defaultWidth  = -1;
        sk.defaultHeight = -1;

        local.setMiniPos(-1, -1);

        window.setMinimumSize(st.minimumWidth, st.minimumHeight);

        window.setDefaultGeometry();

        wall.updateView();

        wall.enableAnimation = true;

        st.animate = true;

        local.scale = scale;
    }

    //---------------------------------------------------------------------------------------------

    function zoom(scale, x, y, duration /* 0 */, easing /* Easing.Linear */, zoomAfter /* false */)
    {
        if (duration == undefined)
        {
            duration = st.duration_fast;
        }

        if (easing == undefined)
        {
            easing = Easing.Linear;
        }

        if (zoomAfter == undefined)
        {
            zoomAfter = false;
        }

        if (actionCue.tryPush(actionZoom))
        {
            pZoomScale = scale;

            pZoomX = x;
            pZoomY = y;

            pZoomDuration = duration;
            pZoomEasing   = easing;

            pZoomAfter = zoomAfter;

            return;
        }

        pZoomLater = zoomAfter;

        wall.enableAnimation = false;

        itemAsynchronous = Image.AsynchronousOff;

        scaleBefore();

        if (zoomAfter == false)
        {
            window.zoomTo(scale, x, y, duration, easing, false);

            scaleAfter();

            itemAsynchronous = Image.AsynchronousOn;
        }
        else window.zoomTo(scale, x, y, duration, easing, true);

        wall.updateView();

        wall.enableAnimation = true;

        panelPreview.update();

        if (window.realTime)
        {
             startActionCue(duration);
        }
        else startActionCue(duration + st.duration_faster);
    }

    //---------------------------------------------------------------------------------------------

    function expand()
    {
        panelTracks.restore();

        if (isExpanded || actionCue.tryPush(actionExpand)) return;

        areaContextual.hidePanels();

        panelLibrary.saveScroll();

        isExpanded = true;

        if (panelRelated.isExposed)
        {
            var width = itemContent.width;

            panelPlayer.wallExpand(width - panelRelated.getWidth(width), itemContent.height);
        }
        else panelPlayer.wallExpand(itemContent.width, itemContent.height);

        panelCover.updatePanel();

        local.expanded = true;

        startActionCue(st.duration_normal);
    }

    function restore()
    {
        restoreMini();

        if (isExpanded == false || actionCue.tryPush(actionRestore)) return;

        if (panelBrowse.isExposed)
        {
             panelBrowse.visible = true;
        }
        else panelTracks.visible = true;

        panelLibrary.visible = true;

        isExpanded = false;

        if (panelRelated.isExposed)
        {
            var width = itemContent.width - panelLibrary.width;

            panelPlayer.wallExpand(width - panelRelated.getWidth(width), panelPlayer.heightPlayer);
        }
        else panelPlayer.wallExpand(itemContent.width - panelLibrary.width,
                                    panelPlayer.heightPlayer);

        panelCover.updatePanel();

        local.expanded = false;

        startActionCue(st.duration_normal);
    }

    function toggleExpand()
    {
        if (isExpanded) restore();
        else            expand ();
    }

    //---------------------------------------------------------------------------------------------

    function exposeWall()
    {
        restoreMicro();

        panelTracks.restore();

        if (wall.isExposed || actionCue.tryPush(actionWallExpose)) return;

        wall.expose();

        startActionCue(st.duration_normal);
    }

    function restoreWall()
    {
        if (wall.isExposed == false || actionCue.tryPush(actionWallRestore)) return;

        wall.restore();

        startActionCue(st.duration_normal);
    }

    function toggleWall()
    {
        if (wall.isExposed) restoreWall();
        else                exposeWall ();
    }

    //---------------------------------------------------------------------------------------------

    function expandBars()
    {
        if (areaContextual.isActive)
        {
            areaContextual.hidePanels();

            return;
        }
        else if (panelApplication.isExposed)
        {
            panelApplication.collapse();

            return;
        }
        else if (lineEditSearch.isFocused)
        {
            window.clearFocus();

            return;
        }
        else if (panelTracks.isExpanded)
        {
            panelTracks.restore();

            return;
        }
        else if (highlightedTab)
        {
            tabs.currentTab = highlightedTab;

            return;
        }
        else if (panelRelated.isExposed)
        {
            panelRelated.collapse();

            return;
        }
        else if (isExpanded == false)
        {
            expand();

            return;
        }
        else if (panelSettings.isExposed)
        {
            panelSettings.collapse();

            return;
        }
        else if (panelShare.isExposed)
        {
            panelShare.collapse();

            return;
        }

        if (barTop.isExpanded || actionCue.tryPush(actionBarsExpand)) return;

        barTop     .expand();
        barControls.expand();

        window.idle = true;

        startActionCue(st.duration_normal);
    }

    function restoreBars()
    {
        if (barTop.isExpanded == false || actionCue.tryPush(actionBarsRestore)) return;

        barTop     .restore();
        barControls.restore();

        window.idle = false;

        startActionCue(st.duration_normal);
    }

    function toggleBars()
    {
        if (barTop.isExpanded) restoreBars();
        else                   expandBars ();
    }

    //---------------------------------------------------------------------------------------------

    function panelAddShow()
    {
        restoreMicro();

        if (buttonAdd.checked || actionCue.tryPush(actionAddShow)) return;

        panelSettings.collapse();
        panelShare   .collapse();

        playlistTemp.clearTracks();

        currentTab.copyTrackTo(playlistTemp);

        panelAdd.setSource(0, playlistTemp, 0);

        if (isMini)
        {
             areaContextual.showPanelPositionMargins(panelAdd, barControls, Sk.TopLeft,
                                                     st.dp2, st.dp2);
        }
        else areaContextual.showPanel(panelAdd, barControls, Sk.TopLeft,
                                      barControls.borderB.x + barControls.borderB.width, -1,
                                      0, st.dp2, false);

        startActionCue(st.duration_faster);
    }

    function panelAddHide()
    {
        if (areaContextual.isActive == false || actionCue.tryPush(actionAddHide)) return;

        areaContextual.hidePanels();

        startActionCue(0);
    }

    //---------------------------------------------------------------------------------------------

    function exposeMaximize()
    {
        if (window.maximized || actionCue.tryPush(actionMaximizeExpose)) return;

        wall.clearDrag();

        wall.enableAnimation = false;

        if (isMini)
        {
            pMini = true;

            st.animate = false;

            pRestoreMiniA();

            if (sk.osWin) window.setWindowMaximize(true);

            window.maximized = true;

            pRestoreMiniB();

            st.animate = true;
        }
        // FIXME Windows: Hiding the window to avoid the animation.
        else if (sk.osWin && window.fullScreen)
        {
            if (pMini == false)
            {
                window.setWindowSnap(true);
            }

            window.setWindowMaximize(true);

            window.visible = false;

            window.fullScreen = false;
            window.maximized  = true;

            window.visible = true;
        }
        else
        {
            window.fullScreen = false;
            window.maximized  = true;
        }

        wall.updateView();

        wall.enableAnimation = true;

        pSaveSize();

        local.maximized = true;

        startActionCue(st.duration_faster);
    }

    function restoreMaximize()
    {
        if (window.maximized == false || actionCue.tryPush(actionMaximizeRestore)) return;

        if (pMini)
        {
            exposeMini();

            return;
        }

        wall.clearDrag();

        wall.enableAnimation = false;

        window.maximized = false;

        wall.updateView();

        wall.enableAnimation = true;

        pSaveSize();

        local.maximized = false;

        startActionCue(st.duration_faster);
    }

    function toggleMaximize()
    {
        if (window.maximized)
        {
            if (window.fullScreen)
            {
                 restoreFullScreen();
            }
            else restoreMaximize();
        }
        else exposeMaximize();
    }

    //---------------------------------------------------------------------------------------------

    function exposeFullScreen()
    {
        if (window.fullScreen || actionCue.tryPush(actionFullScreenExpose)) return;

        wall.clearDrag();

        wall.enableAnimation = false;

        if (isMini)
        {
            pMini = true;

            st.animate = false;

            pRestoreMiniA();

            window.fullScreen = true;

            pRestoreMiniB();

            st.animate = true;
        }
        else
        {
            if (sk.osWin) window.setWindowSnap(false);

            window.fullScreen = true;
        }

        wall.updateView();

        wall.enableAnimation = true;

        startActionCue(st.duration_faster);
    }

    function restoreFullScreen()
    {
        if (window.fullScreen == false || actionCue.tryPush(actionFullScreenRestore)) return;

        if (pMini)
        {
            if (window.maximized == false)
            {
                exposeMini();

                return;
            }
        }
        else if (sk.osWin) window.setWindowSnap(true);

        wall.clearDrag();

        wall.enableAnimation = false;

        window.fullScreen = false;

        wall.updateView();

        wall.enableAnimation = true;

        startActionCue(st.duration_faster);
    }

    function toggleFullScreen()
    {
        if (window.fullScreen) restoreFullScreen();
        else                   exposeFullScreen ();
    }

    //---------------------------------------------------------------------------------------------

    function exposeMini()
    {
        if (isMini || actionCue.tryPush(actionMiniExpose)) return;

        pMini = false;

        isMinified = true;

        st.animate = false;

        wall.clearDrag();

        wall.enableAnimation = false;

        saveEdit();

        collapsePanels();

        if (isExpanded)
        {
            pMiniExpanded = true;

            restoreBars();
        }
        else
        {
            pMiniExpanded = false;
            pMiniTracks   = panelTracks.isExpanded;

            expand();
        }

        if (panelRelated.isExposed)
        {
            pMiniRelated         = true;
            pMiniRelatedExpanded = panelRelated.isExpanded;

            panelRelated.collapse();
        }
        else
        {
            pMiniRelated         = false;
            pMiniRelatedExpanded = false;
        }

        if (wall.isExposed)
        {
            pMiniWall = true;

            wall.restore();
        }
        else pMiniWall = false;

        if (lineEditSearch.isFocused == false)
        {
            lineEditSearch.visible = false;
        }

        if (window.maximized || window.fullScreen)
        {
            // FIXME Windows: Hiding the window to avoid the animation.
            if (sk.osWin)
            {
                window.visible = false;

                window.setWindowSnap    (false);
                window.setWindowMaximize(false);
            }

            window.fullScreen = false;
            window.maximized  = false;
        }
        else
        {
            if (sk.osWin)
            {
                window.view.showNormal();

                window.setWindowSnap    (false);
                window.setWindowMaximize(false);
            }

            if (pMiniSize)
            {
                window.saveGeometry();
            }
        }

        isMini = true;

        window.locked = true;

        window.resizable = false;

        var x = local.miniX;
        var y = local.miniY;

        var geometry = window.geometryNormal;

        local.setMiniPos(geometry.x, geometry.y);

        var width = st.dp480 + window.borderSizeWidth;

        var height = barWindow.height + barTop.height + barControls.height - st.dp2
                     +
                     window.borderSizeHeight;

        window.setMinimumSize(width, height);

        window.width = width;

        if (pMiniMicro)
        {
            isMicro = true;

            window.height = height;

            barTop.updateTab();
        }
        else window.height = height + st.dp2 + st.dp270;

        if (x == -1)
        {
             window.x = geometry.x + geometry.width - width - st.buttonPianoIcon_width - st.dp2;
        }
        else window.x = x;

        if (y == -1)
        {
             window.y = geometry.y;
        }
        else window.y = y;

        window.checkPosition();

        restoreEdit();

        window.visible = true;

        wall.updateView();

        wall.enableAnimation = true;

        st.animate = true;

        startActionCue(st.duration_faster);
    }

    function restoreMini()
    {
        if (isMini == false || pMini || actionCue.tryPush(actionMiniRestore)) return;

        st.animate = false;

        wall.enableAnimation = false;

        pRestoreMiniA();

        if (sk.osWin)
        {
            window.setWindowSnap    (true);
            window.setWindowMaximize(true);
        }

        var geometry = window.geometryNormal;

        window.width  = geometry.width;
        window.height = geometry.height;

        window.x = geometry.x;
        window.y = geometry.y;

        // FIXME Windows: Applying the minimum size after the resize.
        window.setMinimumSize(st.minimumWidth, st.minimumHeight);

        window.checkPosition();

        window.resizable = true;

        pRestoreMiniB();

        wall.updateView();

        wall.enableAnimation = true;

        st.animate = true;

        startActionCue(st.duration_faster);
    }

    function toggleMini()
    {
        if (isMini) restoreMini();
        else        exposeMini ();
    }

    //---------------------------------------------------------------------------------------------

    function exposeMicro()
    {
        restoreWall();

        if (isMicro || actionCue.tryPush(actionMicroExpose)) return;

        window.clearFocus();

        collapsePanels();

        isMicro = true;

        window.resizeHeight(window.minimumHeight, true);

        barTop.updateTab();

        startActionCue(st.duration_normal);

        local.micro = true;
    }

    function restoreMicro()
    {
        if (isMicro == false || actionCue.tryPush(actionMicroRestore)) return;

        panelPlayer.visible = true;

        isMicro = false;

        window.resizeHeight(window.minimumHeight + st.dp2 + st.dp270, true);

        barTop.updateTab();

        startActionCue(st.duration_normal);

        local.micro = false;
    }

    function toggleMicro()
    {
        if (isMicro) restoreMicro();
        else         exposeMicro ();
    }

    //---------------------------------------------------------------------------------------------

    function collapsePanels()
    {
        panelApplication.collapse();

        panelSettings.collapse();
        panelShare   .collapse();

        panelCover.clearItem();
    }

    //---------------------------------------------------------------------------------------------

    function setCurrentTrack(playlist, index)
    {
        playlist.currentIndex = index;

        playlist.selectSingleTrack(index);

        currentTab.playlist = playlist;
    }

    //---------------------------------------------------------------------------------------------

    function selectTrack(tab)
    {
        if (tab == null || tab.idTrack == -1) return;

        if (tab.idFolderRoot == 1)
        {
            restore();

            panelBrowse.collapse();

            library.setCurrentTabIds(tab);
        }
        else if (tab.idFolderRoot == 2)
        {
            restore();

            if (tab.playlist != playlistBrowse)
            {
                panelBrowse.clearEdit();
            }

            panelBrowse.expose();

            hubs.setCurrentTabIds(tab);
        }
        else if (tab.idFolderRoot == 3)
        {
            restoreMini();

            panelTracks.restore();

            panelRelated.expose();

            related.setCurrentTabIds(tab);
        }
        else restoreMini();

        focusListPlaylist(tab.playlist);
    }

    function selectCurrentTrack()
    {
        selectTrack(currentTab);
    }

    //---------------------------------------------------------------------------------------------

    function playTrack(playlist, index, resume)
    {
        if (playlist == null) return;

        playlist.currentIndex = index;

        playerTab.playlist = playlist;

        if (playerTab.isValid)
        {
            play(playlist, resume);
        }
    }

    function play(playlist, resume)
    {
        if (resume)
        {
            var time = playlist.currentTime;

            if (time != -1)
            {
                if (player.isStopped)
                {
                    playerTab.currentTime = time;
                }
                else player.seekTo(time);
            }
        }

        player.play();

        window.clearFocus();
    }

    //---------------------------------------------------------------------------------------------

    function playItem(folder, index)
    {
        var type = core.itemType(folder, index);

        if (folder.typeIsPlaylist(type) == false) return;

        if (folder.activeIndex == index)
        {
            player.play();

            return;
        }

        var playlist = createItemAt(folder, index);

        if (playlist == null) return;

        if (playlist.isEmpty == false)
        {
            if (playlist.currentIndex == -1)
            {
                playlist.currentIndex = 0;
            }

            playerTab.playlist = playlist;

            play(playlist, true);
        }

        playlist.tryDelete();
    }

    //---------------------------------------------------------------------------------------------

    function playTab()
    {
        if (currentTab.isValid == false || (player.isPlaying && highlightedTab == null))
        {
            toggleWall();
        }
        else playerBrowser.play();
    }

    //---------------------------------------------------------------------------------------------

    function stop()
    {
        var tab = playerTab;

        player.stop();

        tab.currentTime = -1;

        setCurrentTrack(player.playlist, player.trackIndex);
    }

    //---------------------------------------------------------------------------------------------

    function browseFeed(tab)
    {
        if (tab == null) return;

        browseFeedTrack(tab.source, tab.feed);
    }

    function browseCurrentFeed()
    {
        browseFeedTrack(currentTab.source, currentTab.feed);
    }

    //---------------------------------------------------------------------------------------------

    function browseFeedTrack(source, feed)
    {
        restore();

        if (controllerNetwork.urlScheme(feed) == "")
        {
            var host = controllerNetwork.extractUrlHost(source);

            feed = controllerNetwork.resolveUrl(feed, host);
        }

        panelBrowse.browse(feed);
    }

    //---------------------------------------------------------------------------------------------

    function browseRelated(data)
    {
        restoreBars();
        restoreMini();

        panelTracks.restore();

        panelRelated.expose();

        panelRelated.load(data);
    }

    //---------------------------------------------------------------------------------------------

    function trackData(source, title, cover, author, feed, duration, date, quality)
    {
        var data = new Object;

        data.source = source;

        data.title = title;
        data.cover = cover;

        data.author = author;
        data.feed   = feed;

        data.duration = duration;

        data.date = date;

        data.quality = quality;

        return data;
    }

    //---------------------------------------------------------------------------------------------

    function loadTabItems(tab)
    {
        if (tab == null || tab.isValid == false) return;

        if (tab.idFolderRoot == 1)
        {
            library.loadTabItems(tab);
        }
        else if (tab.idFolderRoot == 2)
        {
            hubs.loadTabItems(tab);
        }
        else if (tab.idFolderRoot == 3)
        {
            related.loadTabItems(tab);
        }
    }

    //---------------------------------------------------------------------------------------------

    function focusSearch()
    {
        if (barTop.isExpanded)
        {
            restoreBars();

            actionCue.tryPush(actionSearchExpose);
        }
        else if (isMini)
        {
            lineEditSearch.showAndFocus();
        }
        else lineEditSearch.focus();
    }

    function focusListPlaylist(playlist)
    {
        var list = getListPlaylist(playlist);

        if (list) list.focus();
    }

    //---------------------------------------------------------------------------------------------

    function getListFolder(folder)
    {
        if (library == folder)
        {
            return listLibrary;
        }
        else if (listFolder.folder == folder)
        {
            return listFolder;
        }
        else return null;
    }

    function getListPlaylist(playlist)
    {
        if (listPlaylist.playlist == playlist)
        {
            return listPlaylist;
        }
        else if (playlistBrowse == playlist)
        {
            return panelBrowse.listPlaylist;
        }
        else if (playlistRelated == playlist)
        {
            return panelRelated.list;
        }
        else return null;
    }

    //---------------------------------------------------------------------------------------------

    function getScrollFolder(folder)
    {
        var list = getListFolder(folder);

        if (list)
        {
             return list.scrollArea;
        }
        else return null;
    }

    function getScrollPlaylist(playlist)
    {
        var list = getListPlaylist(playlist);

        if (list)
        {
             return list.scrollArea;
        }
        else return null;
    }

    //---------------------------------------------------------------------------------------------

    function getTabTitle(title, state, source)
    {
        if (title)
        {
            return title;
        }
        else if (state == LocalObject.Loading)
        {
            return qsTr("Loading...");
        }
        else if (source != "")
        {
            return getUrlTitle(source, qsTr("Track"));
        }
        else return qsTr("New Tab");
    }

    function getTrackTitle(title, state, source)
    {
        if (title)
        {
            return title;
        }
        else if (state == LocalObject.Loading)
        {
            return qsTr("Loading Track...");
        }
        else if (source != "")
        {
            return getUrlTitle(source, qsTr("Track"));
        }
        else return qsTr("Invalid Track");
    }

    function getUrlTitle(source, text)
    {
        var title = controllerNetwork.urlTitle(source);

        if (title)
        {
             return title + ' ' + text;
        }
        else return text;
    }

    function getOpenTitle(source)
    {
        if (controllerNetwork.urlIsFile(source))
        {
             return qsTr("Open Folder");
        }
        else return qsTr("Webpage");
    }

    //---------------------------------------------------------------------------------------------

    function getItemName(type)
    {
        if      (type == LibraryItem.PlaylistNet)  return qsTr("Playlist");
        else if (type == LibraryItem.PlaylistFeed) return qsTr("Feed");
        else                                       return qsTr("Folder");
    }

    //---------------------------------------------------------------------------------------------

    function getTrackAuthor(author, feed)
    {
        if (author)
        {
            return author;
        }
        else if (feed)
        {
            return controllerNetwork.urlName(feed);
        }
        else return "";
    }

    function getTrackDuration(duration)
    {
        var time = controllerPlaylist.getPlayerTime(duration, 7);

        if (time == "0:00")
        {
             return "";
        }
        else return time;
    }

    //---------------------------------------------------------------------------------------------

    function setPlaylistFocus(playlist)
    {
        if (gui.playlist && gui.playlist != playlist)
        {
            gui.playlist.unselectTracks();
        }

        if (playlistRelated && playlistRelated != playlist)
        {
            playlistRelated.unselectTracks();
        }

        if (playlistBrowse && playlistBrowse != playlist)
        {
            playlistBrowse.unselectTracks();
        }
    }

    //---------------------------------------------------------------------------------------------

    function loadTracksLater(playlist, index)
    {
        pLoadPlaylist = playlist;
        pLoadIndex    = index;

        timerLoad.restart();
    }

    //---------------------------------------------------------------------------------------------

    function createItemAt(folder, index)
    {
        var item = folder.createLibraryItemAt(index);

        while (item && item.isLoading)
        {
            sk.processEvents();
        }

        return item;
    }

    function loadItemAt(folder, index)
    {
        folder.loadCurrentIndex(index, true);

        var item = folder.currentItem;

        if (item == null) return;

        while (item && item.isLoading)
        {
            sk.processEvents();
        }

        return item;
    }

    //---------------------------------------------------------------------------------------------

    function insertTrackToPlaylist(source, folder, to)
    {
        var item = createItemAt(folder, to);

        if (item == null || item.isPlaylist == false)
        {
            return false;
        }

        var list = getListPlaylist(item);

        if (list)
        {
            return list.insertSource(-1, source, true);
        }
        else if (item.isFull == false)
        {
            item.insertSource(-1, source);

            return true;
        }
        else return false;
    }

    function copyTracksToPlaylist(playlist, indexes, folder, to)
    {
        var item = createItemAt(folder, to);

        if (item == null || item.isPlaylist == false)
        {
            return false;
        }

        var list = getListPlaylist(item);

        if (list)
        {
            return list.copyTracksFrom(playlist, indexes, -1, true);
        }
        else if (item.checkFull(indexes.length) == false)
        {
            playlist.copyTracksTo(indexes, item, -1);

            return true;
        }
        else return false;
    }

    //---------------------------------------------------------------------------------------------

    function copyTrackToFolder(source, folder, to)
    {
        var item = loadItemAt(folder, to);

        var scrollArea = getScrollFolder(item);

        if (scrollArea)
        {
            scrollArea.createItem(0);

            scrollArea.setAddTrackSource(source);
        }
    }

    function copyTracksToFolder(playlist, indexes, folder, to)
    {
        var item = loadItemAt(folder, to);

        var scrollArea = getScrollFolder(item);

        if (scrollArea)
        {
            scrollArea.createItem(0);

            scrollArea.setAddTracks(playlist, indexes);
        }
    }

    //---------------------------------------------------------------------------------------------

    function copyPlaylist(folderA, from, folderB, to)
    {
        if (folderB.isFull) return false;

        var playlistA = createItemAt(folderA, from);

        if (playlistA == null || playlistA.isPlaylist == false)
        {
            return false;
        }

        var playlistB = playlistA.duplicate();

        playlistA.tryDelete();

        var list = getListFolder(folderB);

        if (list)
        {
            list.insertLibraryItem(to, playlistB, true)
        }
        else folderB.insertLibraryItem(to, playlistB);

        if (folderB.currentId == -1)
        {
            folderB.currentId = playlistB.id;
        }

        playlistB.tryDelete();

        return true;
    }

    function copyPlaylistToFolder(folderA, from, folderB, to)
    {
        var item = createItemAt(folderB, to);

        if (item == null || item.isFolder == false)
        {
            return false;
        }

        var result = copyPlaylist(folderA, from, item, 0);

        item.tryDelete();

        return result;
    }

    //---------------------------------------------------------------------------------------------

    function copyPlaylistUrl(type, url, folder, to)
    {
        if (folder.isFull) return false;

        var playlist = core.createPlaylist(type);

        var list = getListFolder(folder);

        if (list)
        {
            list.insertLibraryItem(to, playlist, true)
        }
        else folder.insertLibraryItem(to, playlist);

        if (folder.currentId == -1)
        {
            folder.currentId = playlist.id;
        }

        playlist.loadSource(url);

        playlist.tryDelete();
    }

    function copyPlaylistUrlToFolder(type, url, folder, to)
    {
        var item = createItemAt(folder, to);

        if (item == null || item.isFolder == false)
        {
            return false;
        }

        var result = copyPlaylistUrl(type, url, item, 0);

        item.tryDelete();

        return result;
    }

    //---------------------------------------------------------------------------------------------

    function movePlaylist(folderA, from, folderB, to)
    {
        if (folderA != folderB && folderB.isFull)
        {
            return false;
        }

        folderA.move(folderA, from, folderB, to, false);

        var list = getListFolder(folderA);

        if (list)
        {
            list.removeItem(from, true);

            if (folderA == library && folderA.currentIndex == from)
            {
                folderA.currentId = folderB.id;

                folderB.currentIndex = to;
            }
        }
        else folderA.removeAt(from);

        if (folderB.currentId == -1)
        {
            folderB.currentIndex = to;
        }

        list = getListFolder(folderB);

        if (list) list.animateAdd(to);

        return true;
    }

    function movePlaylistToFolder(folderA, from, folderB, to)
    {
        var item = createItemAt(folderB, to);

        if (item == null || item.isFolder == false)
        {
            return false;
        }

        var result = movePlaylist(folderA, from, item, 0);

        item.tryDelete();

        return result;
    }

    //---------------------------------------------------------------------------------------------

    function updateScreenDim()
    {
        if (window.isActive && panelTracks.isExpanded == false && player.isPlaying)
        {
             sk.screenDimEnabled = false;
        }
        else sk.screenDimEnabled = true;
    }

    //---------------------------------------------------------------------------------------------

    function openUrl(url)
    {
        Qt.openUrlExternally(url);
    }

    function openFile(url)
    {
        Qt.openUrlExternally(controllerFile.fileUrl(url));
    }

    function openSource(url)
    {
        player.pause();

        if (controllerNetwork.urlIsFile(url))
        {
             Qt.openUrlExternally(controllerFile.folderPath(url));
        }
        else Qt.openUrlExternally(url);
    }

    //---------------------------------------------------------------------------------------------

    function applyProxy(active)
    {
        var backend = player.backend;

        if (active)
        {
             backend.setProxy(local.proxyHost, local.proxyPort, local.proxyPassword);
        }
        else backend.clearProxy();

        core.applyProxy(active);

        if (player.isPlaying)
        {
            player.keepState = true;

            player.stop();
            player.play();

            player.keepState = false;
        }
        else player.stop();
    }

    //---------------------------------------------------------------------------------------------

    function startActionCue(duration)
    {
        if (st.animate)
        {
            actionCue.start(duration);
        }
    }

    function clearActionCue()
    {
        actionCue.clear();
    }

    //---------------------------------------------------------------------------------------------

    function saveEdit()
    {
        pEditStart = lineEditSearch.selectionStart;
        pEditEnd   = lineEditSearch.selectionEnd;

        if (lineEditSearch.cursorPosition == pEditEnd)
        {
             pEditAtEnd = true;
        }
        else pEditAtEnd = false;
    }

    function restoreEdit()
    {
        if (pEditAtEnd)
        {
             lineEditSearch.select(pEditStart, pEditEnd);
        }
        else lineEditSearch.select(pEditEnd, pEditStart);
    }

    //---------------------------------------------------------------------------------------------

    function onMousePressed(event)
    {
        if (event.button & Qt.XButton1)
        {
            event.accepted = true;

            buttonBackward.returnPressed();
        }
        else if (event.button & Qt.XButton2)
        {
            event.accepted = true;

            buttonForward.returnPressed();
        }
    }

    function onMouseReleased(event)
    {
        if (event.button & Qt.XButton1)
        {
            buttonBackward.returnReleased();
        }
        else if (event.button & Qt.XButton2)
        {
            buttonForward.returnReleased();
        }
    }

    //---------------------------------------------------------------------------------------------

    function onDragEntered(event)
    {
        if (drag != -1) return;

        var text = event.text;

        event.accepted = true;

        bordersDrop.setItem(gui);

        var isTrack = controllerPlaylist.urlIsTrack(text);

        if (isTrack)
        {
            if (player.isPlaying && highlightedTab == null)
            {
                toolTip.show(qsTr("Play Track"), st.icon24x24_play, 24, 24);

                dragType = 1;
            }
            else
            {
                toolTip.show(qsTr("Browse Track"), st.icon32x32_track, 32, 32);

                dragType = 0;
            }
        }
        else
        {
            var type = core.urlType(text);

            if (type == LibraryItem.PlaylistNet)
            {
                toolTip.show(qsTr("Browse Playlist"), st.icon32x32_playlist, 32, 32);
            }
            else if (type == LibraryItem.PlaylistFeed)
            {
                toolTip.show(qsTr("Browse Feed"), st.icon32x32_feed, 32, 32);
            }
            else toolTip.show(qsTr("Browse URL"), st.icon32x32_search, 32, 32);

            dragType = 0;
        }
    }

    function onDragExited(event)
    {
        toolTip.hide();

        bordersDrop.clearItem(gui);
    }

    function onDrop(event)
    {
        var url = event.text;

        if (dragType)
        {
             panelBrowse.search(panelSearch.hubAt(0), url, true, true);
        }
        else panelBrowse.search(panelSearch.hubAt(0), url, true, false);
    }

    //---------------------------------------------------------------------------------------------

    function onDragEnded()
    {
        toolTip.hide();

        areaDrag.clearItem();

        bordersDrop.clear();

        if (dragItem)
        {
            dragItem.tryDelete();

            dragItem = null;
        }

        drag     = -1;
        dragList = null;
        dragId   = -1;
        dragType = -1;
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Left)
        {
            if (event.modifiers == (Qt.AltModifier))
            {
                event.accepted = true;

                restoreBars();

                if (isMicro)
                {
                    restoreMicro();
                }
                else itemTabs.selectPrevious();
            }
            else if (event.modifiers == (Qt.ControlModifier | Qt.AltModifier))
            {
                event.accepted = true;

                buttonBackward.returnPressed();
            }
        }
        else if (event.key == Qt.Key_Right)
        {
            if (event.modifiers == (Qt.AltModifier))
            {
                event.accepted = true;

                restoreBars();

                if (isMicro)
                {
                    restoreMicro();
                }
                else itemTabs.selectNext();
            }
            else if (event.modifiers == (Qt.ControlModifier | Qt.AltModifier))
            {
                event.accepted = true;

                buttonForward.returnPressed();
            }
        }
        else if ((event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                 &&
                 event.modifiers & Qt.AltModifier)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            toggleFullScreen();
        }
        else if (event.key == Qt.Key_T && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            restoreBars();

            barTop.buttonAdd.returnPressed();
        }
        else if (event.key == Qt.Key_W && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            restoreBars();

            barTop.closeCurrentTab();
        }
        else if (event.key == Qt.Key_R && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            if (panelRelated.isExposed == false)
            {
                restoreBars();
                restoreMini();

                panelTracks.restore();

                panelRelated.expose();
            }
            else panelRelated.buttonRefresh.returnPressed();
        }
        else if (event.key == Qt.Key_P && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            core.saveShot(window);
        }
        else if (event.key == Qt.Key_U && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            if (core.updateVersion())
            {
                window.close();
            }
        }
        else if (event.key == Qt.Key_Q && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            barWindow.buttonClose.returnPressed();
        }
        else if (event.key == Qt.Key_F1)
        {
            event.accepted = true;

            restoreBars();

            if (window.fullScreen)
            {
                 barTop.buttonApplication.returnPressed();
            }
            else barWindow.buttonApplication.returnPressed();
        }
        else if (event.key == Qt.Key_F2)
        {
            event.accepted = true;

            restoreBars();

            buttonExpand.returnPressed();
        }
        else if (event.key == Qt.Key_F3)
        {
            event.accepted = true;

            if (panelTracks.isExpanded == false)
            {
                restoreBars();

                buttonWall.returnPressed();
            }
            else panelTracks.restore();
        }
        else if (event.key == Qt.Key_F4)
        {
            event.accepted = true;

            if (isMini)
            {
                restoreBars();
                restoreMini();

                panelRelated.expose();
            }
            else if (panelTracks.isExpanded)
            {
                panelTracks.restore();

                panelRelated.expose();
            }
            else
            {
                restoreBars();

                buttonRelated.returnPressed();
            }
        }
        else if (event.key == Qt.Key_F5)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            restoreBars();
            restore    ();

            panelCover.buttonTrack.returnPressed();
        }
        else if (event.key == Qt.Key_F6)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            panelApplication.collapse();

            restoreBars();
            restore    ();

            if (panelBrowse.isExposed)
            {
                panelTracks.restore();
            }

            panelLibrary.buttonPlaylist.returnPressed();
        }
        else if (event.key == Qt.Key_F7)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            panelApplication.collapse();

            restoreBars();
            restore    ();

            if (panelBrowse.isExposed)
            {
                panelTracks.restore();
            }

            panelLibrary.buttonFolder.returnPressed();
        }
        else if (event.key == Qt.Key_F8)
        {
            event.accepted = true;

            if (isMini || isExpanded)
            {
                restoreBars();
                restore    ();

                panelBrowse.expose();
            }
            else panelLibrary.buttonBrowse.returnPressed();
        }
        else if (event.key == Qt.Key_F9)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            toggleMini();

            window.checkLeave(st.duration_faster);
        }
        else if (event.key == Qt.Key_F10)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            if (buttonMaximize.visible)
            {
                buttonMaximize.returnPressed();
            }
            else toggleMaximize();
        }
        else if (event.key == Qt.Key_F11)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            buttonFullScreen.returnPressed();
        }
        else if (event.key == Qt.Key_F12)
        {
            event.accepted = true;

            if (panelTracks.buttonUp.visible)
            {
                panelTracks.buttonUp.returnPressed();
            }
            else if (panelBrowse.buttonUp.visible)
            {
                panelBrowse.buttonUp.returnPressed();
            }
            else
            {
                restoreBars();
                restoreMini();

                panelTracks.expand();
            }
        }
        else if (event.key == Qt.Key_MediaPrevious)
        {
            event.accepted = true;

            barControls.buttonPrevious.returnPressed();
        }
        else if (event.key == Qt.Key_MediaNext)
        {
            event.accepted = true;

            barControls.buttonNext.returnPressed();
        }
        else if (event.key == Qt.Key_MediaPlay || event.key == Qt.Key_MediaTogglePlayPause)
        {
            event.accepted = true;

            barControls.buttonPlay.returnPressed();
        }
        else if (event.key == Qt.Key_MediaPause || event.key == Qt.Key_MediaStop)
        {
            event.accepted = true;

            if (player.isPlaying)
            {
                barControls.buttonPlay.returnPressed();
            }
        }

        if (event.accepted)
        {
            areaContextual.hidePanels();
        }
        // FIXME: Sometimes the focus is lost.
        else if (window.getFocus() == false)
        {
            window.clearFocus();
        }
    }

    function onKeyReleased(event)
    {
        if (event.isAutoRepeat)
        {
            return;
        }
        else if (barWindow.buttonApplication.isReturnPressed)
        {
            barWindow.buttonApplication.returnReleased();
        }
        else if (barWindow.buttonClose.isReturnPressed)
        {
            barWindow.buttonClose.returnReleased();
        }
        else if (barTop.buttonApplication.isReturnPressed)
        {
            barTop.buttonApplication.returnReleased();
        }
        else if (barTop.buttonAdd.isReturnPressed)
        {
            barTop.buttonAdd.returnReleased();
        }
        else if (buttonBackward.isReturnPressed)
        {
            buttonBackward.returnReleased();
        }
        else if (buttonForward.isReturnPressed)
        {
            buttonForward.returnReleased();
        }
        else if (buttonExpand.isReturnPressed)
        {
            buttonExpand.returnReleased();
        }
        else if (buttonWall.isReturnPressed)
        {
            buttonWall.returnReleased();
        }
        else if (buttonRelated.isReturnPressed)
        {
            buttonRelated.returnReleased();
        }
        else if (panelLibrary.buttonPlaylist.isReturnPressed)
        {
            panelLibrary.buttonPlaylist.returnReleased();
        }
        else if (panelLibrary.buttonFolder.isReturnPressed)
        {
            panelLibrary.buttonFolder.returnReleased();
        }
        else if (panelLibrary.buttonBrowse.isReturnPressed)
        {
            panelLibrary.buttonBrowse.returnReleased();
        }
        else if (panelTracks.buttonUp.isReturnPressed)
        {
            panelTracks.buttonUp.returnReleased();
        }
        else if (panelBrowse.buttonUp.isReturnPressed)
        {
            panelBrowse.buttonUp.returnReleased();
        }
        else if (panelRelated.buttonRefresh.isReturnPressed)
        {
            panelRelated.buttonRefresh.returnReleased();
        }
        else if (panelCover.buttonTrack.isReturnPressed)
        {
            panelCover.buttonTrack.returnReleased();
        }
        else if (buttonPrevious.isReturnPressed)
        {
            buttonPrevious.returnReleased();
        }
        else if (buttonNext.isReturnPressed)
        {
            buttonNext.returnReleased();
        }
        else if (buttonPlay.isReturnPressed)
        {
            buttonPlay.returnReleased();
        }
        else if (buttonSettings.isReturnPressed)
        {
            buttonSettings.returnReleased();
        }
        else if (buttonShare.isReturnPressed)
        {
            buttonShare.returnReleased();
        }
        else if (buttonMaximize.isReturnPressed)
        {
            buttonMaximize.returnReleased();
        }
        else if (buttonFullScreen.isReturnPressed)
        {
            buttonFullScreen.returnReleased();
        }
    }

    //---------------------------------------------------------------------------------------------

    function keyPressed(event)
    {
        if (event.key == Qt.Key_Up)
        {
            if (event.modifiers == Qt.ControlModifier)
            {
                restoreBars();

                sliderVolume.volumeUp();
            }
            else if (barTop.isExpanded)
            {
                restoreBars();
            }
            else if (isMini)
            {
                if (isMicro == false)
                {
                    buttonExpand.returnPressed();
                }
            }
            else if (isExpanded)
            {
                buttonExpand.returnPressed();
            }
            else if (panelBrowse.isExposed == false)
            {
                panelLibrary.buttonBrowse.returnPressed();
            }
            else if (panelTracks.isExpanded == false)
            {
                panelTracks.buttonUp.returnPressed();
            }
        }
        else if (event.key == Qt.Key_Down)
        {
            if (event.modifiers == Qt.ControlModifier)
            {
                restoreBars();

                sliderVolume.volumeDown();
            }
            else if (isMini)
            {
                if (isMicro)
                {
                    buttonExpand.returnPressed();
                }
                else if (player.isPlaying)
                {
                    if (wall.isExposed)
                    {
                        restoreWall();
                    }
                    else expandBars();
                }
            }
            else if (isExpanded == false)
            {
                if (panelTracks.isExpanded)
                {
                    panelTracks.buttonUp.returnPressed();
                }
                else if (panelBrowse.isExposed)
                {
                    panelLibrary.buttonBrowse.returnPressed();
                }
                else buttonExpand.returnPressed();
            }
            else if (panelRelated.isExposed)
            {
                buttonRelated.returnPressed();
            }
            else if (player.isPlaying)
            {
                if (wall.isExposed)
                {
                    restoreWall();
                }
                else expandBars();
            }
        }
        else if (event.key == Qt.Key_Left)
        {
            if (event.modifiers == Qt.ControlModifier)
            {
                barControls.buttonPrevious.returnPressed();
            }
            else if (playerBrowser.visible)
            {
                if (event.modifiers == Qt.NoModifier && event.isAutoRepeat == false)
                {
                    playerBrowser.buttonPrevious.returnPressed();
                }
            }
            else if (player.isPlaying)
            {
                restoreBars();

                if (event.modifiers == Qt.ShiftModifier)
                {
                     sliderStream.moveTo(sliderStream.value - 30000);
                }
                else sliderStream.moveTo(sliderStream.value - 10000);
            }
        }
        else if (event.key == Qt.Key_Right)
        {
            if (event.modifiers == Qt.ControlModifier)
            {
                barControls.buttonNext.returnPressed();
            }
            else if (playerBrowser.visible)
            {
                if (event.modifiers == Qt.NoModifier && event.isAutoRepeat == false)
                {
                    playerBrowser.buttonNext.returnPressed();
                }
            }
            else if (player.isPlaying)
            {
                restoreBars();

                if (event.modifiers == Qt.ShiftModifier)
                {
                     sliderStream.moveTo(sliderStream.value + 30000);
                }
                else sliderStream.moveTo(sliderStream.value + 10000);
            }
        }
        else if (event.key == Qt.Key_Space)
        {
            buttonPlay.returnPressed();
        }
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            if (playerBrowser.visible)
            {
                playerBrowser.play();
            }
            else if (player.hasStarted == false)
            {
                buttonPlay.returnPressed();
            }
            else if (player.isPlaying)
            {
                if (wall.isExposed)
                {
                    restoreWall();
                }
                else if (isMicro)
                {
                    restoreMicro();
                }
                else toggleBars();
            }
        }
        else if (event.key == Qt.Key_Escape)
        {
            if (panelApplication.isExposed)
            {
                panelApplication.collapse();
            }
            else if (panelSettings.isExposed)
            {
                panelSettings.collapse();
            }
            else if (panelShare.isExposed)
            {
                panelShare.collapse();
            }
            else if (panelTracks.isExpanded)
            {
                panelTracks.restore();
            }
            else if (highlightedTab)
            {
                tabs.currentTab = playerTab;
            }
            else if (barTop.isExpanded)
            {
                restoreBars();
            }
            else if (isExpanded)
            {
                restore();
            }
            else if (panelBrowse.isExposed)
            {
                panelBrowse.collapse();
            }
            else if (panelRelated.isExposed)
            {
                panelRelated.collapse();
            }
            else restoreFullScreen();
        }
        else if (event.key == Qt.Key_Backspace && player.isStopped == false)
        {
            stop();
        }
        else if (event.key == Qt.Key_Tab)
        {
            if (panelBrowse.lineEdit.visible)
            {
                panelBrowse.lineEdit.focus();
            }
            else focusSearch();
        }
        else if (event.key == Qt.Key_Backtab)
        {
            focusSearch();
        }
        else if (event.key == Qt.Key_Plus && event.isAutoRepeat == false)
        {
            restoreBars();

            buttonAdd.returnPressed();
        }
        else if (event.key == Qt.Key_Menu && barTop.isExpanded == false)
        {
            if (areaContextual.isActive == false)
            {
                barTop.showCurrentTabMenu();
            }
        }
    }

    function keyReleased(event)
    {
        if (event.isAutoRepeat)
        {
            return;
        }
        else if (buttonExpand.isReturnPressed)
        {
            buttonExpand.returnReleased();
        }
        else if (buttonRelated.isReturnPressed)
        {
            buttonRelated.returnReleased();
        }
        else if (panelLibrary.buttonBrowse.isReturnPressed)
        {
            panelLibrary.buttonBrowse.returnReleased();
        }
        else if (playerBrowser.buttonPrevious.isReturnPressed)
        {
            playerBrowser.buttonPrevious.returnReleased();
        }
        else if (playerBrowser.buttonNext.isReturnPressed)
        {
            playerBrowser.buttonNext.returnReleased();
        }
        else if (panelTracks.buttonUp.isReturnPressed)
        {
            panelTracks.buttonUp.returnReleased();
        }
        else if (barControls.buttonPrevious.isReturnPressed)
        {
            barControls.buttonPrevious.returnReleased();
        }
        else if (barControls.buttonNext.isReturnPressed)
        {
            barControls.buttonNext.returnReleased();
        }
        else if (buttonPrevious.isReturnPressed)
        {
            buttonPrevious.returnReleased();
        }
        else if (buttonNext.isReturnPressed)
        {
            buttonNext.returnReleased();
        }
        else if (buttonPlay.isReturnPressed)
        {
            buttonPlay.returnReleased();
        }
        else if (buttonAdd.isReturnPressed)
        {
            buttonAdd.returnReleased();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onBeforeCloseTab(index)
    {
        if (player.isPlaying && player.tabIndex == index)
        {
            player.pause();

            return false;
        }

        if (highlightedTab && tabs.currentIndex == index)
        {
            tabs.currentTab = highlightedTab;
        }

        return true;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pRestoreMiniA()
    {
        saveEdit();

        local.setMiniPos(window.x, window.y);

        if (isMicro)
        {
            pMiniMicro = true;

            panelPlayer.visible = true;

            isMicro = false;

            barTop.updateTab();
        }
        else pMiniMicro = false;

        isMini = false;

        pMiniVisible = window.visible;

        window.locked = false;
    }

    function pRestoreMiniB()
    {
        window.visible = pMiniVisible;

        restoreBars();

        if (pMiniExpanded == false)
        {
            restore();

            if (pMiniTracks) panelTracks.expand();
        }

        if (pMiniRelated)
        {
            panelRelated.expose();

            if (pMiniRelatedExpanded) panelRelated.expand();
        }

        if (pMiniWall) wall.expose();

        lineEditSearch.visible = true;

        restoreEdit();

        isMinified = false;
    }

    //---------------------------------------------------------------------------------------------

    function pGetCurrentList()
    {
        if (listPlaylist.visible && listPlaylist.activeFocus)
        {
            return listPlaylist;
        }

        var list = panelBrowse.listPlaylist;

        if (list.visible && list.activeFocus)
        {
            return list;
        }

        list = panelRelated.list;

        if (list.visible && list.activeFocus)
        {
             return list;
        }
        else return null;
    }

    function pGetCurrentPlaylist()
    {
        var list = pGetCurrentList();

        if (list && list.count)
        {
            return list.playlist;
        }
        else if (currentTab.playlist)
        {
            return currentTab.playlist;
        }
        else if (panelRelated.isExposed && playlistRelated && playlistRelated.count)
        {
            return playlistRelated;
        }
        else if (isExpanded == false)
        {
            if (panelBrowse.isExposed)
            {
                if (playlistBrowse && playlistBrowse.count)
                {
                     return playlistBrowse;
                }
                else return null;
            }
            else if (playlist && playlist.count)
            {
                 return playlist;
            }
            else return null;
        }
        else return null;
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateCache()
    {
        var playlist = currentTab.playlist;

        if (playlist)
        {
            var index = playlist.currentIndex;

            core.updateCache(playlist, index);
        }
    }

    //---------------------------------------------------------------------------------------------

    function pSaveSize()
    {
        if (window.maximized)
        {
            var geometry = window.geometryNormal;

            local.setSize(window.getScreenNumber(), geometry.width, geometry.height);
        }
        else local.setSize(window.getScreenNumber(), window.width, window.height);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ActionCue
    {
        id: actionCue

        onProcessAction:
        {
            if      (id == actionExpand)  expand ();
            else if (id == actionRestore) restore();

            else if (id == actionWallExpose)  exposeWall ();
            else if (id == actionWallRestore) restoreWall();

            else if (id == actionRelatedExpose)   panelRelated.expose  ();
            else if (id == actionRelatedCollapse) panelRelated.collapse();
            else if (id == actionRelatedExpand)   panelRelated.expand  ();
            else if (id == actionRelatedRestore)  panelRelated.restore ();

            else if (id == actionBarsExpand)  expandBars ();
            else if (id == actionBarsRestore) restoreBars();

            else if (id == actionTracksExpand)  panelTracks.expand ();
            else if (id == actionTracksRestore) panelTracks.restore();

            else if (id == actionBrowseExpose)   panelBrowse.expose  ();
            else if (id == actionBrowseCollapse) panelBrowse.collapse();

            else if (id == actionAddShow) panelAddShow();
            else if (id == actionAddHide) panelAddHide();

            else if (id == actionSettingsExpose)   panelSettings.expose  ();
            else if (id == actionSettingsCollapse) panelSettings.collapse();

            else if (id == actionShareExpose)   panelShare.expose  ();
            else if (id == actionShareCollapse) panelShare.collapse();

            else if (id == actionSearchExpose) lineEditSearch.focus();

            else if (id == actionMaximizeExpose)  exposeMaximize ();
            else if (id == actionMaximizeRestore) restoreMaximize();

            else if (id == actionFullScreenExpose)  exposeFullScreen ();
            else if (id == actionFullScreenRestore) restoreFullScreen();

            else if (id == actionMiniExpose)  exposeMini ();
            else if (id == actionMiniRestore) restoreMini();

            else if (id == actionMicroExpose)  exposeMicro ();
            else if (id == actionMicroRestore) restoreMicro();

            else if (id == actionTabOpen) barTop.openTab           ();
            else if (id == actionTabMenu) barTop.showCurrentTabMenu();

            else if (id == actionZoom) zoom(pZoomScale, pZoomX, pZoomY, pZoomDuration, pZoomEasing,
                                            pZoomAfter);
        }

        onActiveChanged:
        {
            if (panelPreview.isHovered)
            {
                panelPreview.clearInstant();
            }
            else if (isActive == false)
            {
                panelPreview.update();
            }
        }
    }

    Timer
    {
        id: timerLoad

        interval: 200

        onTriggered:
        {
            if (pLoadPlaylist == null) return;

            if (pLoadPlaylist.trackIsDefault(pLoadIndex) == false)
            {
                for (var i = 3; i; i--)
                {
                    if (pLoadPlaylist.trackIsDefault(pLoadIndex - i)
                        ||
                        pLoadPlaylist.trackIsDefault(pLoadIndex + i))
                    {
                        pLoadPlaylist.loadTracks(pLoadIndex, 10);
                    }
                }
            }
            else pLoadPlaylist.loadTracks(pLoadIndex, 10);
        }
    }

    Item
    {
        id: itemContent

        anchors.top   : barTop.bottom
        anchors.bottom: barControls.top

        anchors.left : parent.left
        anchors.right: parent.right

        PanelPlayer { id: panelPlayer }

        PanelLibrary { id: panelLibrary }

        PanelTracks { id: panelTracks }

        PanelBrowse { id: panelBrowse }

        PanelCover { id: panelCover }

        PanelShare { id: panelShare }

        PanelSettings { id: panelSettings }

        PanelSearch { id: panelSearch }
    }

    BarTop { id: barTop }

    BarControls { id: barControls }

    PanelApplication { id: panelApplication }

    BarWindowApplication { id: barWindow }

    AreaDrag { id: areaDrag }

    RectangleBordersDrop
    {
        id: bordersDrop

        z: 1

        opacity: (visible)

        Behavior on opacity
        {
            PropertyAnimation { duration: st.duration_fast }
        }
    }

    AreaContextualApplication { id: areaContextual }

    PanelPreview { id: panelPreview }

    ToolTip
    {
        id: toolTip

        z: 1
    }
}
