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

ItemList
{
    id: componentLibraryItem

    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property int pAction: -1

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    isSelected: (index == indexCurrent)

    iconAsynchronous: gui.itemAsynchronous

    background.anchors.top   : undefined
    background.anchors.bottom: undefined

    background.height: st.dp32

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "add"; when: (pAction == 0)

            PropertyChanges
            {
                target: componentLibraryItem

                height: st.itemList_height
            }
        },
        State
        {
            name: "remove"; when: (pAction == 1)

            PropertyChanges
            {
                target: componentLibraryItem

                height: st.dp1
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                property: "height"

                duration: st.duration_normal
            }

            ScriptAction
            {
                script: if (pAction != 1) clip = false
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function getIndex() { return index; }

    //---------------------------------------------------------------------------------------------

    function animateAdd()
    {
        pAction = -1;

        clip = true;

        height = st.dp1;

        pAction = 0;
    }

    function animateRemove()
    {
        pAction = -1;

        clip = true;

        pAction = 1;
    }

    //---------------------------------------------------------------------------------------------
    // ItemList implementation

    function selectIndex()
    {
        indexCurrent = index;
    }
}
