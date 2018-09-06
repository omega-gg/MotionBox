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

ContextualItem
{
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: st.componentDiscover_height

    filter: null

    background.visible: true

    background.gradient: Gradient
    {
        GradientStop
        {
            position: 0.0

            color:
            {
                if (isCurrent)
                {
                    if (pressed || isReturnPressed)
                    {
                        return st.itemList_colorSelectFocusA;
                    }
                    else if (containsMouse)
                    {
                        return st.itemList_colorSelectHoverA;
                    }
                    else return st.itemList_colorSelectA;
                }
                else if (pressed)
                {
                    return st.itemList_colorSelectFocusA;
                }
                else if (containsMouse)
                {
                    return st.itemList_colorHoverA;
                }
                else return st.itemList_colorA;
            }
        }

        GradientStop
        {
            position: 1.0

            color:
            {
                if (isCurrent)
                {
                    if (pressed || isReturnPressed)
                    {
                        return st.itemList_colorSelectFocusB;
                    }
                    else if (containsMouse)
                    {
                        return st.itemList_colorSelectHoverB;
                    }
                    else return st.itemList_colorSelectB;
                }
                else if (pressed)
                {
                    return st.itemList_colorSelectFocusB;
                }
                else if (containsMouse)
                {
                    return st.itemList_colorHoverB;
                }
                else return st.itemList_colorB;
            }
        }
    }

    itemText.leftMargin: (itemIcon.width) ? st.contextualItem_padding + pIconWidth
                                          : st.contextualItem_padding

    itemText.font.pixelSize: st.dp16

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Icon
    {
        anchors.right: parent.right

        anchors.verticalCenter: background.verticalCenter

        opacity: (isEnabled) ? 1.0 : st.icon_opacityDisable

        source    : st.icon_slideRight
        sourceSize: st.size32x32

        style: st.icon_sunken

        filter: st.icon_filter
    }
}
