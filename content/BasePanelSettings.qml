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
    id: basePanelSettings

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed: false

    /* mandatory */ property variant sources
    /* mandatory */ property variant titles

    /* read */ property int currentIndex: -1

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias page: loader.item

    //---------------------------------------------------------------------------------------------

    property alias button: button

    property alias loader: loader

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

//#QT_4
    anchors.right: parent.right
    anchors.top  : parent.bottom
//#ELSE
    // FIXME Qt5.12 Win8: Panel size changes for no reason when hidden.
    x: parent.width - width

    y: parent.height + height
//#END

    width : getWidth ()
    height: getHeight()

    borderLeft  : borderSize
    borderRight : 0
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
            target: basePanelSettings

            anchors.top   : undefined
            anchors.bottom: parent.bottom
        }
//#ELSE
        PropertyChanges
        {
            target: basePanelSettings

            y: parent.height - basePanelSettings.height
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

    Behavior on width
    {
        enabled: pAnimate

        PropertyAnimation
        {
            duration: st.duration_fast

            easing.type: st.easing
        }
    }

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

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function loadPage()
    {
        if (currentIndex == -1)
        {
            currentIndex = 0;

            loader.source = sources[0];

            loader.item.forceActiveFocus();
        }

        // NOTE: We check if the 'onShow' function is defined.
        if (page.onShow) page.onShow();
    }

    //---------------------------------------------------------------------------------------------

    function getWidth()
    {
        var item = loader.item;

        if (item)
        {
             return item.contentWidth + borderSizeWidth;
        }
        else return borderSizeWidth;
    }

    function getHeight()
    {
        var item = loader.item;

        if (item)
        {
             return loader.y + item.contentHeight;
        }
        else return loader.y;
    }

    //---------------------------------------------------------------------------------------------
    // Virtual

    /* virtual */ function expose  () {}
    /* virtual */ function collapse() {}

    //---------------------------------------------------------------------------------------------
    // Private

    function pSelectTab(index)
    {
        if (loader.isAnimated || currentIndex == index || index >= sources.length) return;

        var source = sources[index];

        pAnimate = true;

        if (currentIndex < index)
        {
             loader.loadLeft(source);
        }
        else loader.loadRight(source);

        // NOTE: We check if the 'onShow' function is defined.
        if (page.onShow) page.onShow();

        pAnimate = false;

        // NOTE: We apply the current index after the animation.
        currentIndex = index;

        loader.item.forceActiveFocus();
    }

    //---------------------------------------------------------------------------------------------

    function pGetTitle()
    {
        if (currentIndex == -1)
        {
            return "";
        }
        else return titles[currentIndex];
    }

    function pGetSettings()
    {
        var settings = new Array;

        for (var i = 0; i < titles.length; i++)
        {
            settings.push({ "title": titles[i] });
        }

        return settings;
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

        ButtonSettings
        {
            id: button

            width: st.dp128

            // NOTE: We disable the button when we have a single source.
            enabled: (sources.length > 1)

            text: pGetTitle()

            settings: pGetSettings()

            currentIndex: basePanelSettings.currentIndex

            font.pixelSize: st.dp14

            // NOTE: We make sure the text is always opaque even when the item is disabled.
            itemText.opacity: 1.0

            //-----------------------------------------------------------------------------------------
            // ButtonSettingsAction implementation

            function onClick(index)
            {
                pSelectTab(index);
            }
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
