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
    // NOTE: We have to rely on these properties to avoid binding loops in BasePanelSettings.

    /* read */ property int contentWidth : st.dp192
    /* read */ property int contentHeight: button.y + button.height

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

//#QT_NEW
    // NOTE Qt5.9: We need to forceLayout and processEvents to get the proper contentHeight.
    Component.onCompleted: if (typeof forceLayout == "function") forceLayout()
//#END

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // BasePanelSettings events

    // NOTE: We need to forceLayout and processEvents to get the proper contentHeight.
    function onShow()
    {
        sk.processEvents();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#DESKTOP
    ButtonCheckSettings
    {
//#WINDOWS
        visible: (sk.isUwp == false)
//#END

        checked: controllerPlaylist.associateVbml

        text: qsTr("Set default player")

        onCheckClicked: controllerPlaylist.associateVbml = checked
    }
//#END

    BarSettings { text: qsTr("Content") }

    ButtonPush
    {
        anchors.left : parent.left
        anchors.right: parent.right

        text: qsTr("View storage")
    }

    BarSettings { text: qsTr("Cache") }

    ButtonsCheck
    {
        anchors.left : parent.left
        anchors.right: parent.right

        checkable: false

        model: ListModel {}

        Component.onCompleted:
        {
//#QT_4
            // NOTE Qt4: We can only append items one by one.
            model.append({ "title": qsTr("Clear tabs") });
            model.append({ "title": qsTr("Clear cache") });
//#ELSE
            model.append(
            [
                { "title": qsTr("Clear tabs") },
                { "title": qsTr("Clear cache") }
            ]);
//#END
        }
    }

    ButtonPush
    {
        anchors.left : parent.left
        anchors.right: parent.right

        text: qsTr("Clear both")
    }

    BarSettings { text: qsTr("Zoom") }

    ButtonPush
    {
        anchors.left : parent.left
        anchors.right: parent.right

        text: qsTr("100%")
    }

    BarSettings { text: qsTr("Style") }

    ButtonPush
    {
        id: button

        anchors.left : parent.left
        anchors.right: parent.right

        text: qsTr("Light")
    }
}
