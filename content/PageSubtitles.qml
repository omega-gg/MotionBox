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

Item
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate: true

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

        onTabChanged:
        {
            if (pSearch)
            {
                pHideSearch();
            }
            else pSetText(playerTab.subtitle);
        }
    }

    Connections
    {
        target: playerTab

        onCurrentBookmarkChanged:
        {
            var subtitle = playerTab.subtitle;

            if (subtitle)
            {
                if (pSearch)
                {
                    pHideSearch();
                }
                else pSetText(subtitle);
            }
            // NOTE: We only want to search when the panel is visible.
            else if (visible && pSearch)
            {
                pApplyQuery();
            }
        }

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

    function clearSubtitle()
    {
        if (pSearch) pItem.clearIndex();
    }

    //---------------------------------------------------------------------------------------------
    // Events

    function onShow()
    {
        if (gui.dragType == -2) return;

        var title = playerTab.title;

        if (controllerPlaylist.urlIsVideo(title) == false)
        {
            if (pSearch)
            {
                pAnimate = false;

                pHideSearch();

                pAnimate = true;
            }

            return;
        }

        if (pSearch == false)
        {
            pAnimate = false;

            pShowSearch();

            pAnimate = true;
        }

//#QT_4
        pApplyUrl(title);
//#ELSE
        // FIXME: We have to call this later otherwise we get a 'nested sendEvent'.
        Qt.callLater(pApplyUrl, title);
//#END
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

            pShowSearch();

            pApplyQuery();
        }
        else pHideSearch();
    }

    //---------------------------------------------------------------------------------------------

    function pApplyQuery()
    {
        var title = playerTab.title;

        if (controllerPlaylist.urlIsVideo(title) == false)
        {
            pSetText("");

            pItem.clear();

            pQuery = "";
        }
        else pApplyUrl(title);
    }

    function pApplyUrl(title)
    {
        title = controllerNetwork.removeFileExtension(title);

        if (lineEdit.text == title) return;

        pSetText(title);

        pItem.search(title);

        pQuery = title;
    }

    //---------------------------------------------------------------------------------------------

    function pGetText()
    {
        if (pEnable)
        {
             return qsTr("What subtitle are you looking for ?");
        }
        else return qsTr("No Track selected");
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

                var title = playerTab.title;

                if (controllerPlaylist.urlIsVideo(title))
                {
                    pApplyUrl(title);

                    lineEdit.selectAll();
                }
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

            if (pSearch) pItem.clearIndex();
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

        onClicked: pToogleSearch()
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

                    duration: (pAnimate) ? st.duration_fast : 0

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
