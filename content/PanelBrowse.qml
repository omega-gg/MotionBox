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

    property url pSearchCover: pGetSearchCover()

    property bool pBrowsing: (pFolderHubs.currentId == 1)
    property bool pLoading : false

    property bool pSelect: false
    property bool pPlay  : false

    property bool pHubsEvents  : true
    property bool pBrowseEvents: true

    property int pIndexButton: -2

    //---------------------------------------------------------------------------------------------

    property string pQuery
    property string pText: local.query

    property bool pSearchHidden: (pItemBrowse != null
                                  &&
                                  controllerNetwork.urlIsFile(pItemBrowse.source))

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

    property alias pBrowseIndex: buttonsBrowse.currentIndex

    //---------------------------------------------------------------------------------------------

    property alias pFolderHubs  : scrollHubs  .folder
    property alias pFolderBrowse: scrollBrowse.folder
    property alias pFolder      : scrollFolder.folder

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

    onActiveFocusChanged: isSelecting = false

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: (pFolderHubs && pFolderHubs.isLoaded && pHubsEvents) ? pFolderHubs : null

        onLoaded:
        {
            buttonsBrowse.enableAnimation = false;

            pBrowseIndex = pUpdateButtons();

            buttonsBrowse.enableAnimation = true;
        }

        onCurrentIdChanged:
        {
            if (pIndexButton == -2)
            {
                pLoadHub();

                pBrowseIndex = pUpdateButtons();
            }
            else
            {
                pApplyButton(pIndexButton);

                pIndexButton = -2;
            }
        }
    }

    Connections
    {
        target: (pFolderBrowse && pBrowseEvents) ? pFolderBrowse : null

        onLoaded: if (pLoading) pSearchBrowse()

        onQueryEnded:
        {
            if (pFolderBrowse.currentIndex != -1) return;

            pFolderBrowse.loadCurrentIndex(0, true);

            if (playlist && playlist.isEmpty == false)
            {
                pCompleteSearch();
            }
        }

        onQueryCompleted: if (pFolderBrowse.isEmpty) pSearchStop()

        onCurrentIdChanged:
        {
            pLoadItem();

            if (pBrowsing)
            {
                pBrowseIndex = pUpdateButtonsBrowsing();
            }
        }
    }

    Connections
    {
        target: (pItemBrowse) ? pItemBrowse : null

        onLoaded: if (pLoading) pSearchStart()
    }

    Connections
    {
        target: (pFolder) ? pFolder : null

        onQueryEnded:
        {
            if (pFolder.currentIndex != -1) return;

            pFolder.loadCurrentIndex(0, true);

            if (playlist && playlist.queryIsLoading == false)
            {
                if (playlist.isEmpty)
                {
                    pSearchStop();
                }
                else pCompleteSearch();
            }
        }

        onQueryCompleted: if (pFolder.isEmpty) pSearchStop()
    }

    Connections
    {
        target: (playlist) ? playlist : null

        onQueryEnded: if (playlist.isEmpty == false) pCompleteSearch()

        onQueryCompleted: if (playlist.isEmpty) pSearchStop()
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
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

        panelCover.updatePanel();

        local.browserVisible = true;

        gui.startActionCue(st.duration_normal);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionBrowseCollapse)) return;

        isExposed = false;

        panelLibrary.visible = true;
        panelTracks .visible = true;

        panelCover.updatePanel();

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

        expose();

        pSetHubId(id);

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

        focus();

        pQuery = query;

        pSelect = select;
        pPlay   = play;

        pLoading = true;

        if (pFolderBrowse.isLoading == false)
        {
            pSearchBrowse();
        }
    }

    function browse(url)
    {
        search(1, url, true, false);
    }

    //---------------------------------------------------------------------------------------------

    function focus()
    {
        if (lineEdit.visible)
        {
            lineEdit.focus();

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

            pStartSearch(pQuery);
        }
        else pStartSearch(query);
    }

    //---------------------------------------------------------------------------------------------

    function pSearchBrowse()
    {
        pSetBrowseIndex(0);

        if (pItemBrowse == null || pItemBrowse.isLoading == false)
        {
            pSearchStart();
        }
    }

    function pSearchStart()
    {
        pLoading = false;

        pStartSearch(pQuery);
    }

    //---------------------------------------------------------------------------------------------

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

        var source;

        if (pBrowsing)
        {
            if (pItemBrowse && pBrowseIndex != -1)
            {
                source = pSiteQuery(pItemBrowse.title, query);

                source = controllerPlaylist.createSource(pSearchEngine,
                                                         "search", "site", source);
            }
            else
            {
                if (panelBrowse.query == "")
                {
                     source = query;
                }
                else source = controllerPlaylist.createSource(pSearchEngine,
                                                              "search", "urls", query);

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

                return;
            }
        }
        else if (pItemBrowse)
        {
            source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                     "search", pItemBrowse.label, query);
        }

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

    //---------------------------------------------------------------------------------------------

    function pCompleteSearch()
    {
        if (isSearching == false) return;

        isSearching = false;

        if (isSelecting == false) return;

        isSelecting = false;

        var index;

        if (playlist.currentIndex == -1)
        {
             index = 0;
        }
        else index = playlist.currentIndex;

        if (pPlay)
        {
            gui.setCurrentTrack(playlist, index);

            if (highlightedTab) tabs.highlightedTab = null;

            player.replay();
        }
        else if (player.isPlaying && highlightedTab == null)
        {
            playlist.selectSingleTrack(index);

            if (gui.isExpanded)
            {
                if (barTop.openTabPlaylist(playlist))
                {
                     gui.restoreBars();
                }
                else gui.restore();
            }
        }
        else gui.setCurrentTrack(playlist, index);

        if (gui.isExpanded == false && playlist.isEmpty == false)
        {
            scrollPlaylist.focus();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pClearSearch()
    {
        clearEdit();

        pFolderHubs.loadCurrentId(1, true);

        pClearSource();
    }

    function pClearSource()
    {
        pFolderBrowse.clearItems();

        pFolderBrowse.source = "";
    }

    //---------------------------------------------------------------------------------------------

    function pSetHubId(id)
    {
        pHubsEvents = false;

        pFolderHubs.loadCurrentId(id, true);

        pBrowseIndex = pUpdateButtons();

        pHubsEvents = true;
    }

    function pSetBrowseIndex(index)
    {
        pBrowseEvents = false;

        pFolderBrowse.loadCurrentIndex(index, true);

        if (pBrowsing)
        {
            pBrowseIndex = pUpdateButtonsBrowsing();
        }

        pBrowseEvents = true;
    }

    //---------------------------------------------------------------------------------------------

    function pLoadHub()
    {
        if (pBrowsing)
        {
            if (query == "") return;

            var source = controllerPlaylist.createSource(pSearchEngine, "search", "urls", query);

            if (pFolderBrowse.source == source && pItemBrowse)
            {
                source = pSiteQuery(pItemBrowse.title, query);

                source = controllerPlaylist.createSource(pSearchEngine,
                                                         "search", "site", source);

                pItemBrowse.loadSource(source);
            }
            else pFolderBrowse.loadSource(source);
        }
        else if (pItemBrowse)
        {
            pBrowseHub();
        }
    }

    function pBrowseHub()
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

    //---------------------------------------------------------------------------------------------

    function pLoadItem()
    {
        if (pItemBrowse == null || query == "") return;

        var source;

        if (pBrowsing)
        {
            source = pSiteQuery(pItemBrowse.title, query);

            source = controllerPlaylist.createSource(pSearchEngine, "search", "site", source);
        }
        else source = controllerPlaylist.createSource(pFolderBrowse.label,
                                                      "search", pItemBrowse.label, query);

        pItemBrowse.loadSource(source);
    }

    //---------------------------------------------------------------------------------------------

    function pBrowseSource(url)
    {
        pClearSource();

        var folder = core.createFolder(LibraryItem.FolderSearch);

        folder.title = url;
        folder.cover = controllerPlaylist.backendCoverFromUrl(url);

        if (query != "")
        {
            var source = pSiteQuery(url, query);

            folder.source = controllerPlaylist.createSource(pSearchEngine,
                                                            "search", "site", source);
        }

        pFolderBrowse.addLibraryItem(folder);

        pFolderBrowse.currentIndex = 0;

        folder.tryDelete();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateButtons()
    {
        if (pBrowsing)
        {
            return pUpdateButtonsBrowsing();
        }

        buttonsBrowse.clearItems();

        if (pFolderBrowse == null) return -1;

        var backend = controllerPlaylist.backendFromId(pFolderBrowse.label);

        if (backend)
        {
            buttonsBrowse.pushItem(backend.getHost (), pSearchCover);
            buttonsBrowse.pushItem(backend.getTitle(), pFolderBrowse.cover);

            return 1;
        }
        else return -1;
    }

    function pUpdateButtonsBrowsing()
    {
        buttonsBrowse.clearItems();

        if (pItemBrowse)
        {
            var title = pItemBrowse.title;

            if (pSearchHidden)
            {
                 buttonsBrowse.pushItem(title);
            }
            else buttonsBrowse.pushItem(title, pSearchCover);

            var backend = controllerPlaylist.backendFromUrl(title);

            if (backend)
            {
                buttonsBrowse.pushItem(backend.getTitle(), pItemBrowse.cover);
            }

            return 0;
        }
        else return -1;
    }

    //---------------------------------------------------------------------------------------------

    function pSelectButton(index)
    {
        if (pBrowseIndex == index)
        {
            if (pSearchHidden)
            {
                scrollBrowse.focus();

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
                focus();

                return;
            }
        }
        else if (lineEdit.isFocused)
        {
            if (local.query != query)
            {
                local.query = query;

                pHideCompletion();
            }
        }

        if (index == 1)
        {
            pIndexButton = 1;

            var title = buttonsBrowse.model.get(1).title;

            var id = core.idFromTitle(hubs, title);

            pFolderHubs.currentId = id;

            focus();
        }
        else if (pFolderHubs.currentId != 1)
        {
            pIndexButton = index;

            pFolderHubs.currentId = 1;

            focus();
        }
        else pApplyButton(index);
    }

    function pApplyButton(index)
    {
        if (index == -1)
        {
            if (pSearchHidden) pClearSource();

            if (query)
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
        }
        else if (index == 0)
        {
            if (pSearchHidden) pClearSource();

            var title = buttonsBrowse.model.get(0).title;

            if (pItemBrowse == null)
            {
                pBrowseSource(title);

                local.cache = true;
            }
            else
            {
                if (pItemBrowse.title == title)
                {
                    if (query)
                    {
                        /* var */ source = pSiteQuery(title, query);

                        source = controllerPlaylist.createSource(pSearchEngine,
                                                                 "search", "site", source);

                        pItemBrowse.loadSource(source);
                    }
                }
                else pBrowseSource(title);
            }
        }
        else // if (index == 1)
        {
            pBrowseHub();
        }

        pUpdateButtons();

        pBrowseIndex = index;

        focus();
    }

    //---------------------------------------------------------------------------------------------

    function pShowCompletion()
    {
        scrollCompletion.visible = true;
    }

    function pHideCompletion()
    {
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

        query = pText;

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
        if (gui.isLoaded)
        {
             return controllerPlaylist.backendCoverFromId(pSearchEngine);
        }
        else return "";
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : backgroundPlaylist.left
        anchors.top   : backgroundPlaylist.top
        anchors.bottom: backgroundPlaylist.bottom

        color: st.panelBrowse_color
    }

    Rectangle
    {
        id: backgroundPlaylist

        anchors.fill: scrollPlaylist

        color: st.panelBrowse_colorPlaylist
    }

    ButtonPianoEdit
    {
        id: buttonEdit

        anchors.left : scrollBrowse.left
        anchors.right: scrollBrowse.right
        anchors.top  : bar.bottom

        anchors.topMargin: (pSearchHidden) ? -height : 0

        height: lineEdit.height + borderEdit.size

        lineEdit: lineEdit

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
                            buttonEdit.visible = false;
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
            PropertyAnimation { duration: st.duration_fast }
        }

        LineEditClear
        {
            id: lineEdit

            anchors.left : parent.left
            anchors.right: parent.right

            isHovered: (containsMouse || buttonEdit.isHovered)

            enabled: (pSearchHidden == false)

            text: pText

            textDefault: qsTr("What are you looking for ?")

            itemFocus.visible: false

            onTextChanged:
            {
                if (isFocused == false || pTextEvents == false) return;

                scrollCompletion.currentIndex = -1;

                scrollCompletion.query = text;

                scrollCompletion.runQuery();

                if (scrollCompletion.query != "")
                {
                    scrollCompletion.scrollTo(0);

                    pShowCompletion();
                }
                else pHideCompletion();

                pText = scrollCompletion.query;
            }

            onIsFocusedChanged:
            {
                if (isFocused) return;

                pHideCompletion();

                isSelecting = false;

                text = local.query;

                if (pBrowsing && buttonsBrowse.count)
                {
                    pBrowseIndex = 0;
                }
            }

            function onClear()
            {
                if (text)
                {
                    text = "";

                    local.query = text;
                }
                else window.clearFocus();
            }

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Up && event.modifiers == Qt.NoModifier)
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
                    else buttonBrowse.focus();
                }
                else if (event.key == Qt.Key_Down && event.modifiers == Qt.NoModifier)
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
                    else scrollBrowse.focus();
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

                    lineEditSearch.focus();
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
        anchors.left  : scrollHubs.left
        anchors.right : scrollHubs.right
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        text: qsTr("Hubs")
    }

    ButtonPianoIcon
    {
        id: buttonHome

        anchors.left  : scrollBrowse.left
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        width: st.dp32 + borderSizeWidth

        checkable: true
        checked  : (panelContextual.item == buttonHome)

        icon          : st.icon28x28_url
        iconSourceSize: st.size28x28

        onPressed:
        {
            panelContextual.loadPageBrowse();

            areaContextual.showPanelPositionMargins(panelContextual,
                                                    buttonHome, Sk.BottomRight, -st.dp2, 0);
        }
    }

    ButtonPiano
    {
        id: buttonBrowse

        anchors.left  : buttonHome.right
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        checkable: true
        checked  : (pBrowseIndex == -1)

        text: qsTr("Browse")

        itemRight: buttonsBrowse

        itemBottom: (pSearchHidden) ? scrollBrowse
                                    : lineEdit

        font.pixelSize: st.barTitleText_pixelSize

        onPressed: pSelectButton(-1)

        Keys.onPressed:
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

        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        anchors.rightMargin: buttonClear.width

        itemLeft  : buttonBrowse
        itemBottom: buttonBrowse.itemBottom

        onPressed: pSelectButton(index)
    }

    ButtonPushIcon
    {
        id: buttonClear

        anchors.left  : buttonsBrowse.left
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        anchors.leftMargin: buttonsBrowse.getWidth()

        width: height

        enabled: (buttonsBrowse.count)

        icon          : st.icon16x16_close
        iconSourceSize: st.size16x16

        onClicked: pClearSearch()
    }

    ButtonPianoIcon
    {
        id: buttonAddItem

        anchors.right : borderFolder.left
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        width: height + borderSizeWidth

        borderLeft : borderSize
        borderRight: 0

        visible: (pFolder != null && pFolder.currentItem != null)

        checkable: true
        checked  : (panelAdd.item == buttonAddItem)

        icon          : st.icon24x24_addIn
        iconSourceSize: st.size24x24

        onPressed:
        {
            panelAdd.setSource(1, pFolder, -1);

            areaContextual.showPanelMargins(panelAdd, buttonAddItem, 2, 0);
        }
    }

    ButtonPianoIcon
    {
        id: buttonAddTrack

        anchors.right : buttonUp.left
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        width: height + borderSizeWidth

        borderLeft: borderSize

        visible: (playlist != null && playlist.selectedCount)

        checkable: true
        checked  : (panelAdd.item == buttonAddTrack)

        icon          : st.icon24x24_addIn
        iconSourceSize: st.size24x24

        onPressed:
        {
            panelAdd.setSource(0, playlist, -1);

            areaContextual.showPanelFrom(panelAdd, buttonAddTrack);
        }
    }

    ButtonPianoIcon
    {
        id: buttonUp

        anchors.right : buttonClose.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        width: height + borderSizeWidth

        borderLeft: (buttonAddTrack.visible) ? 0 : borderSize

        checkable: true
        checked  : panelTracks.isExpanded

        icon          : st.icon24x24_slideUp
        iconSourceSize: st.size24x24

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

        width: height + borderSizeWidth

        highlighted: isExposed

        icon          : st.icon16x16_close
        iconSourceSize: st.size16x16

        onClicked: collapse()
    }

    ButtonPianoIcon
    {
        id: buttonPlaylist

        anchors.left  : scrollPlaylist.left
        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        width: st.dp42 + borderSizeWidth

        visible: (playlist != null && playlist.isPlaylistSearch == false)

        highlighted: (player.isPlaying && player.playlist == playlist)

        checkable: true
        checked  : (panelContextual.item == buttonPlaylist || panelAdd.item == buttonPlaylist)

        icon: (playlist != null && playlist.isFeed) ? st.icon28x28_feed
                                                    : st.icon28x28_playlist

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
                                                    Sk.BottomRight, -st.dp2, 0);
        }
    }

    ButtonPianoIcon
    {
        id: buttonRefresh

        anchors.left: (buttonPlaylist.visible) ? buttonPlaylist.right
                                               : scrollPlaylist.left

        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        width: height + borderSizeWidth

        visible: (playlist != null && playlist.isPlaylistSearch == false && playlist.isOnline)

        icon          : st.icon24x24_refresh
        iconSourceSize: st.size24x24

        onClicked: playlist.reloadQuery()
    }

    ButtonPianoTitle
    {
        id: buttonTitle

        anchors.left:
        {
            if (buttonRefresh.visible)
            {
                return buttonRefresh.right;
            }
            else if (buttonPlaylist.visible)
            {
                return buttonPlaylist.right;
            }
            else return scrollPlaylist.left;
        }

        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        visible: (itemTitle.visible && itemTitle.text != ""
                  &&
                  playlist.source != pFolderBrowse.source)

        itemTitle: itemTitle

        itemBottom: scrollPlaylist

        onClicked:
        {
            if (isFocused) window.clearFocus();

            browse(playlist.source);
        }
    }

    BarTitleText
    {
        id: itemTitle

        anchors.left: buttonTitle.left

        anchors.right: (buttonAddTrack.visible) ? buttonAddTrack.left
                                                : buttonUp      .left

        anchors.top   : buttonUp.top
        anchors.bottom: buttonUp.bottom

        visible: buttonPlaylist.visible

        text: (playlist) ? playlist.title : ""
    }

    ScrollFolder
    {
        id: scrollHubs

        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        anchors.bottomMargin: panelCover.getHeight()

        width: widthColum

        folder: hubs

        delegate: ComponentFolder
        {
            iconDefault: (index == 0) ? st.icon32x32_url
                                      : st.icon32x32_feed

            function onPressed(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    pSelectItem(index);
                }
            }

            function onDoubleClicked(mouse)
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

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                search(pFolderHubs.currentId, query, true, false);
            }
        }
    }

    ScrollFolder
    {
        id: scrollBrowse

        anchors.left  : borderHubs.right
        anchors.top   : buttonEdit.bottom
        anchors.bottom: parent.bottom

        width: widthColum

        visible: (scrollCompletion.visible == false)

        delegate: ComponentFolder
        {
            function onPressed(mouse)
            {
                if (mouse.button & Qt.LeftButton)
                {
                    pSelectItem(index);
                }
            }

            function onDoubleClicked(mouse)
            {
                if (mouse.button & Qt.LeftButton
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

        textDefault: (pBrowsing) ? qsTr("Type something to watch")
                                 : qsTr("Empty Folder")

        itemLeft: scrollHubs

        itemRight: (scrollFolder.visible) ? scrollFolder
                                          : scrollPlaylist

        itemTop: (pSearchHidden) ? buttonBrowse
                                 : lineEdit

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                if (pItemBrowse.isFolderSearch || pItemBrowse.isPlaylistSearch)
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
                scrollToItem(currentIndex);

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

        textDefault:
        {
            if (folder == null || folder.isFolderSearch == false)
            {
                return qsTr("Empty Folder");
            }
            else if (folder.source == "")
            {
                return qsTr("Type a query");
            }
            else return qsTr("No results");
        }

        itemLeft : scrollBrowse
        itemRight: scrollPlaylist

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Plus && buttonAddItem.visible)
            {
                event.accepted = true;

                buttonAddItem.focus();

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

        anchors.left: (borderFolder.visible) ? borderFolder.right
                                             : borderBrowse.right

        anchors.right : parent.right
        anchors.top   : scrollFolder.top
        anchors.bottom: scrollFolder.bottom

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
                 return qsTr("Type a Track query");
            }
            else return qsTr("No Track results");
        }

        itemLeft: (scrollFolder.visible) ? scrollFolder
                                         : scrollBrowse

        itemTop: (buttonTitle.visible) ? buttonTitle : null

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Plus && buttonAddTrack.visible)
            {
                event.accepted = true;

                buttonAddTrack.focus();

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

        ButtonLogoBorders
        {
            id: buttonCover

            anchors.top: parent.top

            anchors.topMargin: st.dp16

            anchors.horizontalCenter: parent.horizontalCenter

            imageDefaultWidth : st.dp96
            imageDefaultHeight: st.dp96

            imageMaximumWidth: st.dp256

            sourceSize.height: imageDefaultHeight

            visible: (source != "")

            source: (buttonOpen.visible) ? playlist.cover : ""

            fillMode: Image.PreserveAspectFit

            asynchronous: Image.AsynchronousOn

            onClicked: gui.openSource(playlist.source)
        }

        ButtonPushFull
        {
            id: buttonOpen

            anchors.top: (buttonCover.visible) ? buttonCover.bottom
                                               : scrollPlaylist.itemText.bottom

            anchors.topMargin: st.dp11

            anchors.horizontalCenter: parent.horizontalCenter

            visible: (text != "")

            icon          : st.icon16x16_external
            iconSourceSize: st.size16x16

            text: (buttonPlaylist.visible
                   &&
                   scrollPlaylist.itemText.visible) ? getOpenTitle(playlist.source) : ""

            onClicked: gui.openSource(playlist.source)
        }
    }

    BorderVertical
    {
        id: borderHubs

        anchors.left  : scrollHubs.right
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
