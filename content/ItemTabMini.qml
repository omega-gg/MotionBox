//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

ItemTab
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property bool isHighlighted: (tab == highlightedTab)

    property bool isContextualHovered: (containsMouse && buttonsItem.checked)

    property TabTrack tab: null

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    iconWidth: st.componentTabBrowser_iconWidth

    borderLeft: (lineEditSearch.isFocused) ? st.dp2 : 0

    isHovered: (containsMouse || buttonsItem.checked)

    isCurrent: (tab == currentTab)

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    icon       : tab.cover
    iconDefault: itemTabs.iconDefault

    text: gui.getTabTitle(tab.title, tab.state, tab.source)

    iconFillMode: Image.PreserveAspectCrop

    textColor: st.text1_color

    textStyle: (isCurrent) ? Text.Raised
                           : Text.Sunken

    iconStyle: (isCurrent) ? Sk.IconRaised
                           : Sk.IconSunken

    textStyleColor: (isCurrent) ? st.text1_colorShadow
                                : st.text1_colorSunken

    filterIcon      : st.icon1_filter
    filterIconShadow: st.icon1_filterShadow

    background.gradient: Gradient
    {
        GradientStop
        {
            position: 0.0

            color:
            {
                if (isHighlighted)
                {
                    if      (isContextualHovered) return st.itemTab_colorHighlightContextualA;
                    else if (isHovered)           return st.itemTab_colorHighlightHoverA;
                    else                          return st.itemTab_colorHighlightA;
                }
                else if (isCurrent)           return colorSelectA;
                else if (isContextualHovered) return st.itemTab_colorContextualHoverA;
                else if (isHovered)           return colorHoverA;
                else                          return colorA;
            }
        }

        GradientStop
        {
            position: 1.0

            color:
            {
                if (isHighlighted)
                {
                    if      (isContextualHovered) return st.itemTab_colorHighlightContextualB;
                    else if (isHovered)           return st.itemTab_colorHighlightHoverB;
                    else                          return st.itemTab_colorHighlightB;
                }
                else if (isCurrent)           return colorSelectB;
                else if (isContextualHovered) return st.itemTab_colorContextualHoverB;
                else if (isHovered)           return colorHoverB;
                else                          return colorB;
            }
        }
    }
}
