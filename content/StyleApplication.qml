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

StyleComponents
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Global

    property int minimumWidth : dp800
    property int minimumHeight: dp540

    property url logoApplication: "pictures/logo.svg"

    //---------------------------------------------------------------------------------------------
    // Splash

    property int splash_borderSize: dp8

    property color splash_colorA: (local.style == 3) ? "#646464" : logo_colorB
    property color splash_colorB: (local.style == 3) ? "#323232" : logo_colorA

    //---------------------------------------------------------------------------------------------
    // PanelRelated

    property int panelRelated_duration: 2000

    //---------------------------------------------------------------------------------------------
    // PanelCover

    //property int panelCover_intervalClear: ms1000

    //---------------------------------------------------------------------------------------------
    // PanelTag

    property color panelTag_color: "#242424"

    //---------------------------------------------------------------------------------------------
    // PanelAdd

    property int panelAdd_durationCollapse: 1000
    property int panelAdd_durationAdd     : 1400

    //---------------------------------------------------------------------------------------------
    // LineEditSearch

    property int lineEditSearch_maximumLength: 10000

    //---------------------------------------------------------------------------------------------
    // ScrollFolderCreate

    property int scrollFolderCreate_durationSelect: 1000
    property int scrollFolderCreate_durationAdd   : panelAdd_durationAdd

    //---------------------------------------------------------------------------------------------
    // ScrollPlaylist

    property int scrollPlaylist_intervalLoad  :   200
    property int scrollPlaylist_intervalReload: 60000 // 1 minute

    //---------------------------------------------------------------------------------------------
    // ScrollPlaylistCreate

    property int scrollPlaylistCreate_durationAdd: panelAdd_durationAdd

    //---------------------------------------------------------------------------------------------
    // SliderStream

    property int sliderStream_intervalA: wallVideo_interval
    property int sliderStream_intervalB: 30000

    //---------------------------------------------------------------------------------------------
    // ComponentDiscover

    //property int componentDiscover_height: dp48 + border_size

    //---------------------------------------------------------------------------------------------
    // PageOutput

    property int pageOutput_interval: 10000 // 10 seconds

    //---------------------------------------------------------------------------------------------
    // Icons

    property url icon_qt    : "icons/qt.png"
    property url icon_qtGray: "icons/qtGray.png"

    property url icon_vlc    : "icons/vlc.png"
    property url icon_vlcGray: "icons/vlcGray.png"

    property url icon_sky    : "icons/sky.png"
    property url icon_skyGray: "icons/skyGray.png"

    property url icon_w: "icons/w.svg"

    //---------------------------------------------------------------------------------------------

    property url icon_download: "icons/download.svg"

    property url icon_goBackward: "icons/arrow-left.svg"
    property url icon_goForward : "icons/arrow-right.svg"

    property url icon_goRelated: "icons/arrow-right.svg"

    property url icon_expand : "icons/expand-alt.svg"
    property url icon_wall   : "icons/expand.svg"
    property url icon_related: "icons/bars.svg"

    property url icon_refresh: "icons/redo.svg"

    property url icon_addBold: "icons/plus.svg"
    property url icon_addList: "icons/plus-circle.svg"
    property url icon_addIn  : "icons/plus-circle.svg"

    property url icon_search: "icons/search.svg"

    property url icon_tag: "icons/qrcode.svg"

    property url icon_subtitles: "icons/quote-right.svg"
    property url icon_settings : "icons/cog.svg"
    property url icon_output   : "icons/chromecast.svg"

    property url icon_history: "icons/history.svg"
    property url icon_suggest: "icons/lightbulb.svg"
    property url icon_recent : "icons/clock.svg"
    property url icon_hub    : "icons/circle-nodes.svg"

    property url icon_shuffle: "icons/random.svg"

    property url icon_repeat   : "icons/redo.svg"
    property url icon_repeatOne: "icons/redo.svg"

    property url icon_setting: "icons/cog.svg"
    property url icon_about  : "icons/info-circle.svg"

    property url icon_url   : "icons/globe-americas.svg"
    property url icon_link  : "icons/link.svg"
    property url icon_unlink: "icons/link-slash.svg"

    property url icon_rotate: "icons/camera-rotate.svg"

    property url icon_pen: "icons/pen.svg"

    property url icon_palette: "icons/palette.svg"

    property url icon_playlist: "icons/tv.svg"
    property url icon_folder  : "icons/folder.svg"
    property url icon_feed    : "icons/rss.svg"

    property url icon_track: "icons/video.svg"

    property url icon_list: "icons/list.svg"

    property url icon_shutdown: "icons/power-off.svg"

    property url icon_tevolution: "icons/tevolution.svg"

    property url icon_love: "icons/heart.svg"

    //---------------------------------------------------------------------------------------------
    // 16x16

    property url icon16x16_download: icon_download

    property url icon16x16_goBackward: icon_goBackward
    property url icon16x16_goForward : icon_goForward

    property url icon16x16_goRelated: icon_goRelated

    property url icon16x16_refresh: icon_refresh

    property url icon16x16_addBold: icon_addBold

    property url icon16x16_tag: icon_tag

    property url icon16x16_history: icon_history
    property url icon16x16_suggest: icon_suggest
    property url icon16x16_recent : icon_recent
    property url icon16x16_hub    : icon_hub

    property url icon16x16_shuffle: icon_shuffle

    property url icon16x16_repeat   : icon_repeat
    property url icon16x16_repeatOne: icon_repeatOne

    property url icon16x16_link  : icon_link
    property url icon16x16_unlink: icon_unlink

    property url icon16x16_rotate: icon_rotate

    property url icon16x16_pen: icon_pen

    property url icon16x16_palette: icon_palette

    property url icon16x16_playlist: icon_playlist
    property url icon16x16_folder  : icon_folder
    property url icon16x16_feed    : icon_feed

    property url icon16x16_track: icon_track

    property url icon16x16_list: icon_list

    property url icon16x16_shutdown: icon_shutdown

    //---------------------------------------------------------------------------------------------
    // 18x18

    property url icon18x18_addIn: icon_addIn

    //---------------------------------------------------------------------------------------------
    // 20x20

    property url icon20x20_expand : icon_expand
    property url icon20x20_wall   : icon_wall
    property url icon20x20_related: icon_related

    property url icon20x20_addList: icon_addList

    property url icon20x20_search: icon_search

    property url icon20x20_subtitles: icon_subtitles
    property url icon20x20_settings : icon_settings

    property url icon20x20_setting: icon_setting
    property url icon20x20_about  : icon_about

    property url icon20x20_url: icon_url

    property url icon20x20_love: icon_love

    //---------------------------------------------------------------------------------------------
    // 24x24

    property url icon24x24_output: icon_output

    //---------------------------------------------------------------------------------------------
    // Pictures

    property url picture_camera: "pictures/camera.svg"

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------
    // Global

    // FIXME: Workaround for the rounding issue.
    scale: local.scale.toFixed(3)

    zoom: window.zoom

    icon: "icons/icon.svg"

    logo: (local.style) ? "pictures/logoBackgroundB.svg"
                        : "pictures/logoBackgroundA.svg"

    logo_colorA: (local.style) ? "#404040"
                               : "#c8c8c8"

    //---------------------------------------------------------------------------------------------
    // Border

    // NOTE: We want to make sure we always have a visible border.
    border_size: (local.style < 2) ? Math.max(st.dp1, 1)
                                   : st.dp2

    border_sizeFocus: st.dp2

    border_color: (local.style) ? "#242424"
                                : "#969696"

    //---------------------------------------------------------------------------------------------
    // Animation

    animate: false

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function applyStyle(index)
    {
        if (index == 0)
        {
            applyLight();
        }
        else if (index == 1 || index == 2)
        {
            applyNight();

            // NOTE: We need a darker background to contrast with the player default background.
            window_color = "#323232";
        }
        else // if (index == 3)
        {
            applyClassic();
        }
    }
}
