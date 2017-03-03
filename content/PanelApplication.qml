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

import QtQuick       1.1
import Sky           1.0
import SkyComponents 1.0

Panel
{
    id: panelApplication

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed : false
    /* read */ property bool isAnimated: false

    /* read */ property string sourceSettings: "PageSettingsMain.qml"
    /* read */ property string sourceAbout   : "PageAboutMain.qml"

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

    property int pMessageValue: 0
    property int pCreditsValue: 0

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias itemTabs: itemTabs

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.right: parent.left

    anchors.bottom: (window.fullScreen) ? barWindow.bottom
                                        : barTop   .bottom

    width: st.dp320 + borderRight

    height: bar.height
            + (st.barTitleSmall_height + st.dp2 * 2 + st.buttonPush_height + st.dp3 * 2) * 4
            - st.dp2 + borderSizeHeight

    borderLeft: 0
    borderTop : 0

    visible: false

    backgroundOpacity: (gui.isExpanded) ? st.panelContextual_backgroundOpacity : 1.0

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "visible"; when: isExposed

        AnchorChanges
        {
            target: panelApplication

            anchors.left : parent.left
            anchors.right: undefined

            anchors.top: (window.fullScreen) ? barTop   .bottom
                                             : barWindow.bottom

            anchors.bottom: undefined
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_fast }

            ScriptAction
            {
                script:
                {
                    if (isExposed == false) visible = false;

                    isAnimated = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onActiveFocusChanged: if (activeFocus) loader.item.forceActiveFocus()

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on color
    {
        ColorAnimation
        {
            duration: (pAnimate) ? st.ms500 : 0
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
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            collapse();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || isAnimated) return;

        gui.restoreMicro();

        if (itemTabs.indexCurrent == -1)
        {
            itemTabs.selectTab(0);
        }

        visible = true;

        isAnimated = st.animate;

        isExposed = true;

        barWindow.buttonApplication.checked = true;
        barTop   .buttonApplication.checked = true;

        focus();
    }

    function collapse()
    {
        if (isExposed == false || isAnimated) return;

        isAnimated = st.animate;

        isExposed = false;

        barWindow.buttonApplication.checked = false;
        barTop   .buttonApplication.checked = false;

        window.clearFocusItem(panelApplication);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function updateTabs()
    {
        var model = itemTabs.model;

        model.setProperty(0, "sourceDefault", st.icon32x32_setting);
        model.setProperty(1, "sourceDefault", st.icon32x32_about);
    }

    //---------------------------------------------------------------------------------------------

    function setAboutPage(page)
    {
        if (itemTabs.indexCurrent != 1)
        {
            itemTabs.indexCurrent = 1;

            sourceAbout = page;

            if (isExposed == false)
            {
                loader.load(Qt.resolvedUrl("PageAbout.qml"));

                expose();
            }
            else loader.loadLeft(Qt.resolvedUrl("PageAbout.qml"));
        }
        else if (isExposed == false)
        {
            loader.item.load(Qt.resolvedUrl(page));

            expose();
        }
        else loader.item.loadLeft(Qt.resolvedUrl(page));

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

        Tabs
        {
            id: itemTabs

            anchors.left : parent.left
            anchors.right: buttonClose.left

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin : -st.dp2

            spacing: st.dp2

            Component.onCompleted:
            {
                addTab("", qsTr("Settings"), st.icon32x32_setting);
                addTab("", qsTr("About"),    st.icon32x32_about);
            }

            function selectTab(index)
            {
                if (loader.isAnimated
                    ||
                    index < 0 || index >= count || indexCurrent == index) return;

                if (indexCurrent == -1)
                {
                    indexCurrent = index;

                    loader.load(Qt.resolvedUrl("PageSettings.qml"));
                }
                else
                {
                    indexCurrent = index;

                    if (indexCurrent == 0)
                    {
                        sourceSettings = "PageSettingsMain.qml";

                        loader.loadRight(Qt.resolvedUrl("PageSettings.qml"));
                    }
                    else
                    {
                        sourceAbout = "PageAboutMain.qml";

                        loader.loadLeft(Qt.resolvedUrl("PageAbout.qml"));
                    }
                }

                loader.item.forceActiveFocus();
            }
        }

        ButtonPianoIcon
        {
            id: buttonClose

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            borderRight: 0

            icon          : st.icon16x16_close
            iconSourceSize: st.size16x16

            onClicked: collapse()
        }
    }

    LoaderSlide
    {
        id: loader

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom
    }
}
