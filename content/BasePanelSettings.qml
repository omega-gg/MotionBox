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

    /* mandatory */ property variant loader

    /* mandatory */ property variant sources
    /* mandatory */ property variant titles

    /* read */ property int currentIndex: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: false

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

    /* QML_EVENT */ Keys.onPressed: function(event)
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

    function selectTab(index)
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

    function loadPage()
    {
        if (loader.source == "")
        {
            loader.source = sources[currentIndex];

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
             return borderSizeWidth + item.contentWidth;
        }
        else return borderSizeWidth;
    }

    function getHeight()
    {
        var item = loader.item;

        if (item)
        {
             return Math.min(loader.y + borderSizeHeight + item.contentHeight, gui.panelHeight);
        }
        else return Math.min(loader.y + borderSizeHeight, gui.panelHeight);
    }

    function getTitle()
    {
        return titles[currentIndex];
    }

    function getSettings()
    {
        var settings = new Array;

        for (var i = 0; i < titles.length; i++)
        {
            settings.push({ "title": titles[i] });
        }

        return settings;
    }

    //---------------------------------------------------------------------------------------------
    // Virtual

    /* virtual */ function expose  () {}
    /* virtual */ function collapse() {}
}
