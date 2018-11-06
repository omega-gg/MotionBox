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

Item
{
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pSetStyle(index)
    {
        gui.restoreMini();

        st.applyStyle(index);

        gui.updateColor();

        local.style = index;
    }

    //---------------------------------------------------------------------------------------------

    function pClearTabs()
    {
        wall.enableAnimation = false;

        player.stop();

        tabs.closeTabs();

        wall.enableAnimation = true;
    }

    function pClearCache()
    {
        panelBrowse.clearEdit();

        core.clearCache();
    }

    //---------------------------------------------------------------------------------------------

    function pScale(scale)
    {
//#QT_4
        gui.scale(scale);
//#ELSE
        Qt.callLater(gui.scale, scale);
//#END
    }

    function pSetScale(percent)
    {
        if (percent < 80)
        {
            percent = 80;

            editScale.text = "80";
        }

        if      (percent == 92)  buttonsScale.currentIndex =  0;
        else if (percent == 100) buttonsScale.currentIndex =  1;
        else if (percent == 128) buttonsScale.currentIndex =  2;
        else if (percent == 160) buttonsScale.currentIndex =  3;
        else if (percent == 200) buttonsScale.currentIndex =  4;
        else                     buttonsScale.currentIndex = -1;

        gui.scale(percent / 100);
    }

    //---------------------------------------------------------------------------------------------

    function pResetProxy()
    {
        local.proxyHost     = "";
        local.proxyPort     = -1;
        local.proxyPassword = "";

        local.proxyStream = false;

        if (local.proxyActive)
        {
            local.proxyActive = false;

            gui.applyProxy(false);
        }
    }

    function pResetTorrent()
    {
        local.torrentConnections = 500;

        local.torrentUpload   = 0;
        local.torrentDownload = 0;

        local.torrentUploadActive   = false;
        local.torrentDownloadActive = false;

        local.torrentCache = 1000;

        core.applyTorrentOptions(500, 0, 0, 1000);
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitleSmall
    {
        id: barContent

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        ButtonPiano
        {
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            borderRight: borderSize

            text: qsTr("Content")

            onClicked: gui.openFile(core.pathStorage)
        }
    }

    ButtonPushLeft
    {
        id: buttonTabs

        anchors.left: parent.left
        anchors.top : barContent.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        width: st.dp100

        enabled: (tabs.count > 1 || currentTab.isValid)

        text: qsTr("Clear tabs")

        onClicked: pClearTabs()
    }

    ButtonPushRight
    {
        id: buttonCache

        anchors.left: buttonTabs.right
        anchors.top : buttonTabs.top

        width: st.dp100

        enabled: local.cache

        text: qsTr("Clear cache")

        onClicked: pClearCache()
    }

    ButtonPush
    {
        anchors.left : buttonCache.right
        anchors.right: parent.right
        anchors.top  : buttonCache.top

        anchors.rightMargin: st.dp3

        enabled: (buttonTabs.enabled || buttonCache.enabled)

        text: qsTr("Clear both")

        onClicked:
        {
            pClearTabs ();
            pClearCache();
        }
    }

    BarSettingReset
    {
        id: barNetwork

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : buttonTabs.bottom

        anchors.topMargin: st.dp3

        enabled: (buttonsStyle.currentIndex != 0)

        text: qsTr("Style")

        onReset: buttonsStyle.pressAt(0)
    }

    ButtonsCheck
    {
        id: buttonsStyle

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : barNetwork.bottom

        anchors.leftMargin : st.dp3
        anchors.rightMargin: st.dp3
        anchors.topMargin  : st.dp3

        model: ListModel {}

        currentIndex: local.style

        Component.onCompleted:
        {
            model.append({ "title": qsTr("Night")   });
            model.append({ "title": qsTr("Light")   });
            model.append({ "title": qsTr("Classic") });
        }

        onPressed: pSetStyle(currentIndex)
    }

    BarTitleSmall
    {
        id: barProxy

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : buttonsStyle.bottom

        anchors.topMargin: st.dp3
    }

    BarTitleText
    {
        id: itemTextProxy

        anchors.left  : barProxy.left
        anchors.right : border.right
        anchors.top   : barProxy.top
        anchors.bottom: barProxy.bottom

        anchors.topMargin   : barProxy.borderTop
        anchors.bottomMargin: barProxy.borderBottom

        verticalAlignment: Text.AlignVCenter

        text: qsTr("Proxy")

        font.pixelSize: st.dp12
    }

    ButtonPianoReset
    {
        anchors.right : border.left
        anchors.top   : itemTextProxy.top
        anchors.bottom: itemTextProxy.bottom

        enabled: (local.proxyHost || local.proxyPort != -1 || local.proxyPassword
                  ||
                  local.proxyStream || local.proxyActive)

        onClicked: pResetProxy()
    }

    BarTitleText
    {
        anchors.left  : border.right
        anchors.right : barProxy.right
        anchors.top   : itemTextProxy.top
        anchors.bottom: itemTextProxy.bottom

        verticalAlignment: Text.AlignVCenter

        text: qsTr("Torrent")

        font.pixelSize: st.dp12
    }

    ButtonPianoReset
    {
        anchors.right : barProxy.right
        anchors.top   : itemTextProxy.top
        anchors.bottom: itemTextProxy.bottom

        enabled: (local.torrentConnections != 500
                  ||
                  local.torrentUpload != 0 || local.torrentDownload != 0
                  ||
                  local.torrentUploadActive != false || local.torrentDownloadActive != false
                  ||
                  local.torrentCache != 1000)

        onClicked: pResetTorrent()
    }

    ButtonPush
    {
        id: buttonProxy

        anchors.left: parent.left
        anchors.top : barProxy.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        width: st.dp100

        text: qsTr("Configure")

        onClicked: loadPage(Qt.resolvedUrl("PageSettingsProxy.qml"))
    }

    BorderVertical
    {
        id: border

        anchors.top   : barProxy.top
        anchors.bottom: barScale.bottom

        anchors.topMargin   : barProxy.borderTop
        anchors.bottomMargin: barScale.borderTop

        anchors.horizontalCenter: parent.horizontalCenter
    }

    ButtonPush
    {
        anchors.left: border.right
        anchors.top : barProxy.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        width: st.dp100

        text: qsTr("Configure")

        onClicked: loadPage(Qt.resolvedUrl("PageSettingsTorrent.qml"))
    }

    BarSettingReset
    {
        id: barScale

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : buttonProxy.bottom

        anchors.topMargin: st.dp3

        enabled: (st.scale != 1.0)

        text: qsTr("Scale")

        onReset:
        {
            buttonsScale.pressAt(1);

            window.clearFocus();
        }
    }

    ButtonsCheck
    {
        id: buttonsScale

        anchors.left : parent.left
        anchors.right: editScale.left
        anchors.top  : barScale.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        padding: st.dp8

        model: ListModel {}

        Component.onCompleted:
        {
            model.append({ "title": qsTr("92")  });
            model.append({ "title": qsTr("100") });
            model.append({ "title": qsTr("128") });
            model.append({ "title": qsTr("160") });
            model.append({ "title": qsTr("200") });

            if      (st.scale == 0.92) currentIndex = 0;
            else if (st.scale == 1.0)  currentIndex = 1;
            else if (st.scale == 1.28) currentIndex = 2;
            else if (st.scale == 1.6)  currentIndex = 3;
            else if (st.scale == 2.0)  currentIndex = 4;
        }

        onPressed:
        {
            if (currentIndex == 0)
            {
                editScale.text = "92";

                pScale(0.92);
            }
            else if (currentIndex == 1)
            {
                editScale.text = "100";

                pScale(1.0);
            }
            else if (currentIndex == 2)
            {
                editScale.text = "128";

                pScale(1.28);
            }
            else if (currentIndex == 3)
            {
                editScale.text = "160";

                pScale(1.6);
            }
            else // if (currentIndex == 4)
            {
                editScale.text = "200";

                pScale(2.0);
            }

//#QT_4
            window.clearFocus();
//#ELSE
            Qt.callLater(window.clearFocus);
//#END
        }
    }

    LineEdit
    {
        id: editScale

        anchors.right: parent.right

        anchors.rightMargin: st.dp5

        anchors.verticalCenter: buttonsScale.verticalCenter

        width: st.dp48

        text: st.scale * 100

        maximumLength: 3

        textInput.validator: IntValidator { bottom: 80; top: 300 }

        onIsFocusedChanged:
        {
            if (isFocused == false)
            {
                pSetScale(text);
            }
        }

        function onKeyPressed(event)
        {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                pSetScale(text);

                editScale.selectAll();
            }
            else if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                text = st.scale * 100;

                window.clearFocus();
            }
        }
    }
}
