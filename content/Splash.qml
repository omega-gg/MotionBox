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

    width : parent.width + st.splash_borderSize
    height: parent.height

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

            AnchorAnimation
            {
                duration: st.duration_slower

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
        if (image.isSourceDefault)
        {
            clip = true;

            pTransition = 0;
        }
        else
        {
            hoverRetain = false;

            pTransition = 1;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pClearSpash()
    {
        window.resizable = true;

        visible = false;
        clip    = false;

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
        id: background

        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        width: loader.width

        x: -(parent.x)

        visible: image.isSourceDefault

        gradient: Gradient
        {
            GradientStop { position: 0.0; color: st.splash_colorA }
            GradientStop { position: 1.0; color: st.splash_colorB }
        }
    }

    ImageScale
    {
        id: image

        anchors.centerIn: background

        width: (isSourceDefault) ? Math.round(parent.width / 1.5)
                                 : loader.width

        height: (isSourceDefault) ? Math.round(width / 3.875)
                                  : loader.height

        source: (local.splashWidth  == loader.width
                 &&
                 local.splashHeight == loader.height) ? core.pathSplash : ""

        sourceSize: (isSourceDefault) ? undefined : Qt.size(local.splashWidth, local.splashHeight)

        sourceDefault: st.logoApplication

        cache: false

        scaling   : isSourceDefault
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

                    easing.type: st.easing
                }

                ScriptAction { script: pClearSpash() }
            }
        }
    }

    BorderVertical
    {
        anchors.right: parent.right

        size: st.splash_borderSize

        visible: image.isSourceDefault
    }
}
