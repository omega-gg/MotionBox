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

Panel
{
    id: panelGet

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    /* read */ property int indexCurrent: -1

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias page: loader.item

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

//#QT_4
    anchors.right: parent.right
    anchors.top  : parent.bottom

    anchors.rightMargin: st.dp52
//#ELSE
    // FIXME Qt5.12 Win8: Panel size changes for no reason when hidden.
    x: parent.width - width - st.dp52

    y: parent.height + height
//#END

    width: st.dp480 + borderSizeWidth

    height: bar.height + loader.height + borderSizeHeight

    borderLeft  : borderSize
    borderRight : borderLeft
    borderBottom: 0

    visible: false

    backgroundOpacity: st.panelContextual_backgroundOpacity

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

//#QT_4
        AnchorChanges
        {
            target: panelGet

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
//#ELSE
        PropertyChanges
        {
            target: panelGet

            y: parent.height - panelGet.height
        }
//#END
    }

    transitions: Transition
    {
        SequentialAnimation
        {
//#QT_4
            AnchorAnimation
            {
                duration: st.duration_faster

                easing.type: st.easing
            }
//#ELSE
            NumberAnimation
            {
                property: "y"

                duration: st.duration_faster

                easing.type: st.easing
            }
//#END

            ScriptAction
            {
                script:
                {
                    if (isExposed == false) visible = false;

                    z = 0;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    Keys.onPressed:
    {
        if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            collapse();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionShareExpose)) return;

        gui.panelAddHide();

        panelSettings.collapse();

        if (indexCurrent == -1)
        {
            indexCurrent = 0;

            loader.load(Qt.resolvedUrl("PageSubtitles.qml"));

            page.onShow();
        }
        else if (indexCurrent == 0)
        {
            page.onShow();
        }

        isExposed = true;

        z = 1;

        panelSettings.z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionShareCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function selectTab(index)
    {
        if (indexCurrent == index) return;

        indexCurrent = index;

        if (index == 0)
        {
            loader.load(Qt.resolvedUrl("PageSubtitles.qml"));

            if (isExposed) page.onShow();
        }
    }

    //---------------------------------------------------------------------------------------------

    function clearSubtitle()
    {
        if (indexCurrent == 0) page.clearSubtitle();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        height: st.dp32 + borderSizeHeight

        borderTop: 0

        ButtonPiano
        {
            width: st.dp128

            checkable: true
            checked  : (indexCurrent == 0)

            checkHover: false

            text: qsTr("Subtitles")

            font.pixelSize: st.dp14
        }
    }

    LoaderSlide
    {
        id: loader

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : bar.bottom

        height: (item) ? item.height : 0
    }
}
