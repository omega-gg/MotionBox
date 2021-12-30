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

ScrollArea
{
    id: scrollFolder

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property string textDefault: qsTr("Empty Folder")

    //---------------------------------------------------------------------------------------------
    // Private

    property int pSelectedY: -1

    property bool pAtBottom: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias hasFolder: list.hasFolder

    property alias folder: list.folder

    property alias model   : list.model
    property alias delegate: list.delegate

    property alias listFolder  : list.listFolder
    property alias listPlaylist: list.listPlaylist

    /* read */ property alias count: list.count

//#QT_4
    /* read */ property alias indexContextual: list.indexContextual
//#END

    property alias enableLoad      : list.enableLoad
    property alias enablePreview   : list.enablePreview
    property alias enablePlay      : list.enablePlay
    property alias enableContextual: list.enableContextual
    property alias enableAdd       : list.enableAdd
    property alias enableDrag      : list.enableDrag
    property alias enableDragMove  : list.enableDragMove

    property alias textVisible: itemText.visible

    property alias itemLeft  : list.itemLeft
    property alias itemRight : list.itemRight
    property alias itemTop   : list.itemTop
    property alias itemBottom: list.itemBottom

    //---------------------------------------------------------------------------------------------

    property alias list    : list
    property alias itemText: itemText

    property alias buttonContextual: list.buttonContextual

    property alias itemWatcher: list.itemWatcher

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    contentHeight: (labelLoading.visible) ? list.height + labelLoading.height + st.dp16
                                          : list.height

    singleStep     : list.itemSize
    wheelMultiplier: 1

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function focus()
    {
        list.focus();
    }

    //---------------------------------------------------------------------------------------------

    function updateView()
    {
        updateListHeight(list);

        if (list.itemHovered)
        {
            window.updateHover();
        }

        timer.restart();
    }

    //---------------------------------------------------------------------------------------------

    function updateCurrentY()
    {
        pSelectedY = currentItemY();

        if (atTop) pAtBottom = false;
        else       pAtBottom = atBottom;
    }

    function updateVisible()
    {
        if (pSelectedY != -1)
        {
            ensureVisible(list.y + pSelectedY, list.itemSize);
        }
        else if (pAtBottom)
        {
            scrollToBottom();
        }
    }

    //---------------------------------------------------------------------------------------------

    function currentItemY()
    {
        var y = list.currentItemY();

        if (y != -1 && checkVisible(0, list.y + y))
        {
             return y;
        }
        else return -1;
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onRangeUpdated()
    {
        if (st.animate) updateVisible();

        updateView();
    }

    function onValueUpdated()
    {
        updateView();
    }

    function onWheelUpdated()
    {
        if (list.indexContextual != -1)
        {
            window.clearContextual();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_faster

        onTriggered: updateCurrentY()
    }

    ListFolder
    {
        id: list

        anchors.left : parent.left
        anchors.right: parent.right

        scrollArea: scrollFolder
    }

    TextListDefault
    {
        id: itemText

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : list.bottom

        anchors.topMargin: st.dp20

        horizontalAlignment: Text.AlignHCenter

        visible: (count == 0 && folder != null && folder.queryIsLoading == false)

        text: textDefault
    }

    LabelLoadingButton
    {
        id: labelLoading

        anchors.top: list.bottom

        anchors.topMargin: st.dp8

        anchors.horizontalCenter: parent.horizontalCenter

        visible: (folder != null && folder.queryIsLoading)

        text: qsTr("Loading...")

        onClicked: folder.abortQuery()
    }
}
