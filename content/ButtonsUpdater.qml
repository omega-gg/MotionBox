//=================================================================================================
/*
    Copyright (C) 2015-2016 MotionBox authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of MotionBox.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.
*/
//=================================================================================================

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

Item
{
    id: buttonsUpdater

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: (online.version && online.version != sk.version)

    /* read */ property bool isActive: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonVersion: buttonVersion
    property alias buttonUpdate : buttonUpdate

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted: clip = false

    onIsExposedChanged:
    {
        clip = true;

        if (isExposed)
        {
            buttonVersion.visible = true;
        }
        else clearActive();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function clearActive()
    {
        if (isActive) window.clearFocus();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonPiano
    {
        id: buttonVersion

        anchors.left  : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        borderLeft : borderSize
        borderRight: 0

        visible: isExposed

        highlighted: true
        checked    : isActive

        text: qsTr("New Version")

        state: (isExposed) ? "exposed" : ""

        states: State
        {
            name: "exposed"; when: isExposed

            AnchorChanges
            {
                target: buttonVersion

                anchors.left : undefined
                anchors.right: parent.right
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
                        buttonsUpdater.clip = false;

                        if (isExposed) return;

                        buttonVersion.visible = false;
                    }
                }
            }
        }

        onPressed:
        {
            if (buttonsUpdater.clip) return;

            if (checked == false)
            {
                buttonUpdate.text = qsTr("Update to" + ' ' + sk.getVersionLite(online.version));

                buttonUpdate.visible = true;

                buttonUpdate.focus();
            }
            else window.clearFocus();
        }
    }

    ButtonPiano
    {
        id: buttonUpdate

        anchors.left : parent.left
        anchors.right: buttonVersion.left
        anchors.top  : parent.bottom

        height: parent.height + borderSizeHeight

        borderRight: 0
        borderTop  : borderSize

        z: 1

        visible: false

        font.pixelSize: st.dp14

        states: State
        {
            name: "active"; when: isActive

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
                        if (isExposed || buttonVersion.visible == false)
                        {
                            buttonsUpdater.clip = false;
                        }

                        if (isActive) return;

                        buttonUpdate.visible = false;
                    }
                }
            }
        }

        onIsFocusedChanged:
        {
            buttonsUpdater.clip = true;

            isActive = isFocused;
        }

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
}
