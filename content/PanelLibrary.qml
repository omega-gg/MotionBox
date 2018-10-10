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

Panel
{
    id: panelLibrary

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property int translate: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property int pValue: -1

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonAdd: buttonAdd

    property alias scrollLibrary: scrollLibrary

    property alias listLibrary: scrollLibrary.list

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width:
    {
        var size = Math.round(parent.width / 3);

        return Math.min(size, st.dp320 + borderRight);
    }

    height:
    {
        if (panelTracks.isExpanded == false)
        {
            var height = Math.max(panelPlayer.height, panelBrowse.y);

            return Math.min(height, panelCover.getY());
        }
        else return panelCover.getY();
    }

    borderLeft  : 0
    borderTop   : 0
    borderBottom: 0

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: gui.isExpanded

        AnchorChanges
        {
            target: panelLibrary

            anchors.right: parent.left
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_normal }

            ScriptAction
            {
                script:
                {
                    if (gui.isExpanded)
                    {
                        visible = false;
                    }
                    else restoreScroll();

                    panelPlayer.wallRestore();
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function saveScroll()
    {
        pValue = scrollLibrary.value;
    }

    function restoreScroll()
    {
        if (pValue != -1)
        {
            scrollLibrary.scrollTo(pValue);

            pValue = -1;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        ButtonPianoIcon
        {
            id: buttonAdd

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp32 + borderSizeWidth

            checkable: true
            checked  : scrollLibrary.isCreating

            icon          : st.icon24x24_addBold
            iconSourceSize: st.size24x24

            onPressed:
            {
                if (checked)
                {
                     scrollLibrary.clearItem();
                }
                else scrollLibrary.createItem(0);
            }
        }

        BarTitleText
        {
            id: libraryTitle

            anchors.left  : buttonAdd.right
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            text: qsTr("Library")
        }

        ButtonPianoFull
        {
            id: buttonPlaylist

            anchors.left  : buttonAdd.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: Math.round((parent.width - buttonAdd.width) / 3)

            visible: (opacity != 0.0)

            opacity: (scrollLibrary.isCreating) ? 1.0 : 0.0

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type == 0)

            checkHover: false

            icon: st.icon28x28_playlist
            text: qsTr("Playlist")

            onPressed: scrollLibrary.createItem(0)

            Behavior on opacity
            {
                PropertyAnimation { duration: st.duration_faster }
            }
        }

        ButtonPianoFull
        {
            id: buttonFeed

            anchors.left  : buttonPlaylist.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: buttonPlaylist.width

            visible: buttonPlaylist.visible
            opacity: buttonPlaylist.opacity

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type == 1)

            checkHover: false

            icon: st.icon28x28_feed
            text: qsTr("Feed")

            onPressed: scrollLibrary.createItem(1)
        }

        ButtonPianoFull
        {
            anchors.left  : buttonFeed.right
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            borderRight: 0

            visible: buttonPlaylist.visible
            opacity: buttonPlaylist.opacity

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type == 2)

            checkHover: false

            icon: st.icon28x28_folder
            text: qsTr("Folder")

            onPressed: scrollLibrary.createItem(2)
        }
    }

    ScrollFolderCreate
    {
        id: scrollLibrary

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        folder: library

        listFolder  : gui.listFolder
        listPlaylist: gui.listPlaylist

        itemRight: (listFolder.visible) ? listFolder
                                        : listPlaylist

        itemText.visible: false
    }

    ScrollerList
    {
        visible: scrollLibrary.dragAccepted

        opacity: (visible) ? bordersDrop.opacity : 1.0

        scrollArea: scrollLibrary
    }
}
