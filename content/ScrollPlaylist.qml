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

ScrollArea
{
    id: scrollPlaylist

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property string textDefault: qsTr("Playlist is empty")

    //---------------------------------------------------------------------------------------------
    // Private

    property int pSelectedY: -1

    property bool pAtBottom: false

    // NOTE: We need this to avoid loading tracks when the item is not loaded.
    property bool pReady: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias hasPlaylist: list.hasPlaylist

    property alias playlist: list.playlist

    property alias model   : list.model
    property alias delegate: list.delegate

    /* read */ property alias count: list.count

    property alias linkIcon          : list.linkIcon
    property alias linkIconSourceSize: list.linkIconSourceSize

    property alias enableLoad      : list.enableLoad
    property alias enablePreview   : list.enablePreview
    property alias enableContextual: list.enableContextual
    property alias enableAdd       : list.enableAdd
    property alias enableLink      : list.enableLink
    property alias enableDrag      : list.enableDrag
    property alias enableDragMove  : list.enableDragMove

    property alias textVisible: itemText.visible

    property alias itemLeft  : list.itemLeft
    property alias itemRight : list.itemRight
    property alias itemTop   : list.itemTop
    property alias itemBottom: list.itemBottom

    //---------------------------------------------------------------------------------------------

    property alias list    : list
    property alias itemText: itemText

    property alias checkBox        : list.checkBox
    property alias buttonContextual: list.buttonContextual
    property alias buttonLink      : list.buttonLink

    property alias itemWatcher: list.itemWatcher

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    contentHeight: (labelLoading.visible) ? list.height + labelLoading.height + st.dp16
                                          : list.height

    singleStep     : list.itemSize
    wheelMultiplier: 1

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pReady = true;

        pUpdateVisible();
    }

    onHeightChanged: reloadTracks()

    onValueChanged: reloadTracks()

    onVisibleChanged: if (pReady) pUpdateVisible()

    //---------------------------------------------------------------------------------------------

    onPlaylistChanged: reloadTracks()

    onCountChanged: reloadTracks()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function reloadTracks()
    {
        if (pReady == false || visible == false) return;

        timerLoad.restart();
    }

    //---------------------------------------------------------------------------------------------

    function focus()
    {
        list.focus();
    }

    //---------------------------------------------------------------------------------------------

    function updateView()
    {
        updateListHeight(list);

        if (list.itemHovered)
        {
            window.updateHover();
        }

        timer.restart();
    }

    //---------------------------------------------------------------------------------------------

    function updateCurrentY()
    {
        pSelectedY = currentItemY();

        if (atTop) pAtBottom = false;
        else       pAtBottom = atBottom;
    }

    function updateVisible()
    {
        if (pSelectedY != -1)
        {
            ensureVisible(list.y + pSelectedY, list.itemSize);
        }
        else if (pAtBottom)
        {
            scrollToBottom();
        }
    }

    //---------------------------------------------------------------------------------------------

    function currentItemY()
    {
        var y = list.selectedItemY();

        if (y != -1 && checkVisible(0, list.y + y))
        {
             return y;
        }
        else return -1;
    }

    //-----------------------------------------------------------------------------------------
    // Events

    function onRangeUpdated()
    {
        if (st.animate) updateVisible();

        updateView();
    }

    function onValueUpdated()
    {
        updateView();
    }

    function onWheelUpdated()
    {
        if (list.indexContextual != -1)
        {
            window.clearContextual();
        }
    }

    //---------------------------------------------------------------------------------------------

    function onLink(index)
    {
        var data = playlist.trackData(index);

        gui.browseRelated(data);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateVisible()
    {
        if (visible)
        {
            reloadTracks();

            timerReload.start();
        }
        else timerReload.stop();
    }

    function pApplyReload()
    {
        if (playlist == null) return;

        // NOTE: We skip tracks that were reloaded less than 1 minute ago.
        playlist.reloadTracks(pGetIndex(), pGetCount(), 60000);
    }

    //---------------------------------------------------------------------------------------------

    function pGetIndex()
    {
        return Math.floor(value / list.itemSize);
    }

    function pGetCount()
    {
        // NOTE: We add 1 to cover the entire region when half a track is exposed at the top and
        //       the bottom of the list.
        return Math.ceil(height / list.itemSize) + 1;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_faster

        onTriggered: updateCurrentY()
    }

    Timer
    {
        id: timerLoad

        interval: st.scrollPlaylist_intervalLoad

        onTriggered: pApplyReload()
    }

    // NOTE: We want to reload each track periodically.
    Timer
    {
        id: timerReload

        interval: st.scrollPlaylist_intervalReload

        repeat: true

        onTriggered:
        {
            // NOTE: We are reloading so we don't need to load anymore.
            timerLoad.stop();

            pApplyReload();
        }
    }

    ListPlaylist
    {
        id: list

        anchors.left : parent.left
        anchors.right: parent.right

        scrollArea: scrollPlaylist

        /* QML_EVENT */ onLink: function(index)
        {
            scrollPlaylist.onLink(index);
        }
    }

    TextListDefault
    {
        id: itemText

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : list.bottom

        anchors.topMargin: st.dp20

        horizontalAlignment: Text.AlignHCenter

        visible: (count == 0 && playlist != null && playlist.queryIsLoading == false)

        text: textDefault
    }

    LabelLoadingButton
    {
        id: labelLoading

        anchors.top: list.bottom

        anchors.topMargin: st.dp8

        anchors.horizontalCenter: parent.horizontalCenter

        visible: (playlist != null && playlist.queryIsLoading)

        text: qsTr("Loading Tracks...")

        onClicked: playlist.abortQuery()
    }
}
