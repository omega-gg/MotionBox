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

PanelImage
{
    id: panelPreview

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property BaseList list
    /* read */ property variant  item: null

    /* read */ property int type: 0

    /* read */ property bool detail: false

    /* read */ property Playlist playlist

    /* read */ property url trackSource

    /* read */ property string title

    /* read */ property string author
    /* read */ property string feed

    /* read */ property int duration: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate          : false
    property int  pAnimationDuration: (pAnimate) ? st.duration_normal : 0

    property bool pActive: false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: (type) ? st.dp192 + borderSizeWidth
                  : st.dp108 + borderSizeWidth

    height: pGetHeight(detail)

    sourceSize: Qt.size(st.dp192, st.dp108)

    z: 1

    visible: false

    backgroundOpacity: st.panelContextual_backgroundOpacity

    animate: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    hoverEnabled: (type)

    fillMode: (type) ? Image.PreserveAspectFit
                     : Image.PreserveAspectCrop

    color: st.panel_color

    //---------------------------------------------------------------------------------------------

    imageBack.anchors.fill: undefined

    imageBack.anchors.left : imageFront.parent.left
    imageBack.anchors.right: imageFront.parent.right

    imageBack.height: imageFront.height

    imageBack.z: imageFront.z

    imageBack.visible: true

    imageBack.gradient: Gradient
    {
        GradientStop
        {
            position: 0.0

            color: (imageFront.isSourceDefault) ? imageBack.colorA
                                                : st.panelImage_color
        }

        GradientStop
        {
            position: 1.0

            color: (imageFront.isSourceDefault) ? imageBack.colorB
                                                : st.panelImage_color
        }
    }

    //---------------------------------------------------------------------------------------------

    imageFront.anchors.fill: undefined

    imageFront.anchors.left : imageFront.parent.left
    imageFront.anchors.right: imageFront.parent.right

    imageFront.height: st.dp108

    imageFront.z: 1

    imageFront.clip: true

    imageFront.asynchronous: true

    //---------------------------------------------------------------------------------------------

    imageBackground.visible: imageFront.isSourceDefault

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

        /* QML_CONNECTION */ function onTrackUpdated(index)
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

            easing.type: st.easing

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
        PropertyAnimation
        {
            duration: pAnimationDuration

            easing.type: st.easing
        }
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

            y = pos.y - st.border_size;
        }
        else
        {
            panelPreview.x = pos.x - st.border_size;

            y = pos.y - height;
        }

        var minY = barTop.y + barTop.height - st.border_size;

        var maxY = barControls.y + st.border_size;

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

        if (data.state < LocalObject.Loaded)
        {
             return false;
        }
        else return true;
    }

    //---------------------------------------------------------------------------------------------

    function pGetHeight(detail)
    {
        var size = st.dp108 + borderSizeHeight;

        if (detail)
        {
            if (itemDuration.text == "")
            {
                if (textDate.text == "")
                {
                     return size + buttonFeed.height;
                }
                else return size + buttonFeed.height + border.size + st.dp24;
            }
            else if (textDate.text == "")
            {
                 return size + buttonFeed.height + border.size + st.dp24;
            }
            else return size + buttonFeed.height + border.size + st.dp48;
        }
        else return size;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.duration_faster

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
        anchors.fill: imageFront

        z: 1

        onClicked: clearInstant()

        LabelLoading
        {
            anchors.centerIn: parent

            visible: (pAnimate && detail == false)
        }
    }

    Item
    {
        id: details

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: buttonFeed.top

        height: (itemDuration.visible && textDate.visible) ? st.dp48 : st.dp24

        visible: (detail && duration != -1)

        TextBase
        {
            id: itemDuration

            anchors.left : parent.left
            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.leftMargin : st.dp6
            anchors.rightMargin: st.dp6
            anchors.topMargin  : (textDate.visible) ? st.dp1 : 0

            height: st.dp24

            verticalAlignment: Text.AlignVCenter

            visible: (text != "")

            text: gui.getTrackDuration(duration)

            style: st.text_raised

            font.pixelSize: st.dp14
        }

        TextDate
        {
            id: textDate

            anchors.left  : parent.left
            anchors.right : parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin  : st.dp6
            anchors.rightMargin : st.dp6
            anchors.bottomMargin: (itemDuration.visible) ? st.dp1 : 0

            height: st.dp24

            verticalAlignment: Text.AlignVCenter

            visible: (text != "")

            date: core.datePreview

            style: st.text_raised
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
            else gui.browseFeedTrack(feed, trackSource);

            pClear();
        }
    }

    BorderHorizontal
    {
        id: border

        anchors.top: imageFront.bottom

        visible: details.visible
    }
}
