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

Panel
{
    id: panelSearch

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    property bool isActive: lineEditSearch.isFocused

    /* read */ property int hub: -1

    /* read */ property int action: 0

    //---------------------------------------------------------------------------------------------
    // Private

    property string pText

    property int pIndexFocus: -1

    property bool pTextEvents: true

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias buttonSearch: buttonSearch

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    width: barHubs.x + barHubs.width + borders.sizeWidth

    height: st.dp202 + borderSizeHeight

    borderTop: 0

    x: lineEditSearch.x - borderLeft

    z: 1

    visible: false
    opacity: 0.0

    enableFocus: false

    backgroundOpacity: (gui.isExpanded) ? st.panelContextual_backgroundOpacity : 1.0

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State
    {
        name: "active"; when: isActive

        PropertyChanges
        {
            target: panelSearch

            opacity: 1.0
        }
    }

    transitions: Transition
    {
        SequentialAnimation
        {
            NumberAnimation
            {
                property: "opacity"

                duration: st.duration_faster
            }

            ScriptAction
            {
                script: if (isActive == false) visible = false
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onIsActiveChanged:
    {
        if (isActive)
        {
            gui.restoreMicro();

            panelApplication.collapse();

            pIndexFocus = 1;

            var index = getHubIndex();

            if (index == -1)
            {
                selectHub(0);
            }
            else scrollHubs.scrollToItem(index);

            action = 0;

            visible = true;
        }
        else lineEditSearch.clear();
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
                selectHub(0);
            }

            scrollCompletion.currentIndex = -1;

            scrollCompletion.query = text;

            scrollCompletion.runQuery();

            pText = scrollCompletion.query;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function browse()
    {
        lineEditSearch.focus();

        hub = 1;
    }

    //---------------------------------------------------------------------------------------------

    function selectPrevious()
    {
        if (pIndexFocus == 1)
        {
             selectPreviousHub();
        }
        else selectPreviousCompletion();
    }

    function selectNext()
    {
        if (pIndexFocus == 1)
        {
             selectNextHub();
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

    function hubAt(index)
    {
        return hubs.idAt(index);
    }

    function getHubIndex()
    {
        return hubs.indexFromId(hub);
    }

    //---------------------------------------------------------------------------------------------

    function selectHub(index)
    {
        var id = hubs.idAt(index);

        if (id == -1) return;

        hub = id;

        scrollHubs.scrollToItem(index);
    }

    function selectPreviousHub()
    {
        var index = getHubIndex() - 1;

        selectHub(index);
    }

    function selectNextHub()
    {
        var index = getHubIndex() + 1;

        selectHub(index);
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

    function triggerActionPressed()
    {
        if (action == 0) buttonSearch.triggerPressed();
        else             buttonPlay  .triggerPressed();
    }

    function triggerActionReleased()
    {
        if (action == 0) buttonSearch.triggerReleased();
        else             buttonPlay  .triggerReleased();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pStartSearch()
    {
        if (action == 0)
        {
             panelBrowse.search(hub, lineEditSearch.text, true, false);
        }
        else panelBrowse.search(hub, lineEditSearch.text, true, true);
    }

    //---------------------------------------------------------------------------------------------

    function pSearch()
    {
        action = 0;

        pStartSearch();
    }

    function pPlay()
    {
        action = 1;

        pStartSearch();
    }

    function pTriggerSearch()
    {
        if (buttonSearch.isFocused)
        {
            pSearch();
        }
        else if (buttonPlay.isFocused)
        {
            pPlay();
        }
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

        width: (gui.isMini) ? st.dp258
                            : lineEditSearch.width

        textDefault: qsTr("Type something to watch")

        onQueryCompleted: pUpdateFocus()

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                pIndexFocus = -1;

                scrollToItem(currentIndex);

                pTextEvents = false;

                lineEditSearch.text = completion;

                pTextEvents = true;

                lineEditSearch.moveCursorAtEnd();
            }
            else scrollTo(0);
        }

        onItemDoubleClicked: pTriggerSearch()
    }

    BorderVertical
    {
        id: border

        anchors.left: scrollCompletion.right
    }

    BarTitleSmall
    {
        id: barHubs

        anchors.left: border.right

        width: st.dp220

        borderTop: 0

        acceptedButtons: Qt.NoButton

        BarTitleText
        {
            anchors.fill: parent

            text: qsTr("Hubs")

            font.pixelSize: st.dp12
        }
    }

    ScrollView
    {
        id: scrollHubs

        property variant itemHovered: null

        property int indexHover: (itemHovered) ? itemHovered.getIndex()
                                               : -1

        anchors.left  : border.right
        anchors.top   : barHubs.bottom
        anchors.bottom: buttonSearch.top

        anchors.bottomMargin: -(buttonSearch.borderTop)

        width: barHubs.width

        model: ModelLibraryFolder { folder: hubs }

        delegate: ComponentLibraryItem
        {
            isSelected: (id == hub)

            isFocused: (pIndexFocus == 1)

            icon: cover

            iconDefault: (id == 1) ? st.icon32x32_url
                                   : st.icon32x32_folder

            text: title

            onPressed: hub = id

            onDoubleClicked: pTriggerSearch()
        }
    }

    ButtonPianoFull
    {
        id: buttonSearch

        anchors.left  : border.right
        anchors.bottom: parent.bottom

        width: Math.round((scrollHubs.width) / 2)

        borderRight: 0
        borderTop  : borderSize

        spacing: st.dp2

        enabled: (scrollCompletion.query)

        isFocused: (enabled && action == 0)

        icon          : st.icon16x16_searchSmall
        iconSourceSize: st.size16x16

        text: qsTr("Browse")

        onClicked: pSearch()
    }

    ButtonPianoFull
    {
        id: buttonPlay

        anchors.left  : buttonSearch.right
        anchors.right : parent.right
        anchors.top   : buttonSearch.top
        anchors.bottom: buttonSearch.bottom

        borderLeft : borderSize
        borderRight: 0
        borderTop  : borderSize

        spacing: st.dp2

        enabled: buttonSearch.enabled

        isFocused: (enabled && action == 1)

        icon          : st.icon16x16_playSmall
        iconSourceSize: st.size16x16

        text: qsTr("Play")

        onClicked: pPlay()
    }
}
