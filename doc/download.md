# Track downloads in Sky and MotionBox

## Context

MotionBox can play a track and save its VBML, but it can't keep the media itself. This adds a
download action on a track, the upper tab and the player, a Downloads panel with progress and abort,
and a downloads folder whose tracks play inside MotionBox. Each download gives a media file and a VBML
side by side. Video and audio parts are muxed with FFmpeg, several downloads can run at once, and
BitTorrent sources work.

## Decisions

- **Folder:** the user's `Downloads` folder directly, through a new
  `WControllerFile::pathDownloads()`.
- **X button:** on a running row it aborts, removes the partial files and removes the row. On a
  finished or failed row it removes the row and keeps the files. "Cleared" never deletes a download.
- **Failed downloads:** the row stays with a "Failed" label until it is cleared.
- **Session only:** the list isn't kept across restarts. Quitting aborts running downloads and removes
  their partial files, with no prompt.
- **Not downloadable:** live, hub, channel and interactive tracks, timeline tracks and local files.
  The menu item is disabled when the track type or source already says so. Otherwise the panel shows
  "Nothing here".
- **HLS:** `.m3u8` sources download through the same mux step, for almost no extra code.
- **Not included:** covers stay remote and subtitles aren't saved.

## Approach

### Transfer and mux

Qt networking doesn't fit: `WRemoteData` buffers the whole file in memory and has no progress signal.
FFmpeg's own I/O does, and it's already how the player reads media, so the headers, proxy, reconnect
and YouTube's 10 MB requests all behave the same. No `ffmpeg.exe` is needed: the muxers are in the
`sk-avformat` DLL, the build only disables the command line programs.

`WFfmpegDownload` is a generic worker with its own thread. URLs, options and a base path go in,
progress and a final path come out. The main thread never blocks.

1. **Copy:** `avio_open2` and `avio_read` write each URL in turn to `<base>.0.part` and
   `<base>.1.part`. It succeeds only if the received bytes match `avio_size`. Abort goes through an
   `AVIOInterruptCB` and an atomic flag.
2. **Mux:** stream copy of the video and audio into `<base>.part`, taking the lowest timestamp from
   the two inputs. Remuxing sets `codec_tag = 0` and rescales timestamps.
3. **Container:** `.mp4`, or `.mkv` when `avformat_write_header` refuses the streams. Audio only gives
   `.m4a` or `.mka`. `avformat_query_codec` isn't used: Matroska's refuses codecs it can carry.
4. **Rename:** the part file takes its final name only once complete, so an unfinished file never
   shows up as media.

Routing:

| Input | Path |
|---|---|
| `.m3u8` (checked first, it's in the video regex) | no copy, mux from the URL, progress from packet time |
| one input with a media extension | copy, then rename |
| one input with no extension, as YouTube's `videoplayback` | copy, then mux |
| video and audio | copy both in sequence, then mux |

Progress is the bytes received over the total, and holds at 99% during the mux. With two parts, their
sizes are read first so the total doesn't change. A playlist has no total, its progress comes from
the packet time and its bytes from the file written so far.

### Torrents

A torrent is a source step before the same worker. `WControllerTorrent::getTorrent` in `Default` mode
fetches the file into the torrent cache, and the worker then copies the local path, keeping the
original bytes and extension. The reply is deleted after the copy, because the cache only evicts
inactive torrents.

`Sequential` and `Default` had no callers, so the engine needed fixes (step 1). A track with no
`#id.ext` fragment selects all files, so it picks the first media file and requests it again with the
fragment. That fragment also goes into the saved `origin`: a torrent alone opens as a playlist, which
doesn't start playing when the file is gone.

### Saved VBML

The file is written once the media has its final name:

```
# vbml 1.0.6

type: track

origin: https://...

source: Big Buck Bunny.mp4

title: Big Buck Bunny

cover: https://...

author: ...

feed: https://...

date: ...
```

- **`origin`:** the source URL of the track, without its `#t=` position. The `source` plays first,
  and the origin when that file is gone. Related tracks still come from the origin. A remote source
  that fails to load doesn't fall back yet.
- **No `duration`:** `toVbml` writes milliseconds but a bare number reads as seconds, and a `duration`
  with a `source` takes the timeline path. The player gets it from the file.
- **Safe values:** a title starting with `#`, `|` or `>` is read as YAML structure and swallows the
  lines after it, so these values use the `|` block form.

### Names

The sanitizer keeps Unicode and spaces. It drops `< > : " / \ | ? * # %` and control characters, trims
trailing dots and spaces, avoids reserved Windows names and caps the length. `#`, `?` and `%` have to
go because URL helpers cut at them. An empty result becomes `Track`. Names are made unique against
existing `.vbml` files and active downloads at the start, then against the final media file at the
rename, and the VBML follows the final name.

## Steps

### Sky

1. **`SkTorrent/src/torrent/WTorrentEngine.cpp`:**
   - In the piece handler, `continue` instead of `return true` when an item isn't at that piece. The
     `return` left the item loop, so a stream or a second item on the same torrent could miss pieces
     and never finish.
   - Report per-file progress for non-stream items. `total_done` covers the whole torrent, so a file
     could show 100% at once. Reuse the existing buffer event.
   - Fix the `end` piece calculation for a file ending exactly on a piece boundary.
   - Keep the torrent info in `WTorrentData`. A second item arriving while the torrent is still being
     added called `torrent_file()` on an invalid handle, which stopped the engine thread.
   - Count a piece once: libtorrent announces pieces again when a torrent resumes.
2. **`SkGui/src/controllers/WControllerPlaylist.cpp`:**
   - Add `m4a` to the audio regex and the file filter.
   - `vbmlSource`: a value with no scheme, no `/` and a media extension resolves to
     `baseUrl + '/' + url`, when `baseUrl` contains `://`. Limiting it to media extensions keeps values
     like `youtube.com` and `cover: image.jpg` unchanged.
   - `vbmlSourceResolves`: false when the source is empty or a local file that's gone. `applyVbml`
     and `WControllerMedia` only follow the `origin` then, so the source comes first.
   - `applyFolder`: when a `.vbml` and a media file share a base name, point the media entry at the
     VBML and drop the VBML from `files`. Without this each download shows twice with raw names. With
     it, one track loads the VBML's title and cover. A folder with no text-type files skips this.
     Folders and files now share a single list, sorted by name and ignoring case.
3. **`SkMedia/src/ffmpeg/WFfmpegPlayer.cpp`:** move the input options, the `header=` loop and the
   proxy format into static helpers, with no behavior change. They stay in this file because other
   projects have their own `ffmpeg.pri` and would otherwise fail to link.
4. **New `SkMedia/src/ffmpeg/WFfmpegDownload.{h,cpp}`:** as described above, with `setProxy`, one
   `openIo` for each URL it opens, an `SK_NO_FFMPEGDOWNLOAD` guard in `Sk.h`, entries in Sky's and
   MotionBox's `ffmpeg.pri`, and forwarding headers from `include/generate.sh`.
5. **`SkCore/src/controllers/WControllerFile.cpp`:** add `pathDownloads()`.

### MotionBox C++ (`src/controllers/ControllerCore.*`)

The orchestration lives here: this class already owns the media and torrent controllers, and naming
and folder choices are app policy.

6. **`loadLinks`:** keep the last reply in a `QPointer<WMediaReply>`, for `download` to read. Each new
   load deletes the previous reply with `deleteLater`, since it may be emitting, so the links of an
   earlier track can't fill the panel of another. An empty source returns at once, `getMedia` has no
   reply for it. Add a `canDownload` signal argument.
7. **API:**
   - `Q_INVOKABLE int download(trackData, quality, isAudio)` and `abortDownload(id)`.
   - Signals `downloadProgress(id, percent, received, total)` and
     `downloadFinished(id, ok, source, size)`. The total is -1 when it isn't known.
   - Property `canDownload`, false on builds without FFmpeg.
   - C++ reads `medias[q]`, `audios[q]` and `options()` from the same reply, the pairing the player
     uses.
8. **Torrent branch** under `SK_NO_TORRENT`: handle `hasError`, empty `paths` and the reply's
   `destroyed` signal, which `clearTorrents` can trigger. Torrent bytes go out with every megabyte.
9. **VBML writer** with `startWriteFile` and its own slot. `writeVbmlFile` would fire `vbmlSaved` and
   show the Save VBML popup.
10. **Quit:** on `sk`'s `aboutToQuit`, set every abort flag, `wait()` on every thread, delete the
    replies. Each worker removes its own parts before exiting. A UI abort doesn't wait, it cleans up on
    `QThread::finished`.

### MotionBox QML (`content/`)

11. **`AreaContextualApplication.qml`:**
    - Add "Download" after "Save VBML" in `loadPageTrack` and `loadPageTab`. The player and the
      upper tab both reach `loadPageTab`.
    - Don't renumber ids: use id 11 on the track page and 10 on the tab page.
    - The insert shifts the positional `setItemEnabled` indexes: Download is 10 and Close moves to 11.
    - Rename the tab page's "Close" to "Close Track".
    - `currentId` 8 maps to `ContextualDownload.qml` in `pGetSource`.
12. **New `BaseContextualLinks.qml`,** shared by `ContextualLinks.qml` and the new
    `ContextualDownload.qml`, which only differ by their row:
    - A "Safe mode" toggle at the top that reloads the links, then a "Video" section with the
      qualities and an "Audio" section with "Audio 1", "Audio 2".
    - Safe mode starts disabled in both: it skips adaptive sources, so it only offers lower qualities.
    - `onMediaLoaded` already lists each distinct audio once, from the lowest quality up.
    - The "Nothing here" and "Loading..." label uses the new `LabelAction.qml`, and
      `ButtonWideSource.qml` gets its margins back. Both follow `ButtonAction`, since push buttons
      lost their own margins. The "Track added" label of `ScrollFolderCreate.qml` gets its inset
      back the same way.
13. **New `PanelDownloads.qml`** on `PanelSettingsAction`, like `PanelSubtitles`:
    - It holds the `ListModel`, so the state survives the page loader. The most recent download goes
      first.
    - A one second timer works out the speed of each running row from its bytes, smoothed.
    - A finished download shows the usual popup with the folder, or "Failed to download".
    - It slides down from under the bar through a new `isTop` property of `BasePanelSettings`, inside
      a clipped `Item` so it doesn't pass over the bar.
    - Wire it in `Gui.qml` (declaration, two free action ids, sibling collapses) and in the expose
      function of `PanelSubtitles`, `PanelSettings` and `PanelOutput`.
14. **New `PageDownloads.qml`:** `ScrollList` plus a bottom "Show download folder" button, which
    collapses the panel and opens the folder in Browse with `search(…, false, false)`, so the current
    track stays. `PanelBrowse.qml` no longer hides its search bar on local folders.
15. **New `ComponentDownload.qml`** on `ItemList`, since `ComponentTrack` only works inside
    `ListPlaylist`:
    - Cover, title, `BarProgress` with its default blue colors, white on a selected row.
    - The speed and size as `8 MB/s, 45 MB / 120 MB`, right aligned, and the X shown on hover. A
      finished row shows its size.
    - A click selects the row like a track, and a double click on a finished row plays its local
      VBML from a playlist of the panel's own, without opening Browse, and collapses the panel.
    - A finished row drags to the playlists like a track of `ListPlaylist`. The drag carries its
      VBML through a playlist of its own, which `onDragEnded` deletes.
16. **`BarWindowApplication.qml`:** a standalone `ButtonPushIcon` left of the separator:
    - Hidden until the first download of the session, then visible until the application closes. It
      toggles the panel, and is only highlighted when the panel is shown, like the other buttons.
    - The icon is `icon18x18_download`, a new alias in `StyleApplication.qml`.
    - While a download is active a `Loader` creates `ItemDownloadProgress.qml`, a ring with the
      average progress around the icon at 14x14.
    - The track tab anchors to the button when it's visible.
17. **Register** the new QML in `OTHER_FILES`, and run the generate step. `dist/qrc/MotionBox.qrc` is
    generated.

### VBML

18. **`doc/track.md`:** under `origin`, note that the source plays first and the origin when it
    doesn't resolve.

### Plan copy

19. Copy this plan to `doc/download.md` in MotionBox, next to the other plans.

## Verification

Build with MinGW, run from a temp folder while MotionBox is closed, and start each run checking the
first 30 seconds for errors. No test needs the Windows-only paths beyond the build.

1. **YouTube:** one video + audio quality, one audio entry and a muxed-only quality. Check that the
   file opens, has both streams, stays in sync and that seeking works.
2. **Containers:** an H.264 + AAC pair gives `.mp4`, and a pair MP4 refuses falls back to `.mkv`.
3. **HLS:** a VOD `.m3u8` source.
4. **Names:** spaces, Unicode, brackets, a title starting with `#`, a title with only symbols, and the
   same track twice.
5. **VBML:** the file reads back with its bare `source` and plays from it. With the file gone, it
   plays its `origin`.
6. **Downloads folder:** Show download folder gives one entry per download, with the right title and
   cover, and it plays. A folder with unrelated media still lists as before.
7. **Abort and quit:** during copy, during mux and during a torrent. No `.part` files remain and no
   thread stays alive.
8. **Concurrency:** three downloads at once while playing another track, with no UI stall.
9. **Button:** hidden at start, visible from the first download, highlighted only while the panel is
   shown, with the ring during a download, in all four styles with `local.style` set.
10. **BitTorrent, Big Buck Bunny:** this makes peer-to-peer traffic, so check the network is fine for
    it first.
    - Download one file of the multi-file torrent, and compare its checksum with the source. This also
      answers whether a copy can start before the last blocks reach disk.
    - A magnet with no fragment, two downloads of one torrent, and the same torrent streaming at once.
    - Progress on the file alone, not on the whole torrent, and a resume without a speed spike.
    - The `origin` fallback once the file and the torrent cache are gone, with and without a fragment.

## Results

Tested in the app, on Windows with MinGW:

- **Downloads:** YouTube video + audio, audio only, Safe mode, HLS, a file with no extension, the
  `.mkv` fallback, a 404, and names with spaces, Unicode, brackets and a leading `#`.
- **BitTorrent:** checksums match the source from an empty cache, while streaming the same torrent
  and with a second row aborted. A magnet with no index picks the media file. Resume shows no speed
  spike.
- **Fallback:** a VBML whose file is gone plays its `origin`, for YouTube and for torrents with and
  without a fragment.
- **UI:** both panels with Safe mode on and off, the menus, the ring, the button in the four styles,
  the panel from the top, the tooltip, the selected row, and the downloads folder with a VBML and its
  media listed once.
- **Abort and quit:** no `.part` files left, during a copy, a mux and a torrent.

Not tested:

- **Real mouse:** selecting a row, the double click to play, the drag to a playlist, the hover X and
  the track list's right click. The tests called these paths directly.
- **Since the last cleanups:** HLS and the `.mkv` fallback weren't run again.
- **Never:** a real proxy, a dead magnet, and which codecs trigger MP4's "experimental" error.
- **Platforms:** Android and macOS.
