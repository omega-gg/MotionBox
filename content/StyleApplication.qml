//=================================================================================================
/*
    Copyright (C) 2015-2017 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick 1.0
import Sky     1.0

Style
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Global

    property int dp36: 36 * ratio
    property int dp37: 37 * ratio
    property int dp44: 44 * ratio
    property int dp50: 50 * ratio
    property int dp52: 52 * ratio
    property int dp92: 92 * ratio

    property int dp100: 100 * ratio
    property int dp108: 108 * ratio
    property int dp110: 110 * ratio
    property int dp160: 160 * ratio
    property int dp192: 192 * ratio

    property int dp220: 220 * ratio
    property int dp256: 256 * ratio
    property int dp258: 258 * ratio
    property int dp270: 270 * ratio

    property int dp320: 320 * ratio

    property int dp480: 480 * ratio

    property variant size56x32: size(56, 32)

    //---------------------------------------------------------------------------------------------

    property int minimumWidth : 800 * scale
    property int minimumHeight: 540 * scale

    property url logoApplication: "pictures/logo.svg"

    //---------------------------------------------------------------------------------------------
    // Splash

    property int splash_borderSize: dp8

    property color splash_colorA: (local.style == 2) ? "#646464" : logo_colorB
    property color splash_colorB: (local.style == 2) ? "#323232" : logo_colorA

    //---------------------------------------------------------------------------------------------
    // PanelRelated

    property int panelRelated_durationMinimum:  500
    property int panelRelated_durationMaximum: 2000

    //---------------------------------------------------------------------------------------------
    // PanelCover

    property int panelCover_intervalClear: ms1000

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
    // ScrollPlaylistCreate

    property int scrollPlaylistCreate_durationAdd: panelAdd_durationAdd

    //---------------------------------------------------------------------------------------------
    // SliderStream

    property int sliderStream_intervalA: 10000
    property int sliderStream_intervalB: 30000

    //---------------------------------------------------------------------------------------------
    // ComponentDiscover

    property int componentDiscover_height: dp48 + border_size

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

    property url icon_point: "pictures/icons/scale/point.svg"

    property url icon_mini: "pictures/icons/scale/mini.svg"
    property url icon_maxi: "pictures/icons/scale/maxi.svg"

    property url icon_goBackward: "pictures/icons/scale/goBackward.svg"
    property url icon_goForward : "pictures/icons/scale/goForward.svg"

    property url icon_expand : "pictures/icons/scale/expand.svg"
    property url icon_wall   : "pictures/icons/scale/wall.svg"
    property url icon_related: "pictures/icons/scale/related.svg"

    property url icon_goUp     : "pictures/icons/scale/goUp.svg"
    property url icon_goRelated: "pictures/icons/scale/goRelated.svg"

    property url icon_refresh: "pictures/icons/scale/refresh.svg"
    property url icon_abort  : "pictures/icons/scale/abort.svg"

    property url icon_addBold: "pictures/icons/scale/addBold.svg"
    property url icon_addList: "pictures/icons/scale/addList.svg"
    property url icon_addIn  : "pictures/icons/scale/addIn.svg"

    property url icon_search     : "pictures/icons/scale/search.svg"
    property url icon_searchSmall: "pictures/icons/scale/searchSmall.svg"

    property url icon_paste: "pictures/icons/scale/paste.svg"

    property url icon_tuning: "pictures/icons/scale/tuning.svg"
    property url icon_share : "pictures/icons/scale/share.svg"

    property url icon_playSmall: "pictures/icons/scale/playSmall.svg"

    property url icon_shuffle: "pictures/icons/scale/shuffle.svg"

    property url icon_repeat   : "pictures/icons/scale/repeat.svg"
    property url icon_repeatOne: "pictures/icons/scale/repeatOne.svg"

    property url icon_setting: "pictures/icons/scale/setting.svg"
    property url icon_about  : "pictures/icons/scale/about.svg"

    property url icon_url: "pictures/icons/scale/url.svg"

    property url icon_playlist: "pictures/icons/scale/playlist.svg"
    property url icon_folder  : "pictures/icons/scale/folder.svg"
    property url icon_feed    : "pictures/icons/scale/feed.svg"

    property url icon_track    : "pictures/icons/scale/track.svg"
    property url icon_trackWide: "pictures/icons/scale/trackWide.svg"

    property url icon_love: "pictures/icons/scale/love.svg"

    //---------------------------------------------------------------------------------------------
    // 42x32 and 36x28

    property url icon56x32_track: vector("pictures/icons/track.png",      icon_trackWide)
    property url icon50x28_track: vector("pictures/icons/trackSmall.png", icon_trackWide)

    //---------------------------------------------------------------------------------------------
    // 16x16

    property url icon16x16_point: vector("pictures/icons/16x16/point.png", icon_point)

    property url icon16x16_mini: vector("pictures/icons/16x16/mini.png", icon_mini)
    property url icon16x16_maxi: vector("pictures/icons/16x16/maxi.png", icon_maxi)

    property url icon16x16_searchSmall: vector("pictures/icons/16x16/searchSmall.png",
                                               icon_searchSmall)

    property url icon16x16_playSmall: vector("pictures/icons/16x16/playSmall.png", icon_playSmall)

    //---------------------------------------------------------------------------------------------
    // 24x24

    property url icon24x24_expand : vector("pictures/icons/24x24/expand.png",  icon_expand)
    property url icon24x24_wall   : vector("pictures/icons/24x24/wall.png",    icon_wall)
    property url icon24x24_related: vector("pictures/icons/24x24/related.png", icon_related)

    property url icon24x24_goUp     : vector("pictures/icons/24x24/goUp.png",      icon_goUp)
    property url icon24x24_goRelated: vector("pictures/icons/24x24/goRelated.png", icon_goRelated)

    property url icon24x24_refresh: vector("pictures/icons/24x24/refresh.png", icon_refresh)
    property url icon24x24_abort  : vector("pictures/icons/24x24/abort.png",   icon_abort)

    property url icon24x24_addBold: vector("pictures/icons/24x24/addBold.png", icon_addBold)
    property url icon24x24_addIn  : vector("pictures/icons/24x24/addIn.png",   icon_addIn)

    property url icon24x24_tuning: vector("pictures/icons/24x24/tuning.png", icon_tuning)
    property url icon24x24_share : vector("pictures/icons/24x24/share.png",  icon_share)

    property url icon24x24_shuffle: vector("pictures/icons/24x24/shuffle.png", icon_shuffle)

    property url icon24x24_repeat   : vector("pictures/icons/24x24/repeat.png",    icon_repeat)
    property url icon24x24_repeatOne: vector("pictures/icons/24x24/repeatOne.png", icon_repeatOne)

    property url icon24x24_love: vector("pictures/icons/24x24/love.png", icon_love)

    //---------------------------------------------------------------------------------------------
    // 28x28

    property url icon28x28_playlist: vector("pictures/icons/28x28/playlist.png", icon_playlist)
    property url icon28x28_folder  : vector("pictures/icons/28x28/folder.png",   icon_folder)
    property url icon28x28_feed    : vector("pictures/icons/28x28/feed.png",     icon_feed)

    property url icon28x28_url: vector("pictures/icons/28x28/url.png", icon_url)

    //---------------------------------------------------------------------------------------------
    // 32x32

    property url icon32x32_goBackward: vector("pictures/icons/32x32/goBackward.png",
                                              icon_goBackward)

    property url icon32x32_goForward: vector("pictures/icons/32x32/goForward.png",
                                             icon_goForward)

    property url icon32x32_addList: vector("pictures/icons/32x32/addList.png", icon_addList)

    property url icon32x32_search: vector("pictures/icons/32x32/search.png", icon_search)

    property url icon32x32_paste: vector("pictures/icons/32x32/paste.png", icon_paste)

    property url icon32x32_setting: vector("pictures/icons/32x32/setting.png", icon_setting)
    property url icon32x32_about  : vector("pictures/icons/32x32/about.png",   icon_about)

    property url icon32x32_url: vector("pictures/icons/32x32/url.png", icon_url)

    property url icon32x32_playlist: vector("pictures/icons/32x32/playlist.png", icon_playlist)
    property url icon32x32_folder  : vector("pictures/icons/32x32/folder.png",   icon_folder)
    property url icon32x32_feed    : vector("pictures/icons/32x32/feed.png",     icon_feed)

    property url icon32x32_track: vector("pictures/icons/32x32/track.png", icon_track)

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------
    // Global

    // FIXME: Workaround for the rounding issue.
    scale: local.scale.toFixed(3)

    zoom: window.zoom

    ratio: scale * zoom * window.ratio

    icon: "pictures/icons/icon.svg"

    logo: (local.style) ? "pictures/logoBackgroundB.svg"
                        : "pictures/logoBackgroundA.svg"

    logo_colorA: (local.style) ? "#404040"
                               : "#c8c8c8"

    //---------------------------------------------------------------------------------------------
    // Border

    border_size: (local.style == 2) ? st.dp2
                                    : st.dp1

    border_sizeFocus: st.dp2

    border_color: (local.style) ? "#161616"
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
        else if (index == 1)
        {
            applyNight();
        }
        else // if (index == 2)
        {
            applyClassic();
        }
    }
}
