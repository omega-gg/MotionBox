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
    /* read */ property int contentHeight: buttonStyle.y + buttonStyle.height

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
    // Quality

    function pScaleString()
    {
        return qsTr("%1 %").arg(Math.round(st.scale * 100));
    }

    function pScaleIndex()
    {
        var scale = st.scale;

        if      (scale == 0.92) return 0;
        else if (scale == 1.0)  return 1;
        else if (scale == 1.28) return 2;
        else if (scale == 1.6)  return 3;
        else if (scale == 2.0)  return 4;
    }

    function pScaleSelect(index)
    {
        if      (index == 0) gui.scale(0.92);
        else if (index == 1) gui.scale(1.0);
        else if (index == 2) gui.scale(1.28);
        else if (index == 3) gui.scale(1.6);
        else                 gui.scale(2.0);
    }

    //---------------------------------------------------------------------------------------------
    // Style

    function pStyleString()
    {
        var style = local.style;

        if      (style == 0) return qsTr("Light");
        else if (style == 1) return qsTr("Night");
        else if (style == 2) return qsTr("Bold");
        else                 return qsTr("Classic");
    }

    function pStyleIndex() { return local.style }

    function pStyleSelect(index)
    {
        st.applyStyle(index);

        gui.updateColor();

        local.style = index;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

//#DESKTOP
    ButtonCheckSettings
    {
        id: buttonDefault

//#WINDOWS
        visible: (sk.isUwp == false)
//#END

        checked: controllerPlaylist.associateVbml

        text: qsTr("Set default player")

        onCheckClicked: controllerPlaylist.associateVbml = checked
    }
//#END

    BarSettings
    {
//#DESKTOP
        borderTop: (buttonDefault.visible) ? borderSize : 0
//#END

        text: qsTr("Content")
    }

    ButtonWide
    {
        text: qsTr("View storage")

        onClicked: gui.openFile(core.pathStorage)
    }

    BarSettings { text: qsTr("Cache") }

    ButtonsCheck
    {
        id: buttonsClear

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

        onClicked:
        {
            if (index == 0)
            {
                gui.clearTabs();

                itemAt(0).enabled = false;
            }
            else
            {
                gui.clearCache();

                itemAt(1).enabled = false;
            }
        }
    }

    ButtonWide
    {
        text: qsTr("Clear both")

        onClicked:
        {
            buttonsClear.clickAt(0);
            buttonsClear.clickAt(1);

            enabled = false;
        }
    }

    BarSettings { text: qsTr("Scale") }

    ButtonSettings
    {
        settings: [{ "title": qsTr("92 %")  },
                   { "title": qsTr("100 %") },
                   { "title": qsTr("128 %") },
                   { "title": qsTr("160 %") },
                   { "title": qsTr("200 %") }]

        text: pScaleString()

        currentIndex: pScaleIndex()

        function onSelect(index) { pScaleSelect(index) }
    }

    BarSettings { text: qsTr("Style") }

    ButtonSettings
    {
        id: buttonStyle

        settings: [{ "title": qsTr("Light")   },
                   { "title": qsTr("Night")   },
                   { "title": qsTr("Bold")    },
                   { "title": qsTr("Classic") }]

        text: pStyleString()

        currentIndex: pStyleIndex()

        function onSelect(index) { pStyleSelect(index) }
    }
}
