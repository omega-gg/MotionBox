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

MouseArea
{
    id: panelBrowse

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    /* read */ property bool isSearching: false
    /* read */ property bool isSelecting: false

    property int widthColum: Math.min((width - st.dp6) / 4, st.dp320)

    //---------------------------------------------------------------------------------------------
    // Private

    property string pSearchEngine: "duckduckgo"
    property string pSearchCover

    property bool pBrowsing: (pFolderBackends.currentId == 1)
    property bool pLoading : false

    property bool pSelect: false
    property bool pPlay  : false
    property bool pTrack : false

    property bool pEventBackend: true
    property bool pEventBrowse : true

    property int pIndexBrowse: -2

    //---------------------------------------------------------------------------------------------

    property string pQuery

    property bool pSearchHidden: (pFolderBrowse != null
                                  &&
                                  controllerNetwork.urlIsFile(pFolderBrowse.source))

    property bool pTextEvents: true

    //---------------------------------------------------------------------------------------------

    property variant pItemBrowse: (pFolderBrowse) ? pFolderBrowse.currentItem : null

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias query: lineEdit.text

    property alias playlist: scrollPlaylist.playlist

    //---------------------------------------------------------------------------------------------

    property alias buttonUp: buttonUp

    property alias lineEdit: lineEdit

    property alias listPlaylist: scrollPlaylist.list

    //---------------------------------------------------------------------------------------------
    // Private

    property alias pButtonsIndex: buttonsBrowse.currentIndex

    //---------------------------------------------------------------------------------------------

    property alias pFolderBackends : scrollBackends.folder
    property alias pFolderBrowse   : scrollBrowse  .folder
    property alias pFolder         : scrollFolder  .folder

    //---------------------------------------------------------------------------------------------

    property alias pItemText: scrollPlaylist.itemText

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right
    anchors.top  : parent.bottom

    height: panelTracks.height

    visible: false

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

        AnchorChanges
        {
            target: panelBrowse

            anchors.top: panelTracks.top
        }
//#QT_6
        // FIXME Qt6.2: We have to redeclare this to have a proper height.
        PropertyChanges
        {
            target: panelBrowse

            height: panelTracks.height
        }
//#END
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
                    if (isExposed)
                    {
                        if (panelTracks.isExpanded)
                        {
                            panelLibrary.visible = false;
                        }

                        panelTracks.visible = false;
                    }
                    else visible = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onPressed: window.clearFocus()

    onVisibleChanged: if (visible == false) window.clearFocusItem(panelBrowse)

    onActiveFocusChanged: isSelecting = false

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: (pFolderBackends && pFolderBackends.isLoaded && pEventBackend) ? pFolderBackends
                                                                               : null

        /* QML_CONNECTION */ function onLoaded()
        {
            buttonsBrowse.enableAnimation = false;

            pApplyBrowseIndex();

            buttonsBrowse.enableAnimation = true;
        }

        /* QML_CONNECTION */ function onCurrentIdChanged()
        {
            if (pIndexBrowse == -2)
            {
                pBrowse();

                pApplyBrowseIndex();
            }
            else
            {
                pApplyButton(pIndexBrowse);

                pIndexBrowse = -2;
            }
        }
    }

    Connections
    {
        target: (pFolderBrowse && pEventBrowse) ? pFolderBrowse : null

        /* QML_CONNECTION */ function onLoaded()
        {
            if (pLoading) pSearchBrowse();
        }

        /* QML_CONNECTION */ function onQueryEnded()
        {
            if (pFolderBrowse.currentIndex != -1) return;

            pFolderBrowse.loadCurrentIndex(0, true);

            if (playlist && playlist.isEmpty == false)
            {
                pCompleteSearch();
            }
        }

        /* QML_CONNECTION */ function onQueryCompleted()
        {
            if (pFolderBrowse.isEmpty == false) return;

            pSearchStop();

            if (pBrowsing)
            {
                // NOTE: We need to clear the browse index when a query fails.
                pButtonsIndex = -1;
            }
        }

        /* QML_CONNECTION */ function onCurrentIdChanged()
        {
            if (pLoading) return;

            pBrowseBackendItem();

            // NOTE: We want to set the first index as soon as possible.
            //       We use pItemBrowse in case the pFolder alias has not been updated yet.
            if (pBrowsing && pItemBrowse && pItemBrowse.currentIndex == -1)
            {
                pItemBrowse.loadCurrentIndex(0, true);
            }

            pUpdateButtons();
        }
    }

    Connections
    {
        target: (pItemBrowse) ? pItemBrowse : null

        /* QML_CONNECTION */ function onLoaded()
        {
            if (pLoading) pSearchStart();
        }

        /* QML_CONNECTION */ function onQueryStarted()
        {
            // NOTE: We want to set the first index as soon as possible.
            if (pBrowsing && pItemBrowse.currentIndex == -1)
            {
                pItemBrowse.loadCurrentIndex(0, true);
            }
        }

        /* QML_CONNECTION */ function onQueryEnded()
        {
            // NOTE: We want to set the first index as soon as possible.
            if (pBrowsing && pItemBrowse.currentIndex == -1)
            {
                pItemBrowse.loadCurrentIndex(0, true);
            }
        }
    }

    Connections
    {
        target: (pFolder) ? pFolder : null

        /* QML_CONNECTION */ function onQueryEnded()
        {
            var source = pFolder.source;

            if (source[0] == '#')
            {
                gui.applyArgument(controllerPlaylist.vbmlHash(source));

                isSearching = false;
                isSelecting = false;

                pClearSearch();

                return;
            }

            if (pCheckQuery(source) || pFolder.currentIndex != -1) return;

            pFolder.loadCurrentIndex(0, true);

            if (playlist == null || playlist.queryIsLoading) return;

            if (playlist.isEmpty)
            {
                pSearchStop();
            }
            else pCompleteSearch();
        }

        /* QML_CONNECTION */ function onQueryCompleted()
        {
            if (pFolder.isEmpty) pSearchStop();
        }
    }

    Connections
    {
        target: (playlist) ? playlist : null

        // NOTE: We want the first tracks to be loaded rigth away.
        /* QML_CONNECTION */ function onQueryEnded()
        {
            if (playlist.isEmpty || pTrack) return;

            gui.loadTracksLater(playlist, 0);

            pCompleteSearch();
        }

        /* QML_CONNECTION */ function onQueryCompleted()
        {
            if (playlist.queryIsLoading) return;

            if (playlist.isEmpty)
            {
                pSearchStop();

                return;
            }

            pCompleteSearch();

            if (pTrack == false) return;

            pTrack = false;

            // FIXME: This could be done at the backend level.
            playlist.clearDuplicates();
        }

        /* QML_CONNECTION */ function onTrackQueryEnded() { pCompleteSearch() }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        panelTag.collapse();

        if (isExposed || actionCue.tryPush(gui.actionBrowseExpose)) return;

        gui.scrollFolder.clearItem();

        isExposed = true;

        if (gui.isExpanded == false)
        {
            visible = true;
        }

        if (gui.listLibrary.activeFocus)
        {
            window.clearFocus();
        }

        local.browserVisible = true;

        gui.startActionCue(st.duration_normal);
    }

    function collapse()
    {
        panelTag.collapse();

        if (isExposed == false || actionCue.tryPush(gui.actionBrowseCollapse)) return;

        isExposed = false;

        panelLibrary.visible = true;
        panelTracks .visible = true;

        local.browserVisible = false;

        gui.startActionCue(st.duration_normal);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function search(id, query, select, play)
    {
        if (query == "") return;

        var hash = controllerPlaylist.vbmlHashFromUrl(query);

        if (hash != "")
        {
            gui.applyArgument(hash);

            return;
        }

        if (controllerPlaylist.urlIsVbmlConnect(query))
        {
            core.connectToHost(query);

            return;
        }

        expose();

        pSetBackendId(id);

        if (pFolderBrowse == null) return;

        if (id == 1)
        {
            pFolderBrowse.clearItems();

            if (core.checkUrl(query))
            {
                 pSetQuery("");
            }
            else pSetQuery(query);
        }
        else pSetQuery(query);

        setFocus();

        pQuery = query;

        pSelect = select;
        pPlay   = play;

        pLoading = true;

        if (pFolderBrowse.isLoading == false)
        {
            pSearchBrowse();
        }
    }

    function searchMore(playlist, source, title)
    {
        // NOTE: When the source is empty we push the playlist in the history.
        if (source == "" && playlist)
        {
            gui.addHistoryPlaylist(playlist, "", "", false);
        }

        // NOTE: We simplify the title to remove '.' and ':' thus avoiding matching the query as
        //       a url in the PanelTracks.
        title = controllerPlaylist.simpleQuery(title);

        // NOTE: We select the DuckDuckGo backend by default.
        var index = backends.indexFromLabel("duckduckgo");

        search(backends.idAt(index), title, true, false);
    }

    function browse(query)
    {
        search(panelSearch.backendAt(0), query, true, false);
    }

    function play(query)
    {
        search(panelSearch.backendAt(0), query, true, true);
    }

    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        if (lineEdit.visible)
        {
            lineEdit.setFocus();

            lineEdit.selectAll();
        }
        else window.clearFocus();
    }

    //---------------------------------------------------------------------------------------------

    function clearEdit()
    {
        lineEdit.clear();

        local.query = "";
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pSearch()
    {
        if (query == "") return;

        pSelect = true;
        pPlay   = false;

        if (pBrowsing && core.checkUrl(query))
        {
            pFolderBrowse.clearItems();

            pQuery = query;

            pSetQuery("");

            pStartSearch(pQuery);
        }
        else pStartSearch(query);
    }

    //---------------------------------------------------------------------------------------------

    function pSearchBrowse()
    {
        pSetBrowseIndex(0);

        pSearchStart();
    }

    function pSearchStart()
    {
        pLoading = false;

        pStartSearch(pQuery);
    }

    function pSearchStop()
    {
        if (isSearching) pSearchEnd();
    }

    function pSearchEnd()
    {
        isSearching = false;
        isSelecting = false;

        gui.restore();
    }

    //---------------------------------------------------------------------------------------------

    function pStartSearch(query)
    {
        pHideCompletion();

        local.query = panelBrowse.query;

        isSearching = true;
        isSelecting = pSelect;

        if (pSelect && pPlay == false && player.isPlaying && highlightedTab == null)
        {
            gui.restore();
        }

        var source;

        if (pBrowsing)
        {
            // NOTE: When the pFolderBrowse is empty or the browse button is selected.
            if (pItemBrowse == null || pButtonsIndex == -1)
            {
                if (panelBrowse.query == "")
                {
                    source = controllerPlaylist.generateSource(query);

                    pFolderBrowse.loadSource(source, false);

                    pFolderBrowse.clearItems();

                    core.addFolderSearch(pFolderBrowse, controllerNetwork.urlName(source));

                    pFolderBrowse.loadCurrentIndex(0, true);

                    if (pFolder.loadSource(source))
                    {
                        pFolder.loadCurrentIndex(0, true);

                        local.cache = true;
                    }
                    else pSearchEnd();

                    pFolder.cover = controllerPlaylist.backendCoverFromUrl(source);

                    pUpdateButtonsBrowsing();

                    return;
                }

                source = controllerPlaylist.createSource(pSearchEngine, "search", "urls", query);
            }
            else
            {
                source = pSiteQuery(controllerNetwork.urlName(pItemBrowse.source), query);

                source = controllerPlaylist.createSource(pSearchEngine, "search", "site", source);
            }

            if (pFolderBrowse.source == source)
            {
                if (pFolderBrowse.reloadQuery() == false)
                {
                    pSearchEnd();
                }
            }
            else if (pFolderBrowse.loadSource(source))
            {
                local.cache = true;
            }
            else pSearchEnd();
        }
        else
        {
            if (pItemBrowse)
            {
                source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                         "search", pItemBrowse.label, query);
            }
            else source = query;

            if (pItemBrowse.source == source)
            {
                if (pItemBrowse.reloadQuery() == false)
                {
                    pSearchEnd();
                }
            }
            else if (pItemBrowse.loadSource(source))
            {
                local.cache = true;
            }
            else pSearchEnd();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pCompleteSearch()
    {
        if (isSearching == false) return;

        isSearching = false;

        if (isSelecting == false) return;

        isSelecting = false;

        var index = playlist.currentIndex;

        if (index == -1)
        {
            if (controllerPlaylist.urlIsTrack(playlist.source) == false)
            {
                if (gui.isExpanded)
                {
                    if (playlist.isEmpty)
                    {
                        gui.restore();
                    }
                    else gui.showGrid(listPlaylist, playlist, -1);
                }
                else if (player.isPlaying == false || highlightedTab)
                {
                    gui.setCurrentTrack(playlist, 0);
                }
                else gui.restore();

                return;
            }

            // NOTE: If it's a Track URL we want to select it right away.
            index = 0;
        }

        pTrack = true;

        if (pPlay)
        {
            gui.setCurrentTrack(playlist, index);

            if (highlightedTab) tabs.highlightedTab = null;

            player.play();
        }
        else if (player.isPlaying == false || highlightedTab)
        {
            gui.setCurrentTrack(playlist, index);
        }
        else gui.restore();

        if (gui.isExpanded == false && playlist.isEmpty == false)
        {
            scrollPlaylist.setFocus();
        }
    }

    function pCheckQuery(source)
    {
        if (backends.currentId != 1) return false; // browser id

        if (controllerPlaylist.urlIsVbmlRun(source) == false) return false;

        var method = controllerNetwork.extractUrlValue(source, "method");

        if (method != "search") return false;

        isSearching = false;
        isSelecting = false;

        var label = controllerNetwork.extractUrlValue(source, "backend");

        var q = controllerNetwork.extractUrlEncoded(source, "q");

        // NOTE: When the q is empty, we clear the backends and open the search panel.
        if (q == "")
        {
            pClearSearch();

            lineEditSearch.setFocus();

            lineEditSearch.clear();

            panelSearch.selectBackend(panelSearch.getIndexFromLabel(label));
        }
        // NOTE: When we have a q, we apply the query and select the proper backend.
        else search(panelSearch.getIdFromLabel(label), q, pSelect, pPlay);

        return true;
    }

    //---------------------------------------------------------------------------------------------

    function pClearSearch()
    {
        clearEdit();

        pFolderBackends.loadCurrentId(1, true);

        pClearSource();

        pButtonsIndex = -1;
    }

    function pClearSource()
    {
        if (pFolderBrowse == null) return;

        pFolderBrowse.clearItems();

        pFolderBrowse.source = "";
    }

    //---------------------------------------------------------------------------------------------

    function pSetBackendId(id)
    {
        pEventBackend = false;

        pFolderBackends.loadCurrentId(id, true);

        pApplyBrowseIndex();

        pEventBackend = true;
    }

    function pSetBrowseIndex(index)
    {
        pEventBrowse = false;

        pFolderBrowse.loadCurrentIndex(index, true);

        pUpdateButtons();

        pEventBrowse = true;
    }

    //---------------------------------------------------------------------------------------------

    function pBrowse()
    {
        if (pBrowsing)
        {
            if (query == "") return;

            var source = controllerPlaylist.createSource(pSearchEngine, "search", "urls", query);

            pFolderBrowse.loadSource(source);
        }
        else if (pItemBrowse)
        {
            pBrowseBackend();
        }
    }

    function pBrowseBackend()
    {
        if (query == "") return;

        var source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                     "search", pItemBrowse.label, query);

        if (pItemBrowse.source == source) return;

        if (pFolderBrowse.currentIndex != 0)
        {
            pSetBrowseIndex(0);

            source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                     "search", pItemBrowse.label, query);
        }

        pItemBrowse.loadSource(source);
    }

    function pBrowseBackendItem()
    {
        if (pBrowsing || pItemBrowse == null || query == "") return;

        var source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                     "search", pItemBrowse.label, query);

        pItemBrowse.loadSource(source);
    }

    //---------------------------------------------------------------------------------------------

    function pBrowseSite(url)
    {
        if (query)
        {
            var source = pSiteQuery(url, query);

            source = controllerPlaylist.createSource(pSearchEngine, "search", "site", source);

            pFolderBrowse.loadSource(source);
        }
        // NOTE: If we have no query we browse the backend url by default.
        else browse(url);
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateButtons()
    {
        if (pBrowsing)
        {
            pUpdateButtonsBrowsing();

            return false;
        }

        if (pFolderBrowse == null)
        {
            buttonsBrowse.clearItems();

            return false;
        }

        var backend = controllerPlaylist.backendFromId(pFolderBrowse.label);

        // NOTE: We need to clear items after creating the backend because of processEvents.
        buttonsBrowse.clearItems();

        if (backend)
        {
            buttonsBrowse.pushItem(backend.getTitle(), pFolderBrowse.cover);

            backend.tryDelete();

            return true;
        }

        return false;
    }

    function pUpdateButtonsBrowsing()
    {
        if (pItemBrowse == null)
        {
            buttonsBrowse.clearItems();

            return;
        }

        var source = controllerNetwork.urlName(pItemBrowse.source);

        var backend = controllerPlaylist.backendFromUrl(source);

        // NOTE: We need to clear items after creating the backend because of processEvents.
        buttonsBrowse.clearItems();

        if (backend)
        {
            if (backend.hasSearch())
            {
                buttonsBrowse.pushItem(backend.getTitle(), backend.getCover());
            }

            backend.tryDelete();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pApplyBrowseIndex()
    {
        // NOTE: When this returns true it means we are on a backend.
        if (pUpdateButtons())
        {
             pButtonsIndex = 0;
        }
        else pButtonsIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSelectButton(index)
    {
        if (pButtonsIndex == index)
        {
            if (pSearchHidden)
            {
                pClearSource();

                setFocus();

                return;
            }
            else if (lineEdit.isFocused)
            {
                if (local.query == query)
                {
                    lineEdit.selectAll();

                    return;
                }

                local.query = query;

                pHideCompletion();
            }
            else
            {
                setFocus();

                return;
            }
        }
        else if (lineEdit.isFocused && local.query != query)
        {
            local.query = query;

            pHideCompletion();
        }

        if (index == 0)
        {
            pIndexBrowse = 0;

            var title = buttonsBrowse.model.get(0).title;

            var id = core.idFromTitle(backends, title);

            pFolderBackends.currentId = id;

            setFocus();
        }
        else if (pFolderBackends.currentId != 1)
        {
            pIndexBrowse = index;

            pFolderBackends.currentId = 1;

            setFocus();
        }
        else pApplyButton(index);
    }

    function pApplyButton(index)
    {
        if (index == -1)
        {
            if (pSearchHidden == false && query)
            {
                var source;

                if (core.checkUrl(query))
                {
                    source = query;

                    clearEdit();
                }
                else source = controllerPlaylist.createSource(pSearchEngine,
                                                              "search", "urls", query);

                pFolderBrowse.loadSource(source);
            }
            else pClearSource();
        }
        else // if (index == 0)
        {
            pBrowseBackend();
        }

        pUpdateButtons();

        pButtonsIndex = index;

        setFocus();
    }

    //---------------------------------------------------------------------------------------------

    function pShowCompletion()
    {
        scrollCompletion.visible = true;
    }

    function pHideCompletion()
    {
        if (scrollCompletion.visible == false) return;

        scrollCompletion.visible = false;

        scrollCompletion.currentIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSetQuery(text)
    {
        pTextEvents = false;

        query = text;

        pTextEvents = true;
    }

    function pRestoreQuery()
    {
        pTextEvents = false;

        query = scrollCompletion.query;

        pTextEvents = true;
    }

    //---------------------------------------------------------------------------------------------

    function pSiteQuery(url, query)
    {
        return "site:" + url + ' ' + query;
    }

    //---------------------------------------------------------------------------------------------

    function pGetSearchCover()
    {
        if (pSearchCover) return pSearchCover;

        if (gui.isLoaded)
        {
            pSearchCover = controllerPlaylist.backendCoverFromId(pSearchEngine);
        }

        return pSearchCover;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: parent

        color: st.panel_color
    }

    Item
    {
        id: itemEdit

        anchors.left : scrollBrowse.left
        anchors.right: scrollBrowse.right
        anchors.top  : bar.bottom

        anchors.topMargin: (pSearchHidden) ? -height : 0

        height: lineEdit.height + borderEdit.size

        states: State { name: "Hidden"; when: pSearchHidden }

        transitions: Transition
        {
            SequentialAnimation
            {
                PauseAnimation { duration: st.duration_fast }

                ScriptAction
                {
                    script:
                    {
                        if (pSearchHidden)
                        {
                            itemEdit.visible = false;
                        }

                        panelBrowse.clip = false;
                    }
                }
            }
        }

        onStateChanged:
        {
            panelBrowse.clip = true;

            visible = true;
        }

        Behavior on anchors.topMargin
        {
            PropertyAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }
        }

        LineEditBoxClear
        {
            id: lineEdit

            anchors.left : parent.left
            anchors.right: parent.right

            enabled: (pSearchHidden == false)

            text: local.query

//#QT_4
            textDefault: qsTr("What are you looking for ?")
//#ELSE
            textDefault: (text) ? text
                                : qsTr("What are you looking for ?")
//#END

            font.pixelSize: st.dp14

//#QT_NEW
            textInput.visible: isFocused

            itemTextDefault.visible: (isFocused == false)
//#END

            onTextChanged:
            {
                if (isFocused == false || pTextEvents == false) return;

                scrollCompletion.runCompletion(text);

                if (scrollCompletion.query != "")
                {
                    scrollCompletion.scrollTo(0);

                    pShowCompletion();
                }
                else pHideCompletion();
            }

            onIsFocusedChanged:
            {
                if (isFocused) return;

                pHideCompletion();

                // NOTE: Avoid unselecting when loading a local file.
                if (pSearchHidden == false)
                {
                    isSelecting = false;
                }

                if (text) text = local.query;
            }

            function onClear()
            {
                text = "";
            }

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Up && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (scrollCompletion.visible && scrollCompletion.currentIndex != -1)
                    {
                        scrollCompletion.selectPrevious();

                        if (scrollCompletion.currentIndex == -1)
                        {
                            pRestoreQuery();
                        }
                    }
                    else buttonBrowse.setFocus();
                }
                else if (event.key == Qt.Key_Down && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (scrollCompletion.visible)
                    {
                        scrollCompletion.selectNext();

                        if (scrollCompletion.currentIndex == -1)
                        {
                            pRestoreQuery();
                        }
                    }
                    else scrollBrowse.setFocus();
                }
                else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                {
                    event.accepted = true;

                    if (event.isAutoRepeat) return;

                    pSearch();
                }
                else if (event.key == Qt.Key_Escape)
                {
                    event.accepted = true;

                    window.clearFocus();
                }
                else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
                {
                    event.accepted = true;

                    lineEditSearch.setFocus();
                }
            }
        }

        BorderHorizontal
        {
            id: borderEdit

            anchors.bottom: parent.bottom
        }
    }

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        onDoubleClicked: panelTracks.toggleExpand()
    }

    BarTitleText
    {
        anchors.left  : scrollBackends.left
        anchors.right : scrollBackends.right
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        text: qsTr("Backends")
    }

    ButtonPianoIcon
    {
        id: buttonHome

        anchors.left  : scrollBrowse.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        width: st.dp32 + borderSizeWidth

        borderRight: 0

        checkable: true
        checked  : (panelContextual.item == buttonHome)

        icon          : st.icon20x20_url
        iconSourceSize: st.size20x20

        onPressed:
        {
            panelContextual.loadPageBrowse();

            areaContextual.showPanelPositionMargins(panelContextual, buttonHome,
                                                    Sk.BottomRight, -st.border_size, 0);
        }
    }

    ButtonPiano
    {
        id: buttonBrowse

        anchors.left  : buttonHome.right
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderRight: 0

        checkable: true
        checked  : (pButtonsIndex == -1 && pSearchHidden == false)

        text: qsTr("Browse")

        itemRight: buttonsBrowse

        itemBottom: (pSearchHidden) ? scrollBrowse
                                    : lineEdit

        font.pixelSize: st.barTitleText_pixelSize

        onPressed: pSelectButton(-1)

        /* QML_EVENT */ Keys.onPressed: function(event)
        {
            if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                window.clearFocus();
            }
        }
    }

    ButtonsBrowse
    {
        id: buttonsBrowse

        anchors.left: buttonBrowse.right

        anchors.right: (buttonAddItem.visible) ? buttonAddItem.left
                                               : borderFolder .left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        anchors.rightMargin: st.dp14

        itemLeft  : buttonBrowse
        itemBottom: buttonBrowse.itemBottom

        onPressed: pSelectButton(index)
    }

    BorderVertical
    {
        anchors.left  : buttonsBrowse.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        anchors.leftMargin: buttonsBrowse.getWidth()
    }

    ButtonPianoIcon
    {
        id: buttonAddItem

        anchors.right : borderFolder.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        width: st.dp32 + borderSizeWidth

        borderLeft : borderSize
        borderRight: 0

        visible: (pFolder != null && pFolder.currentItem != null)

        checkable: true
        checked  : (panelAdd.item == buttonAddItem)

        icon          : st.icon18x18_addIn
        iconSourceSize: st.size18x18

        onPressed:
        {
            panelAdd.setSource(1, pFolder, -1);

            areaContextual.showPanelMargins(panelAdd, buttonAddItem, 2, 0);
        }
    }

    ButtonPianoIcon
    {
        id: buttonAddTrack

        anchors.right: (buttonTag.visible) ? buttonTag.left
                                           : buttonUp.left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft : borderSize
        borderRight: 0

        visible: (playlist != null && playlist.selectedCount)

        checkable: true
        checked  : (panelAdd.item == buttonAddTrack)

        icon          : st.icon18x18_addIn
        iconSourceSize: st.size18x18

        onPressed:
        {
            panelAdd.setSource(0, playlist, -1);

            areaContextual.showPanelFrom(panelAdd, buttonAddTrack);
        }
    }

    ButtonPianoIcon
    {
        id: buttonTag

        anchors.right : buttonUp.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft : (buttonAddTrack.visible) ? 0 : borderSize
        borderRight: 0

        visible: buttonPlaylist.visible

        icon          : st.icon16x16_tag
        iconSourceSize: st.size16x16

        onClicked:
        {
            var folder = playlist.parentFolder;

            gui.showTagPlaylist(folder, folder.currentIndex);
        }
    }

    ButtonPianoIcon
    {
        id: buttonUp

        anchors.right : buttonClose.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft : (buttonAddTrack.visible || buttonTag.visible) ? 0 : borderSize
        borderRight: 0

        checkable: true
        checked  : panelTracks.isExpanded

        icon          : st.icon16x16_slideUp
        iconSourceSize: st.size16x16

        onClicked: panelTracks.toggleExpand()
    }

    ButtonPianoIcon
    {
        id: buttonClose

        anchors.right : parent.right
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        anchors.rightMargin : st.dp16
        anchors.topMargin   : bar.borderTop
        anchors.bottomMargin: bar.borderBottom

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

        onClicked: collapse()
    }

    ButtonPianoIcon
    {
        id: buttonPlaylist

        anchors.left  : scrollPlaylist.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        width: st.dp56 + borderSizeWidth

        visible: (playlist != null && playlist.isPlaylistSearch == false)

        highlighted: (player.isPlaying && player.playlist == playlist)

        checkable: true
        checked  : (panelContextual.item == buttonPlaylist || panelAdd.item == buttonPlaylist)

        icon: (playlist != null && playlist.isFeed) ? st.icon16x16_feed
                                                    : st.icon16x16_playlist

        iconSourceSize: st.size16x16

        onPressed:
        {
            var folder = playlist.parentFolder;

            var list;

            if (scrollFolder.visible)
            {
                 list = scrollFolder.list;
            }
            else list = scrollBrowse.list;

            var index = folder.indexFromId(playlist.id);

            panelContextual.loadPageFolder(list, index);

            areaContextual.showPanelPositionMargins(panelContextual, buttonPlaylist,
                                                    Sk.BottomRight, -st.border_size, 0);
        }
    }

    BarTitleText
    {
        anchors.left: (buttonPlaylist.visible) ? buttonPlaylist.right
                                               : scrollPlaylist.left

        anchors.right: (buttonAddTrack.visible) ? buttonAddTrack.left
                                                : buttonTag     .left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        // NOTE: This is required for oriental right to left text.
        horizontalAlignment: Text.AlignLeft

        visible: buttonPlaylist.visible

        text: (playlist) ? playlist.title : ""
    }

    ScrollFolder
    {
        id: scrollBackends

        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        //anchors.bottomMargin: panelCover.getHeight()

        width: widthColum

        folder: backends

        delegate: ComponentFolder
        {
            iconDefault: (index == 0) ? st.icon20x20_url
                                      : st.icon16x16_feed

            iconDefaultSize: (index == 0) ? st.size20x20
                                          : st.size16x16

            function pPressed(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    pSelectItem(index);
                }
            }

            function pDoubleClicked(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    search(id, query, true, false);
                }
            }
        }

        listFolder: scrollBrowse.list

        enablePlay      : false
        enableContextual: false
        enableAdd       : false
        enableDrag      : false

        itemRight: scrollBrowse

        /* QML_EVENT */ Keys.onPressed: function(event)
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                search(pFolderBackends.currentId, query, true, false);
            }
        }
    }

    ScrollFolder
    {
        id: scrollBrowse

        anchors.left  : borderBackends.right
        anchors.top   : itemEdit.bottom
        anchors.bottom: parent.bottom

        width: widthColum

        visible: (scrollCompletion.visible == false)

        delegate: ComponentFolder
        {
            function pPressed(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    pSelectItem(index);
                }
            }

            function pDoubleClicked(mouse)
            {
                if (mouse.button & Qt.LeftButton && pBrowsing == false
                    &&
                    (type == LibraryItem.FolderSearch || type == LibraryItem.PlaylistSearch))
                {
                    pSearch();
                }
            }
        }

        listPlaylist: scrollPlaylist.list
        listFolder  : scrollFolder  .list

        enablePlay      : false
        enableContextual: false
        enableAdd       : false
        enableDrag      : false

        textDefault: (pBrowsing) ? "" : qsTr("Empty Folder")

        itemLeft: scrollBackends

        itemRight: (scrollFolder.visible) ? scrollFolder
                                          : scrollPlaylist

        itemTop: (pSearchHidden) ? buttonBrowse
                                 : lineEdit

        /* QML_EVENT */ Keys.onPressed: function(event)
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                if (pBrowsing == false
                    &&
                    (pItemBrowse.isFolderSearch || pItemBrowse.isPlaylistSearch))
                {
                    pSearch();
                }
            }
        }
    }

    ScrollCompletion
    {
        id: scrollCompletion

        anchors.fill: scrollBrowse

        visible: false

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                pTextEvents = false;

                lineEdit.text = completion;

                pTextEvents = true;

                lineEdit.moveCursorAtEnd();
            }
            else scrollTo(0);
        }

        onItemClicked:
        {
            lineEdit.selectAll();

            pSearch();
        }
    }

    ScrollFolder
    {
        id: scrollFolder

        anchors.left  : borderBrowse.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        width: widthColum

        visible: hasFolder

        listPlaylist: scrollPlaylist.list

        enableAdd: false

        textDefault: (folder == null || folder.source == "") ? "" : qsTr("No results")

        itemLeft: scrollBrowse

        itemRight: scrollPlaylist

        /* QML_EVENT */ Keys.onPressed: function(event)
        {
            if (event.key == Qt.Key_Plus && buttonAddItem.visible)
            {
                event.accepted = true;

                buttonAddItem.setFocus();

                buttonAddItem.returnPressed();
            }
        }

        Keys.onReleased:
        {
            if (buttonAddItem.isReturnPressed)
            {
                buttonAddItem.returnReleased();
            }
        }
    }

    ScrollPlaylist
    {
        id: scrollPlaylist

        anchors.left: (scrollFolder.visible) ? borderFolder.right
                                             : borderBrowse.right

        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        enableAdd: false

        textDefault:
        {
            if (playlist == null || playlist.isPlaylistSearch == false)
            {
                if (buttonCover.visible)
                {
                     return "";
                }
                else return qsTr("Playlist is empty");
            }
            else if (playlist.source == "")
            {
                 return "";
            }
            else return qsTr("No Track results");
        }

        itemLeft:
        {
            if (scrollFolder.visible)
            {
                return scrollFolder;
            }
            else return scrollBrowse;
        }

        /* QML_EVENT */ Keys.onPressed: function(event)
        {
            if (event.key == Qt.Key_Plus && buttonAddTrack.visible)
            {
                event.accepted = true;

                buttonAddTrack.setFocus();

                buttonAddTrack.returnPressed();
            }
        }

        Keys.onReleased:
        {
            if (buttonAddTrack.isReturnPressed)
            {
                buttonAddTrack.returnReleased();
            }
        }
    }

    ButtonImageBorders
    {
        id: buttonCover

        anchors.top: scrollPlaylist.top

        anchors.topMargin: st.dp16

        anchors.horizontalCenter: scrollPlaylist.horizontalCenter

        imageDefaultWidth : st.dp96
        imageDefaultHeight: st.dp96

        imageMaximumWidth: st.dp256

        sourceSize.height: imageDefaultHeight

        visible: (source != "")

        source: (buttonOpen.visible) ? playlist.cover : ""

        fillMode: Image.PreserveAspectFit

        asynchronous: true

        onClicked: gui.openSource(playlist.source)
    }

    ButtonPushFull
    {
        id: buttonOpen

        anchors.top: (buttonCover.visible) ? buttonCover.bottom
                                           : scrollPlaylist.top

        anchors.topMargin: (buttonCover.visible) ? st.dp11
                                                 : pItemText.y + pItemText.height + st.dp15

        anchors.horizontalCenter: scrollPlaylist.horizontalCenter

        visible: (text != "")

        icon          : st.icon16x16_external
        iconSourceSize: st.size16x16

        text: (buttonPlaylist.visible
               &&
               scrollPlaylist.textVisible) ? getOpenTitle(playlist.source) : ""

        onClicked: gui.openSource(playlist.source)
    }

    BorderVertical
    {
        id: borderBackends

        anchors.left  : scrollBackends.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom
    }

    BorderVertical
    {
        id: borderBrowse

        anchors.left  : scrollBrowse.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom
    }

    BorderVertical
    {
        id: borderFolder

        anchors.left  : scrollFolder.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        visible: scrollFolder.visible
    }
}
