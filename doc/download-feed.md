# Downloads feed in Sky and MotionBox

## Context

MotionBox downloads tracks as a media file plus a VBML in the downloads folder, but the Downloads
panel only lists the downloads of the current session. A Downloads feed, next to Suggestions,
Recents and Interactive, lists every VBML in the downloads folder, most recent download on top, so
the user sees what this machine has downloaded, with the titles and covers from the VBML. It
reloads each time it's opened. The listing lives in Sky so MotionMonkey can add the same feed
later.

## Approach

The feeds already run on `WLoaderPlaylist` (Sky `SkGui/src/media`): when its feed item becomes
current it calls `onStart()`, and `onStop()` when another one is selected. So "reload on open" is
free. A new `WLoaderDownloads` only has to list the files and hand them to the existing
`applySources(sources, tracks, load)`, which keeps the tracks already there, loads the new ones from
their VBML, reorders and removes the rest.

The order is the download time: the VBML is written once the media is complete, so its
modification time is when the download finished. `QDir::Time` sorts on it without reading any file.

## Steps

### Sky (`src/SkGui/src/media`)

1. **New `WLoaderDownloads.{h,_p.h,cpp}`** on `WLoaderPlaylist`, with an `SK_NO_LOADERDOWNLOADS`
   guard, like `WLoaderRecent`:
   - `path` property, `WControllerFile::pathDownloads()` by default, so another app can point it
     at its own folder.
   - `onStart()`: `setQueryLoading(true)`, then a reply on `wControllerPlaylist->thread()`, as
     `WLoaderRecentPrivate::updateSources` does, so the main thread never touches the disk.
   - The reply subclasses `WLoaderPlaylistReply`, to reuse its `loaded(WLoaderPlaylistData)` and
     `abortAndDelete`. Its one invokable lists `QDir(path).entryInfoList({"*.vbml"}, QDir::Files,
     QDir::Time)` as file URLs (`WControllerFile::fileUrl`) into `data.sources`.
   - `onLoaded`: `applySources(data.sources, QHash<QString, const WTrack *>(), true)`, then
     `setQueryLoading(false)`.
   - `onStop()`: `abortAndDelete` the pending reply, then the base `clearQueries()`.
   - `reload()` stays the base one: it clears the tracks and starts again.
2. **Build lists:** `media.pri` of SkGui, and the forwarding headers through `include/generate.sh`
   (`WLoaderDownloads`, `private/WLoaderDownloads_p`).

**Sky style:** `WLoaderDownloads` is a copy of the `WLoaderSuggest` / `WLoaderTracks` shape, so it
reads like its siblings:

- The same license header and banners as `WLoaderSuggest`, and a `// Static variables` block
  with `LOADERDOWNLOADS_MAX_COUNT = 500`, the cap of `WLoaderTracks`, so a huge folder stays
  bounded.
- `WLoaderDownloadsPrivate : WLoaderPlaylistPrivate` with `init()`, `public: // Functions`
  (`updateSources`, `clearQueries`), `public: // Slots` (`onLoaded`), `public: // Variables`
  (`path`, `reply`, `method`), and `W_DECLARE_PUBLIC`.
- The public class has `W_DECLARE_PRIVATE`,
  `Q_PRIVATE_SLOT(d_func(), void onLoaded(const WLoaderPlaylistData &))`,
  `protected: // WLoaderPlaylist implementation` with `/* virtual */ onStart / onStop`,
  `signals: void pathChanged();`, and `public: // Properties` with `path` / `setPath`. The
  one-line bodies are `Q_D(WLoaderDownloads); d->updateSources();`, like `WLoaderRecent`.
- `WLoaderDownloadsReply` is declared in the `.cpp`, like `WLoaderSuggestReply`, with
  `#include "WLoaderDownloads.moc"` at the end. Its invokable is
  `/* Q_INVOKABLE */ void extract(const QString & path, int maximum)`. `init()` caches its
  `QMetaMethod` from `staticMetaObject`, and `updateSources()` calls
  `method.invoke(reply, Q_ARG(...))` after `moveToThread(wControllerPlaylist->thread())`, the
  same calls as `WLoaderTracksPrivate`.
- `updateSources` and `clearQueries` copy `WLoaderTracksPrivate`: `if (reply)
  reply->abortAndDelete(q);`, `setQueryLoading(true)`, and `reply = NULL` after
  `deleteLater()` in `onLoaded`.
- `// NOTE:` comments, `== false`, `NULL`, aligned declarations and arguments, at most 99
  columns.

### MotionBox C++ (`src/controllers/ControllerCore.*`, `src/media/media.pri`)

3. `media.pri`: add the three Sky files.
4. `ControllerCore`: a `WLoaderDownloads * _loaderDownloads`, created in `onFeedChanged` for the
   label `downloads` and started, deleted in `onFeedUpdated` when `itemLabel(4)` isn't `downloads`
   anymore, and reloaded by `reload("downloads")`.

### MotionBox QML (`content/`)

5. **`Gui.qml` `pCreatePlaylists`:** a `PlaylistFeed` at index 4, title "Downloads", label
   `downloads`. The loader feeds always stay on top:
   - A new `indexFeeds` property (5) replaces the hard coded 4 of `addHistoryFeed`,
     `addHistoryPlaylist` and `pAddPlaylist`, so the feeds of the played tracks go after them.
   - `pCreateFeed(index, type, title, label)` finds each loader feed by its label: it creates it
     when it's missing and moves it back to its index when it moved. Before, a loader feed at
     another index was created a second time. The label at its index is checked first, so the
     usual case stays one read.
   - A new `indexLock` in `ScrollFolderCreate.qml`, which `PanelLibrary` sets to `indexFeeds` on
     the feeds: a drop can't go above the loaders, and a loader feed can't be moved.
6. **`PanelLibrary.qml`:** `downloads` joins `pIsLoader`, with `st.icon16x16_download`, the same
   `icons/download.svg` as the bar button's `icon18x18_download`.
7. **`ContextualFolder.qml`:** `downloads` gets the "Reload" entry like the other loader feeds.
8. **`PageDownloads.qml`:** "Show download folder" becomes "Show downloads folder", and opens the
   folder in the file explorer with `gui.openFile(controllerFile.pathDownloads())`, like the
   storage button of `PageApplication`. `showFolder()` of `PanelDownloads.qml` goes away.

The MotionBox changes copy the lines next to them: the `interactive` blocks in `ControllerCore`
and `pCreatePlaylists`, the `else if (label == ...)` chain of `PanelLibrary`, and one condition per
line in the `pIsLoader` and "Reload" lists.

## Critical files

- Sky: `src/SkGui/src/media/WLoaderPlaylist.{h,cpp}` (`applySources`, `setQueryLoading`,
  `WLoaderPlaylistReply`), `WLoaderRecent.cpp` (reply on the playlist thread),
  `src/SkCore/src/controllers/WControllerFile` (`pathDownloads`, `fileUrl`).
- MotionBox: `ControllerCore.cpp` (`onFeedChanged`, `onFeedUpdated`, `reload`), `Gui.qml`
  (`pCreatePlaylists`), `PanelLibrary.qml`, `ContextualFolder.qml`, `PanelDownloads.qml`.

## Verification

Build with MinGW, running qmake by hand since the `.pri` changes. Run from a temp folder while
MotionBox is closed, checking the first 30 seconds of the log.

1. Open the Downloads feed with a few downloads: one row per VBML, with its title and cover, the
   latest download first. Media without a VBML and other files don't show.
2. Download a track, then reopen the feed: it's on top, and only it loads.
3. Delete a VBML in the file manager and reopen the feed: its row is gone.
4. "Show downloads folder" in the panel opens the downloads folder in the file explorer.
5. The feed's icon matches the bar button, "Reload" works, and a double click plays a row.
6. An empty or missing downloads folder gives an empty feed with no errors.
7. Existing feeds keep their items, shifted after the new Downloads feed.
8. A feed dropped above the loaders lands after Downloads, and a loader can't be moved inside the
   feeds.

## Results

Built with MinGW. In the app, the Downloads feed appears after a play.

Not tested since the fixes: the order, "Reload", "Show downloads folder" and the drag guards.
