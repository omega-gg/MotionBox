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

ItemList
{
    id: componentDownload

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    iconWidth: st.dp56

    iconDefaultSize: st.size16x16

    icon: cover

    iconDefault: st.icon16x16_track

    iconFillMode: SkyImage.PreserveAspectCrop

    iconAsynchronous: true

    text: title

    textMargin: label.width + st.dp16 + ((buttonClose.visible) ? buttonClose.width : 0)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onDoubleClicked: if (source != "") panelDownloads.play(source)

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pGetText()
    {
        if (failed) return qsTr("Failed");

        var text = panelDownloads.getSize(received);

        if (running == false) return text;

        if (total > 0) text += " / " + panelDownloads.getSize(total);

        if (speed > 0) return panelDownloads.getSize(speed) + "/s, " + text;

        return text;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BarProgress
    {
        anchors.left  : parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: itemIcon.width

        width: (parent.width - itemIcon.width) * progress / 100

        height: st.border_size

        visible: running

        // NOTE: The default color would not show on a selected track.
        colorA: (isSelected) ? st.itemList_colorTextSelected
                             : st.barProgress_colorA

        colorB: (isSelected) ? st.itemList_colorTextSelected
                             : st.barProgress_colorB
    }

    TextBase
    {
        id: label

        anchors.right: (buttonClose.visible) ? buttonClose.left
                                             : parent.right

        anchors.rightMargin: st.dp8

        anchors.verticalCenter: parent.verticalCenter

        text: pGetText()

        color: itemText.color

        style: itemText.style
    }

    ButtonPushIcon
    {
        id: buttonClose

        anchors.right: parent.right

        anchors.rightMargin: st.dp5

        anchors.verticalCenter: parent.verticalCenter

        width : st.buttonsItem_buttonSize
        height: st.buttonsItem_buttonSize

        visible: componentDownload.isHovered

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

        cursor: Qt.PointingHandCursor

        colorHoverA: st.button_colorConfirmHoverA
        colorHoverB: st.button_colorConfirmHoverB

        colorPressA: st.button_colorConfirmPressA
        colorPressB: st.button_colorConfirmPressB

        filterIcon: (isHovered || isPressed) ? st.button_filterIconB
                                             : st.button_filterIconA

        onClicked: panelDownloads.remove(index)
    }
}
