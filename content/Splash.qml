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

Rectangle
{
    id: splash

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property bool pFade: false

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.fill: parent

    gradient: Gradient
    {
        GradientStop { position: 0.0; color: st.splash_colorA }
        GradientStop { position: 1.0; color: st.splash_colorB }
    }

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "fade"; when: pFade

        PropertyChanges
        {
            target: splash

            opacity: 0.0
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                property: "opacity"

                // NOTE: We want to fade slower when restoring to let images load.
                duration: (image.isSourceDefault) ? st.duration_normal
                                                  : st.duration_slow

                easing.type: st.easing
            }

            ScriptAction { script: pClearSpash() }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function hide()
    {
        pFade = true;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearSpash()
    {
        window.resizable = true;

        visible = false;

        width  = undefined;
        height = undefined;

        image.source = "";

        online.load();
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Image
    {
        id: image

        anchors.fill: parent

        source: (local.splashWidth  == loader.width
                 &&
                 local.splashHeight == loader.height) ? core.pathSplash : ""

        sourceSize: (isSourceDefault) ? undefined : Qt.size(local.splashWidth, local.splashHeight)

        cache: false
    }
}
