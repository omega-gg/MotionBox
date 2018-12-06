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

import QtQuick 1.0
import Sky     1.0

LineEditBox
{
    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

//#QT_4
    textDefault: qsTr("What do you want to watch ?")
//#ELSE
    textDefault: (text) ? text
                        : qsTr("What do you want to watch ?")

    textInput.visible: isFocused

    itemTextDefault.visible: (isFocused == false)
//#END

    //---------------------------------------------------------------------------------------------
    // Style

    maximumLength: st.lineEditSearch_maximumLength

    font.pixelSize: st.dp14

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onIsFocusedChanged:
    {
        if (isFocused == false)
        {
            text = currentTab.source;

            panelSearch.visible = false;
        }
        else if (text == "")
        {
            panelSearch.visible = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions events
    //---------------------------------------------------------------------------------------------

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

                panelSearch.selectPreviousBackend();
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

                panelSearch.selectNextBackend();
            }
        }
        else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            panelSearch.search();
        }
        else if (event.key == Qt.Key_Escape)
        {
            event.accepted = true;

            window.clearFocus();
        }
        else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Backtab)
        {
            event.accepted = true;

            if (event.isAutoRepeat == false && (panelSearch.visible == false || text == ""))
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
}
