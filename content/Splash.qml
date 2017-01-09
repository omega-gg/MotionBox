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

MouseArea
{
    id: splash

    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property int pTransition: -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    hoverRetain: true

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "scroll"; when: (pTransition == 0)

        AnchorChanges
        {
            target: splash

            anchors.right: parent.left
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            PauseAnimation { duration: st.ms1000 }

            AnchorAnimation { duration: st.duration_slower }

            ScriptAction { script: pClearSpash() }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function hide()
    {
        if (image.isSourceDefault == false)
        {
            hoverRetain = false;

            pTransition = 1;
        }
        else pTransition = 0;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearSpash()
    {
        visible = false;

        width  = undefined;
        height = undefined;

        image.source        = "";
        image.sourceDefault = "";

        online.load();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Rectangle
    {
        anchors.fill: parent

        visible: image.isSourceDefault

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.logo_colorB }
            GradientStop { position: 1.0; color: st.logo_colorA }
        }

        BorderVertical { anchors.left: parent.right }
    }

    ImageScale
    {
        id: image

        anchors.centerIn: parent

        width: (isSourceDefault) ? Math.round(parent.width / 1.5)
                                 : parent.width

        height: (isSourceDefault) ? Math.round(width / 3.875)
                                  : parent.height

        source: (local.splashWidth  == loader.width
                 &&
                 local.splashHeight == loader.height) ? core.pathSplash : ""

        sourceDefault: st.logoApplication

        cache: false

        scaling: isSourceDefault

        scaleDelay: 0

        states: State
        {
            name: "fade"; when: (pTransition == 1)

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

                    duration: st.duration_slower
                }

                ScriptAction { script: pClearSpash() }
            }
        }

        BorderImageShadow
        {
            visible: image.isSourceDefault

            opacity: st.splash_shadowOpacity
        }
    }
}
