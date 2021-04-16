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

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool hasMessage: (online.messageUrl != "")

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pLoad(page)
    {
        loadPage(Qt.resolvedUrl(page));
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonLogo
    {
        id: logo

        anchors.top: parent.top

        anchors.topMargin: st.dp16

        anchors.horizontalCenter: parent.horizontalCenter

        sourceSize.height: st.dp64

        source: st.logoApplication

        fillMode: Image.PreserveAspectFit

        onClicked: gui.openUrl("http://omega.gg/MotionBox")
    }

    TextLogo
    {
        id: textLogo

        anchors.top: logo.bottom

        text: qsTr("Video Browser")
    }

    ButtonPushCenterIcon
    {
        id: buttonMessage

        anchors.top: textLogo.bottom

        anchors.topMargin: st.dp16

        anchors.horizontalCenter: parent.horizontalCenter

        width: st.dp34

        icon: online.messageIcon

        iconDefault   : st.icon20x20_love
        iconSourceSize: st.size20x20

        enableFilter: isIconDefault

        onClicked: pLoad("PageAboutMessage.qml")
    }

    ButtonPushLeftFull
    {
        id: buttonReadme

        anchors.top: buttonMessage.top

        minimumWidth: st.dp92

        x: (hasMessage) ? buttonMessage.x - width
                        : buttonMessage.x - width + st.dp17

        text: qsTr("Readme")

        icon          : st.icon16x16_external
        iconSourceSize: st.size16x16

        onClicked: gui.openUrl(controllerFile.applicationFileUrl("Readme.html"))

        Behavior on x
        {
            PropertyAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    ButtonPushRight
    {
        id: buttonCredits

        anchors.top: buttonMessage.top

        minimumWidth: st.dp92

        x: (hasMessage) ? buttonMessage.x + buttonMessage.width
                        : buttonMessage.x + st.dp17

        text: qsTr("Credits")

        onClicked: pLoad("PageAboutCredits.qml")

        Behavior on x
        {
            PropertyAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    ButtonImage
    {
        id: logoQt

        anchors.right: logoVlc.left
        anchors.top  : logoVlc.top

        anchors.rightMargin: st.dp16
        anchors.topMargin  : st.dp4

        sourceSize.height: st.dp40

        source: (isHovered) ? st.icon_qt
                            : st.icon_qtGray

        onClicked: gui.openUrl("http://www.qt.io")
    }

    ButtonImage
    {
        id: logoVlc

        anchors.bottom: footer.top

        anchors.bottomMargin: st.dp16

        anchors.horizontalCenter: parent.horizontalCenter

        sourceSize.height: st.dp48

        source: (isHovered) ? st.icon_vlc
                            : st.icon_vlcGray

        onClicked: gui.openUrl("http://www.videolan.org")
    }

    ButtonImage
    {
        anchors.left: logoVlc.right
        anchors.top : logoQt.top

        anchors.leftMargin: st.dp16

        sourceSize.height: st.dp40

        source: (isHovered) ? st.icon_sky
                            : st.icon_skyGray

        onClicked: gui.openUrl("http://omega.gg/Sky")
    }

    BarTitleSmall
    {
        id: footer

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        height: st.dp32 + borderSizeHeight

        borderBottom: 0

        BarTitleText
        {
            anchors.left  : logoW.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin: st.dp6

            text: qsTr("omega Movement")
        }

        BarTitleText
        {
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            text: core.versionName
        }

        ButtonLogo
        {
            id: logoW

            sourceSize: st.size32x32

            source: st.icon_w

            onClicked: gui.openUrl("http://omega.gg/about")
        }
    }
}
