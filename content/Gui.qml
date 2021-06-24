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
    id: gui

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isLoaded: false

    /* read */ property bool isExpanded: local.expanded

    property bool asynchronous: true

    /* read */ property TabTrack currentTab    : tabs.currentTab
    /* read */ property TabTrack highlightedTab: tabs.highlightedTab

    /* read */ property TabTrack playerTab: player.tab

    /* read */ property LibraryFolder library : core.library
    /* read */ property LibraryFolder feeds   : core.feeds
    /* read */ property LibraryFolder backends: core.backends
    /* read */ property LibraryFolder related : core.related

    /* read */ property variant currentPlaylist: currentTab.playlist

    /* read */ property Playlist playlistTracks: null
    /* read */ property Playlist playlistTemp  : controllerPlaylist.createPlaylist()

    //---------------------------------------------------------------------------------------------
    // Drag

    property int     drag     : -1
    property variant dragList : null
    property variant dragItem : null
    property int     dragId   : -1
    property int     dragType : -1
    property int     dragIndex: -1
    property variant dragData

    //---------------------------------------------------------------------------------------------
    // Actions

    /* read */ property int actionExpand : 0
    /* read */ property int actionRestore: 1

    /* read */ property int actionBarsExpand : 2
    /* read */ property int actionBarsRestore: 3

    /* read */ property int actionWallExpose : 4
    /* read */ property int actionWallRestore: 5

    /* read */ property int actionRelatedExpose  : 6
    /* read */ property int actionRelatedCollapse: 7

    /* read */ property int actionRelatedExpand : 8
    /* read */ property int actionRelatedRestore: 9

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

    /* read */ property int actionTabOpen: 25
    /* read */ property int actionTabMenu: 26

    /* read */ property int actionZoom: 27

    //---------------------------------------------------------------------------------------------
    // Private

    // NOTE: Are we ready to display the GUI ?
    property bool pReady: (isLoaded
                           &&
                           listLibrary.folder.isLoading == false && backends.isLoading == false
                           &&
                           related.isLoading == false)

    // NOTE: Are ready to make a search request ?
    property bool pReadyBrowse: (isLoaded && backends.isLoading == false && core.index.isLoaded)

    //---------------------------------------------------------------------------------------------

    property bool pExpanded: true

    property bool pWall: false

    property bool pRelated        : false
    property bool pRelatedExpanded: false

    //---------------------------------------------------------------------------------------------

    property Playlist pLoadPlaylist: null

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

//#!DEPLOY
    //---------------------------------------------------------------------------------------------
    // Dev

    /* read */ property bool cursorIsActive: (cursorVisible && sk.cursorVisible
                                              &&
                                              window.isEntered)

    property bool cursorVisible: false

    property url sourceBlank: controllerFile.currentFileUrl("../dist/cursors/blank.svg")
    property url sourceArrow: controllerFile.currentFileUrl("../dist/cursors/arrow.svg")
    property url sourceHand : controllerFile.currentFileUrl("../dist/cursors/hand.svg")
    property url sourceBeam : controllerFile.currentFileUrl("../dist/cursors/beam.svg")
//#END

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
    // BarWindowApplication

    property alias tabs: barWindow.tabs

    property alias itemTabs: barWindow.itemTabs

    property alias buttonMaximize: barWindow.buttonMaximize

    //---------------------------------------------------------------------------------------------
    // BarTop

    property alias buttonBackward: barTop.buttonBackward
    property alias buttonForward : barTop.buttonForward

    property alias lineEditSearch: barTop.lineEditSearch

    property alias buttonBrowse : barTop.buttonBrowse
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
    property alias buttonGet       : barControls.buttonGet
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

        player.output   = local.output;
        player.quality  = local.quality;
        player.fillMode = local.fillMode;

        if (local.proxyActive)
        {
            var backend = player.backend;

            backend.setProxy(local.proxyHost, local.proxyPort, local.proxyPassword);
        }

        barWindow.updateTab();

        window.clearFocus();

        isLoaded = true;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    onPReadyChanged:
    {
        if (pReady == false) return;

        pReady = false;

        st.animate = true;

        splash.hide();
    }

    onPReadyBrowseChanged:
    {
        if (pReadyBrowse == false) return;

        pReadyBrowse = false;

//#DESKTOP
        browse(core.argument);
//#ELSE
        browse(sk.getMessage());
//#END
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
            areaDrag   .updatePosition();
            bordersDrop.updatePosition();
        }
    }

    Connections
    {
        target: window

        onMousePressed : onMousePressed (event)
        onMouseReleased: onMouseReleased(event)

        onKeyPressed : onKeyPressed (event)
        onKeyReleased: onKeyReleased(event)

        onDragEntered: onDragEntered(event)
        onDragExited : onDragExited (event)
        onDrop       : onDrop       (event)

        onDragEnded: onDragEnded()

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
            window.minimized = false;

            local.maximized = window.maximized;

            restoreFullScreen();

            st.animate = false;

            areaContextual.hidePanels();

            collapsePanels();

            barWindow.buttonVersion.visible = false;
            barWindow.buttonMessage.visible = false;

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

        onZoomChanged:
        {
            if (pZoomLater)
            {
                pZoomLater = false;

                scaleAfter();

                asynchronous = true;
            }
        }

        onActiveChanged: updateScreenDim()

        onVsyncChanged: local.vsync = window.vsync

        onIdleChanged:
        {
            if (window.idle)
            {
                // NOTE: We make sure hovered items are up to date.
                window.updateHover();

                if (playerMouseArea.containsMouse)
                {
                    sk.cursorVisible = false;
                }
            }
            else sk.cursorVisible = true;
        }
    }

    Connections
    {
        target: tabs

        onCurrentTabChanged:
        {
            if (currentTab.currentTime == -1)
            {
                restoreBars();
            }

            barWindow.updateTab();

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
            panelSearch.setText(currentTab.source);

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

        onSourceChanged: timerHistory.restart()

        onIsPlayingChanged:
        {
            updateScreenDim();

            if (player.isPlaying)
            {
                sk.screenSaverEnabled = false;

                return;
            }

            if (player.isStopped && playerBrowser.visible)
            {
                var playlist = player.playlist;

                if (playlist)
                {
                    var index = playlist.lastSelected;

                    if (index != -1
                        &&
                        (playlist != currentTab.playlist || index != currentTab.trackIndex))
                    {
                        playlist.unselectTracks();
                    }
                }
            }

            restoreBars();

            sk.screenSaverEnabled = true;
        }

        onHasStartedChanged:
        {
            restoreBars();

            timerHistory.restart();
        }

        onSpeedChanged: local.speed = player.speed

        onVolumeChanged: local.volume = player.volume

        onRepeatChanged: local.repeat = player.repeat

        onOutputChanged  : local.output   = player.output
        onQualityChanged : local.quality  = player.quality
        onFillModeChanged: local.fillMode = player.fillMode

        onCurrentTrackUpdated: timerHistory.restart()

        onTabChanged: timerHistory.restart()
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function scale(scale)
    {
        if (st.scale == scale) return;

        st.animate = false;

        wall.enableAnimation = false;

        scaleBefore();

        st.scale = scale;

        scaleAfter();

        sk.defaultScreen = window.getScreenNumber();

        sk.defaultWidth  = -1;
        sk.defaultHeight = -1;

        window.setMinimumSize(st.minimumWidth, st.minimumHeight);

        window.setDefaultGeometry();

        pRestoreWall();

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

        asynchronous = false;

        scaleBefore();

        if (zoomAfter == false)
        {
            window.zoomTo(scale, x, y, duration, easing, false);

            scaleAfter();

            asynchronous = true;
        }
        else window.zoomTo(scale, x, y, duration, easing, true);

        pRestoreWall();

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

        //panelDiscover.collapse();

        panelLibrary.saveScroll();

        isExpanded = true;

        if (panelRelated.isExposed)
        {
            var width = itemContent.width;

            panelPlayer.wallExpand(width - panelRelated.getWidth(width), itemContent.height);
        }
        else panelPlayer.wallExpand(itemContent.width, itemContent.height);

        local.expanded = true;

        startActionCue(st.duration_normal);
    }

    function restore()
    {
        if (isExpanded == false || actionCue.tryPush(actionRestore)) return;

        //panelDiscover.collapse();

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

        local.expanded = false;

        startActionCue(st.duration_normal);
    }

    function toggleExpand()
    {
        if (isExpanded) restore();
        else            expand ();
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
        else if (panelGet.isExposed)
        {
            panelGet.collapse();

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
        if (barTop.isExpanded)
        {
            if (timer.running)
            {
                timer.stop();

                restoreBars();

                restore();
            }
            else
            {
                restoreBars();

                timer.start();
            }
        }
        else if (isExpanded == false)
        {
            timer.stop();

            expandBars();
        }
        else if (timer.running)
        {
            timer.stop();

            restoreBars();

            restore();
        }
        else
        {
            expandBars();

            if (highlightedTab == null)
            {
                timer.start();
            }
        }
    }

    //---------------------------------------------------------------------------------------------

    function exposeWall()
    {
        panelTracks.restore();

        if (wall.isExposed || actionCue.tryPush(actionWallExpose)) return;

        //panelDiscover.collapse();

        wall.expose();

        clearExpand();

        startActionCue(st.duration_normal);
    }

    function restoreWall()
    {
        if (wall.isExposed == false || actionCue.tryPush(actionWallRestore)) return;

        //panelDiscover.collapse();

        wall.restore();

        startActionCue(st.duration_normal);
    }

    function toggleWall()
    {
        if (wall.isExposed) restoreWall();
        else                exposeWall ();
    }

    //---------------------------------------------------------------------------------------------

    function panelAddShow()
    {
        if (buttonAdd.checked || actionCue.tryPush(actionAddShow)) return;

        panelSettings.collapse();
        panelGet     .collapse();

        playlistTemp.clearTracks();

        currentTab.copyTrackTo(playlistTemp);

        panelAdd.setSource(0, playlistTemp, 0);

        areaContextual.showPanel(panelAdd, barControls, Sk.TopLeft,
                                 barControls.borderB.x + barControls.borderB.width, -1, 0,
                                 st.border_size, false);

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

        // FIXME Windows: Hiding the window to avoid the animation.
        if (sk.osWin)
        {
            if (window.fullScreen)
            {
                window.setWindowMaximize(true);

                window.visible = false;

                pRestoreFullScreen();

                window.maximized = true;

                window.visible = true;
            }
            else window.maximized = true;
        }
        else if (window.fullScreen)
        {
            pRestoreFullScreen();
        }
        else window.maximized = true;

        pRestoreWall();

        pSaveSize();

        local.maximized = true;

        startActionCue(st.duration_faster);
    }

    function restoreMaximize()
    {
        if (window.maximized == false || actionCue.tryPush(actionMaximizeRestore)) return;

        wall.clearDrag();

        wall.enableAnimation = false;

        window.maximized = false;

        pRestoreWall();

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

        if (sk.osWin) window.setWindowSnap(false);

        st.animate = false;

        window.fullScreen = true;

        pExpandFullScreen();

        st.animate = true;

        pRestoreWall();

        startActionCue(st.duration_faster);
    }

    function restoreFullScreen()
    {
        if (window.fullScreen == false || actionCue.tryPush(actionFullScreenRestore)) return;

        if (sk.osWin) window.setWindowSnap(true);

        wall.clearDrag();

        wall.enableAnimation = false;

        pRestoreFullScreen();

        pRestoreWall();

        startActionCue(st.duration_faster);
    }

    function toggleFullScreen()
    {
        if (window.fullScreen) restoreFullScreen();
        else                   exposeFullScreen ();
    }

    //---------------------------------------------------------------------------------------------

    function collapsePanels()
    {
        panelApplication.collapse();

        panelSettings.collapse();
        panelGet     .collapse();

        //panelDiscover.collapse();

        //panelCover.clearItem();
    }

    //---------------------------------------------------------------------------------------------

    function clearExpand()
    {
        if (pExpanded) return;

        pExpanded = true;

        pWall = false;

        pRelated         = false;
        pRelatedExpanded = false;
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

            panelLibrary.select(1);

            library.setCurrentTabIds(tab);
        }
        else if (tab.idFolderRoot == 2)
        {
            restore();

            panelBrowse.collapse();

            panelLibrary.select(0);

            feeds.setCurrentTabIds(tab);
        }
        else if (tab.idFolderRoot == 3)
        {
            restore();

            if (tab.playlist != playlistBrowse)
            {
                panelBrowse.clearEdit();
            }

            panelBrowse.expose();

            backends.setCurrentTabIds(tab);
        }
        else if (tab.idFolderRoot == 4)
        {
            panelTracks.restore();

            panelRelated.expose();

            related.setCurrentTabIds(tab);
        }

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

        if (highlightedTab) tabs.currentTab = playerTab;

        playlist.currentIndex = index;

        playerTab.playlist = playlist;

        play(playlist, resume);
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
                else player.seek(time);
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
            if (highlightedTab) tabs.currentTab = playerTab;

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
            restoreBars();

            toggleWall();
        }
        else playerBrowser.play();
    }

    //---------------------------------------------------------------------------------------------

    function pause()
    {
        if (player.isStarting || player.isResuming)
        {
             player.stop();
        }
        else player.pause();
    }

    function stop()
    {
        var tab = playerTab;

        player.stop();

        tab.currentTime = -1;

        setCurrentTrack(player.playlist, player.trackIndex);
    }

    //---------------------------------------------------------------------------------------------

    function browse(url)
    {
        if (url == "") return;

        if (controllerPlaylist.urlIsTrack(url) && player.isPlaying && highlightedTab == null)
        {
             panelBrowse.search(panelSearch.backendAt(0), url, true, true);
        }
        else panelBrowse.search(panelSearch.backendAt(0), url, true, false);
    }

    //---------------------------------------------------------------------------------------------

    function browseFeed(tab)
    {
        if (tab == null) return;

        browseFeedTrack(tab.feed, tab.source);
    }

    function browseCurrentFeed()
    {
        browseFeedTrack(currentTab.feed, currentTab.source);
    }

    //---------------------------------------------------------------------------------------------

    function browseFeedTrack(feed, source)
    {
        restore();

        feed = controllerPlaylist.getFeed(feed, source);

        panelBrowse.browse(feed);
    }

    //---------------------------------------------------------------------------------------------

    function browseRelated(data)
    {
        restoreBars();

        panelTracks.restore();

        panelRelated.expose();

        panelRelated.load(data);
    }

    //---------------------------------------------------------------------------------------------

    function browseFile()
    {
        var path = core.openFile(qsTr("Select File"));

        panelBrowse.browse(path);
    }

    function browseFolder()
    {
        var path = core.openFolder(qsTr("Select Folder"));

        panelBrowse.browse(path);
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
            feeds.loadTabItems(tab);
        }
        else if (tab.idFolderRoot == 3)
        {
            backends.loadTabItems(tab);
        }
        else if (tab.idFolderRoot == 4)
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
        if (listLibrary.folder == folder)
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
        if      (type == LibraryItem.Playlist)     return qsTr("Playlist");
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

    function insertLibraryItem(index, item, list, folder)
    {
        if (list.folder == folder)
        {
            list.insertLibraryItem(index, item, true);
        }
        else folder.insertLibraryItem(index, item);
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

        var playlist = controllerPlaylist.createPlaylist(type);

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
        if (folderA == folderB)
        {
            folderA.moveAt(from, to);

            return true;
        }

        if (folderB.isFull) return false;

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
            else if (folderB.currentId == -1)
            {
                folderB.currentIndex = to;
            }
        }
        else
        {
            folderA.removeAt(from);

            if (folderB.currentId == -1)
            {
                folderB.currentIndex = to;
            }
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

    function updateColor()
    {
        if (wall.isActive)
        {
             window.color = st.window_color;
        }
        else window.color = "black";
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
        Qt.openUrlExternally(controllerNetwork.encodedUrl(url));
    }

    function openFile(url)
    {
        Qt.openUrlExternally(controllerFile.fileUrl(url));
    }

    //---------------------------------------------------------------------------------------------

    function openSource(url)
    {
        pause();

        if (controllerNetwork.urlIsFile(url))
        {
            Qt.openUrlExternally(controllerFile.folderUrl(url));
        }
        else openUrl(url);
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
            player.stop();
            player.play();
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
    // Events

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

        if (controllerPlaylist.urlIsSubtitle(text))
        {
            if (playerTab.currentIndex == -1) return;

            event.accepted = true;

            bordersDrop.setItem(gui);

            toolTip.show(qsTr("Open Subtitle"), st.icon16x16_track, st.dp16, st.dp16);

            dragType = -2;

            panelGet.selectTab(0);

            panelGet.expose();

            return;
        }

        event.accepted = true;

        bordersDrop.setItem(gui);

        if (controllerPlaylist.urlIsTrack(text))
        {
            if (player.isPlaying && highlightedTab == null)
            {
                toolTip.show(qsTr("Play Track"), st.icon16x16_play, st.dp16, st.dp12);

                dragType = 1;
            }
            else
            {
                toolTip.show(qsTr("Browse Track"), st.icon16x16_track, st.dp16, st.dp16);

                dragType = 0;
            }
        }
        else
        {
            var type = core.urlType(text);

            if (type == LibraryItem.Playlist)
            {
                toolTip.show(qsTr("Browse Playlist"), st.icon16x16_playlist, st.dp16, st.dp16);
            }
            else if (type == LibraryItem.PlaylistFeed)
            {
                toolTip.show(qsTr("Browse Feed"), st.icon16x16_feed, st.dp16, st.dp16);
            }
            else toolTip.show(qsTr("Browse URL"), st.icon20x20_search, st.dp20, st.dp20);

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

        if (dragType == -2)
        {
            panelGet.page.hideSearch();

            playerTab.subtitle = url;
        }
        else if (dragType == 0)
        {
             panelBrowse.search(panelSearch.backendAt(0), url, true, false);
        }
        else panelBrowse.search(panelSearch.backendAt(0), url, true, true);
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

        if (dragIndex != -1)
        {
            if (scrollLibrary.isCreating == false && scrollLibrary.isDropping == false
                &&
                scrollFolder.isDropping == false && scrollPlaylist.isDropping == false)
            {
                panelLibrary.select(dragIndex);
            }

            dragIndex = -1;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Keys

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Left)
        {
            if (event.modifiers == sk.keypad(Qt.AltModifier))
            {
                event.accepted = true;

                restoreBars();

                itemTabs.selectPrevious();
            }
            else if (event.modifiers == sk.keypad(Qt.ControlModifier | Qt.AltModifier))
            {
                event.accepted = true;

                buttonBackward.returnPressed();
            }
        }
        else if (event.key == Qt.Key_Right)
        {
            if (event.modifiers == sk.keypad(Qt.AltModifier))
            {
                event.accepted = true;

                restoreBars();

                itemTabs.selectNext();
            }
            else if (event.modifiers == sk.keypad(Qt.ControlModifier | Qt.AltModifier))
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

            barWindow.buttonAdd.returnPressed();
        }
        else if (event.key == Qt.Key_W && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            restoreBars();

            barWindow.itemTabs.closeCurrentTab();
        }
        else if (event.key == Qt.Key_R && event.modifiers == Qt.ControlModifier)
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            core.resetBackends();
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
        else if (event.key == Qt.Key_F1) // Browse
        {
            event.accepted = true;

//#!DEPLOY
            if (event.modifiers == Qt.ControlModifier)
            {
                sk.restartScript();

                return;
            }
//#END

            if (isExpanded)
            {
                restoreBars();
                restore    ();

                panelBrowse.expose();
            }
            else buttonBrowse.returnPressed();
        }
        else if (event.key == Qt.Key_F2) // Expand
        {
            event.accepted = true;

//#!DEPLOY
            if (event.modifiers == Qt.ControlModifier)
            {
                pSetDesktop();

                player.volume = 0.4;

                return;
            }
//#END

            restoreBars();

            buttonExpand.returnPressed();
        }
        else if (event.key == Qt.Key_F3) // Wall
        {
            event.accepted = true;

//#!DEPLOY
            if (event.modifiers == Qt.ControlModifier)
            {
                pSetDesktop();

                player.volume = 0.0;

                return;
            }
//#END

            if (panelTracks.isExpanded == false)
            {
                restoreBars();

                buttonWall.returnPressed();
            }
            else panelTracks.restore();
        }
        else if (event.key == Qt.Key_F4) // Related
        {
            event.accepted = true;

            if (panelTracks.isExpanded)
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
        else if (event.key == Qt.Key_F5) // Select
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            restoreBars();
            restore    ();

            selectTrack(playerTab);

            //panelCover.buttonTrack.returnPressed();
        }
        else if (event.key == Qt.Key_F6) // Get
        {
            event.accepted = true;

            buttonGet.returnPressed();
        }
        else if (event.key == Qt.Key_F7) // Settings
        {
            event.accepted = true;

            buttonSettings.returnPressed();
        }
        else if (event.key == Qt.Key_F8) // Playlist
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            restoreBars();
            restore    ();

            panelLibrary.buttonAdd.returnPressed();
        }
        else if (event.key == Qt.Key_F9) // Normal
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            if (window.maximized)
            {
                if (window.fullScreen)
                {
//#MAC
                    // FIXME macOS: We can't go from full screen to normal window right away.
                    //              This could be related to the animation.
                    buttonFullScreen.returnPressed();
//#ELSE
                    restoreFullScreen();
                    restoreMaximize  ();
//#END
                }
                else buttonMaximize.returnPressed();
            }
            else if (window.fullScreen)
            {
                 buttonFullScreen.returnPressed();
            }
        }
        else if (event.key == Qt.Key_F10) // Maximize
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            if (buttonMaximize.visible)
            {
                buttonMaximize.returnPressed();
            }
            else toggleMaximize();
        }
        else if (event.key == Qt.Key_F11) // FullScreen
        {
            event.accepted = true;

            if (event.isAutoRepeat) return;

            buttonFullScreen.returnPressed();
        }
        else if (event.key == Qt.Key_F12) // Expand
        {
            event.accepted = true;

//#!DEPLOY
            if (event.modifiers == Qt.ControlModifier)
            {
                pTakeShot();

                return;
            }
//#END

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
        else if (barWindow.buttonClose.isReturnPressed)
        {
            barWindow.buttonClose.returnReleased();
        }
        /*else if (buttonApplication.isReturnPressed)
        {
            buttonApplication.returnReleased();
        }*/
        else if (buttonBackward.isReturnPressed)
        {
            buttonBackward.returnReleased();
        }
        else if (buttonForward.isReturnPressed)
        {
            buttonForward.returnReleased();
        }
        else if (barWindow.buttonAdd.isReturnPressed)
        {
            barWindow.buttonAdd.returnReleased();
        }
        else if (buttonBrowse.isReturnPressed)
        {
            buttonBrowse.returnReleased();
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
        else if (panelLibrary.buttonAdd.isReturnPressed)
        {
            panelLibrary.buttonAdd.returnReleased();
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
        /*else if (panelCover.buttonTrack.isReturnPressed)
        {
            panelCover.buttonTrack.returnReleased();
        }*/
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
        else if (buttonGet.isReturnPressed)
        {
            buttonGet.returnReleased();
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
        if (event.key == Qt.Key_Left)
        {
            if (event.modifiers == sk.keypad(Qt.ControlModifier))
            {
                barControls.buttonPrevious.returnPressed();
            }
            else if (playerBrowser.visible)
            {
                if (event.modifiers == sk.keypad(Qt.NoModifier) && event.isAutoRepeat == false)
                {
                    playerBrowser.buttonPrevious.returnPressed();
                }
            }
            else if (player.isPlaying)
            {
                if (event.modifiers == sk.keypad(Qt.ShiftModifier))
                {
                     sliderStream.moveTo(sliderStream.value - st.sliderStream_intervalB);
                }
                else sliderStream.moveTo(sliderStream.value - st.sliderStream_intervalA);
            }
        }
        else if (event.key == Qt.Key_Right)
        {
            if (event.modifiers == sk.keypad(Qt.ControlModifier))
            {
                barControls.buttonNext.returnPressed();
            }
            else if (playerBrowser.visible)
            {
                if (event.modifiers == sk.keypad(Qt.NoModifier) && event.isAutoRepeat == false)
                {
                    playerBrowser.buttonNext.returnPressed();
                }
            }
            else if (player.isPlaying)
            {
                if (event.modifiers == sk.keypad(Qt.ShiftModifier))
                {
                     sliderStream.moveTo(sliderStream.value + st.sliderStream_intervalB);
                }
                else sliderStream.moveTo(sliderStream.value + st.sliderStream_intervalA);
            }
        }
        else if (event.key == Qt.Key_Up)
        {
            if (event.modifiers == sk.keypad(Qt.ControlModifier))
            {
                restoreBars();

                sliderVolume.volumeUp();
            }
            else if (barTop.isExpanded)
            {
                restoreBars();
            }
            else if (isExpanded)
            {
                buttonExpand.returnPressed();
            }
            else if (panelBrowse.isExposed == false)
            {
                buttonBrowse.returnPressed();
            }
            else if (panelTracks.isExpanded == false)
            {
                panelTracks.buttonUp.returnPressed();
            }
        }
        else if (event.key == Qt.Key_Down)
        {
            if (event.modifiers == sk.keypad(Qt.ControlModifier))
            {
                restoreBars();

                sliderVolume.volumeDown();
            }
            else if (isExpanded == false)
            {
                if (panelTracks.isExpanded)
                {
                    panelTracks.buttonUp.returnPressed();
                }
                else if (panelBrowse.isExposed)
                {
                    buttonBrowse.returnPressed();
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
            else if (panelGet.isExposed)
            {
                panelGet.collapse();
            }
            /*else if (panelDiscover.isExposed)
            {
                panelDiscover.collapse();
            }*/
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
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            areaContextual.hidePanels();

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
                barWindow.showCurrentTabMenu();
            }
        }
    }

    function keyReleased(event)
    {
        if (event.isAutoRepeat)
        {
            return;
        }
        else if (buttonBrowse.isReturnPressed)
        {
            buttonBrowse.returnReleased();
        }
        else if (buttonExpand.isReturnPressed)
        {
            buttonExpand.returnReleased();
        }
        else if (buttonRelated.isReturnPressed)
        {
            buttonRelated.returnReleased();
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

    function onBeforeTabClose(index)
    {
        if (player.isPlaying && player.tabIndex == index)
        {
            pause();

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

    function pExpandFullScreen()
    {
        pExpanded = isExpanded;

        pWall = wall.isExposed;

        pRelated         = panelRelated.isExposed;
        pRelatedExpanded = panelRelated.isExpanded;

        expand();

        wall.restore();

        panelRelated.collapse();

        if (player.isPlaying)
        {
            expandBars();
        }
    }

    function pRestoreFullScreen()
    {
        st.animate = false;

        window.fullScreen = false;

        pRestoreExpand();

        st.animate = true;
    }

    //---------------------------------------------------------------------------------------------

    function pRestoreExpand()
    {
        restoreBars();

        if (pExpanded == false) restore();

        if (pWall) wall.expose();

        if (pRelated)
        {
            panelRelated.expose();

            if (pRelatedExpanded) panelRelated.expand();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pRestoreWall()
    {
//#QT_5
        // FIXME Qt5: Waiting for resize to be applied.
        sk.processEvents();
//#END

        wall.updateView();

        wall.enableAnimation = true;
    }

    //---------------------------------------------------------------------------------------------

    function pCreatePlaylistTracks()
    {
        playlistTracks = controllerPlaylist.createPlaylist(LibraryItem.PlaylistFeed);

        playlistTracks.title = qsTr("Tracks");
        playlistTracks.label = "tracks";
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateHistory()
    {
        if (player.hasStarted == false) return;

        var source = playerTab.source;

        if (source == "") return;

        if (feeds.isEmpty)
        {
            if (playlistTracks) playlistTracks.tryDelete();

            pCreatePlaylistTracks();

            insertLibraryItem(0, playlistTracks, listLibrary, feeds);

            feeds.currentIndex = 0;
        }
        else if (playlistTracks == null)
        {
            if (feeds.itemLabel(0) != "tracks")
            {
                pCreatePlaylistTracks();

                insertLibraryItem(0, playlistTracks, listLibrary, feeds);
            }
            else playlistTracks = createItemAt(feeds, 0);
        }

        pAddHistoryTrack(source);

        var feed = playerTab.feed;

        if (feed == "" || controllerPlaylist.urlIsTorrent(feed)) return;

        pAddHistoryFeed(controllerPlaylist.getFeed(feed, source));
    }

    //---------------------------------------------------------------------------------------------

    function pAddHistoryTrack(source)
    {
        // NOTE: We match the source with the 'noFragment' option to avoid duplicates.
        var index = playlistTracks.indexFromSource(source, true);

        if (index == 0)
        {
            // NOTE: Sometimes duration is updated after playback.
            playlistTracks.setTrackDuration(0, playerTab.duration);

            return;
        }

        if (index == -1)
        {
            while (playlistTracks.isFull)
            {
                playlistTracks.removeTrack(playlistTracks.count - 1);
            }

            var playlist = playerTab.playlist;

            if (playlist)
            {
                if (listPlaylist.playlist == playlistTracks)
                {
                    listPlaylist.copyTrackFrom(playlist, playerTab.trackIndex, 0, true);
                }
                else playlist.copyTrackTo(playerTab.trackIndex, playlistTracks, 0);
            }
            else
            {
                playlistTracks.insertSource(0, source);

                playlistTracks.loadTrack(0);
            }
        }
        else
        {
            playlistTracks.moveTrack(index, 0);

            // NOTE: We make sure we have the right source with the right fragment.
            playlistTracks.setTrackSource(0, source);
        }

        var cover = playlistTracks.trackCover(0);

        if (cover) playlistTracks.cover = cover;
    }

    function pAddHistoryFeed(source)
    {
        var index = feeds.indexFromSource(source);

        if (index == -1)
        {
            while (feeds.isFull)
            {
                feeds.removeAt(feeds.count - 1);
            }

            var playlist = controllerPlaylist.createPlaylist(core.urlType(source));

            insertLibraryItem(1, playlist, listLibrary, feeds);

            if (controllerPlaylist.urlIsMedia(player.trackTitle))
            {
                playlist.cover = player.trackCover;
            }

            playlist.loadSource(source);

            playlist.tryDelete();
        }
        else feeds.moveAt(index, 1);
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

//#!DEPLOY
    //---------------------------------------------------------------------------------------------
    // Dev

    function pClearCursor()
    {
        window.registerCursorUrl(Qt.ArrowCursor,        sourceBlank);
        window.registerCursorUrl(Qt.PointingHandCursor, sourceBlank);
        window.registerCursorUrl(Qt.IBeamCursor,        sourceBlank);
    }

    function pSetDesktop()
    {
        pClearCursor();

        cursorVisible = true;

        window.borderSize = 0;

        window.resizable = false;

        var width = window.availableGeometry.width;

        if (width == 1920)
        {
            // NOTE: This is optimized for 1920 x 1080.
            st.ratio = 1.2;
        }
        else st.ratio = 1.6;

        st.applyStyle(0);

        width /= 1.3333;

        window.width  = width;
        window.height = width * 0.5625; // 16:9 ratio

        window.centerWindow();

        pClearTorrents();
    }

    function pClearTorrents()
    {
        var index = 0;

        // NOTE: We make sure that playlistTracks has been created.
        if (playlistTracks == null)
        {
            playlistTracks = createItemAt(feeds, 0);
        }

        while (index < playlistTracks.count)
        {
            if (controllerPlaylist.urlIsTorrent(playlistTracks.trackSource(index)))
            {
                playlistTracks.removeTrack(index);
            }
            else index++;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pTakeShot()
    {
        //-----------------------------------------------------------------------------------------
        // NOTE: Apply the default state

        player.stop();

        player.volume = 1.0;

        tabs.closeTabs();

        core.clearCache();

        expand();

        panelTracks.restore();

        panelBrowse .collapse();
        panelRelated.collapse();

        scrollLibrary.visible = false;

        feeds.currentId = -1;

        //-----------------------------------------------------------------------------------------

        window.clearHover();

        window.hoverEnabled = false;

        var width = 1920;

        window.width  = width;
        window.height = width * 0.5625; // 16:9 ratio

        st.ratio = 1.4;

        var path = "../dist/screens";

        pSaveShot(path + "/MotionBoxA.png");

        lineEditSearch.focus();

        // NOTE: Wait for the cursor.
        sk.wait(200);

        pSaveShot(path + "/MotionBoxB.png");

        restore();

        panelBrowse.search(3, "chillwave", true, false); // Youtube

        // NOTE: Wait for the icons to load.
        sk.wait(5000);

        // NOTE: We want to skip a few tracks.
        for (var i = 0; i < 3; i++)
        {
            player.setNextTrack();
        }

        pSaveShot(path + "/MotionBoxC.png");

        panelBrowse.browse("https://www.youtube.com/watch?v=n5vjV4hwRxo");

        // NOTE: We wait for the track to load.
        sk.wait(3000);

        expand();

        pSaveShot(path + "/MotionBoxD.png");

        window.compressShots(path);

        window.close();
    }

    function pSaveShot(path)
    {
        sk.wait(1000);

        window.saveShot(path);
    }
//#END

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

            else if (id == actionBarsExpand)  expandBars ();
            else if (id == actionBarsRestore) restoreBars();

            else if (id == actionWallExpose)  exposeWall ();
            else if (id == actionWallRestore) restoreWall();

            else if (id == actionRelatedExpose)   panelRelated.expose  ();
            else if (id == actionRelatedCollapse) panelRelated.collapse();
            else if (id == actionRelatedExpand)   panelRelated.expand  ();
            else if (id == actionRelatedRestore)  panelRelated.restore ();

            else if (id == actionTracksExpand)  panelTracks.expand ();
            else if (id == actionTracksRestore) panelTracks.restore();

            else if (id == actionBrowseExpose)   panelBrowse.expose  ();
            else if (id == actionBrowseCollapse) panelBrowse.collapse();

            else if (id == actionAddShow) panelAddShow();
            else if (id == actionAddHide) panelAddHide();

            else if (id == actionSettingsExpose)   panelSettings.expose  ();
            else if (id == actionSettingsCollapse) panelSettings.collapse();

            else if (id == actionShareExpose)   panelGet.expose  ();
            else if (id == actionShareCollapse) panelGet.collapse();

            else if (id == actionSearchExpose) lineEditSearch.focus();

            else if (id == actionMaximizeExpose)  exposeMaximize ();
            else if (id == actionMaximizeRestore) restoreMaximize();

            else if (id == actionFullScreenExpose)  exposeFullScreen ();
            else if (id == actionFullScreenRestore) restoreFullScreen();

            else if (id == actionTabOpen) barWindow.openTabPlaylist(barWindow.playlist);

            else if (id == actionTabMenu) barWindow.showCurrentTabMenu();

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
        id: timer

        interval: 400
    }

    Timer
    {
        id: timerLoad

        interval: 200

        onTriggered:
        {
            if (pLoadPlaylist)
            {
                pLoadPlaylist.loadTracks(pLoadIndex, 10);
            }
        }
    }

    Timer
    {
        id: timerHistory

        interval: 1000

        onTriggered: pUpdateHistory()
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

        //PanelCover { id: panelCover }

        //PanelDiscover { id: panelDiscover }

        PanelGet { id: panelGet }

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
            PropertyAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }
        }
    }

    AreaContextualApplication { id: areaContextual }

    PanelPreview { id: panelPreview }

    ToolTip
    {
        id: toolTip

        z: 1
    }

    //---------------------------------------------------------------------------------------------
    // Dev

//#!DEPLOY
    CursorSvg
    {
        width: Math.round(st.cursor_size * 1.5)

        z: 1

        visible: cursorIsActive

        source:
        {
            if (window.mouseCursor == Qt.PointingHandCursor)
            {
                return sourceHand;
            }
            else if (window.mouseCursor == Qt.IBeamCursor)
            {
                return sourceBeam;
            }
            else return sourceArrow;
        }
    }
//#END
}
