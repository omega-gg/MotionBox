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

Panel
{
    id: panelLibrary

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int index: local.libraryIndex

    //---------------------------------------------------------------------------------------------
    // Private

    property int pIndex: -1
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

    height: (panelTracks.isExpanded) ? parent.height
                                     : Math.max(panelPlayer.height, panelBrowse.y)

    /*height:
    {
        if (panelTracks.isExpanded == false)
        {
            var height = Math.max(panelPlayer.height, panelBrowse.y);

            return Math.min(height, panelCover.getY());
        }
        else return panelCover.getY();
    }*/

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
            AnchorAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }

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

    function select(index)
    {
        if (panelLibrary.index == index) return;

        itemWipe.init();

        if (panelLibrary.index < index)
        {
            panelLibrary.index = index;

            itemWipe.startLeft();
        }
        else
        {
            panelLibrary.index = index;

            itemWipe.startRight();
        }

        local.libraryIndex = index;
    }

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
    // Private

    function pCreate()
    {
        if (buttonAdd.checked == false)
        {
            pIndex = index;

            if (index == 0)
            {
                select(1);
            }
            else scrollLibrary.createItem(0);
        }
        else scrollLibrary.clearItem();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#QT_4
    Timer
    {
        id: timer

        interval: 1

        onTriggered: scrollLibrary.createItem(0)
    }
//#END

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        ButtonPiano
        {
            id: buttonHistory

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: Math.round((parent.width - buttonAdd.width) / 2)

            checkable: true

            // NOTE: We want to keep the 'feed' button selected during the 'clear' animation.
            checked: (index == 0 || pIndex == -2)

            checkHover: false

            text: qsTr("History")

            font.pixelSize: st.dp14

            itemText.horizontalAlignment: Text.AlignLeft

//#QT_4
            onPressed: select(0)
//#ELSE
            onPressed: Qt.callLater(select, 0)
//#END
        }

        ButtonPiano
        {
            anchors.left  : buttonHistory.right
            anchors.right : buttonAdd.left
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            checkable: true
            checked  : (buttonHistory.checked == false)

            checkHover: false

            text: qsTr("Library")

            font.pixelSize: st.dp14

            itemText.horizontalAlignment: Text.AlignLeft

//#QT_4
            onPressed: select(1)
//#ELSE
            onPressed: Qt.callLater(select, 1)
//#END
        }

        ButtonPianoIcon
        {
            id: buttonAdd

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp32 + borderSizeWidth

            borderRight: 0

            checkable: true

            // NOTE: We want to keep the 'add' button selected during the 'clear' animation.
            checked: (scrollLibrary.isCreating || pIndex > -1)

            icon          : st.icon16x16_addBold
            iconSourceSize: st.size16x16

//#QT_4
            onPressed: pCreate()
//#ELSE
            onPressed: Qt.callLater(pCreate)
//#END
        }

        ButtonPianoFull
        {
            id: buttonPlaylist

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: Math.round((parent.width - buttonAdd.width) / 3)

            // NOTE: This makes sure that the 'create' buttons are visible during the animation.
            visible: (pIndex > -1)

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type < 1)

            checkHover: false

            icon          : st.icon16x16_playlist
            iconSourceSize: st.size16x16

            text: qsTr("Playlist")

            onPressed: scrollLibrary.createItem(0)
        }

        ButtonPianoFull
        {
            id: buttonFeed

            anchors.left  : buttonPlaylist.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: buttonPlaylist.width

            visible: buttonPlaylist.visible

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type == 1)

            checkHover: false

            icon          : st.icon16x16_feed
            iconSourceSize: st.size16x16

            text: qsTr("Feed")

            onPressed: scrollLibrary.createItem(1)
        }

        ButtonPianoFull
        {
            anchors.left  : buttonFeed.right
            anchors.right : buttonAdd.left
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            visible: buttonPlaylist.visible

            enabled: (library.isFull == false)

            checkable: true
            checked  : (scrollLibrary.type == 2)

            checkHover: false

            icon          : st.icon16x16_folder
            iconSourceSize: st.size16x16

            text: qsTr("Folder")

            onPressed: scrollLibrary.createItem(2)
        }
    }

    ItemWipe
    {
        id: itemWipe

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        onIsAnimatedChanged:
        {
            if (scrollLibrary.dragAccepted)
            {
                bordersDrop.updatePosition();

                bordersDrop.visible = true;
            }

            if (isAnimated == false && pIndex == 0)
            {
//#QT_4
                timer.restart();
//#ELSE
                Qt.callLater(scrollLibrary.createItem, 0);
//#END
            }
        }

        ScrollFolderCreate
        {
            id: scrollLibrary

            anchors.fill: parent

            folder: (index == 0) ? feeds : library

            listFolder  : gui.listFolder
            listPlaylist: gui.listPlaylist

            enableAnimation: (itemWipe.isAnimated == false)

            textDefault: qsTr("Empty Library")

            textVisible: (index == 1 && isCreating == false && count == 0)

            itemRight: (listFolder.visible) ? listFolder
                                            : listPlaylist

            onClear:
            {
                if (list.activeFocus || pIndex) return;

                // NOTE: We want to keep the 'feed' button selected during the 'clear'
                //       animation.
                pIndex = -2;

                select(0);
            }

            onFinished: pIndex = -1
        }

        ScrollerList
        {
            visible: scrollLibrary.dragAccepted

            opacity: (visible) ? bordersDrop.opacity : 1.0

            scrollArea: scrollLibrary
        }
    }
}
