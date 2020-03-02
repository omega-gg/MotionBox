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

Panel
{
    id: panelSearch

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int backend: 1 // NOTE: Default to "browse" ID.

    /* read */ property int action: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property string pText

    property int pIndexFocus: -1

    property bool pTextEvents: true

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: lineEditSearch.width + borderSizeWidth

    height: st.list_itemSize * 6 + borderSizeHeight

    borderTop: 0

    x: lineEditSearch.x - borderLeft

    z: 1

    visible: false

    enableFocus: false

    backgroundOpacity: st.panelContextual_backgroundOpacity

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onVisibleChanged:
    {
        if (visible == false) return;

        panelApplication.collapse();
        //panelDiscover   .collapse();

        pIndexFocus = 1;

        selectBackend(0);

        action = 0;

        visible = true;
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: lineEditSearch

        onTextChanged:
        {
            if (pTextEvents == false) return;

            var text = lineEditSearch.text;

            if (text && core.checkUrl(text))
            {
                selectBackend(0);
            }

            scrollCompletion.currentIndex = -1;

            scrollCompletion.query = text;

            scrollCompletion.runQuery();

            pText = scrollCompletion.query;

            if (lineEditSearch.isFocused)
            {
                visible = true;
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function browse()
    {
        lineEditSearch.focus();

        backend = 1;
    }

    function search()
    {
        action = 0;

        pStartSearch();
    }

    //---------------------------------------------------------------------------------------------

    function selectPrevious()
    {
        if (pIndexFocus == 1)
        {
             selectPreviousBackend();
        }
        else selectPreviousCompletion();
    }

    function selectNext()
    {
        if (pIndexFocus == 1)
        {
             selectNextBackend();
        }
        else selectNextCompletion();
    }

    //---------------------------------------------------------------------------------------------

    function selectPreviousCompletion()
    {
        if (pIndexFocus == 0)
        {
            pIndexFocus = -1;

            pRestoreQuery();
        }
        else
        {
            scrollCompletion.selectPrevious();

            if (scrollCompletion.currentIndex == -1)
            {
                pRestoreQuery();
            }
        }
    }

    function selectNextCompletion()
    {
        scrollCompletion.selectNext();

        if (scrollCompletion.currentIndex == -1)
        {
            pRestoreQuery();
        }
    }

    //---------------------------------------------------------------------------------------------

    function backendAt(index)
    {
        return backends.idAt(index);
    }

    function getBackendIndex()
    {
        return backends.indexFromId(backend);
    }

    //---------------------------------------------------------------------------------------------

    function selectBackend(index)
    {
        var id = backends.idAt(index);

        if (id == -1) return;

        backend = id;

        scrollBackends.scrollToItem(index);
    }

    function selectPreviousBackend()
    {
        var index = getBackendIndex() - 1;

        selectBackend(index);
    }

    function selectNextBackend()
    {
        var index = getBackendIndex() + 1;

        selectBackend(index);
    }

    //---------------------------------------------------------------------------------------------

    function selectPreviousAction()
    {        
        if (action == 0) action = 1;
        else             action--;
    }

    function selectNextAction()
    {
        if (action == 1) action = 0;
        else             action++;
    }

    //---------------------------------------------------------------------------------------------

    function setText(text)
    {
        if (visible == false)
        {
            pTextEvents = false;

            lineEditSearch.text = text;

            pTextEvents = true;
        }
        else lineEditSearch.text = text;

        if (lineEditSearch.isFocused)
        {
            lineEditSearch.selectAll();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pStartSearch()
    {
        if (action == 0)
        {
             panelBrowse.search(backend, lineEditSearch.text, true, false);
        }
        else panelBrowse.search(backend, lineEditSearch.text, true, true);
    }

    //---------------------------------------------------------------------------------------------

    function pRestoreQuery()
    {
        pTextEvents = false;

        lineEditSearch.text = pText;

        pTextEvents = true;
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateFocus()
    {
        if (scrollCompletion.count) pIndexFocus = -1;
        else                        pIndexFocus =  1;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ScrollCompletion
    {
        id: scrollCompletion

        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        anchors.bottomMargin: -st.border_size

        width: Math.max(st.dp256, parent.width - st.dp256)

        textDefault: qsTr("Type something to watch")

        onQueryCompleted: pUpdateFocus()

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                pIndexFocus = -1;

                pTextEvents = false;

                lineEditSearch.text = completion;

                pTextEvents = true;

                lineEditSearch.moveCursorAtEnd();
            }
            else scrollTo(0);
        }

        onItemDoubleClicked: search()
    }

    BorderVertical
    {
        id: border

        anchors.left: scrollCompletion.right
    }

    ScrollList
    {
        id: scrollBackends

        property variant itemHovered: null

        property int indexHover: (itemHovered) ? itemHovered.getIndex()
                                               : -1

        anchors.left  : border.right
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        anchors.bottomMargin: -st.border_size

        model: ModelLibraryFolder { folder: backends }

        delegate: ComponentLibraryItem
        {
            isSelected: (id == backend)

            isFocused: (pIndexFocus == 1)

            icon: cover

            iconDefault: (id == 1) ? st.icon32x32_url
                                   : st.icon32x32_feed

            text: title

            onPressed: backend = id

            onClicked: if (isFocused == false) search()

            onDoubleClicked: search()
        }
    }
}
