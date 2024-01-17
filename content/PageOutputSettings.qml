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

ColumnScroll
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property variant pOutput: core.output

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: pOutput

        /* QML_CONNECTION */ function onSettingsChanged()
        {
            pUpdateVisible();
        }

        /* QML_CONNECTION */ function onVolumeChanged()
        {
            sliderVolume.value = pOutput.volume;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function pUpdateVisible()
    {
        sliderVolume.visible     = pOutput.hasSetting("VOLUME");
        buttonScreen.visible     = pOutput.hasSetting("SCREEN");
        buttonFullScreen.visible = pOutput.hasSetting("FULLSCREEN");
        buttonVideoTag.visible   = pOutput.hasSetting("VIDEOTAG");

        buttonAdvanced.visible = (pOutput.hasSetting("CLEAR") || pOutput.hasSetting("STARTUP")
                                  ||
                                  pOutput.hasSetting("SHUTDOWN"));
    }

    //---------------------------------------------------------------------------------------------
    // Screen

    function pScreenSettings()
    {
        var settings = new Array;

        for (var i = 0; i < pOutput.screenCount; i++)
        {
            settings.push({ "title": qsTr("Screen %1").arg(i + 1) });
        }

        return settings;
    }

    function pScreenString()
    {
        return qsTr("Screen %1").arg(pOutput.screen + 1);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ButtonOutput { onClicked: panelOutput.selectTab(0) }

    ButtonWideFull
    {
        icon          : st.icon16x16_unlink
        iconSourceSize: st.size16x16

        text: qsTr("Disconnect")

        onClicked:
        {
            player.currentOutput = 0;

            // NOTE: We want to hide the panel right away.
            panelOuput.collapse();
        }
    }

    BarSettings
    {
        visible: sliderVolume.visible

        text: qsTr("Volume")
    }

    SliderWide
    {
        id: sliderVolume

        value: pOutput.volume

        onValueChanged: pOutput.volume = value
    }

    BarSettings
    {
        visible: (buttonScreen.visible || buttonFullScreen.visible || buttonVideoTag.visible)

        text: qsTr("Display")
    }

    ButtonSettings
    {
        id: buttonScreen

        settings: pScreenSettings()

        text: pScreenString()

        currentIndex: pOutput.screen

        function onSelect(index) { pOutput.screen = index }
    }

    ButtonCheckSettings
    {
        id: buttonFullScreen

        checked: pOutput.fullScreen

        text: qsTr("Fullscreen")

        onCheckClicked: pOutput.fullScreen = checked
    }

    ButtonCheckSettings
    {
        id: buttonVideoTag

        checked: pOutput.videoTag

        text: qsTr("Show VideoTag")

        onCheckClicked: pOutput.videoTag = checked
    }

    ButtonWide
    {
        id: buttonAdvanced

        text: qsTr("Advanced")

        onClicked: panelOutput.selectTab(2)
    }
}
