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

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

PanelImage
{
    id: panelPreview

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property List    list
    /* read */ property variant item: null

    /* read */ property int type: 0

    /* read */ property bool detail: false

    /* read */ property PlaylistNet playlist

    /* read */ property url trackSource

    /* read */ property string title

    /* read */ property string author
    /* read */ property string feed

    /* read */ property int duration: 0

    /* read */ property int quality: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate          : false
    property int  pAnimationDuration: (pAnimate) ? st.duration_normal : 0

    property bool pActive: false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: (type) ? st.dp146 + borderSizeWidth
                  : st.dp110 + borderSizeWidth

    height: pGetHeight(detail)

    sourceSize: Qt.size(st.dp146, st.dp110)

    z: 1

    visible: false

    animate: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    hoverEnabled: (type)

    fillMode: Image.PreserveAspectCrop

    background.anchors.fill: undefined

    background.anchors.left : itemImage.parent.left
    background.anchors.right: itemImage.parent.right

    background.height: itemImage.height + borderTop

    itemImage.anchors.fill: undefined

    itemImage.anchors.left : itemImage.parent.left
    itemImage.anchors.right: itemImage.parent.right

    itemImage.height: st.dp110

    itemImage.z: 1

    itemImage.clip: true

    itemImage.asynchronous: true

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onEntered: show    ()
    onExited : clearNow()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: (pActive && type == 1) ? playlist : null

        onTrackUpdated:
        {
            if (list.indexPreview != index) return;

            var detail = panelPreview.detail;

            panelPreview.detail = pUpdateTrack();

            if (playlist.trackIsLoading(index))
            {
                pAnimate = true;
            }
            else if (detail == false && panelPreview.detail)
            {
                pUpdateHeight(pGetHeight(true));
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on height
    {
        PropertyAnimation
        {
            duration: pAnimationDuration

            onRunningChanged:
            {
                if (running || pAnimate == false) return;

                pAnimate = false;

                pUpdate();
            }
        }
    }

    Behavior on y
    {
        PropertyAnimation { duration: pAnimationDuration }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function activateFolder(list)
    {
        var item = list.itemHovered;

        panelPreview.list = list;
        panelPreview.item = item;

        trackSource = "";

        source = item.getCover();

        detail = false;

        type = 0;

        pUpdate();
    }

    function activatePlaylist(list)
    {
        panelPreview.list = list;
        panelPreview.item = list.itemHovered;

        playlist = list.playlist;

        detail = pUpdateTrack();

        type = 1;

        pUpdate();
    }

    function activateTab(item, tab)
    {
        panelPreview.list = null;
        panelPreview.item = item;

        trackSource = tab.source;

        title  = tab.title;
        source = tab.cover;

        author = tab.author;
        feed   = tab.feed;

        duration = tab.duration;

        core.datePreview = tab.date;

        quality = tab.quality;

        detail = true;

        type = 2;

        pUpdate();
    }

    //---------------------------------------------------------------------------------------------

    function show()
    {
        if (pActive) return;

        pActive = true;

        timer.restart();
    }

    function showInstant()
    {
        if (visible) return;

        timer.stop();

        pActive = true;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------

    function clear()
    {
        if (pActive && isHovered == false)
        {
            pClearActive();
        }
    }

    function clearNow()
    {
        if (pActive) pClearActive();
    }

    function clearInstant()
    {
        if (visible == false) return;

        pClear();
    }

    //---------------------------------------------------------------------------------------------

    function update()
    {
        if (pActive) pUpdate();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearActive()
    {
        pAnimate = false;
        pActive  = false;

        timer.restart();
    }

    function pClear()
    {
        timer.stop();

        pAnimate = false;
        pActive  = false;

        visible = false;

        list = null;
        item = null;
    }

    //---------------------------------------------------------------------------------------------

    function pUpdate()
    {
        pUpdateHeight(height);
    }

    function pUpdateHeight(height)
    {
        var pos = gui.mapFromItem(item, 0, 0);

        var y;

        if (type != 2)
        {
            var x = pos.x - width;

            if (x < 0)
            {
                 panelPreview.x = pos.x + item.width;
            }
            else panelPreview.x = x;

            y = pos.y - st.dp2;
        }
        else
        {
            panelPreview.x = pos.x - st.dp2;

            y = pos.y - height;
        }

        var minY = barTop.y + barTop.height - st.dp2;

        var maxY = barControls.y + st.dp2;

        if (y < minY)
        {
            panelPreview.y = minY;
        }
        else if (y + height > maxY)
        {
            panelPreview.y = maxY - height;
        }
        else panelPreview.y = y;

        show();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateTrack()
    {
        var index = list.indexPreview;

        var data = playlist.trackData(index);

        trackSource = data.source;

        title  = data.title;
        source = data.cover;

        author = data.author;
        feed   = data.feed;

        duration = data.duration;

        core.datePreview = data.date;

        quality = data.quality;

        if (data.state == LocalObject.Loaded)
        {
             return true;
        }
        else return false;
    }

    //---------------------------------------------------------------------------------------------

    function pGetHeight(detail)
    {
        var size = st.dp110 + borderSizeHeight;

        if (detail)
        {
            if (duration == -1)
            {
                 return size + buttonFeed.height;
            }
            else return size + buttonFeed.height + border.size + details.height;
        }
        else return size;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_normal

        onTriggered:
        {
            if (pActive == false)
            {
                visible = false;

                list = null;
                item = null;
            }
            else visible = true;
        }
    }

    MouseArea
    {
        anchors.fill: itemImage

        z: 1

        onClicked: clearInstant()

        LabelLoading
        {
            anchors.centerIn: parent

            visible: (pAnimate && detail == false)
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: details.top

        visible: details.visible
    }

    Item
    {
        id: details

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: buttonFeed.top

        height: (itemDuration.visible && textDate.visible) ? st.dp48 : st.dp24

        visible: (detail && duration != -1)

        Rectangle
        {
            anchors.fill: parent

            opacity: st.panelContextual_backgroundOpacity

            gradient: Gradient
            {
                GradientStop { position: 0.0; color: "#161616" }
                GradientStop { position: 1.0; color: "#323232" }
            }
        }

        Icon
        {
            id: icon

            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.rightMargin:  st.dp3
            anchors.topMargin  : -st.dp1

            visible: (quality >= AbstractBackend.QualityHigh)

            source    : st.icon28x28_hd
            sourceSize: st.size28x28

            style: Sk.IconRaised
        }

        TextBase
        {
            id: itemDuration

            anchors.left: parent.left
            anchors.top : parent.top

            anchors.right: (icon.visible) ? icon.left : parent.right

            leftMargin : st.dp6
            rightMargin: st.dp6
            topMargin  : (textDate.visible) ? st.dp1 : 0

            height: st.dp24

            verticalAlignment: Text.AlignVCenter

            visible: (text != "")

            text: gui.getTrackDuration(duration)

            color: st.panelPreview_colorText

            style: Text.Raised

            font.pixelSize: st.dp14
        }

        TextDate
        {
            id: textDate

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            leftMargin  : st.dp6
            rightMargin : st.dp6
            bottomMargin: (itemDuration.visible) ? st.dp1 : 0

            height: st.dp24

            verticalAlignment: Text.AlignVCenter

            visible: (text != "")

            date: core.datePreview

            style: Text.Raised
        }
    }

    ButtonPiano
    {
        id: buttonFeed

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        borderRight: 0
        borderTop  : st.border_size

        padding: st.dp6

        visible: detail

        enabled: (feed != "")

        text: gui.getTrackAuthor(author, feed)

        itemText.horizontalAlignment: Text.AlignLeft

        onClicked:
        {
            if (type == 2)
            {
                 gui.browseFeed(playerTab);
            }
            else gui.browseFeedTrack(trackSource, feed);

            pClear();
        }
    }
}
