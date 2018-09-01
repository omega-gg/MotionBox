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
    id: panelCover

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed : false
    /* read */ property bool isExpanded: false
    /* read */ property bool isPreview : false

    /* read */ property bool hasItem: false

    /* read */ property bool detail: true

    /* read */ property ListPlaylist list
    /* read */ property Playlist  playlist

    /* read */ property int trackState

    /* read */ property url source

    /* read */ property string title
    /* read */ property url    cover

    /* read */ property string author
    /* read */ property string feed

    /* read */ property int duration: 0

    /* read */ property int quality: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate  : false
    property bool pAnimating: false

    property bool pExposed: local.panelCoverVisible

    property bool pButtonActive: (player.isPlaying && isPreview == false
                                  &&
                                  gui.isExpanded == false && (panelTracks.isExpanded
                                                              ||
                                                              panelBrowse.isExposed == false))

    property bool pClearLater: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonTrack: buttonTrack

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: panelLibrary.width

    height: Math.round(panelLibrary.contentWidth * 0.5625) + borderTop + buttonTrack.height
            +
            details.height

    y: parent.height - buttonTrack.height

    borderLeft  : 0
    borderBottom: 0

    color: st.panelCover_color

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "expanded"; when: (isExpanded && detail == false)

            PropertyChanges
            {
                target: panelCover

                y: parent.height - height + details.height
            }
        },
        State
        {
            name: "expandedDetail"; when: isExpanded

            PropertyChanges
            {
                target: panelCover

                y: parent.height - height
            }
        },
        State
        {
            name: "exposedBrowse"; when: (isExposed
                                          &&
                                          panelTracks.isExpanded && panelBrowse.isExposed)

            PropertyChanges
            {
                target: panelCover

                width: panelBrowse.widthColum + st.dp2

                y: parent.height - height
            }
        },
        State
        {
            name: "exposed"; when: isExposed

            PropertyChanges
            {
                target: panelCover

                y: parent.height - height
            }
        },
        State
        {
            name: "hiddenBrowse"; when: (player.source == "" && panelBrowse.isExposed)

            PropertyChanges
            {
                target: panelCover

                width: panelBrowse.widthColum + st.dp2

                y: parent.height
            }
        },
        State
        {
            name: "hidden"; when: (player.source == "" || gui.isExpanded)

            PropertyChanges
            {
                target: panelCover

                y: parent.height
            }
        },
        State
        {
            name: "browse"; when: panelBrowse.isExposed

            PropertyChanges
            {
                target: panelCover

                width: panelBrowse.widthColum + st.dp2
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                properties: "y, width"

                duration: st.duration_normal
            }

            ScriptAction
            {
                script:
                {
                    pAnimating = false;

                    isPreview = isExpanded;

                    if (isExposed) return;

                    if (pClearLater) pClearSource();

                    if (gui.isExpanded || player.source == "")
                    {
                        visible = false;
                    }
                    else itemCover.visible = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onStateChanged:
    {
        if (isPreview || player.source)
        {
             visible = true;
        }
        else visible = false;

        if (width != panelLibrary.width)
        {
            pAnimating = true;
        }
    }

    onExited: clearItemLater()

    //---------------------------------------------------------------------------------------------
    // Private

    onPButtonActiveChanged:
    {
        if (pButtonActive)
        {
            buttonUp.visible = true;
        }

        clip = true;
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: (hasItem) ? playlist : null

        onTrackUpdated:
        {
            if (list.indexPreview != index) return;

            if (playlist.trackIsLoading(index))
            {
                pAnimate = true;
            }
            else pUpdateItem();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function updatePanel()
    {
        if (isExpanded) return;

        if (player.isPlaying && pExposed
            &&
            gui.isExpanded == false && (panelTracks.isExpanded
                                        ||
                                        panelBrowse.isExposed == false))
        {
             expose();
        }
        else collapse();
    }

    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed) return;

        itemCover.visible = true;

        isExposed = true;
    }

    function collapse()
    {
        isExposed = false;
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function setItem(list)
    {
        timer.stop();

        pAnimate = false;

        panelCover.list     = list;
        panelCover.playlist = list.playlist;

        pUpdateItem();

        hasItem = true;

        isExpanded = true;
        isPreview  = true;

        pClearLater = false;

        expose();
    }

    //---------------------------------------------------------------------------------------------

    function clearItem()
    {
        if (hasItem == false) return;

        timer.stop();

        pClearItem();
    }

    function clearItemLater()
    {
        timer.start();
    }

    //---------------------------------------------------------------------------------------------

    function getHeight()
    {
        if (isPreview)
        {
             return Math.min(height, st.dp30);
        }
        else return parent.height - y;
    }

    function getY()
    {
        if (isPreview)
        {
             return Math.max(parent.height - st.dp30, y);
        }
        else return y;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateItem()
    {
        var index = list.indexPreview;

        var data = playlist.trackData(index);

        trackState = data.state;

        source = data.source;

        title = data.title;
        cover = data.cover;

        author = data.author;
        feed   = data.feed;

        duration = data.duration;

        core.dateCover = data.date;

        quality = data.quality;

        if (data.state == LocalObject.Loaded)
        {
             detail = true;
        }
        else detail = false;
    }

    //---------------------------------------------------------------------------------------------

    function pClearItem()
    {
        isExpanded = false;

        pClearLater = true;

        updatePanel();

        if (isExposed) pClearSource();
    }

    function pClearSource()
    {
        pClearLater = false;

        pAnimate = false;

        source = "";

        detail = true;

        hasItem = false;
    }

    //---------------------------------------------------------------------------------------------

    function pSelectTrack()
    {
        gui.selectTrack(playerTab);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.panelCover_intervalClear

        onTriggered: if (isHovered == false) pClearItem()
    }

    Rectangle
    {
        id: background

        width : st.dp50 + borderIcon.size
        height: st.dp28

        color: st.panelCover_colorBackground

        states: State
        {
            name: "Exposed"; when: isExposed

            AnchorChanges
            {
                target: background

                anchors.right: parent.left
            }
        }

        transitions: Transition
        {
            AnchorAnimation { duration: st.duration_normal }
        }

        Image
        {
            id: itemIcon

            anchors.left  : parent.left
            anchors.right : borderIcon.left
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            sourceSize: Qt.size(st.dp50, st.dp28)

            clip: true

            source: player.trackCover

            sourceDefault: st.icon50x28_track

            fillMode: Image.PreserveAspectCrop

            asynchronous: true

            filter: (isSourceDefault) ? st.buttonPiano_filterIcon : null

            ButtonPiano
            {
                id: overlay

                anchors.fill: parent

                borderRight: 0

                highlighted: true

                background.visible: isHovered
                background.opacity: 0.8

                onEntered: panelPreview.activateTab(itemIcon, playerTab)

                onExited: panelPreview.clear()

                onClicked:
                {
                    panelPreview.clearInstant();

                    isExpanded = true;
                    isPreview  = true;

                    expose();
                }
            }

            Icon
            {
                anchors.centerIn: parent

                visible: overlay.background.visible

                source    : st.icon32x32_search
                sourceSize: st.size32x32

                style: Sk.IconRaised
            }
        }

        BorderVertical
        {
            id: borderIcon

            anchors.right: parent.right
        }
    }

    ButtonPiano
    {
        id: buttonTrack

        anchors.left  : background.right
        anchors.right : buttonUp.left
        anchors.top   : background.top
        anchors.bottom: border.bottom

        borderRight : 0
        borderBottom: borderSize

        enabled: (playerTab.playlist != null && hasItem == false)

        highlighted: (player.isPlaying && hasItem == false)

        isPressed: (pressed || isReturnPressed
                    ||
                    (playerTab.playlist == null && hasItem == false))

        text: (hasItem) ? gui.getTrackTitle(title,             trackState,        source)
                        : gui.getTrackTitle(player.trackTitle, player.trackState, player.source)

        colorA:
        {
            if (hasItem)
            {
                return st.barTitle_colorA;
            }
            else if (highlighted)
            {
                return st.buttonPiano_colorHighlightA;
            }
            else return st.buttonPiano_colorA;
        }

        colorB:
        {
            if (hasItem)
            {
                return st.barTitle_colorB;
            }
            else if (highlighted)
            {
                return st.buttonPiano_colorHighlightB;
            }
            else return st.buttonPiano_colorB;
        }

        itemText.horizontalAlignment: Text.AlignLeft

        itemText.opacity: 1.0

        itemText.style: (enabled) ? Text.Sunken
                                  : Text.Raised

        onPressed:
        {
            panelDiscover.collapse();

            pSelectTrack();
        }

        BorderHorizontal
        {
            visible: hasItem

            color: st.barTitle_colorBorderLine
        }
    }

    ButtonPianoIcon
    {
        id: buttonUp

        anchors.left  : parent.right
        anchors.top   : background.top
        anchors.bottom: border.bottom

        width: height + borderSizeWidth

        borderLeft  : borderSize
        borderRight : 0
        borderBottom: borderSize

        visible: false

        checkable: true
        checked  : pExposed

        icon          : st.icon24x24_slideUp
        iconSourceSize: st.size24x24

        states: State
        {
            name: "active"; when: pButtonActive

            AnchorChanges
            {
                target: buttonUp

                anchors.left : undefined
                anchors.right: parent.right
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation
                {
                    duration: (pAnimating) ? 0 : st.duration_normal
                }

                ScriptAction
                {
                    script:
                    {
                        if (pButtonActive == false)
                        {
                            buttonUp.visible = false;
                        }

                        panelCover.clip = false;
                    }
                }
            }
        }

        onClicked:
        {
            if (pButtonActive == false) return;

            toggleExpose();

            pExposed = isExposed;

            local.panelCoverVisible = isExposed;
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.left : background.left
        anchors.right: background.right
        anchors.top  : background.bottom
    }

    MouseArea
    {
        id: itemCover

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: details.top

        visible: false

        enabled     : buttonTrack.enabled
        hoverEnabled: buttonTrack.enabled

        cursor: Qt.PointingHandCursor

        onPressed: pSelectTrack()

        RectangleLogo
        {
            anchors.fill: parent

            visible: (itemImage.visible == false)
        }

        Image
        {
            id: itemImage

            anchors.fill: parent

            sourceSize.height: height

            visible: (isSourceDefault == false)

            source: (hasItem) ? cover
                              : player.trackCover

            fillMode: Image.PreserveAspectFit

            asynchronous: true
        }

        LabelLoading
        {
            anchors.centerIn: parent

            visible: (pAnimate && detail == false)
        }
    }

    BarTitle
    {
        id: details

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        borderBottom: 0

        visible: itemCover.visible

        Icon
        {
            id: icon

            anchors.left: parent.left

            anchors.leftMargin: st.dp3

            anchors.verticalCenter: parent.verticalCenter

            visible: (hasItem) ? (quality           >= AbstractBackend.QualityHigh)
                               : (playerTab.quality >= AbstractBackend.QualityHigh)

            source    : st.icon28x28_hd
            sourceSize: st.size28x28
        }

        TextBase
        {
            id: itemDuration

            anchors.left: (icon.visible) ? icon.right : parent.left

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            leftMargin: (icon.visible) ? st.dp4 : st.dp6

            verticalAlignment: Text.AlignVCenter

            visible: detail

            text: (hasItem) ? gui.getTrackDuration(duration)
                            : gui.getTrackDuration(playerTab.duration)

            style: Text.Sunken

            font.pixelSize: st.dp14
        }

        ButtonPiano
        {
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            maximumWidth: parent.width - (itemDuration.x + itemDuration.width + st.dp50)

            borderLeft : borderSize
            borderRight: 0

            padding: st.buttonPiano_padding

            visible: (detail && text != "")

            enabled: (hasItem) ? (feed           != "")
                               : (playerTab.feed != "")

            text:
            {
                if (hasItem)
                {
                     return gui.getTrackAuthor(author, feed);
                }
                else return gui.getTrackAuthor(playerTab.author, playerTab.feed);
            }

            onClicked:
            {
                if (hasItem)
                {
                     gui.browseFeedTrack(source, feed);
                }
                else gui.browseFeed(playerTab);

                if (isExpanded) pClearItem();
            }
        }
    }
}
