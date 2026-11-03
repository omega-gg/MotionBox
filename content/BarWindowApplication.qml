//=================================================================================================
/*
    Copyright (C) 2015-2026 MotionBox authors united with omega. <http://omega.gg/about>

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

Item
{
    id: barWindow

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property bool pVersion: (online.version && online.version != sk.version)

    property bool pUpdate: false

    property bool pMessage: (online.messageUrl != "")

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonVersion: buttonVersion
    property alias buttonMessage: buttonMessage

    property alias buttonIconify : buttonIconify
    property alias buttonMaximize: buttonMaximize
    property alias buttonClose   : buttonClose

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    anchors.bottomMargin: barTop.height

    height: st.dp32 + border.size

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: (window.fullScreen && barTop.isExpanded)

        AnchorChanges
        {
            target: barWindow

            anchors.bottom: parent.top
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------
    // Private

    onPVersionChanged:
    {
//#WINDOWS
        // NOTE windows/uwp: Updates are handled by the store.
        if (sk.isUwp) return;
//#END

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

            buttonUpdate.setFocus();
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
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pRestoreMaximize()
    {
        if (window.fullScreen)
        {
            gui.restoreFullScreen();

//#!MAC+!MOBILE
            // FIXME macOS: We can't go from full screen to normal window right away.
            //              This could be related to the animation.
            gui.restoreMaximize();
//#END
        }
        else gui.toggleMaximize();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: border.top

        gradient: Gradient
        {
            GradientStop
            {
                position: 0.0

                color: (window.isActive) ? st.barWindow_colorA
                                         : st.barWindow_colorDisableA
            }

            GradientStop
            {
                position: 1.0

                color: (window.isActive) ? st.barWindow_colorB
                                         : st.barWindow_colorDisableB
            }
        }

        BorderHorizontal
        {
            color: st.barWindow_colorBorderLine

            visible: (st.barWindow_colorA != st.barWindow_colorB)
        }
    }

    ButtonPiano
    {
        id: buttonVersion

        anchors.top: border.top

        borderRight: borderSize
        borderTop  : borderSize

//#WINDOWS
        // NOTE windows/uwp: Updates are handled by the store.
        visible: (sk.isUwp == false && pVersion)
//#ELSE
        visible: pVersion
//#END

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
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation
                {
                    duration: st.duration_normal

                    easing.type: st.easing
                }

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

        onPressed: pUpdate = !(pUpdate)
    }

    ButtonPiano
    {
        id: buttonUpdate

        anchors.left : buttonVersion.left
        anchors.right: buttonVersion.right
        anchors.top  : border.top

        height: buttonVersion.height

        borderRight: borderSize
        borderTop  : borderSize

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
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation
                {
                    duration: st.duration_faster

                    easing.type: st.easing
                }

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
            if (core.updateVersion())
            {
                window.close();

                return;
            }

            gui.openUrl("https://omega.gg/MotionBox/get");

            window.clearFocus();
        }

        /* QML_EVENT */ Keys.onPressed: function(event)
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

        anchors.left: (buttonVersion.visible) ? buttonVersion.right
                                              : parent.left

        anchors.top: border.top

        height: buttonVersion.height

        borderRight: borderSize

        maximumWidth: buttonIconify.x - x + borderRight

        borderTop: borderSize

        visible: pMessage

        icon: online.messageIcon

        iconDefault   : st.icon20x20_love
        iconSourceSize: st.size20x20

        enableFilter: isIconDefault

        text: online.messageTitle

        font.pixelSize: st.dp14

        states: State
        {
            name: "exposed"; when: pMessage

            AnchorChanges
            {
                target: buttonMessage

                anchors.top   : undefined
                anchors.bottom: border.top
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                AnchorAnimation
                {
                    duration: st.duration_normal

                    easing.type: st.easing
                }

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

    ViewDrag
    {
        id: viewDrag

        anchors.left: (buttonMessage.visible) ? buttonMessage.right
                                              : buttonMessage.left

        anchors.right: parent.right

//#QT_4
        height: parent.height
//#ELSE
        // FIXME Qt5: Clickable area is larger than item height.
        height: parent.height - border.size
//#END

        y: -(parent.y)

        dragEnabled: (window.fullScreen == false)

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        /* QML_EVENT */ onPressed: function(mouse)
        {
            window.clearFocus();

            if (window.resizer.visible && window.isTouching
                &&
                (viewDrag.x + mouse.x) < buttonIconify.x)
            {
                window.toggleTouch();
            }
        }

        /* QML_EVENT */ onDoubleClicked: function(mouse)
        {
            if (mouse.button & Qt.LeftButton)
            {
                pRestoreMaximize();
            }
        }
    }

    ButtonPianoWindow
    {
        id: buttonIconify

        anchors.right : (buttonMaximize.visible) ? buttonMaximize.left
                                                 : buttonClose   .left

        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderLeft  : borderSize
        borderBottom: borderSize

        icon          : st.icon12x12_iconify
        iconSourceSize: st.size12x12

        onClicked: window.minimized = true
    }

    ButtonPianoWindow
    {
        id: buttonMaximize

        anchors.right : buttonClose.left
        anchors.top   : buttonClose.top
        anchors.bottom: buttonClose.bottom

        borderBottom: borderSize

        highlighted: (window.maximized || window.fullScreen)

        icon: (highlighted) ? st.icon12x12_minimize
                            : st.icon12x12_maximize

        iconSourceSize: st.size12x12

        onClicked: pRestoreMaximize()
    }

    ButtonPianoWindow
    {
        id: buttonClose

        anchors.right: parent.right
        anchors.top  : parent.top

        height: st.barWindow_height + borderSizeHeight

        borderBottom: borderSize

        icon          : st.icon12x12_close
        iconSourceSize: st.size12x12

        colorHoverA: st.button_colorConfirmHoverA
        colorHoverB: st.button_colorConfirmHoverB

        colorPressA: st.button_colorConfirmPressA
        colorPressB: st.button_colorConfirmPressB

        filterIcon: (isHovered || isPressed) ? st.button_filterIconB
                                             : st.button_filterIconA

        onClicked: window.close()
    }

    BorderHorizontal
    {
        id: border

        anchors.bottom: parent.bottom

        color: st.border_color
    }
}
