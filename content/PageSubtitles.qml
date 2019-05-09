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

    property bool pEnable: (playerTab.currentIndex != -1)

    property bool pSearch: false

    property int pHeight: st.list_itemSize * 6

    property variant pItem: loader.item

    property string pQuery

    property bool pEvents: true

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: lineEdit.height + loader.height

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onPEnableChanged: hideSearch()

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: player

        onTabChanged: pUpdateSearch()
    }

    Connections
    {
        target: playerTab

        onCurrentBookmarkChanged: pUpdateSearch()

        onSubtitleChanged:
        {
            if (pEvents == false || pSearch) return;

            pSetText(playerTab.subtitle);
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function hideSearch()
    {
        if (pSearch) pHideSearch();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pStartSearch(query)
    {
        if (query == "") return;

        if (controllerPlaylist.urlIsSubtitle(query))
        {
            hideSearch();

            playerTab.subtitle = query;
        }
        else
        {
            if (pSearch)
            {
                pItem.hideCompletion();
            }
            else pShowSearch();

            pItem.search(query);

            pQuery = query;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pShowSearch()
    {
        loader.source  = Qt.resolvedUrl("PageSubtitlesSearch.qml");
        loader.visible = true;

        pSearch = true;
    }

    function pHideSearch()
    {
        pQuery = "";

        if (lineEdit.isFocused)
        {
            window.clearFocus();
        }

        pSearch = false;

        pSetText(playerTab.subtitle);
    }

    function pToogleSearch()
    {
        if (pSearch == false)
        {
            pSetText("");

            lineEdit.focus();

            pShowSearch();

            pApplyQuery();
        }
        else pHideSearch();
    }

    //---------------------------------------------------------------------------------------------

    function pApplyQuery()
    {
        var title = playerTab.title;

        if (controllerPlaylist.urlIsVideo(title) == false) return;

        title = controllerNetwork.removeFileExtension(title);

        pSetText(title);

        pItem.search(title);

        pQuery = title;

        lineEdit.selectAll();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateSearch()
    {
        if (pEvents == false) return;

        if (pSearch)
        {
            pHideSearch();
        }
        else pSetText(playerTab.subtitle);
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

    function pSetText(text)
    {
        pEvents = false;

        lineEdit.text = text;

        pEvents = true;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    LineEditBoxClear
    {
        id: lineEdit

        anchors.left : parent.left
        anchors.right: buttonAdd.left

        enabled: pEnable

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

        onIsFocusedChanged:
        {
            if (isFocused)
            {
                if (pSearch || text != "") return;

                pShowSearch();

                pApplyQuery();
            }
            else if (pSearch)
            {
                pSetText(pQuery);

                pItem.hideCompletion();
            }
        }

        onTextChanged:
        {
            if (isFocused == false || pEvents == false) return;

            if (pSearch)
            {
                pItem.applyText(text);
            }
            else pShowSearch();
        }

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

        function onClear()
        {
            text = "";

            playerTab.subtitle = "";
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

        icon          : st.icon24x24_addIn
        iconSourceSize: st.size24x24

        onClicked:
        {
            if (lineEdit.isFocused) window.clearFocus();

            var path = core.openSubtitle(qsTr("Select Subtitle"));

            if (path == "") return;

            playerTab.subtitle = path;

            pSearch = false;

            pSetText(path);
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

        onPressed: pToogleSearch()
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

                    duration: st.duration_fast

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
