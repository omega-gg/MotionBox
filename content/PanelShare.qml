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

Panel
{
    id: panelShare

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.right: parent.right
    anchors.top  : parent.bottom

    anchors.rightMargin: (gui.isMini) ? -st.dp2 : st.dp52

    width: buttonWebpage.x + buttonWebpage.width + st.dp7 + borderRight

    height: st.dp78 + borderSizeHeight

    borderBottom: 0

    visible: false

    backgroundOpacity: (gui.isExpanded) ? st.panelContextual_backgroundOpacity : 1.0

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

        AnchorChanges
        {
            target: panelShare

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_faster }

            ScriptAction
            {
                script:
                {
                    if (isExposed == false) visible = false;

                    z = 0;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            collapse();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        gui.restoreMicro();

        if (isExposed || actionCue.tryPush(gui.actionShareExpose)) return;

        gui.panelAddHide();

        panelSettings.collapse();

        isExposed = true;

        z = 1;

        panelSettings.z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionShareCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitleSmall
    {
        id: barShare

        width: lineEdit.x + lineEdit.width + st.dp6

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter

            text: qsTr("Share Track")

            font.pixelSize: st.dp12
        }
    }

    BorderVertical
    {
        id: border

        anchors.left: barShare.right
    }

    BarTitleSmall
    {
        id: barGoto

        anchors.left : border.right
        anchors.right: parent.right

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            leftMargin: st.dp8

            verticalAlignment: Text.AlignVCenter

            text: qsTr("Go to")

            font.pixelSize: st.dp12
        }
    }

    ButtonPianoIcon
    {
        anchors.right: parent.right

        width : st.barTitleSmall_height + borderSizeWidth
        height: st.barTitleSmall_height

        borderLeft : borderSize
        borderRight: 0

        icon          : st.icon16x16_close
        iconSourceSize: st.size16x16

        onClicked: collapse()
    }

    Item
    {
        anchors.left : parent.left
        anchors.right: parent.right

        anchors.top   : barShare.bottom
        anchors.bottom: parent.bottom

        Image
        {
            id: image

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: parent.height

            sourceSize: Qt.size(width, height)

            visible: false
        }

        BorderVertical
        {
            id: borderImage

            anchors.left: image.right

            visible: image.visible
        }

        LineEditCopy
        {
            id: lineEdit

            anchors.left: (borderImage.visible) ? borderImage.right
                                                : parent.left

            anchors.leftMargin: st.dp6

            anchors.verticalCenter: parent.verticalCenter

            width: st.dp180

            text: controllerFile.filePath(currentTab.source)

            textDefault: qsTr("No track selected")

            onTextChanged:
            {
                var backend = controllerPlaylist.backendFromUrl(text);

                if (backend == null)
                {
                    image.visible = false;

                    return;
                }

                image.source = "pictures/icons/hub/" + backend.id + ".png"

                image.visible = true;
            }
        }

        ButtonPushFull
        {
            id: buttonWebpage

            anchors.left: lineEdit.right

            anchors.leftMargin: st.dp13

            anchors.verticalCenter: parent.verticalCenter

            enabled: (currentTab.source != "")

            icon          : st.icon16x16_external
            iconSourceSize: st.size16x16

            text: gui.getOpenTitle(currentTab.source)

            onClicked: gui.openSource(currentTab.source)
        }
    }
}
