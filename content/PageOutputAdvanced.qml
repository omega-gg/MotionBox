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
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: pUpdateVisible()

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
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function pUpdateVisible()
    {
        buttonClear.visible    = pOutput.hasSetting("CLEAR");
        buttonStartup.visible  = pOutput.hasSetting("STARTUP");
        buttonShutdown.visible = pOutput.hasSetting("SHUTDOWN");
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ButtonOutput
    {
        borderBottom: (buttonClear.visible || buttonStartup.visible || buttonShutdown.visible)
                      ? borderSize
                      : 0

        onClicked: panelOutput.selectTab(1)
    }

    ButtonWide
    {
        id: buttonClear

        text: qsTr("Clear cache")

        onClicked:
        {
            pOutput.clearCache();

            enabled = false;
        }
    }

    ButtonCheckSettings
    {
        id: buttonStartup

        checked: pOutput.startup

        text: qsTr("Run on startup")

        onCheckClicked: pOutput.startup = checked
    }

    ButtonSettings
    {
        id: buttonShutdown

        settings: [{ "title": qsTr("Yes") },
                   { "title": qsTr("No")  }]

        icon          : st.icon16x16_shutdown
        iconSourceSize: st.size16x16

        text: qsTr("Shutdown")

        function onSelect(index)
        {
            pOutput.shutdown();
        }
    }
}
