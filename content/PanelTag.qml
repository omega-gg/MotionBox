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

    /* read */ property int currentIndex: -1

    //---------------------------------------------------------------------------------------------
    // PageTag

    property bool showCover: false

    property bool embedCover: true

    property bool synchronize: true
    property bool prefix     : true

    property string text

    //---------------------------------------------------------------------------------------------
    // Private

    property int pIndex: 2 // PageTag

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

                        currentIndex = -1;

                        text = "";

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

    function exposePage(index)
    {
        if (index < 0 || index > 2) return;

        if (isExposed)
        {
            pLoadSource(index);

            return;
        }

        pIndex = index;

        pExpose(index);
    }

    function expose()
    {
        if (isExposed) return;

        pExpose(pIndex);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionTagCollapse)) return;

        clip = true;

        isExposed = false;

        gui.clearTag();

        gui.startActionCue(st.duration_fast);
    }

    function toggleExpose()
    {
        if (isExposed)
        {
            collapse();
        }
        else exposePage(2); // PageTag
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pExpose(index)
    {
        if (actionCue.tryPush(gui.actionTagExpose)) return;

        window.clearFocus();

        visible = true;

        clip = true;

        isExposed = true;

        currentIndex = index;

        loader.source = pGetSource(index);

        gui.startActionCue(st.duration_fast);
    }

    function pLoadSource(index)
    {
        if (currentIndex == index) return;

        text = "";

        if (index < currentIndex)
        {
            currentIndex = index;

            loader.loadRight(pGetSource(index));
        }
        else
        {
            currentIndex = index;

            loader.loadLeft(pGetSource(index));
        }
    }

    function pGetSource(index)
    {
        if (index == 0)
        {
            return Qt.resolvedUrl("PageCamera.qml");
        }
        else if (index == 1)
        {
            return Qt.resolvedUrl("PageGrid.qml");
        }
        else if (index == 2)
        {
            return Qt.resolvedUrl("PageTag.qml");
        }
        else return "";
    }

    function pGetIndex()
    {
        if (currentIndex == 0)
        {
            return 0;
        }
        else if (currentIndex == 2)
        {
            return 1;
        }
        else return -1;
    }

    function pGetOpacity()
    {
        if (showCover)
        {
            return 1.0;
        }
        else if (currentIndex == 1)
        {
            return 0.9;
        }
        else return 0.8;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    BorderHorizontal
    {
        id: border

        // NOTE: We want the border to stay on top during the animation.
        z: (parent.clip) ? 1 : 0

        size: st.dp8

        color: st.border_colorFocus
    }

    Rectangle
    {
        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : border.bottom
        anchors.bottom: parent.bottom

        opacity: pGetOpacity()

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

            visible: (currentIndex != -1)

            currentIndex: pGetIndex()

            checkable: false

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
//#QT_4
                if (index == 1) pLoadSource(2); // PageTag
//#ELSE
                if (index == 0) pLoadSource(0); // PageCamera
                else            pLoadSource(2); // PageTag
//#END
            }
        }
    }
}
