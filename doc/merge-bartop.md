# MotionBox: merge BarTop into BarWindowApplication

## Context

MotionBox has two bars stacked at the top. `BarWindowApplication` held the tab strip, which is gone,
so it is now mostly empty space above `BarTop`. Merging them gives one bar, returns that height to the
content and removes a component.

**Outcome:** `BarTop.qml` is deleted and `BarWindowApplication` is the only top bar. Left to right:

| Group | Contents |
|---|---|
| Navigation | `buttonBackward`, `buttonForward` |
| Online, when needed | `buttonVersion` and `buttonUpdate`, then `buttonMessage` |
| Search | `lineEditSearch`, taking the remaining width |
| Current track | `itemTrack`, an `ItemTab` with `ButtonsItem` |
| Separator | `borderButtons` |
| Search buttons | `buttonBrowse`, `buttonRelated`, `buttonExpand` |
| Drag gap | `st.dp32` |
| Window | `buttonIconify`, `buttonMaximize`, `buttonClose` |

## Steps

### 1. `content/BarWindowApplication.qml`

Move from `BarTop.qml`:

- `isExpanded`, `expand()` and `restore()`, with `restore()` setting `visible = true`.
- `buttonBackward`, `buttonForward`, `lineEditSearch`, the `timer` used by `buttonBrowse`, the three
  search buttons, and their aliases. Add a `border` alias.

Layout:

- `buttonVersion` and `buttonUpdate`: `anchors.left: buttonForward.right`. Their existing visibility
  and slide logic does not change.
- `buttonMessage`: `anchors.left` stays conditional on `buttonVersion.visible`, now falling back to
  `buttonForward.right`. `maximumWidth` becomes `st.dp192`, because the old value would let a long
  title take all of the search width.
- `lineEditSearch`: `anchors.left: (buttonMessage.visible) ? buttonMessage.right : buttonMessage.left`,
  `anchors.right: itemTrack.left`.
- Previous and next are `ButtonPushLeftIcon` and `ButtonPushCenterIcon`, 38x34 dp with
  `showBorder: false`. `buttonBackward` has a 7 dp left margin. `buttonForward` holds a
  `BorderVertical`, which closes the group next to the search bar.
- Browse, Related and expand are `ButtonPushLeftIcon`, `ButtonPushCenterIcon` and
  `ButtonPushRightIcon`, with the same size as the `BarControls` group, chained from
  `buttonExpand`: `anchors.right: buttonIconify.left`, `anchors.rightMargin: st.dp32`.
- `borderButtons` is a `BorderVertical` with 12 dp on each side, between `itemTrack` and
  `buttonBrowse`, like the separator after the tag button in `BarControls`.
- The bar height is `st.dp48 + border.size`, like `BarControls`. The window buttons stay aligned at
  the top. The rest of the row is vertically centered: `buttonBackward` on the bar background,
  above the bottom border, and the others on `buttonBackward`. The update and message buttons slide
  up from `border.top` to the bottom of `buttonBackward`.
- `itemTrack` is an `ItemTab` showing the current track, as the tab strip did. Left press selects
  the track, right press and the contextual button open the menu, middle press and the close button
  call `gui.closeTrack()`. Double click restores an expanded `PanelTracks`, otherwise it plays the
  track. Its width is `Math.min(st.dp256, parent.width / 6)`, to leave the search
  bar some room at the minimum window width. Key_Menu opens the same menu on it, through
  `barWindow.showTrackMenu()`. `ItemTab` and `ButtonsItem` go back in `generate.sh`, which replaces
  the `ItemTab` and `icons_contextual` defines.
- `itemTrack` is rounded on the right. Its background has the radius of a push button and extends
  past the left edge by that radius, like `ButtonPushRight`, but without clipping: `lineEditSearch`
  is declared after it and covers the left corners, so this relies on the declaration order. The
  background draws the outline, so the tab is 34 dp tall, and `itemIcon.x` puts the cover back in
  place. With no track it shows "New Track", set in the bar because `getTabTitle` is in Sky's shared
  `Style.qml`.
- The update and message buttons stay piano buttons, so they remain square, and get `borderTop` and
  `borderBottom`. `LineEditBox` has no border property, so a `BorderHorizontal` sits above and below
  `lineEditSearch`.
- `ViewDrag` covers the whole bar, declared before the buttons so that they stay above it. The
  gap and the strips above and below the row drag the window. Double click and the touch logic do
  not change.
- The window buttons keep their current size and position.

Hiding in full screen:

- Remove `anchors.bottomMargin: barTop.height`.
- The `hidden` state becomes `when: isExpanded`, since bars only expand in full screen and leaving
  full screen restores them. `anchors.bottom: parent.top` stays.
- The transition adds the `ScriptAction` from `BarTop`: `if (isExpanded) visible = false`.

The bar keeps its own background (`barWindow_color*`, including the inactive window colors). The
`buttonPiano_color*` gradient from `BarTop` is not moved.

### 2. `content/Gui.qml`

- Remove `BarTop { id: barTop }` and the `barTop` alias.
- The button and `lineEditSearch` aliases point to `barWindow`, under the existing
  `BarWindowApplication` section.
- `barTop.isExpanded` becomes `barWindow.isExpanded` (`expandBars`, `restoreBars`, `toggleBars`,
  `focusSearch`, the keys).
- `barTop.expand()` and `barTop.restore()` become the `barWindow` calls.
- `panelHeight` uses `barWindow.border.size`.
- `itemContent`: `anchors.top: barWindow.bottom`.
- `AreaPanel`: `marginTop: barWindow.y + barWindow.height + st.dp16`.

### 3. Other QML

- **`PanelPlayer.qml`:** `barTop.isExpanded` becomes `barWindow.isExpanded`.
- **`PanelAdd.qml`:** `topMargin: barWindow.height - barWindow.border.size`.
- **`PanelPreview.qml`:** `minY` uses `barWindow.y + barWindow.height`.
- **`PanelSearch.qml`:** it follows `lineEditSearch.x` and `lineEditSearch.width`. It moves out of
  `itemContent`, right after `barWindow` in `Gui.qml`, and its `y` sits under the search bar's bottom
  line, so that it has no gap with the search bar. `z: 1` is removed, so it stays under `AreaPanel`.

### 4. Delete `content/BarTop.qml`

`generate.sh` copies `content/*.qml`, so deleting it needs no edit there.

## Behavior changes

- The content area gains height: one 49 dp bar instead of two 33 dp bars.
- The search bar is narrower: the window buttons and the 32 dp gap now share its row. At the minimum
  window width with the update and message buttons both showing, it gets tight.
- The window drags from the gap and the strips above and below the row.
- Previous, next and the search buttons are push buttons, which use the arrow cursor rather than
  the pointing hand.
- Related and expand are swapped, with F2 for Related and F3 for expand.
- Double clicking the track item restores an expanded `PanelTracks` and otherwise plays the track,
  as the old tab did. The old tab's wall toggle is gone.

## Verification

Close any running MotionBox first: the app is single instance and test runs use `bin/storage`.

1. Search `content/` for `barTop` and `BarTop`: no matches.
2. From `content/`: `sh generate.sh win64 clean`, then `sh generate.sh win64 all`, which also clears
   the stale `bin/BarTop.qml`. Run with `QT_FORCE_STDERR_LOGGING=1` and check the log for QML errors.
3. Screenshots of the bar in each style, active and inactive, with and without Related.
4. Manual run:
   - Previous and next, search with its completion panel lined up with the box.
   - Browse, Related and expand, with F1, F2 and F3.
   - The track item: selecting the track, its menu, close, and the buttons showing on hover.
   - Double click on the track item: `PanelTracks` expanded, then stopped, paused, playing and with
     no track.
   - The rounded track item, the row borders and their color, and the separator.
   - Window drag and double click on the gap and on the strips above and below the row, then minimize,
     maximize and close.
   - Full screen: the bar hides, comes back at the top edge, and exits cleanly.
   - PanelAdd and PanelPreview positions under the bar.
5. Force `online.version` and `online.messageUrl` to check the update button, its Update step and the
   message button, including a long title at the minimum window width.
6. `sh generate.sh win64 deploy` succeeds, then regenerate the dev output.
