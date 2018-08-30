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

MouseArea
{
    id: panelDiscover

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pLoaded: false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left  : parent.left
    anchors.right : parent.right
    anchors.bottom: parent.top

    height: parent.height

    visible: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "visible"; when: isExposed

            AnchorChanges
            {
                target: panelDiscover

                anchors.top   : parent.top
                anchors.bottom: undefined
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_fast }

            ScriptAction
            {
                script:
                {
                    if (isExposed == false) visible = false;

                    clip = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed) return;

        gui.restoreMicro();

        panelApplication.collapse();

        if (pLoaded == false) pLoad();

        visible = true;

        clip = true;

        isExposed = true;

        scrollBackends.focus();
    }

    function collapse()
    {
        if (isExposed == false) return;

        clip = true;

        isExposed = false;

        window.clearFocusItem(scrollBackends);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pLoad()
    {
        pLoaded = true;

        page.addItem(ContextualPage.Item, 0, qsTr("Youtube"),
                     controllerPlaylist.backendCoverFromId("youtube"), st.size48x48);

        page.addItem(ContextualPage.Item, 1, qsTr("Dailymotion"),
                     controllerPlaylist.backendCoverFromId("dailymotion"), st.size48x48);

        page.addItem(ContextualPage.Item, 2, qsTr("Vimeo"),
                     controllerPlaylist.backendCoverFromId("vimeo"), st.size48x48);

        page.addItem(ContextualPage.Item, 3, qsTr("SoundCloud"),
                     controllerPlaylist.backendCoverFromId("soundcloud"), st.size48x48);

        scrollBackends.currentPage = page;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ContextualPage { id: page }

    Rectangle
    {
        id: background

        anchors.left : parent.left
        anchors.right: parent.right

        height: parent.height - border.size

        y: -(parent.y)

        opacity: 0.8

        color: "#242424"
    }

    ScrollContextual
    {
        id: scrollBackends

        anchors.top   : background.top
        anchors.bottom: background.bottom

        width: panelLibrary.width - borderBackends.size

        delegate: ComponentDiscover {}

        list.itemSize: st.componentDiscover_height
    }

    BorderVertical
    {
        id: borderBackends

        anchors.left  : scrollBackends.right
        anchors.top   : undefined
        anchors.bottom: undefined

        height: Math.min(scrollBackends.contentHeight, scrollBackends.height)
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom

        size: st.dp8

        color: st.border_colorFocus
    }
}
