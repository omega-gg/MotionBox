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

BasePanelSettings
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool hasSettings: (player.outputType == AbstractBackend.OutputVbml)

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    sources: [ Qt.resolvedUrl("PageOutput.qml"),
               Qt.resolvedUrl("PageOutputSettings.qml"),
               Qt.resolvedUrl("PageOutputAdvanced.qml") ]

    titles: [ qsTr("Output"), qsTr("Settings"), qsTr("Advanced") ]

    // NOTE: For now we only have settings for the VBML output.
    button.enabled: hasSettings

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onHasSettingsChanged:
    {
        if (hasSettings) selectTab(1);
        else             selectTab(0);
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // BasePanelSettings reimplementation

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionOutputExpose)) return;

        timer.stop();

        gui.panelAddHide();

        panelSettings .collapse();
        panelSubtitles.collapse();

        loadPage();

        isExposed = true;

        z = 1;

        panelSettings .z = 0;
        panelSubtitles.z = 0;

        visible = true;

        player.scanOutput = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionOutputCollapse)) return;

        isExposed = false;

        // NOTE: We want to clear the output(s) later in case we reopen this page right away.
        //       That being said, we don't want to scan at all time.
        timer.restart();

        gui.startActionCue(st.duration_faster);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: st.pageOutput_interval

        onTriggered: player.scanOutput = false
    }

    ButtonPushIcon
    {
        anchors.right: parent.right
        anchors.top  : parent.top

        width : st.dp32
        height: st.dp32

        visible: (hasSettings == false)

        icon          : st.icon_tevolution
        iconSourceSize: st.size24x24

        enableFilter: false

        onClicked: gui.openUrl("https://omega.gg/tevolution")
    }
}
