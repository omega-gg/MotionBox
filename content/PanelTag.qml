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

BasePanel
{
    id: panelTag

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    //---------------------------------------------------------------------------------------------
    // PageTag

    property bool showCover: false

    property bool embedCover: true

    property bool synchronize: true
    property bool prefix     : true

    property string text

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pLoaded: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias item: loader.item

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left : parent.left
    anchors.right: parent.right
    anchors.top  : parent.bottom

    height: parent.height

    visible: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "visible"; when: isExposed

            AnchorChanges
            {
                target: panelTag

                anchors.top   : undefined
                anchors.bottom: parent.bottom
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation
            {
                duration: st.duration_fast

                easing.type: st.easing
            }

            ScriptAction
            {
                script:
                {
                    if (isExposed == false)
                    {
                        visible = false;

                        buttonsCheck.currentIndex = -1;

                        loader.source = "";
                    }

                    clip = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed) return;

        if (pLoaded == false) pLoad();

        visible = true;

        clip = true;

        isExposed = true;

        buttonsCheck.currentIndex = 1;

        loader.source = Qt.resolvedUrl("PageTag.qml");
    }

    function collapse()
    {
        if (isExposed == false) return;

        clip = true;

        isExposed = false;

        gui.clearTag();
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pLoad()
    {
        pLoaded = true;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    BorderHorizontal
    {
        id: border

        size: st.dp8

        color: st.border_colorFocus
    }

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: parent.bottom

        opacity: (showCover) ? 1.0 : 0.8

        color: st.panelTag_color

        Behavior on opacity
        {
            PropertyAnimation
            {
                duration: st.duration_normal

                easing.type: st.easing
            }
        }
    }

    Item
    {
        id: background

        anchors.left : parent.left
        anchors.right: parent.right

        height: parent.height

        y: -(parent.y)

        LoaderWipe
        {
            id: loader

            anchors.fill: parent

            borderSize: st.dp8

//#QT_NEW
            loader.asynchronous: true
//#END
        }

        ButtonsCheck
        {
            id: buttonsCheck

            anchors.bottom: parent.bottom

            anchors.bottomMargin: st.dp16

            anchors.horizontalCenter: parent.horizontalCenter

            width: st.dp256

            model: ListModel {}

            Component.onCompleted:
            {
//#QT_4
                // NOTE Qt4: We can only append items one by one.
                model.append({ "title": qsTr("Camera")   });
                model.append({ "title": qsTr("VideoTag") });
//#ELSE
                model.append(
                [
                    { "title": qsTr("Camera")   },
                    { "title": qsTr("VideoTag") }
                ]);
//#END
            }

            onClicked:
            {
                if (index == 0)
                {
                     loader.loadLeft(Qt.resolvedUrl("PageCamera.qml"));
                }
                else loader.loadRight(Qt.resolvedUrl("PageTag.qml"));
            }
        }
    }
}
