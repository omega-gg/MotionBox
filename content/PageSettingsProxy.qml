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

BasePageSettings
{
    id: pageSettingsProxy

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // NOTE: We have to rely on these properties to avoid binding loops in BasePanelSettings.

    /* read */ property int contentWidth : st.dp320
    /* read */ property int contentHeight: st.dp288

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pStream: local.proxyStream

    property string pClipboard

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    itemBefore: editPassword
    itemAfter : editHost

    KeyNavigation.tab: editHost

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onCancel: loadMain()

    onOk: pApply()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pApply()
    {
        var host = sk.simplify(editHost.editText);

        var port;

        if (editPort.editText)
        {
             port = editPort.editText;
        }
        else port = -1;

        var password = editPassword.editText;

        var stream = pStream;

        var active = buttonActive.checked;

        if (local.proxyHost == host && local.proxyPort == port && local.proxyPassword == password
            &&
            local.proxyStream == stream && local.proxyActive == active)
        {
            loadMain();

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

        loadMain();
    }

    //---------------------------------------------------------------------------------------------

    function pReset()
    {
        editHost    .editText = "";
        editPort    .editText = "";
        editPassword.editText = "";

        pStream = false;

        buttonActive.checked = false;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BarSettingReset
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        enabled: (editHost.editText || editPort.editText || editPassword.editText
                  ||
                  pStream || buttonActive.checked)

        text: qsTr("Proxy settings")

        onReset: pReset()
    }

    LineEditLabel
    {
        id: editHost

        anchors.left : parent.left
        anchors.right: editPort.left
        anchors.top  : editPort.top

        anchors.leftMargin: st.dp3

        text: qsTr("Host")

        editText: local.proxyHost

        KeyNavigation.backtab: buttonCancel
        KeyNavigation.tab    : editPort
    }

    LineEditLabel
    {
        id: editPort

        anchors.right: parent.right
        anchors.top  : bar.bottom

        anchors.rightMargin: st.dp3
        anchors.topMargin  : st.dp3

        width: st.dp128

        text: qsTr("Port")

        editText: (local.proxyPort != -1) ? local.proxyPort : ""

//#QT_OLD
        textInput.validator: RegExpValidator { regExp: /[0-9]*/ }
//#ELSE
        textInput.validator: RegularExpressionValidator { regularExpression: /[0-9]*/ }
//#END

        KeyNavigation.backtab: editHost
        KeyNavigation.tab    : editPassword
    }

    LineEditLabel
    {
        id: editPassword

        anchors.left : editHost.left
        anchors.right: editPort.right
        anchors.top  : editHost.bottom

        text: qsTr("Password")

        editText: local.proxyPassword

        textInput.echoMode: TextInput.Password

        KeyNavigation.backtab: editPort
        KeyNavigation.tab    : buttonOk
    }

    ButtonPushLeft
    {
        anchors.left : editHost.left
        anchors.right: buttonStream.left
        anchors.top  : buttonStream.top

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

        width: st.dp100

        checked   : pStream
        checkHover: false

        text: qsTr("Stream")

        onPressed: pStream = true
    }

    ButtonCheckLabel
    {
        id: buttonActive

        anchors.right: parent.right
        anchors.top  : editPassword.bottom

        anchors.rightMargin: st.dp3

        checked: local.proxyActive

        text: qsTr("Active")
    }
}
