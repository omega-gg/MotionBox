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

    property string pSearchEngine: "opensubtitles"

    property bool pVisible: (scrollCompletion.visible == false)

    property bool pTextEvents: true

    //---------------------------------------------------------------------------------------------
    // Aliases private
    //---------------------------------------------------------------------------------------------

    property alias pFolder: model.folder

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    height: pHeight

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pFolder = core.createFolder();

        scrollLanguages.scrollToItemTop(scrollLanguages.currentIndex);
    }

    Component.onDestruction: pFolder.tryDelete()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function search(query)
    {
        var language;

        var index = scrollLanguages.currentIndex;

        if (index == -1)
        {
             language = "english";
        }
        else language = modelLanguage.titleAt(index).toLowerCase();

        var source = controllerPlaylist.createSource(pSearchEngine, "subtitles", language, query);

        pFolder.loadSource(source);
    }

    function applyText(text)
    {
        if (pTextEvents == false) return;

        scrollCompletion.currentIndex = -1;

        scrollCompletion.query = text;

        scrollCompletion.runQuery();

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
        }
    }

    function selectNext()
    {
        if (scrollCompletion.visible)
        {
            scrollCompletion.selectNext();
        }
    }

    //---------------------------------------------------------------------------------------------

    function showCompletion()
    {
        scrollCompletion.visible = true;
    }

    function hideCompletion()
    {
        scrollCompletion.visible = false;

        scrollCompletion.currentIndex = -1;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ScrollCompletion
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

        onCurrentIndexChanged:
        {
            var text = lineEdit.text;

            if (text) search(text);

            local.subtitleIndex = currentIndex;
        }
    }

    BorderVertical
    {
        id: border

        anchors.left: scrollLanguages.right

        visible: pVisible
    }

    ScrollCompletion
    {
        id: scrollFolder

        anchors.left  : border.right
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom

        visible: pVisible

        model: ModelLibraryFolder { id: model }

        textDefault: (labelLoading.visible) ? "" : qsTr("Type a subtitle query")
    }

    LabelLoadingButton
    {
        id: labelLoading

        anchors.top: parent.top

        anchors.topMargin: st.dp8

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

        delegate: ComponentCompletion
        {
            itemText.font.pixelSize: st.dp14
        }

        textDefault: qsTr("Type a subtitle query")

        onCompletionChanged:
        {
            if (currentIndex != -1)
            {
                pTextEvents = false;

                lineEdit.text = completion;

                pTextEvents = true;

                lineEdit.moveCursorAtEnd();
            }
            else scrollTo(0);
        }
    }
}
