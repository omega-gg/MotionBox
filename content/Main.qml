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

Application
{
    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias gui: loader.item

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    WindowScale
    {
        id: window

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        minimumWidth : st.minimumWidth
        minimumHeight: st.minimumHeight

        maximized: local.maximized

        vsync: local.vsync

        dropEnabled: true

        resizable: false

        idleCheck: (gui != null)

        areaContextual: if (gui) gui.areaContextual

        st: StyleApplication { id: st }

        color: "black"

        //-----------------------------------------------------------------------------------------
        // Events
        //-----------------------------------------------------------------------------------------

        /* QML_EVENT */ onMessageReceived: function(mesage)
        {
//#MAC
            activate();

            gui.browse(message);
//#ELIF DESKTOP
            activate();

            gui.browse(sk.extractMessage(message));
//#ELSE
            gui.browse(message);
//#END
        }

        onFadeIn:
        {
            core.load();

            if (local.style)
            {
                st.applyStyle(local.style);
            }

            loader.source = "Gui.qml";
        }

        //-----------------------------------------------------------------------------------------
        // Keys
        //-----------------------------------------------------------------------------------------

        /* QML_EVENT */ onViewportKeyPressed: function(event)
        {
            if (gui == null) return;

            event.accepted = true;

            gui.keyPressed(event);
        }

        /* QML_EVENT */ onViewportKeyReleased: function(event) { gui.keyReleased(event); }

        //-----------------------------------------------------------------------------------------
        // Children
        //-----------------------------------------------------------------------------------------

        Loader
        {
            id: loader

            anchors.fill: parent
        }

        Splash { id: splash }
    }
}
