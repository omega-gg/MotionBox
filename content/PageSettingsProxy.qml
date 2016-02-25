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

MouseArea
{
    id: pageSettingsProxy

    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property bool pStream: local.proxyStream

    property string pClipboard

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    acceptedButtons: Qt.NoButton

    dropEnabled: true

    KeyNavigation.tab: lineEditHost

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onDragEntered:
    {
        pClipboard = sk.trim(event.text);

        if (controllerNetwork.textIsIp(pClipboard) == false) return;

        event.accepted = true;

        bordersDrop.setItem(pageSettingsProxy);

        toolTip.show(qsTr("Paste proxy"), st.icon32x32_paste, 32, 32);
    }

    onDragExited:
    {
        bordersDrop.clearItem(pageSettingsProxy);

        pClearDrop();
    }

    onDrop:
    {
        lineEditHost.editText = controllerNetwork.extractIpBase(pClipboard);

        var port = controllerNetwork.extractIpPort(pClipboard);

        if (port) lineEditPort.editText = port;

        pClearDrop();
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            buttonOk.returnPressed();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pApply()
    {
        var host = sk.simplify(lineEditHost.editText);

        var port;

        if (lineEditPort.editText)
        {
             port = parseInt(lineEditPort.editText, 10);
        }
        else port = -1;

        var password = lineEditPassword.editText;

        var stream = pStream;

        var active = buttonActive.checked;

        if (local.proxyHost == host && local.proxyPort == port && local.proxyPassword == password
            &&
            local.proxyStream == stream && local.proxyActive == active)
        {
            pageSettings.loadMain();

            return;
        }

        local.proxyHost     = host;
        local.proxyPort     = port;
        local.proxyPassword = password;

        local.proxyStream = stream;

        if (local.proxyActive != active)
        {
            local.proxyActive = active;

            gui.applyProxy(active);
        }
        else if (active)
        {
            gui.applyProxy(true);
        }

        pageSettings.loadMain();
    }

    //---------------------------------------------------------------------------------------------

    function pReset()
    {
        lineEditHost    .editText = "";
        lineEditPort    .editText = "";
        lineEditPassword.editText = "";

        pStream = false;

        buttonActive.checked = false;
    }

    //---------------------------------------------------------------------------------------------

    function pClearDrop()
    {
        toolTip.hide();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitleSmall
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        BarTitleText
        {
            anchors.left  : parent.left
            anchors.right : buttonReset.left
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            verticalAlignment: Text.AlignVCenter

            text: qsTr("Proxy settings")

            font.pixelSize: st.dp12
        }

        ButtonPiano
        {
            id: buttonReset

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            borderLeft : borderSize
            borderRight: 0

            enabled: (lineEditHost.editText || lineEditPort.editText || lineEditPassword.editText
                      ||
                      pStream || buttonActive.checked)

            text: qsTr("Reset")

            onClicked: pReset()
        }
    }

    LineEditLabel
    {
        id: lineEditHost

        anchors.left : parent.left
        anchors.right: lineEditPort.left
        anchors.top  : lineEditPort.top

        anchors.leftMargin: st.dp4

        text: qsTr("Host")

        editText: local.proxyHost

        KeyNavigation.backtab: buttonCancel
        KeyNavigation.tab    : lineEditPort
    }

    LineEditLabel
    {
        id: lineEditPort

        anchors.left : buttonActive.left
        anchors.right: buttonActive.right
        anchors.top  : bar.bottom

        anchors.leftMargin : st.dp1
        anchors.rightMargin: st.dp1
        anchors.topMargin  : st.dp4

        width: st.dp120

        text: qsTr("Port")

        editText: (local.proxyPort != -1) ? local.proxyPort : ""

        textInput.validator: RegExpValidator { regExp: /[0-9]*/ }

        KeyNavigation.backtab: lineEditHost
        KeyNavigation.tab    : lineEditPassword
    }

    LineEditLabel
    {
        id: lineEditPassword

        anchors.left : lineEditHost.left
        anchors.right: lineEditPort.right
        anchors.top  : lineEditHost.bottom

        text: qsTr("Password")

        editText: local.proxyPassword

        textInput.echoMode: TextInput.Password

        KeyNavigation.backtab: lineEditPort
        KeyNavigation.tab    : buttonOk
    }

    ButtonPushLeft
    {
        anchors.right: buttonStream.left
        anchors.top  : buttonStream.top

        width: st.dp92

        paddingLeft: st.dp15

        checked   : (pStream == false)
        checkHover: false

        text: qsTr("Global")

        onPressed: pStream = false
    }

    ButtonPushRight
    {
        id: buttonStream

        anchors.right: buttonActive.left
        anchors.top  : buttonActive.top

        width: st.dp92

        checked   : pStream
        checkHover: false

        text: qsTr("Stream")

        onPressed: pStream = true
    }

    ButtonCheckLabel
    {
        id: buttonActive

        anchors.right: parent.right
        anchors.top  : lineEditPassword.bottom

        anchors.rightMargin: st.dp3

        checked: local.proxyActive

        text: qsTr("Active")
    }

    BarTitle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        height: st.dp32 + borderSizeHeight

        borderBottom: 0

        ButtonPiano
        {
            id: buttonCancel

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp100

            text: qsTr("Cancel")

            KeyNavigation.backtab: buttonOk
            KeyNavigation.tab    : lineEditHost

            onClicked: pageSettings.loadMain()
        }

        ButtonPiano
        {
            id: buttonOk

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp100

            borderLeft : borderSize
            borderRight: 0

            text: qsTr("OK")

            KeyNavigation.backtab: lineEditPassword
            KeyNavigation.tab    : buttonCancel

            onClicked: pApply()
        }
    }
}
