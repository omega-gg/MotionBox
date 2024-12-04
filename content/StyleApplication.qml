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

    property url icon_qt    : "pictures/icons/qt.png"
    property url icon_qtGray: "pictures/icons/qtGray.png"

    property url icon_vlc    : "pictures/icons/vlc.png"
    property url icon_vlcGray: "pictures/icons/vlcGray.png"

    property url icon_sky    : "pictures/icons/sky.png"
    property url icon_skyGray: "pictures/icons/skyGray.png"

    property url icon_w: "pictures/icons/w.svg"

    //---------------------------------------------------------------------------------------------

    property url icon_download: "pictures/icons/download.svg"

    property url icon_goBackward: "pictures/icons/arrow-left.svg"
    property url icon_goForward : "pictures/icons/arrow-right.svg"

    property url icon_goRelated: "pictures/icons/arrow-right.svg"

    property url icon_expand : "pictures/icons/expand-alt.svg"
    property url icon_wall   : "pictures/icons/expand.svg"
    property url icon_related: "pictures/icons/bars.svg"

    property url icon_refresh: "pictures/icons/redo.svg"

    property url icon_addBold: "pictures/icons/plus.svg"
    property url icon_addList: "pictures/icons/plus-circle.svg"
    property url icon_addIn  : "pictures/icons/plus-circle.svg"

    property url icon_search: "pictures/icons/search.svg"

    property url icon_tag: "pictures/icons/qrcode.svg"

    property url icon_subtitles: "pictures/icons/quote-right.svg"
    property url icon_settings : "pictures/icons/cog.svg"
    property url icon_output   : "pictures/icons/chromecast.svg"

    property url icon_history: "pictures/icons/history.svg"
    property url icon_suggest: "pictures/icons/lightbulb.svg"
    property url icon_recent : "pictures/icons/clock.svg"
    property url icon_hub    : "pictures/icons/circle-nodes.svg"

    property url icon_shuffle: "pictures/icons/random.svg"

    property url icon_repeat   : "pictures/icons/redo.svg"
    property url icon_repeatOne: "pictures/icons/redo.svg"

    property url icon_setting: "pictures/icons/cog.svg"
    property url icon_about  : "pictures/icons/info-circle.svg"

    property url icon_url   : "pictures/icons/globe-americas.svg"
    property url icon_link  : "pictures/icons/link.svg"
    property url icon_unlink: "pictures/icons/link-slash.svg"

    property url icon_playlist: "pictures/icons/tv.svg"
    property url icon_folder  : "pictures/icons/folder.svg"
    property url icon_feed    : "pictures/icons/rss.svg"

    property url icon_track: "pictures/icons/video.svg"

    property url icon_list: "pictures/icons/list.svg"

    property url icon_shutdown: "pictures/icons/power-off.svg"

    property url icon_tevolution: "pictures/icons/tevolution.svg"

    property url icon_love: "pictures/icons/heart.svg"

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
    // Settings
    //---------------------------------------------------------------------------------------------
    // Global

    // FIXME: Workaround for the rounding issue.
    scale: local.scale.toFixed(3)

    zoom: window.zoom

    icon: "pictures/icons/icon.svg"

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
        }
        else // if (index == 3)
        {
            applyClassic();
        }
    }
}
