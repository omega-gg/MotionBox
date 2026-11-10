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

    /* read */ property bool isExpanded: false

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pVersion: (online.version && online.version != sk.version)

    property bool pUpdate: false

    property bool pMessage: (online.messageUrl != "")

    property bool pContextual: false

    property int pSize: st.dp32 + st.border_size * 2

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonBackward: buttonBackward
    property alias buttonForward : buttonForward

    property alias buttonVersion: buttonVersion
    property alias buttonMessage: buttonMessage

    property alias lineEditSearch: lineEditSearch

    property alias buttonBrowse : buttonBrowse
    property alias buttonRelated: buttonRelated
    property alias buttonExpand : buttonExpand

    property alias buttonIconify : buttonIconify
    property alias buttonMaximize: buttonMaximize
    property alias buttonClose   : buttonClose

    property alias border: border

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right

    height: st.dp48 + border.size

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "hidden"; when: isExpanded

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

            ScriptAction
            {
                script: if (isExpanded) visible = false
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

    function expand()
    {
        if (isExpanded) return;

        isExpanded = true;
    }

    function restore()
    {
        if (isExpanded == false) return;

        isExpanded = false;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------

    function showTrackMenu()
    {
        panelContextual.loadPageTab(currentTab);

        if (areaContextual.showPanelMargins(panelContextual, itemTrack, 0, -st.border_size))
        {
            pContextual = true;

            areaContextual.parentContextual = barWindow;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onContextualClear() { pContextual = false; }

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

    Timer
    {
        id: timer

        interval: st.duration_normal
    }

    Rectangle
    {
        id: barBackground

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

    ViewDrag
    {
        anchors.left : parent.left
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
                mouse.x < buttonIconify.x)
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

    ButtonPushLeftIcon
    {
        id: buttonBackward

        anchors.left: parent.left

        anchors.leftMargin: st.dp16

        anchors.verticalCenter: barBackground.verticalCenter

        width : st.dp38
        height: pSize

        showBorder: false

        enabled: (currentTab != null && currentTab.hasPreviousBookmark)

        highlighted: (enabled && player.hasStarted)

        icon          : st.icon16x16_goBackward
        iconSourceSize: st.size16x16

        onClicked:
        {
            panelTag.collapse();

            gui.saveTrackData();

            currentTab.setPreviousBookmark();
        }
    }

    ButtonPushCenterIcon
    {
        id: buttonForward

        anchors.left: buttonBackward.right

        anchors.verticalCenter: buttonBackward.verticalCenter

        width : st.dp38
        height: pSize

        showBorder: false

        enabled: (currentTab != null && currentTab.hasNextBookmark)

        highlighted: (enabled && player.hasStarted)

        icon          : st.icon16x16_goForward
        iconSourceSize: st.size16x16

        onClicked:
        {
            panelTag.collapse();

            gui.saveTrackData();

            currentTab.setNextBookmark();
        }

        BorderVertical { anchors.right: parent.right }
    }

    ButtonPiano
    {
        id: buttonVersion

        anchors.left: buttonForward.right
        anchors.top : border.top

        borderRight : borderSize
        borderTop   : borderSize
        borderBottom: borderSize

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
                anchors.bottom: buttonBackward.bottom
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

        borderRight : borderSize
        borderTop   : borderSize
        borderBottom: borderSize

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
                anchors.bottom: buttonBackward.bottom
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
                                              : buttonForward.right

        anchors.top: border.top

        height: buttonVersion.height

        borderRight : borderSize
        borderTop   : borderSize
        borderBottom: borderSize

        maximumWidth: st.dp192

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
                anchors.bottom: buttonBackward.bottom
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

    ItemTab
    {
        id: itemTrack

        anchors.right: (buttonDownloads.visible) ? buttonDownloads.left
                                                 : borderButtons.left

        anchors.rightMargin: st.dp12

        anchors.verticalCenter: buttonBackward.verticalCenter

        width: Math.min(st.dp256, Math.round(parent.width / 6))

        height: pSize

        borderRight: 0

        // NOTE: lineEditSearch is declared after this item, it covers the rounded left corners.
        background.anchors.leftMargin: -(background.radius)

        background.radius: st.buttonPush_radius

        background.border.width: st.border_size
        background.border.color: st.border_color

        itemIcon.x: background.radius

        isHovered: (hoverActive || pContextual)
        isCurrent: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        icon: (currentTab.cover == "") ? currentTab.videoShot
                                       : currentTab.cover

        iconDefault    : st.icon16x16_track
        iconDefaultSize: st.size16x16

        iconWidth: st.dp56

        iconFillMode: SkyImage.PreserveAspectCrop

        iconAsynchronous: true

        iconCache: (currentTab.cover != "")

        text:
        {
            if (currentTab.isValid)
            {
                return st.getTabTitle(currentTab.title, currentTab.state, currentTab.source);
            }
            else return qsTr("New Track");
        }

        textMargin: (buttonsTrack.visible) ? buttonsTrack.width + st.dp16 : st.dp8

        /* QML_EVENT */ onPressed: function(mouse)
        {
            window.clearFocus();

            if (mouse.button & Qt.LeftButton)
            {
                gui.selectCurrentTrack();
            }
            else if (mouse.button & Qt.RightButton)
            {
                showTrackMenu();
            }
            else if (mouse.button & Qt.MiddleButton)
            {
                gui.closeTrack();
            }
        }

        /* QML_EVENT */ onDoubleClicked: function(mouse)
        {
            if (mouse.button & Qt.LeftButton)
            {
                if (panelTracks.isExpanded)
                {
                    panelTracks.restore();
                }
                else player.play();
            }
        }

        RectangleLive
        {
            anchors.right : itemTrack.itemIcon.right
            anchors.bottom: itemTrack.itemIcon.bottom

            trackType: currentTab.type
        }

        ButtonsItem
        {
            id: buttonsTrack

            anchors.right: parent.right

            anchors.rightMargin: st.dp5

            anchors.verticalCenter: parent.verticalCenter

            visible: itemTrack.isHovered

            checked: pContextual

            buttonClose.enabled: currentTab.isValid

            onContextual: showTrackMenu()

            onClose: gui.closeTrack()
        }
    }

    LineEditSearch
    {
        id: lineEditSearch

        anchors.left: (buttonMessage.visible) ? buttonMessage.right
                                              : buttonMessage.left

        anchors.right: itemTrack.left

        anchors.verticalCenter: buttonBackward.verticalCenter
    }

    BorderHorizontal
    {
        anchors.left  : lineEditSearch.left
        anchors.right : lineEditSearch.right
        anchors.bottom: lineEditSearch.top

        color: st.border_color
    }

    BorderHorizontal
    {
        anchors.left : lineEditSearch.left
        anchors.right: lineEditSearch.right
        anchors.top  : lineEditSearch.bottom

        color: st.border_color
    }

    BorderVertical
    {
        id: borderButtons

        anchors.right: buttonBrowse.left

        anchors.rightMargin: st.dp12
    }

    ButtonPushIcon
    {
        id: buttonDownloads

        anchors.right: borderButtons.left
        anchors.top  : buttonBrowse.top

        anchors.rightMargin: st.dp12

        width : st.dp38
        height: pSize

        visible: panelDownloads.hasDownloaded

        checkable: true
        checked  : panelDownloads.isExposed

        icon: st.icon18x18_download

        // NOTE: The icon makes room for the progress.
        iconSourceSize: (panelDownloads.isActive) ? st.size14x14
                                                  : st.size18x18

//#QT_4
        onPressed: panelDownloads.toggleExpose()
//#ELSE
        onPressed: Qt.callLater(panelDownloads.toggleExpose)

        // NOTE: We only want the progress while downloading.
        Loader
        {
            anchors.centerIn: parent

            source: (panelDownloads.isActive) ? "ItemDownloadProgress.qml" : ""
        }
//#END
    }

    ButtonPushLeftIcon
    {
        id: buttonBrowse

        anchors.right: buttonRelated.left
        anchors.top  : buttonRelated.top

        width : st.dp38
        height: pSize

        showBorder: false

        checkable: true

        checked: (timer.running || (gui.isExpanded == false && panelBrowse.isExposed))

        icon          : st.icon20x20_search
        iconSourceSize: st.size20x20

        onPressed:
        {
            if (gui.isExpanded)
            {
                timer.start();

                gui.restore();

                panelBrowse.expose();
            }
            else panelBrowse.toggleExpose();
        }
    }

    ButtonPushCenterIcon
    {
        id: buttonRelated

        anchors.right: buttonExpand.left
        anchors.top  : buttonExpand.top

        width : st.dp38
        height: pSize

        showBorder: false

        checkable: true
        checked  : panelRelated.isExposed

        icon          : st.icon20x20_related
        iconSourceSize: st.size20x20

        onPressed:
        {
            if (panelTracks.isExpanded)
            {
                panelRelated.expose();
            }
            else panelRelated.toggleExpose();
        }
    }

    ButtonPushRightIcon
    {
        id: buttonExpand

        anchors.right: buttonIconify.left

        anchors.rightMargin: st.dp32

        anchors.verticalCenter: buttonBackward.verticalCenter

        width : st.dp38
        height: pSize

        showBorder: false

        checkable: true

        checked: gui.isExpanded

        icon          : st.icon20x20_expand
        iconSourceSize: st.size20x20

        onPressed: gui.toggleExpand()
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
