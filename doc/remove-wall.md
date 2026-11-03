# MotionBox: replace WallVideo with a regular Player

## Context

MotionBox plays video through `WallVideo`, a Sky component that bundles the Player with a tab grid
(the Wall, F3) and a side by side split view. That split is driven by `tabs.highlightedTab`, which
is checked across the whole application. MotionMonkey has none of this: a plain `Player` sits
directly in its view, with a single tab.

**Outcome:** MotionBox gets a regular Player in `PanelPlayer` and has no Wall, no split view and no
tab strip. The single tab is what removes the split logic: with one tab `highlightedTab` can never
be set.

## Scope

- **Edited:** MotionBox only (`content/`, `src/`).
- **Reference only:** MotionMonkey and tevolution, which also have QML players. They show one way to
  solve a problem, and matching them is not a reason for a change: each change needs a functional
  justification.
- **Not touched:** Sky and Sky-runtime. Sky keeps `WallVideo`, the tab components and the
  `highlightedTab` API, because Sky-runtime still registers and ships them. `WPlayer` needs no
  change: its auto-highlight only fires when the current tab changes during playback.
- **Kept:** `currentTab` and `playerTab`. `WTabTrack` remains the model for the
  current track and its bookmark history, so `BarTop` back and forward keep working.

## Steps

### 1. `content/PanelPlayer.qml`: the regular Player

Replace `WallVideo` with inline children in `Item { id: itemPlayer }` (was `itemSplit`), keeping the
aliases `player`, `playerBrowser`, `playerMouseArea` and `subtitle` so that other files don't change.
Add a `scanner` alias and remove the `wall` alias, `wallExpand` and `wallRestore`.

Port from `Sky/src/SkyComponents/WallVideo.qml` without the wall and split parts. Children, bottom
to top:

| Child | Notes |
|---|---|
| `SkyMouseArea playerMouseArea` | Fills the player and stays visible so that tags on a stopped cover are clickable. `hoverEnabled` and the pointing cursor only when `player.hasStarted`, so cursor hiding is unchanged |
| `Player player` | `anchors.fill: parent`, `tabs: core.tabs`, `autoPlay`, `shuffle`, `pauseTimeout`, `visible: hasStarted`, so that subtitles still show over the cover in audio mode |
| `Rectangle back` + `ImageScale cover` | One cover instead of the wall's two. `source: (pAudio) ? currentTab.cover : currentTab.coverShot`, `visible: (player.isStopped \|\| player.isStarting \|\| player.isResuming \|\| pAudio)`, logo gradient from `st.logo_colorA/B` |
| `RectangleShadowClick areaBackward, areaForward` | `filter: st.icon_filterActive`, which has the same `color_highlight` as the `wallVideo_*` filter that no longer ships |
| `Subtitle subtitle` | `applySize(player, cover)`, clears the subtitle when loading fails |
| `AnimatedLoader` | Unchanged |
| `ItemScan scanner` | One scanner instead of two, with `player` and `cover` |
| `PlayerBrowser playerBrowser` | `anchors.fill: parent`, `visible: (player.hasStarted == false)`, opacity animation kept, title and details bars no longer depend on `isActive` |

Move the wall event handlers to private functions in `PanelPlayer`: `pPlayerClicked` and
`pPlayerDoubleClicked`. A tag click goes straight to `gui.browse(text)`.

Move the seek logic too: `pCheckArea`, `pCheckAreaHover`, `pCheckAreaClick`, with
`player.seek(player.currentTime +/- st.panelPlayer_interval)` inline. `pGetPosition` maps the mouse
position to the player, so that hover and clicks agree. A click saves it in `pPosition`, because
the scanner replies later and the mouse may have moved by then.

Keep the full screen `Connections` on `scanner` that restores the bars. Drop the `posB`, `split`,
`pExpanded`, `rectangleShot` and `hideTimer` code, the exposed states, and `ButtonsItem`,
`IconOverlay` and the extend button.

Add `showContextual(x, y)`, which replaces `pContextualTab` and `barWindow.showTabMenu`. It calls
`panelContextual.loadPageTab(currentTab)` then `areaContextual.showPanelAt` at that position.

### 2. `content/BarWindowApplication.qml`: remove the tab strip

Remove `TabsPlayer itemTabs`, `buttonAdd`, `pMargin`, `pContextualTab`, `pContextualItem`, the `tabs`,
`itemTabs` and `buttonAdd` aliases, and `openTab`, `openTabCurrent`, `openTabPlaylist`, `showTabMenu`,
`showCurrentTabMenu`, `pOpenTabPlaylist`. Anchor `viewDrag` to the right of `buttonMessage`
(`buttonMessage.left` when it is hidden). `pRestoreMaximize` stays.

### 3. `content/Gui.qml`

- **Properties:** `/* read */ property variant tabs: core.tabs` replaces the alias, because Sky's
  `PlayerBrowser.play()` reads `tabs` from scope. Remove `highlightedTab`, `pWall`, `actionWallExpose`,
  `actionWallRestore`, `actionTabOpen`, `actionTabMenu`, and the `buttonWall`, `wall`, `itemTabs`
  aliases. Add a `scanner` alias.
- **Wall functions removed:** `exposeWall`, `restoreWall`, `toggleWall`, `pRestoreWall`, `updateColor`,
  `playTab`, `onBeforeTabClose`, and all `wall.enableAnimation`, `wall.clearDrag`, `wall.restore`
  and `panelPlayer.wallExpand` calls (scale, zoom, expand, restore, maximize, full screen,
  `clearExpand`, `clearTabs`, `pExpandFullScreen`, `pRestoreExpand`).
- **Replacements:** `wall.scan()` becomes `scanner.scan()`. `wall.isScannerHovered` becomes
  `scanner.isHovered`. `wall.isScannerClicking` becomes `scanner.isClicking`.
- **Highlight branches removed:** `expandBars`, `playTrack`, `playItem`, `browse`, the drag tooltip,
  Esc. `player.isPlaying && highlightedTab == null` becomes `player.isPlaying`.
- **New `closeTrack()`**, the same two step behavior as closing a tab did: stop if started,
  otherwise `currentTab.clearBookmarks()`. Bound to Ctrl+W.
- **Keys:**
  - Remove Alt+Left, Alt+Right (`selectPrevious`, `selectNext`) and Ctrl+T.
  - Remove `buttonWall` and `barWindow.buttonAdd` press and release handling.
  - F3 keeps only its `//#!DEPLOY` Ctrl+F3 block.
  - Return and Space drop the `wall.isExposed` branch and keep `expandBars` and `toggleBars`.
  - Key_Menu calls `panelPlayer.showContextualPlayer()`, so the menu opens at the top left of the
    player and not at the mouse cursor.
- **Track refresh:** `TabsTrack.qml` reloaded the track at startup and every minute. A `Timer`
  keeps the periodic part, calling `currentTab.reloadTrack()`. At startup the track is not loaded yet,
  so that first call did nothing and is not kept.
- **Scanner:** `scan` and `click` only run when the scanner is visible, as `WallVideo` did.

### 4. Other QML

- **`BarTop.qml`:** remove `buttonWall`, its alias and its width. `buttonExpand` anchors to
  `buttonRelated`.
- **`PanelRelated.qml`:** remove the `wallExpand` and `wallRestore` calls and the now unused
  `getWidth`. `pGetWidth` stays.
- **`PanelLibrary.qml`:** remove the `wallRestore` call.
- **`AreaContextualApplication.qml`:**
  - In `loadPageTab`, the category becomes `qsTr("Track")`. Replace items 9 and 10 with
    `{ "id": 9, "title": qsTr("Close") }`, which calls `gui.closeTrack()` and is disabled when
    the tab is invalid. Remove the `tabs.count` check.
  - In `loadPageTag`, remove "Open in a new tab" and renumber Copy link to 0, in `onTagClicked` too.
- **`ListPlaylist.qml`:** remove `openInTab`. `player.isPlaying == false || highlightedTab` becomes
  `player.isPlaying == false`. `pPlay` drops the highlight line.
- **`ComponentTrack.qml`:** remove the middle click branch.
- **`PageGrid.qml`:** remove the middle click branch and the `highlightedTab` condition.
- **`PanelBrowse.qml`:** same highlight simplification as `ListPlaylist` in `pStartSearch` and
  `pCompleteSearch`.
- **`ContextualMode.qml`:** remove the "close the split view" lines.
- **`PageApplication.qml`:** remove the `gui.updateColor()` call. The window stays black, as set in
  `Main.qml`, which is also what shows around the video. The "Clear tabs" entry becomes
  "Clear track".
- **`StyleApplication.qml`:**
  - Add a `PanelPlayer` section with `panelPlayer_interval: 10000` and `panelPlayer_color: "black"`
    (the cover background).
  - `sliderStream_intervalA: panelPlayer_interval`.
  - Remove `icon_wall` and `icon20x20_wall`.

### 5. `content/generate.sh`, `content/icons.sh`, icons

Remove from the deployer list: `IconOverlay`, `ButtonsItem`, `BaseTabs`, `TabsBrowser`, `TabsTrack`,
`TabsPlayer`, `BaseWall`, `Wall`, `WallBookmarkTrack`, `WallVideo`, `ItemTab`, `ItemWall`,
`ComponentTab`, `ComponentTabBrowser`, `ComponentTabTrack`, `ComponentWall`,
`ComponentWallBookmarkTrack`.

The deployer strips `StyleComponents` blocks named after files that aren't in the list. Three of
them are still needed, so add these to `defines`, the way `BarWindow` is already defined without a
file in the list:

| Define | Still used by |
|---|---|
| `ItemTab` | Sky's `ItemGrid.qml` (`itemTab_color*`) |
| `icons_navigate` | `PanelRelated.qml` (`icon8x8_previous`, `icon8x8_next`) |
| `icons_contextual` | `ListFolder.qml`, `ListPlaylist.qml` (`icon10x10_contextualDown`) |

`icons_scale`, which `BarControls` needs for `icon20x20_extend`, is already defined.

Remove the `expand.svg` line from `icons.sh` and delete `content/icons/expand.svg`.

### 6. C++ (`src/`)

- **`controllers/ControllerCore.cpp`:**
  - `_tabs->setMaxCount(1)`.
  - Saved files from earlier versions can hold several tabs, and `WTabsTrackReadReply` loads them
    all regardless of `maxCount`. The load stays asynchronous so that the startup handler in
    `Gui.qml` still runs, and `onLoaded` there trims the tabs to the current one.
  - Remove the `ModelTabs` registration and include.
- **`io/DataLocal.h`, `io/DataLocal.cpp`:** remove `macro` (property, signal, member, save, load).
  Old files still load, because `readNextStartElement` scans forward past unknown elements.

## Behavior changes

- **Removed:** tabs, the Wall and F3, the split view, Ctrl+T, Alt+Left, Alt+Right, middle click
  "open in a new tab", "Close other Tabs" and "Close all Tabs".
- **Closing:** Ctrl+W and the new Close menu item stop playback first, then clear the track.
- **Tags:** middle click on a tag browses to it, like a left click.
- **Double click:** the player only reacts to the left button.
- **Saved tabs:** on first launch, tabs other than the current one are dropped from the tab list.
  Their files stay on disk, because `deleteTab` only removes the files of a loaded tab and tabs
  are not loaded yet at that point. They are small and never read again.
- **Title bar:** with no tab strip it becomes a drag area. The current track title no longer shows
  there during playback.

## Follow-ups

- Rename the leftover tab names (`playerTab`, `clearTabs`, `loadPageTab`, `onTabClicked`,
  `showTagTab`) in a rename-only commit.
- `WallVideo` and the tab components no longer have an app using them, only Sky-runtime's
  registration. Removing them from Sky is a separate decision.

## Verification

1. Search `content/` and `src/` for `\bwall\b`, `Wall`, `highlightedTab`, `itemTabs`, `macro`: no
   matches outside unrelated names.
2. From `content/`: `sh generate.sh win64 clean`, then `sh generate.sh win64 all`, which also clears
   the stale `bin/WallVideo.qml` and similar files.
3. Rebuild the C++ with the MinGW kit, then run `bin/MotionBox.exe` with
   `QT_FORCE_STDERR_LOGGING=1`. Check the log for `ReferenceError`, `TypeError` and undefined `st.*`
   values.
4. Manual run:
   - Play, pause, stop, next and previous, including during playback.
   - Seek zones, slider, subtitles, audio only cover.
   - Click, double click, right click and middle click on the player.
   - Tags on a playing video and on a stopped cover.
   - Expand, full screen (bars restore at the edges), panelRelated expose and expand.
   - Cursor hiding when expanded.
   - Style switch, UI scale, maximize, window drag from the title bar.
   - Ctrl+W twice, the context menu's Close, Key_Menu.
5. Restart with an old `tabs` file holding several tabs: one tab loads and its track restores.
6. `sh generate.sh win64 deploy` succeeds, then regenerate the dev output.
