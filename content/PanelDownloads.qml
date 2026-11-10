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
        var download = core.download(track, quality, audio);

        if (download == null) return;

        download.progressChanged.connect(pUpdateProgress);

        download.ended.connect(function()
        {
            pActive--;

            pUpdateProgress();

            if (download.hasError)
            {
                 popup.showText(qsTr("Failed to download: ") + track.title);
            }
            else popup.showText(qsTr("Download saved in: ") + controllerFile.pathDownloads());
        });

        // NOTE: The most recent download comes first.
        model.insert(0, { "download"    : download,
                          "title"       : track.title,
                          "cover"       : track.cover,
                          "receivedLast": 0,
                          "speed"       : 0 });

        hasDownloaded = true;

        pActive++;

        pUpdateProgress();
    }

    // NOTE: A running download is aborted, the files of a finished one stay where they are.
    function remove(index)
    {
        var download = model.get(index).download;

        if (download.isRunning) pActive--;

        // NOTE: The row goes first, so its delegate is deleted before the download it reads.
        model.remove(index);

        download.remove();

        pUpdateProgress();
    }

    // NOTE: This is only enabled when nothing runs, so the files stay where they are.
    function clear()
    {
        var downloads = new Array;

        for (var i = 0; i < model.count; i++)
        {
            downloads.push(model.get(i).download);
        }

        model.clear();

        for (/* var */ i = 0; i < downloads.length; i++)
        {
            downloads[i].remove();
        }

        hasDownloaded = false;

        collapse();
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

        pPlaylistDrag.addSource(item.download.source);

        pPlaylistDrag.setTrackTitle(0, item.title);
        pPlaylistDrag.setTrackCover(0, item.cover);

        gui.drag      = 0;
        gui.dragItem  = pPlaylistDrag;
        gui.dragIndex = panelLibrary.index;
        gui.dragData  = [ 0 ];

        toolTip.showIcon(item.title, st.icon16x16_track, st.dp16, st.dp16,
                         item.cover, st.dp56, st.dp32);

        window.startDrag(item.download.source, Qt.CopyAction);

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

            var download = item.download;

            if (download.isRunning == false) continue;

            var received = download.received;

            // NOTE: The first bytes can be there already, as when a torrent resumes.
            if (item.receivedLast)
            {
                // NOTE: The bytes come in steps, so we smooth the speed over the last seconds.
                var speed = (item.speed + received - item.receivedLast) / 2;

                model.setProperty(i, "speed", Math.floor(speed));
            }

            model.setProperty(i, "receivedLast", received);
        }
    }

    function pUpdateProgress()
    {
        var total = 0;
        var count = 0;

        for (var i = 0; i < model.count; i++)
        {
            var download = model.get(i).download;

            if (download.isRunning == false) continue;

            total += download.progress;

            count++;
        }

        if (count) progress = total / count;
        else       progress = 0;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        interval: 1000

        repeat: true

        running: isActive

        onTriggered: pUpdateSpeed()
    }

    ButtonPiano
    {
        anchors.right: parent.right
        anchors.top  : parent.top

        borderLeft: borderSize

        enabled: (panelDownloads.isActive == false)

        text: qsTr("Clear")

        onClicked: panelDownloads.clear()
    }
}
