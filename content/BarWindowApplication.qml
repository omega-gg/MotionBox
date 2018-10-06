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

BarWindow
{
    id: barWindow

    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property bool pVersion: (online.version && online.version != sk.version)
    property bool pUpdate : false

    property bool pMessage: (online.messageUrl != "")

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonVersion: buttonVersion
    property alias buttonMessage: buttonMessage

    property alias buttonMini: buttonMini

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    buttonApplicationMaximum: buttonMini.x - st.dp32

    //viewDrag.acceptedButtons: Qt.LeftButton | Qt.RightButton

    buttonMaximize.visible: (gui.isMini == false)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onButtonPressed:
    {
        gui.restoreBars();

        panelApplication.toggleExpose();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    onPVersionChanged:
    {
        clip = true;

        if (pVersion)
        {
            buttonVersion.visible = true;
        }
        else if (pUpdate) window.clearFocus();
    }

    onPUpdateChanged:
    {
        clip = true;

        if (pUpdate)
        {
            buttonUpdate.visible = true;

            buttonUpdate.focus();
        }
    }

    //---------------------------------------------------------------------------------------------

    onPMessageChanged:
    {
        clip = true;

        if (pMessage)
        {
            buttonMessage.visible = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pMaximize()
    {
        gui.toggleMaximize();
    }

    function pDoubleClicked(mouse)
    {
        if (mouse.button & Qt.LeftButton)
        {
             gui.toggleMaximize();
        }
        else gui.toggleMini();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonPiano
    {
        id: buttonVersion

        anchors.left: buttonApplication.right
        anchors.top : parent.bottom

        height: buttonApplication.height + borderSizeHeight

        borderTop: borderSize

        visible: pVersion

        highlighted: true
        checked    : pUpdate

        text: qsTr("New Version")

        font.pixelSize: st.dp14

        states: State
        {
            name: "exposed"; when: pVersion

            AnchorChanges
            {
                target: buttonVersion

                anchors.top   : undefined
                anchors.bottom: parent.bottom
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_normal }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pVersion) return;

                        buttonVersion.visible = false;
                    }
                }
            }
        }

        onPressed:
        {
            panelApplication.collapse();

            pUpdate = !(pUpdate);
        }
    }

    ButtonPiano
    {
        id: buttonUpdate

        anchors.left : parent.left
        anchors.right: buttonVersion.left
        anchors.top  : parent.bottom

        height: buttonVersion.height

        borderTop: borderSize

        visible: false

        text: qsTr("Update")

        font.pixelSize: st.dp14

        states: State
        {
            name: "active"; when: pUpdate

            AnchorChanges
            {
                target: buttonUpdate

                anchors.top   : undefined
                anchors.bottom: parent.bottom
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_faster }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pUpdate) return;

                        buttonUpdate.visible = false;
                    }
                }
            }
        }

        onIsFocusedChanged: pUpdate = isFocused

        onClicked:
        {
            if (core.updateVersion() == false)
            {
                gui.openUrl("http://omega.gg/MotionBox/get");

                window.clearFocus();
            }
            else window.close();
        }

        Keys.onPressed:
        {
            if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                window.clearFocus();
            }
        }
    }

    ButtonPianoFull
    {
        id: buttonMessage

        anchors.left: (buttonVersion.visible) ? buttonVersion    .right
                                              : buttonApplication.right

        anchors.top: parent.bottom

        height: buttonVersion.height

        maximumWidth: buttonMini.x - x + borderRight

        borderTop: borderSize

        visible: pMessage

        checked: (panelApplication.isExposed && panelApplication.itemTabs.indexCurrent == 1
                  &&
                  panelApplication.sourceAbout == Qt.resolvedUrl("PageAboutMessage.qml"))

        icon: online.messageIcon

        iconDefault   : st.icon24x24_love
        iconSourceSize: st.size24x24

        enableFilter: isIconDefault

        text: online.messageTitle

        font.pixelSize: st.dp14

        onClicked:
        {
            if (checked)
            {
                 panelApplication.collapse();
            }
            else panelApplication.setAboutPage("PageAboutMessage.qml");
        }

        states: State
        {
            name: "exposed"; when: pMessage

            AnchorChanges
            {
                target: buttonMessage

                anchors.top   : undefined
                anchors.bottom: parent.bottom
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation { duration: st.duration_normal }

                ScriptAction
                {
                    script:
                    {
                        barWindow.clip = false;

                        if (pMessage) return;

                        buttonMessage.visible = false;
                    }
                }
            }
        }
    }

    ButtonPianoIcon
    {
        id: buttonMini

        anchors.right : buttonIconify.left
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        borderLeft : borderSize
        borderRight: 0

        highlighted: gui.pMini

        checkable: true
        checked  : gui.isMini

        icon: (gui.isMini) ? st.icon16x16_maxi
                           : st.icon16x16_mini

        iconSourceSize: st.size16x16

        onClicked: gui.toggleMini();
    }
}
