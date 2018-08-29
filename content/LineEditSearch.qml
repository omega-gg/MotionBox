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

import QtQuick 1.1
import Sky     1.0

LineEditBox
{
    id: lineEditSearch

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* mandatory */ property int widthMinimum
    /* mandatory */ property int widthMaximum

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: widthMinimum

    paddingLeft: (isFocused) ? padding : st.dp32

    textDefault: qsTr("What do you want to watch ?")

    maximumLength: st.lineEditSearch_maximumLength

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "active"; when: isFocused

        PropertyChanges
        {
            target: lineEditSearch

            width: widthMaximum
        }
    }

    transitions: Transition
    {
        NumberAnimation
        {
            property: "width"

            duration: (gui.isMini) ? 0 : st.duration_faster
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function showAndFocus()
    {
        visible = true;

        focus();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onKeyPressed(event)
    {
        if (event.key == Qt.Key_Up)
        {
            if (event.modifiers == Qt.NoModifier)
            {
                event.accepted = true;

                panelSearch.selectPrevious();
            }
            else if (event.modifiers == Qt.AltModifier)
            {
                event.accepted = true;

                panelSearch.selectPreviousHub();
            }
        }
        else if (event.key == Qt.Key_Down)
        {
            if (event.modifiers == Qt.NoModifier)
            {
                event.accepted = true;

                panelSearch.selectNext();
            }
            else if (event.modifiers == Qt.AltModifier)
            {
                event.accepted = true;

                panelSearch.selectNextHub();
            }
        }
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            panelSearch.triggerActionPressed();
        }
        else if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            if (text)
            {
                text = "";
            }
            else window.clearFocus();
        }
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            event.accepted = true;

            if (event.isAutoRepeat == false && text == "")
            {
                if (panelBrowse.lineEdit.visible)
                {
                    panelBrowse.lineEdit.focus();
                }
                else window.clearFocus();
            }
            else panelSearch.selectNextAction();
        }
    }

    function onKeyReleased(event)
    {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            panelSearch.triggerActionReleased();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Image
    {
        anchors.left: parent.left

        anchors.leftMargin: st.dp8

        anchors.verticalCenter: parent.verticalCenter

        visible: (isFocused == false && imageLoading.visible == false)

        source    : st.icon16x16_searchSmall
        sourceSize: st.size16x16

        filter: st.lineEditSearch_filterIcon
    }

    Image
    {
        id: imageLoading

        width : st.dp32
        height: st.dp32

        visible: (isFocused == false && panelBrowse.isSelecting && gui.isExpanded)

        source    : st.icon32x32_loading
        sourceSize: st.size32x32

        filter: st.lineEditSearch_filterIcon

        NumberAnimation on rotation
        {
            running: (st.animate && imageLoading.visible)

            from: 0
            to  : 360

            duration: st.iconLoading_durationAnimation

            loops: Animation.Infinite
        }
    }
}
