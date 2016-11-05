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

Item
{
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pSetNetworkQuality(index)
    {
        if (local.networkCache == index) return;

        if      (index == 0) player.backend.networkCache = 5000;
        else if (index == 1) player.backend.networkCache = 1000;
        else if (index == 2) player.backend.networkCache = 500;
        else                 player.backend.networkCache = 200;

        if (player.isPlaying)
        {
            player.keepState = true;

            player.stop();
            player.play();

            player.keepState = false;
        }
        else player.stop();

        local.networkCache = index;
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

    function pSetScale(percent)
    {
        if (percent < 80)
        {
            percent = 80;

            lineEditScale.text = "80";
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
    // Childs
    //---------------------------------------------------------------------------------------------

    BarSetting
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

        enabled: (buttonsNetwork.currentIndex != 1)

        text: qsTr("Network stability")

        onReset: buttonsNetwork.pressAt(1)
    }

    ButtonsCheck
    {
        id: buttonsNetwork

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : barNetwork.bottom

        anchors.leftMargin : st.dp3
        anchors.rightMargin: st.dp3
        anchors.topMargin  : st.dp3

        model: ListModel {}

        currentIndex: local.networkCache

        Component.onCompleted:
        {
            model.append({ "title": qsTr("Low")   });
            model.append({ "title": qsTr("Med")   });
            model.append({ "title": qsTr("High")  });
            model.append({ "title": qsTr("Ultra") });
        }

        onPressed: pSetNetworkQuality(currentIndex)
    }

    BarSettingReset
    {
        id: barProxy

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : buttonsNetwork.bottom

        anchors.topMargin: st.dp3

        enabled: (local.proxyHost || local.proxyPort != -1 || local.proxyPassword
                  ||
                  local.proxyStream || local.proxyActive)

        text: qsTr("Proxy")

        onReset:
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
    }

    ButtonPush
    {
        id: buttonConfigure

        anchors.left: parent.left
        anchors.top : barProxy.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        width: st.dp100

        text: qsTr("Configure")

        onClicked: pageSettings.load(Qt.resolvedUrl("PageSettingsProxy.qml"))
    }

    ButtonCheckLabel
    {
        anchors.right: parent.right
        anchors.top  : buttonConfigure.top

        anchors.rightMargin: st.dp3

        visible: local.proxyHost

        checked: local.proxyActive

        text: qsTr("Active")

        onCheckClicked:
        {
            local.proxyActive = !(checked);

            gui.applyProxy(checked);
        }
    }

    BarSettingReset
    {
        id: barScale

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : buttonConfigure.bottom

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
        anchors.right: lineEditScale.left
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
                lineEditScale.text = "92";

                gui.scale(0.92);
            }
            else if (currentIndex == 1)
            {
                lineEditScale.text = "100";

                gui.scale(1.0);
            }
            else if (currentIndex == 2)
            {
                lineEditScale.text = "128";

                gui.scale(1.28);
            }
            else if (currentIndex == 3)
            {
                lineEditScale.text = "160";

                gui.scale(1.6);
            }
            else // if (currentIndex == 4)
            {
                lineEditScale.text = "200";

                gui.scale(2.0);
            }

            window.clearFocus();
        }
    }

    LineEdit
    {
        id: lineEditScale

        anchors.right: parent.right

        anchors.rightMargin: st.dp5

        anchors.verticalCenter: buttonsScale.verticalCenter

        width: st.dp46

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

                lineEditScale.selectAll();
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
