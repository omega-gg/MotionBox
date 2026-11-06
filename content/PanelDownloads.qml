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

PanelSettingsAction
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isActive: (pActive > 0)

    /* read */ property bool hasDownloaded: false

    // NOTE: The average of the running downloads, in percent.
    /* read */ property int progress: 0

    /* read */ property ListModel model: ListModel {}

    //---------------------------------------------------------------------------------------------
    // Private

    property int pActive: 0

    property Playlist pPlaylist    : null
    property Playlist pPlaylistDrag: null

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    isTop: true

    borderTop   : 0
    borderBottom: borderSize

    sources: [ Qt.resolvedUrl("PageDownloads.qml") ]

    titles: [ qsTr("Downloads") ]

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onDownloadProgress(id, percent, received, total)
        {
            var index = pGetIndex(id);

            if (index == -1) return;

            model.setProperty(index, "progress", percent);
            model.setProperty(index, "received", received);
            model.setProperty(index, "total",    total);

            pUpdateProgress();
        }

        /* QML_CONNECTION */ function onDownloadFinished(id, ok, source, size)
        {
            var index = pGetIndex(id);

            if (index == -1) return;

            model.setProperty(index, "running",  false);
            model.setProperty(index, "failed",   ok == false);
            model.setProperty(index, "source",   source);
            model.setProperty(index, "received", size);

            pActive--;

            pUpdateProgress();

            if (ok)
            {
                 popup.showText(qsTr("Download saved in: ") + controllerFile.pathDownloads());
            }
            else popup.showText(qsTr("Failed to download: ") + model.get(index).title);
        }
    }

    //---------------------------------------------------------------------------------------------
    // Timers
    //---------------------------------------------------------------------------------------------

    Timer
    {
        interval: 1000

        repeat: true

        running: isActive

        onTriggered: pUpdateSpeed()
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function getSize(bytes)
    {
        if      (bytes < 1048576)    return Math.round(bytes / 1024) + " KB";
        else if (bytes < 1073741824) return Math.round(bytes / 1048576) + " MB";
        else                         return (bytes / 1073741824).toFixed(1) + " GB";
    }

    //---------------------------------------------------------------------------------------------

    function download(track, quality, audio)
    {
        var id = core.download(track, quality, audio);

        if (id == -1) return;

        // NOTE: The most recent download comes first.
        model.insert(0, { "downloadId": id, "title": track.title, "cover": track.cover,
                          "progress": 0, "received": 0, "receivedLast": 0, "total": -1, "speed": 0,
                          "running": true, "failed": false, "source": "" });

        hasDownloaded = true;

        pActive++;

        pUpdateProgress();
    }

    // NOTE: A running download is aborted, the files of a finished one stay where they are.
    function remove(index)
    {
        var item = model.get(index);

        if (item.running)
        {
            core.abortDownload(item.downloadId);

            pActive--;
        }

        model.remove(index);

        pUpdateProgress();
    }

    // NOTE: The track plays from a playlist of its own, as the track of a list.
    function play(source)
    {
        if (pPlaylist == null)
        {
            pPlaylist = controllerPlaylist.createPlaylist();
        }
        else pPlaylist.clearTracks();

        pPlaylist.addSource(source, true);

        gui.setCurrentTrack(pPlaylist, 0);

        player.play();

        collapse();

        window.clearFocus();
    }

    // NOTE: The track is dragged from a playlist of its own, as the tracks of a list. The drag
    //       ends with a tryDelete on it.
    function startDrag(index)
    {
        var item = model.get(index);

        pPlaylistDrag = controllerPlaylist.createPlaylist();

        pPlaylistDrag.addSource(item.source);

        pPlaylistDrag.setTrackTitle(0, item.title);
        pPlaylistDrag.setTrackCover(0, item.cover);

        gui.drag      = 0;
        gui.dragItem  = pPlaylistDrag;
        gui.dragIndex = panelLibrary.index;
        gui.dragData  = [ 0 ];

        toolTip.showIcon(item.title, st.icon16x16_track, st.dp16, st.dp16,
                         item.cover, st.dp56, st.dp32);

        window.startDrag(item.source, Qt.CopyAction);

        panelLibrary.select(1);
    }

    function showFolder()
    {
        collapse();

        gui.restore();

        // NOTE: We only want to show the folder, the current track stays where it is.
        panelBrowse.search(panelSearch.backendAt(0),
                           controllerFile.fileUrl(controllerFile.pathDownloads()), false, false);
    }

    //---------------------------------------------------------------------------------------------
    // BasePanelSettings reimplementation

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionDownloadsExpose)) return;

        gui.panelAddHide();

        panelSettings .collapse();
        panelSubtitles.collapse();
        panelOutput   .collapse();

        loadPage();

        isExposed = true;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionDownloadsCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateSpeed()
    {
        for (var i = 0; i < model.count; i++)
        {
            var item = model.get(i);

            if (item.running == false) continue;

            // NOTE: The first bytes can be there already, as when a torrent resumes.
            if (item.receivedLast)
            {
                // NOTE: The bytes come in steps, so we smooth the speed over the last seconds.
                var speed = (item.speed + item.received - item.receivedLast) / 2;

                model.setProperty(i, "speed", Math.floor(speed));
            }

            model.setProperty(i, "receivedLast", item.received);
        }
    }

    function pUpdateProgress()
    {
        var total = 0;
        var count = 0;

        for (var i = 0; i < model.count; i++)
        {
            var item = model.get(i);

            if (item.running == false) continue;

            total += item.progress;

            count++;
        }

        if (count) progress = total / count;
        else       progress = 0;
    }

    function pGetIndex(id)
    {
        for (var i = 0; i < model.count; i++)
        {
            if (model.get(i).downloadId == id) return i;
        }

        return -1;
    }
}
