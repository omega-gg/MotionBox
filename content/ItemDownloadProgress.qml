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

Canvas
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int value: panelDownloads.progress // NOTE: In percent.

    property int size: st.dp2

    // NOTE: The same color as the icon.
    property color colorBar: (buttonDownloads.isHighlighted) ? st.icon2_colorA
                                                             : st.icon_colorA

    // NOTE: The light border keeps the bar visible in the light style.
    property color colorTrack: st.border_colorLight

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width : st.dp26
    height: st.dp26

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onValueChanged: requestPaint()

    onColorBarChanged  : requestPaint()
    onColorTrackChanged: requestPaint()

    onPaint:
    {
        var context = getContext("2d");

        var center = width / 2;

        var radius = center - size / 2;

        var start = -Math.PI / 2;

        context.reset();

        context.lineWidth = size;

        context.strokeStyle = colorTrack;

        context.beginPath();

        context.arc(center, center, radius, 0, Math.PI * 2);

        context.stroke();

        if (value == 0) return;

        context.strokeStyle = colorBar;

        context.beginPath();

        context.arc(center, center, radius, start, start + Math.PI * 2 * value / 100);

        context.stroke();
    }
}
