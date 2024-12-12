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

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool shareIsEnabled: (imageTag.isSourceDefault == false
                                              &&
                                              panelEdit.active == false)

    /* read */ property bool exportIsEnabled: (shareIsEnabled && pEnableExport)
    /* read */ property bool saveIsEnabled  : (shareIsEnabled && pEnableSave)

    /* read */ property int size: Math.min(parent.width, parent.height) / 2

    //---------------------------------------------------------------------------------------------
    // Private

    property int pSize: size * 2

    // NOTE: Margins are 56 pixels on a 512 tag.
    property int pSizeTag: size * 0.890625

    property int pBorder2x: st.border_size * 2

    property bool pEnableExport: true
    property bool pEnableSave  : true

    property bool pShare: false

    // NOTE: We only show the cover when we have a valid one.
    property bool pShowCover: (cover.isSourceDefault == false)

    property bool pUpdateCover: true

    property string pCover: gui.getTagCover()

    // NOTE: This is useful for web compliant VideoTag(s).
    property string pPrefix: (prefix) ? "https://vbml.omega.gg/" : ""

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: pUpdateTag()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------
    Connections
    {
        target: core

        /* QML_CONNECTION */ function onTagUpdated(image, text)
        {
            imageTag.applyImage(image);

            panelTag.text = text;

            pUpdateSave();
        }

        /* QML_CONNECTION */ function onLinkReady(text)
        {
            if (pShare)
            {
                pShare = false;

                sk.share("Share VBML link", text);
            }
            else if (text)
            {
                gui.applyLink(text);
            }
            else popup.showText(qsTr("Failed to copy link"));
        }

        /* QML_CONNECTION */ function onVbmlSaved(ok, path)
        {
            if (ok)
            {
                pEnableExport = false;

                popup.showText(qsTr("VBML saved in: ") + path);
            }
            else popup.showText(qsTr("Failed to save VBML"));
        }

        /* QML_CONNECTION */ function onTagSaved(ok, path)
        {
            if (ok)
            {
                pEnableSave = false;

                popup.showText(qsTr("VideoTag saved in: ") + path);
            }
            else popup.showText(qsTr("Failed to save VideoTag"));
        }
    }

    Connections
    {
        target: gui

        /* QML_CONNECTION */ function onTagItemChanged()
        {
            pUpdateTag();
        }
    }

    Connections
    {
        target: currentTab

        /* QML_CONNECTION */ function onCurrentBookmarkUpdated()
        {
            pUpdateTag();
        }
    }

    Connections
    {
        target: (synchronize) ? player : null

        /* QML_CONNECTION */ function onCurrentTimeChanged()
        {
            pUpdateTag();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showTagCustom()
    {
        var type = gui.tagType;

        if (type != 3)
        {
            if (type == 1)
            {
                gui.tagItem.tryDelete();
            }

            gui.tagType = 3;

            gui.tagItem = null;
        }

        pUpdateTag();
    }

    function clearTagCustom()
    {
        if (gui.tagType != 3) return;

        gui.tagType = -1;

        panelEdit.clear();

        pUpdateTag();
    }

    function applyCover(checked)
    {
        showCover = checked;
    }

    function applySynchronize(checked)
    {
        if (synchronize == checked) return;

        synchronize = checked;

        pUpdateTag();
    }

    function applyPrefix(checked)
    {
        if (prefix == checked) return;

        prefix = checked;

        pUpdateTag();
    }

    function applyEmbedCover(checked)
    {
        if (embedCover == checked) return;

        embedCover = checked;

        pEnableSave = true;
    }

    function copyLink()
    {
        pShare = false;

        core.copyLink(pGetVbml(), pPrefix);
    }

    function shareLink()
    {
        pShare = true;

        core.copyLink(pGetVbml(), pPrefix);
    }

    function exportVbml()
    {
        core.saveVbml(pGetTitle(), pGetVbml());
    }

    function saveTag()
    {
        var vbml = pGetVbml();

        if (controllerPlaylist.textIsVbmlHash(vbml))
        {
            core.saveTag(pGetTitle(), vbml, st.picture_tagLite, "", pPrefix, 16);
        }
        else if (embedCover)
        {
            core.saveTag(pGetTitle(), vbml, st.picture_tag, pCover, pPrefix);
        }
        else core.saveTag(pGetTitle(), vbml, st.picture_tag, "", pPrefix);
    }

//#MOBILE
    function shareTag()
    {
        gui.wasPlaying = player.isPlaying;

        if (embedCover)
        {
             core.shareTag(pGetTitle(), pGetVbml(), pCover, pPrefix);
        }
        else core.shareTag(pGetTitle(), pGetVbml(), "", pPrefix);
    }
//#END

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateTag()
    {
        if (currentTabActive == false && gui.tagType == -1)
        {
            timer.stop();

            pEnableExport = false;
            pEnableSave   = false;

            imageTag.clearPixmap();

            text = "";

            return;
        }

        timer.restart();
    }

    function pUpdateSave()
    {
        pEnableExport = (imageTag.isSourceDefault == false);

        pEnableSave = pEnableExport;
    }

    function pGetTitle()
    {
        var type = gui.tagType;
        var item = gui.tagItem;

        if (item)
        {
            if (type)
            {
                return item.title;
            }
            else return item.trackTitle(item.indexFromId(gui.tagId));
        }
        else if (type == 3) // Custom
        {
            return "";
        }
        else return currentTab.title;
    }

    function pGetVbml()
    {
        var type = gui.tagType;
        var item = gui.tagItem;

        if (item)
        {
            if (type)
            {
                if (item.label == "tracks")
                {
                     // NOTE: We extract the most recent history tracks.
                     return item.toVbml(1, 30);
                }
                else return item.toVbml();
            }
            else return item.trackVbml(item.indexFromId(gui.tagId));
        }
        else if (type == 3) // Custom
        {
            return panelEdit.text;
        }
        else if (synchronize)
        {
            if (player.hasStarted)
            {
                var source = gui.applyTimeTrack(currentTab.source);

                return currentTab.toVbml(source, player.currentTime);
            }
            else
            {
                /* var */ source = currentTab.source;

                return currentTab.toVbml(source, gui.extractTime(source));
            }
        }
        else
        {
            /* var */ source = gui.clearContext(currentTab.source);

            return currentTab.toVbml(source, -2);
        }
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: 100

        onTriggered: core.generateTag(pGetVbml(), pPrefix)
    }

    ImageScale
    {
        id: background

        anchors.centerIn: parent

        width : size
        height: width

        source: st.picture_tag

        asynchronous: gui.asynchronous
    }

    ImageScale
    {
        id: cover

        anchors.centerIn: parent

        width : pSize
        height: width

        visible: (opacity != 0.0)

        opacity: (showCover) ? 0.8 : 0.0

        clip: true

        source: (visible) ? pCover : ""

        fillMode: Image.PreserveAspectCrop

        asynchronous: gui.asynchronous

        onLoaded:
        {
            if (pUpdateCover == false) return;

            pUpdateCover = false;

            core.applyCover(cover);

            pUpdateCover = true;
        }

        // NOTE: We clear the cover manually because of Image.LoadVisible.
        onVisibleChanged:
        {
            if (visible) return;

            pUpdateCover = false;

            clearPixmap();

            pUpdateCover = true;
        }

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    ImageScale
    {
        anchors.centerIn: parent

        width : size
        height: width

        source: (pShowCover) ? st.picture_tag : ""

        asynchronous: gui.asynchronous
    }

    Image
    {
        id: imageTag

        anchors.centerIn: parent

        width : pSizeTag
        height: pSizeTag

        smooth: false
    }

    PanelEdit
    {
        id: panelEdit

        anchors.fill: background

        textDefault: qsTr("Enter VBML...")

        onVisibleChanged:
        {
            if (visible) return;

            if (text && text != textDefault)
            {
                showTagCustom();
            }
            else clearTagCustom();
        }
    }

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter

        width: st.dp192 + pBorder2x

        height: column.height + pBorder2x

        x: Math.round(background.x - width) / 2

        color: st.panel_color

        border.width: st.border_size
        border.color: st.border_color

        Column
        {
            id: column

            anchors.left : parent.left
            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.margins: st.border_size

            ButtonPushFull
            {
                anchors.left : parent.left
                anchors.right: parent.right

                checkable: true
                checked  : panelTag.showCover

                icon          : st.icon16x16_shuffle
                iconSourceSize: st.size16x16

                text: qsTr("Show cover")

                onClicked: applyCover(!checked)
            }

            ButtonCheckSettings
            {
                checked: panelTag.synchronize

                text: qsTr("Synchronize time")

                onCheckClicked: applySynchronize(checked)
            }

            ButtonCheckSettings
            {
                checked: panelTag.prefix

                text: qsTr("Web compliant")

                onCheckClicked: applyPrefix(checked)
            }

            ButtonCheckSettings
            {
                checked: panelTag.embedCover

                text: qsTr("Embed cover")

                onCheckClicked: applyEmbedCover(checked)
            }

            ButtonPushFull
            {
                anchors.left : parent.left
                anchors.right: parent.right

                enabled: saveIsEnabled

                icon          : st.icon16x16_download
                iconSourceSize: st.size16x16

                text: qsTr("Save VideoTag")

                onClicked: saveTag()
            }

            ButtonPushFull
            {
                anchors.left : parent.left
                anchors.right: parent.right

                enabled: exportIsEnabled

                icon          : st.icon16x16_download
                iconSourceSize: st.size16x16

                text: qsTr("Save VBML")

                onClicked: exportVbml()
            }

            ButtonPushFull
            {
                anchors.left : parent.left
                anchors.right: parent.right

                enabled: shareIsEnabled

                icon          : st.icon16x16_link
                iconSourceSize: st.size16x16

                text: qsTr("VBML link")

                onClicked: copyLink()
            }
        }
    }

    ButtonRound
    {
        anchors.left  : background.right
        anchors.bottom: background.top

        anchors.margins: -st.dp4

        width : st.dp44
        height: width

        checkable: true
        checked  : panelEdit.active

        icon          : st.icon16x16_pen
        iconSourceSize: st.size16x16

        onClicked: panelEdit.active = !(panelEdit.active)
    }

    ButtonRound
    {
        anchors.bottom: parent.bottom

        anchors.bottomMargin: st.dp64

        anchors.horizontalCenter: parent.horizontalCenter

        width : st.dp44
        height: width

        checkable: true
        checked  : synchronize

        icon          : st.icon16x16_recent
        iconSourceSize: st.size16x16

        onClicked: applySynchronize(!synchronize)
    }

    MouseArea
    {
        id: itemTitle

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32

        visible: (itemText.text != "")

        onClicked: panelTag.collapse()

        Rectangle
        {
            anchors.fill: parent

            color: st.itemList_colorSelectA
        }

        BarTitleText
        {
            id: itemText

            anchors.fill: parent

            text: pGetTitle()

            color: st.itemList_colorTextSelected

            style: st.text_raised

            font.pixelSize: st.dp16
        }
    }

    ButtonPianoIcon
    {
        anchors.right : bar.left
        anchors.top   : bar.top
        anchors.bottom: bar.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon16x16_slideDown
        iconSourceSize: st.size16x16

        onClicked: panelTag.collapse()
    }

    Rectangle
    {
        id: bar

        anchors.right : parent.right
        anchors.top   : itemTitle.top
        anchors.bottom: itemTitle.bottom

        width: st.dp16

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.barTitle_colorA }
            GradientStop { position: 1.0; color: st.barTitle_colorB }
        }
    }

    BorderHorizontal
    {
        anchors.left  : bar.left
        anchors.right : bar.right
        anchors.bottom: bar.bottom
    }
}
