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

    property bool pLoaded: false

    property LibraryFolder pFolder: null

    property string pSearchEngine: "opensubtitles"

    property bool pVisible: (scrollCompletion.visible == false)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pLoaded = true;

        scrollLanguages.scrollToItemTop(scrollLanguages.currentIndex);
    }

    Component.onDestruction: if (pFolder) pFolder.tryDelete()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function search(query)
    {
        hideCompletion();

        var language;

        var index = scrollLanguages.currentIndex;

        if (index == -1)
        {
             language = "english";
        }
        else language = modelLanguage.titleAt(index).toLowerCase();

        var source = controllerPlaylist.createSource(pSearchEngine, "subtitles", language, query);

        if (pFolder == null)
        {
            pFolder = controllerPlaylist.createFolder();
        }

        scrollFolder.currentIndex = -1;

        pFolder.reloadSource(source);
    }

    //---------------------------------------------------------------------------------------------

    function clear()
    {
        if (pFolder == null) return;

        scrollFolder.currentIndex = -1;

        pFolder.loadSource("");
    }

    function clearIndex()
    {
        scrollFolder.currentIndex = -1;
    }

    //---------------------------------------------------------------------------------------------

    function applyText(text)
    {
        scrollCompletion.runCompletion(text);

        if (text)
        {
             scrollCompletion.visible = true;
        }
        else scrollCompletion.visible = false;
    }

    //---------------------------------------------------------------------------------------------

    function selectPrevious()
    {
        if (scrollCompletion.visible)
        {
            scrollCompletion.selectPrevious();

            if (scrollCompletion.currentIndex == -1)
            {
                pSetText(scrollCompletion.query);
            }
        }
        else scrollFolder.selectPrevious();
    }

    function selectNext()
    {
        if (scrollCompletion.visible)
        {
            scrollCompletion.selectNext();

            if (scrollCompletion.currentIndex == -1)
            {
                pSetText(scrollCompletion.query);
            }
        }
        else scrollFolder.selectNext();
    }

    //---------------------------------------------------------------------------------------------

    function hideCompletion()
    {
        if (scrollCompletion.visible == false) return;

        scrollCompletion.visible = false;

        scrollCompletion.currentIndex = -1;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pReload()
    {
        if (pFolder == null) return;

        pFolder.reloadQuery()
    }

    //---------------------------------------------------------------------------------------------

    function pApplyItem(index)
    {
        pEvents = false;

        playerTab.subtitle = pFolder.itemSource(index);

        pEvents = true;

        gui.updateTrackSubtitle(-1);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ScrollList
    {
        id: scrollLanguages

        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        width: st.dp128

        visible: pVisible

        currentIndex: local.subtitleIndex

        model: ModelList
        {
            id: modelLanguage

            titles: controllerPlaylist.getLanguages()
        }

        delegate: ComponentList
        {
            checkHover: false

            function onPress()
            {
                scrollLanguages.currentIndex = index;
            }
        }

        onItemDoubleClicked: if (currentIndex == index) pReload()

        onCurrentIndexChanged:
        {
            var text = lineEdit.text;

            if (pLoaded && text)
            {
                search(text);
            }

            local.subtitleIndex = currentIndex;
        }
    }

    BorderVertical
    {
        id: border

        anchors.left: scrollLanguages.right

        visible: pVisible
    }

    ScrollListDefault
    {
        id: scrollFolder

        anchors.left  : border.right
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        visible: pVisible

        model: ModelLibraryFolder { folder: pFolder }

        delegate: ComponentList
        {
            itemText.elide: Text.ElideLeft

            function onPress()
            {
                if (scrollFolder.currentIndex == index)
                {
                     scrollFolder.currentIndex = -1;
                }
                else scrollFolder.currentIndex = index;
            }
        }

        textDefault: (labelLoading.visible) ? "" : qsTr("Type a subtitle query")

        onCurrentIndexChanged: pApplyItem(currentIndex)
    }

    LabelLoadingButton
    {
        id: labelLoading

        anchors.top: parent.top

        anchors.topMargin: scrollFolder.list.height + st.dp8

        anchors.horizontalCenter: scrollFolder.horizontalCenter

        visible: (pFolder) ? pFolder.queryIsLoading : false

        text: qsTr("Loading...")

        onClicked: pFolder.abortQuery()
    }

    ScrollCompletion
    {
        id: scrollCompletion

        anchors.fill: parent

        visible: false

        textDefault: qsTr("Type a subtitle query")

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                pSetText(completion);

                lineEdit.moveCursorAtEnd();
            }
            else scrollTo(0);
        }

        onItemClicked: pStartSearch(lineEdit.text)
    }
}
