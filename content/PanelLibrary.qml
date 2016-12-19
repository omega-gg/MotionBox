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

    property alias buttonsUpdater: buttonsUpdater

    property alias buttonPlaylist: buttonPlaylist
    property alias buttonFolder  : buttonFolder
    property alias buttonBrowse  : buttonBrowse

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

    shadowOpacity: (gui.isExpanded == false && wall.isExposed)

    color: st.panelFolder_color

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

        BarTitleText
        {
            id: libraryTitle

            anchors.fill: parent

            text: qsTr("Library")
        }

        ButtonsUpdater
        {
            id: buttonsUpdater

            anchors.fill: parent

            buttonVersion.width: Math.max(buttonBrowse.width + buttonFolder.borderRight,
                                          buttonVersion.getPreferredWidth())

            ButtonPianoFull
            {
                anchors.right: parent.buttonVersion.left

                anchors.top   : parent.top
                anchors.bottom: parent.bottom

                maximumWidth: bar.width - parent.buttonVersion.width
                              -
                              sk.textWidth(libraryTitle.font, libraryTitle.text) - st.dp16

                borderLeft : borderSize
                borderRight: 0

                spacing: st.dp2

                visible: (opacity != 0.0)

                opacity: (online.messageUrl != "")

                icon: online.messageIcon

                iconDefault   : st.icon24x24_love
                iconSourceSize: st.size24x24

                enableFilter: isIconDefault

                text: online.messageTitle

                onClicked: panelApplication.setAboutPage("PageAboutMessage.qml")

                Behavior on opacity
                {
                    PropertyAnimation { duration: st.duration_normal }
                }
            }
        }
    }

    ButtonPianoFull
    {
        id: buttonPlaylist

        anchors.top: bar.bottom

        width: Math.round(parent.width / 3)

        height: st.dp32 + borderSizeHeight

        borderBottom: borderSize

        enabled: (library.isFull == false)

        checkable: true
        checked  : (scrollLibrary.createType == 0)

        dropEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        icon: (local.typePlaylist) ? st.icon32x32_feed
                                   : st.icon32x32_playlist

        text: (local.typePlaylist) ? qsTr("Feed")
                                   : qsTr("Playlist")

        onPressed:
        {
            if (mouse.button & Qt.RightButton)
            {
                return;
            }
            else if (checked == false)
            {
                 scrollLibrary.createItem(0);
            }
            else scrollLibrary.clearItem();
        }

        onClicked:
        {
            if (mouse.button & Qt.RightButton)
            {
                scrollLibrary.switchType();
            }
        }

        onDragEntered:
        {
            if (library.isFull) return;

            if (gui.drag == 0)
            {
                event.accepted = true;

                bordersDrop.setItem(buttonPlaylist);
            }
            else if (gui.drag == -1)
            {
                var backend = controllerPlaylist.backendFromTrack(event.text);

                if (backend == null) return;

                event.accepted = true;

                bordersDrop.setItem(buttonPlaylist);

                toolTip.show(qsTr("Add Track"), st.icon32x32_addList, 32, 32);
            }
        }

        onDragExited: bordersDrop.clearItem(buttonPlaylist)

        onDrop:
        {
            scrollLibrary.createItem(0);

            if (gui.drag == 0)
            {
                 scrollLibrary.setAddTracks(gui.dragItem, gui.dragData);
            }
            else scrollLibrary.setAddTrackSource(event.text);
        }
    }

    ButtonPianoFull
    {
        id: buttonFolder

        anchors.left  : buttonPlaylist.right
        anchors.top   : buttonPlaylist.top
        anchors.bottom: buttonPlaylist.bottom

        width: buttonPlaylist.width

        borderBottom: borderSize

        enabled: (library.isFull == false)

        checkable: true
        checked  : (scrollLibrary.createType == 1)

        dropEnabled: true

        icon: st.icon32x32_folder
        text: qsTr("Folder")

        onPressed:
        {
            if (checked == false)
            {
                 scrollLibrary.createItem(1);
            }
            else scrollLibrary.clearItem();
        }

        onDragEntered:
        {
            if (library.isFull) return;

            if (gui.drag == 1)
            {
                if (gui.dragType != LibraryItem.PlaylistNet
                    &&
                    gui.dragType != LibraryItem.PlaylistFeed) return;

                event.accepted = true;

                if (event.actions & Qt.MoveAction)
                {
                    event.action = Qt.MoveAction;
                }

                bordersDrop.setItem(buttonFolder);
            }
            else if (gui.drag == -1)
            {
                var url = event.text;

                var backend = controllerPlaylist.backendFromPlaylist(url);

                if (backend == null) return;

                event.accepted = true;

                bordersDrop.setItem(buttonFolder);

                var type = core.getPlaylistType(backend, url);

                if (type == LibraryItem.PlaylistFeed)
                {
                     toolTip.show(qsTr("Add Feed"), st.icon32x32_addList, 32, 32);
                }
                else toolTip.show(qsTr("Add Playlist"), st.icon32x32_addList, 32, 32);
            }
        }

        onDragExited: bordersDrop.clearItem(buttonFolder)

        onDrop:
        {
            scrollLibrary.createItem(1);

            if (gui.drag == 1)
            {
                 scrollLibrary.setAddItem(event.action, gui.dragItem, gui.dragId);
            }
            else scrollLibrary.setAddItemSource(event.action, gui.dragType, event.text);
        }
    }

    ButtonPianoFull
    {
        id: buttonBrowse

        anchors.left  : buttonFolder.right
        anchors.right : parent.right
        anchors.top   : buttonFolder.top
        anchors.bottom: buttonFolder.bottom

        borderRight : 0
        borderBottom: borderSize

        checkable: true
        checked  : panelBrowse.isExposed

        icon: st.icon32x32_search
        text: qsTr("Browse")

        onPressed: panelBrowse.toggleExpose()
    }

    ScrollFolderCreate
    {
        id: scrollLibrary

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : buttonPlaylist.bottom
        anchors.bottom: parent.bottom

        folder: library

        listPlaylist: gui.listPlaylist
        listFolder  : gui.listFolder

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
