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
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    itemBefore: editConnections
    itemAfter : editCache

    KeyNavigation.tab: editCache

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onCancel: pageSettings.loadMain()

    onOk: pApply()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pApply()
    {
        var connections = editConnections.editText;

        var upload   = editUpload  .editText;
        var download = editDownload.editText;

        var uploadActive   = buttonUpload  .checked;
        var downloadActive = buttonDownload.checked;

        var cache = editCache.editText;

        if (local.torrentConnections == connections
            &&
            local.torrentUpload == upload && local.torrentDownload == download
            &&
            local.torrentUploadActive == uploadActive
            &&
            local.torrentDownloadActive == downloadActive
            &&
            local.torrentCache == cache)
        {
            pageSettings.loadMain();

            return;
        }

        local.torrentConnections = connections;

        local.torrentUpload   = upload;
        local.torrentDownload = download;

        local.torrentUploadActive   = uploadActive;
        local.torrentDownloadActive = downloadActive;

        local.torrentCache = cache;

        if (uploadActive == false)
        {
            upload = 0;
        }

        if (downloadActive == false)
        {
            download = 0;
        }

        core.applyTorrentOptions(connections, upload, download, cache);

        pageSettings.loadMain();
    }

    //---------------------------------------------------------------------------------------------

    function pReset()
    {
        editConnections.editText = "500";

        editUpload  .editText = '0';
        editDownload.editText = '0';

        buttonUpload  .checked = false;
        buttonDownload.checked = false;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarSettingReset
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        enabled: (editCache.editText != 1000)

        text: qsTr("Torrent settings")

        onReset: editCache.editText = 1000
    }

    LineEditValue
    {
        id: editCache

        anchors.left : parent.left
        anchors.right: buttonCache.left
        anchors.top  : bar.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        width: labelWidth + st.dp64

        text : qsTr("Cache size")
        value: qsTr("Mb")

        editText: local.torrentCache

        textInput.validator: IntValidator { bottom: 0; top: 100000 }

        KeyNavigation.backtab: buttonCancel
        KeyNavigation.tab    : editUpload
    }

    ButtonPush
    {
        id: buttonCache

        anchors.right: parent.right
        anchors.top  : editCache.top

        anchors.rightMargin: st.dp3

        width: st.dp110

        enabled: sk.fileExists(controllerFile.fileUrl(core.pathStorage + "/torrents"))

        text: qsTr("Clear cache")

        onClicked:
        {
            enabled = false;

            core.clearTorrentCache();
        }
    }

    BarSettingReset
    {
        id: barLimits

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : editCache.bottom

        anchors.topMargin: st.dp3

        enabled: (editConnections.editText != "500"
                  ||
                  editUpload.editText != '0' || editDownload.editText != '0'
                  ||
                  buttonUpload.checked || buttonDownload.checked)

        text: qsTr("Torrent limits")

        onReset: pReset()
    }

    LineEditValue
    {
        id: editUpload

        anchors.left : parent.left
        anchors.right: buttonUpload.left
        anchors.top  : barLimits.bottom

        anchors.leftMargin: st.dp3
        anchors.topMargin : st.dp3

        labelWidth: st.dp108

        text : qsTr("Upload")
        value: qsTr("Kb")

        editText: local.torrentUpload

        textInput.validator: IntValidator { bottom: 0; top: 100000 }

        KeyNavigation.backtab: editCache
        KeyNavigation.tab    : editDownload
    }

    ButtonCheckLabel
    {
        id: buttonUpload

        anchors.right: parent.right
        anchors.top  : editUpload.top

        anchors.rightMargin: st.dp3

        checked: local.torrentUploadActive

        text: qsTr("Active")
    }

    LineEditValue
    {
        id: editDownload

        anchors.left : parent.left
        anchors.right: buttonDownload.left
        anchors.top  : editUpload.bottom

        anchors.leftMargin: st.dp3

        width: editUpload.width

        labelWidth: editUpload.labelWidth

        text : qsTr("Download")
        value: qsTr("Kb")

        editText: local.torrentDownload

        textInput.validator: IntValidator { bottom: 0; top: 100000 }

        KeyNavigation.backtab: editUpload
        KeyNavigation.tab    : editConnections
    }

    ButtonCheckLabel
    {
        id: buttonDownload

        anchors.right: parent.right
        anchors.top  : editDownload.top

        anchors.rightMargin: st.dp3

        checked: local.torrentDownloadActive

        text: qsTr("Active")
    }

    LineEditLabel
    {
        id: editConnections

        anchors.left: parent.left
        anchors.top : buttonDownload.bottom

        anchors.leftMargin: st.dp3

        width: labelWidth + st.dp32

        text: qsTr("Maximum connections")

        editText: local.torrentConnections

        textInput.validator: IntValidator { bottom: 0; top: 1000 }

        KeyNavigation.backtab: editDownload
        KeyNavigation.tab    : buttonOk
    }
}
