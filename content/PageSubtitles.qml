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

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties private
    //---------------------------------------------------------------------------------------------

    property bool pEnable: (playerTab && playerTab.currentIndex != -1)

    property bool pSearch: false

    property bool pAdd: (pSearch || playerTab.subtitle == "")

    property int pHeight: st.list_itemSize * 6

    property variant pItem: loader.item

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: lineEdit.height + loader.height

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onVisibleChanged:
    {
        if (visible || pSearch == false) return;

        pSearchHide();
    }

    onPEnableChanged: if (pSearch) pSearchHide()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: player

        onTabChanged: pUpdateText()
    }

    Connections
    {
        target: playerTab

        onSubtitleChanged: pUpdateText()
    }

    //---------------------------------------------------------------------------------------------
    // Functions private
    //---------------------------------------------------------------------------------------------

    function pStartSearch(query)
    {
        if (query == "") return;

        if (core.checkUrl(query) == false)
        {
            if (pSearch)
            {
                pItem.hideCompletion();
            }
            else pSearchShow();

            pItem.search(query);
        }
        else pSearchHide();
    }

    //---------------------------------------------------------------------------------------------

    function pSearchShow()
    {
        loader.source  = Qt.resolvedUrl("PageSubtitlesSearch.qml");
        loader.visible = true;

        pSearch = true;
    }

    function pSearchHide()
    {
        if (lineEdit.isFocused)
        {
            window.clearFocus();
        }

        pSearch = false;

        lineEdit.text = playerTab.subtitle;
    }

    function pSearchToogle()
    {
        if (pSearch == false)
        {
            lineEdit.text = "";

            lineEdit.focus();
        }
        else pSearchHide();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateText()
    {
        if (pSearch) return;

        lineEdit.text = playerTab.subtitle;
    }

    //---------------------------------------------------------------------------------------------

    function pGetText()
    {
        if (pEnable)
        {
             return qsTr("What subtitle are you looking for ?");
        }
        else return qsTr("No track selected");
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    LineEditBox
    {
        id: lineEdit

        anchors.left : parent.left
        anchors.right: buttonAdd.left

        enabled: (pEnable && (pSearch || text == ""))

        text: playerTab.subtitle

//#QT_4
        textDefault: pGetText()
//#ELSE
        textDefault: (text) ? text
                            : pGetText()

        textInput.visible: isFocused

        itemTextDefault.visible: (isFocused == false)
//#END

        font.pixelSize: st.dp14

        itemTextDefault.elide: Text.ElideLeft

        onIsFocusedChanged: if (isFocused && pSearch == false) pSearchShow()

        onTextChanged: if (pSearch) pItem.applyText(text)

        function onKeyPressed(event)
        {
            if (event.key == Qt.Key_Up)
            {
                event.accepted = true;

                if (pItem) pItem.selectPrevious();
            }
            else if (event.key == Qt.Key_Down)
            {
                event.accepted = true;

                if (pItem) pItem.selectNext();
            }
            else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
            {
                event.accepted = true;

                if (event.isAutoRepeat) return;

                pStartSearch(text);
            }
            else if (event.key == Qt.Key_Escape)
            {
                event.accepted = true;

                window.clearFocus();
            }
        }
    }

    ButtonPianoIcon
    {
        id: buttonAdd

        anchors.right : buttonSearch.left
        anchors.top   : buttonSearch.top
        anchors.bottom: buttonSearch.bottom

        width: buttonSearch.width

        borderLeft : borderSize
        borderRight: 0

        enabled: pEnable

        highlighted: (pAdd) ? false : player.isPlaying

        icon: (pAdd) ? st.icon24x24_addIn
                     : st.icon16x16_close

        iconSourceSize: (pAdd) ? st.size24x24
                               : st.size16x16

        onClicked:
        {
            if (pAdd)
            {
                if (lineEdit.isFocused) window.clearFocus();

                var path = core.openSubtitle(qsTr("Select Subtitle"));

                if (path == "") return;

                pSearch = false;

                playerTab.subtitle = path;
            }
            else playerTab.subtitle = "";
        }
    }

    ButtonPianoIcon
    {
        id: buttonSearch

        anchors.right : parent.right
        anchors.top   : lineEdit.top
        anchors.bottom: lineEdit.bottom

        width: height + borderSizeWidth

        borderLeft : borderSize
        borderRight: 0

        enabled: pEnable

        checkable: true
        checked  : pSearch

        icon          : st.icon32x32_search
        iconSourceSize: st.size32x32

        onPressed: pSearchToogle()
    }

    BorderHorizontal
    {
        id: border

        anchors.top: lineEdit.bottom

        visible: loader.visible
    }

    Loader
    {
        id: loader

        anchors.left : parent.left
        anchors.right: parent.right
        anchors.top  : border.bottom

        height: 0

        visible: false

        states: State
        {
            name: "visible"; when: pSearch

            PropertyChanges
            {
                target: loader

                height: pHeight
            }
        }

        transitions: Transition
        {
            SequentialAnimation
            {
                NumberAnimation
                {
                    property: "height"

                    duration: st.duration_faster

                    easing.type: st.easing
                }

                ScriptAction
                {
                    script:
                    {
                        if (pSearch) return;

                        loader.visible = false;
                        loader.source  = "";
                    }
                }
            }
        }
    }
}
