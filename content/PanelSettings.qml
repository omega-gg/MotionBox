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

Panel
{
    id: panelSettings

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    /* read */ property int indexCurrent: -1

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

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

    anchors.rightMargin: st.dp96
//#ELSE
    // FIXME Qt5.12 Win8: Panel size changes for no reason when hidden.
    x: parent.width - width - st.dp96

    y: parent.height + height
//#END

    width: st.dp400 + borderSizeWidth

    height: bar.height + loader.height + borderSizeHeight

    borderRight : borderSize
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
            target: panelSettings

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
//#ELSE
        PropertyChanges
        {
            target: panelSettings

            y: parent.height - panelSettings.height
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
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on height
    {
        enabled: pAnimate

        PropertyAnimation
        {
            duration: st.duration_fast

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionSettingsExpose)) return;

        gui.panelAddHide();

        panelGet.collapse();

        if (indexCurrent == -1)
        {
            indexCurrent = 0;

            loader.load(Qt.resolvedUrl("PageSettingsVideo.qml"));

            //page.onShow();
        }
        /*else if (indexCurrent == 0)
        {
            page.onShow();
        }*/

        isExposed = true;

        z = 1;

        panelGet.z = 0;

        visible = true;

        gui.startActionCue(st.duration_faster);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionSettingsCollapse)) return;

        isExposed = false;

        gui.startActionCue(st.duration_faster);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pSelectTab(index)
    {
        if (loader.isAnimated || indexCurrent == index) return;

        var source;

        if (index == 0)
        {
            source = Qt.resolvedUrl("PageSettingsVideo.qml");
        }
        else if (index == 1)
        {
            source = Qt.resolvedUrl("PageSettingsAdvanced.qml");
        }
        else source = Qt.resolvedUrl("PageConsole.qml");

        pAnimate = true;

        if (indexCurrent < index)
        {
             loader.loadLeft(source);
        }
        else loader.loadRight(source);

        pAnimate = false;

        indexCurrent = index;

        loader.item.forceActiveFocus();
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
            id: buttonVideo

            width: Math.round(parent.width / 3)

            checkable: true
            checked  : (indexCurrent == 0)

            checkHover: false

            text: qsTr("Video")

            font.pixelSize: st.dp14

//#QT_4
            onPressed: pSelectTab(0)
//#ELSE
            onPressed: Qt.callLater(pSelectTab, 0)
//#END
        }

        ButtonPiano
        {
            id: buttonAdvanced

            anchors.left: buttonVideo.right

            width: buttonVideo.width

            checkable: true
            checked  : (indexCurrent == 1)

            checkHover: false

            text: qsTr("Advanced")

            font.pixelSize: st.dp14

//#QT_4
            onPressed: pSelectTab(1)
//#ELSE
            onPressed: Qt.callLater(pSelectTab, 1)
//#END

            Rectangle
            {
                anchors.left: parent.left

                anchors.leftMargin: st.dp8

                anchors.verticalCenter: parent.verticalCenter

                width : st.dp12
                height: width

                radius: width

                visible: (buttonAdvanced.checked == false
                          &&
                          player.isPlaying && player.speed != 1.0)

                color: st.text_colorCurrent
            }
        }

        ButtonPiano
        {
            anchors.left : buttonAdvanced.right
            anchors.right: parent.right

            borderRight: 0

            checkable: true
            checked  : (indexCurrent == 2)

            checkHover: false

            text: qsTr("Console")

            font.pixelSize: st.dp14

//#QT_4
            onPressed: pSelectTab(2)
//#ELSE
            onPressed: Qt.callLater(pSelectTab, 2)
//#END
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
