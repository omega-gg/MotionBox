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

    property bool pUpdate: true

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pUpdate = false;

        pUpdateList();

        pUpdate = true;
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function updateView()
    {
        pUpdate = false;

        model.clear();

        pUpdateList();

        pUpdate = true;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateList()
    {
        var array = new Array;

        var subtitles = player.subtitlesData;

        var count = subtitles.length;

        for (var i = 0; i < count; i++)
        {
            var data = subtitles[i];

            var source = data.source;
            var title  = data.title;

            if (title == "")
            {
                title = controllerNetwork.extractUrlFileName(source);
            }

            array.push({ "title": title, "source": source });
        }

//#QT_4
        // NOTE Qt4: We can only append items one by one.
        for (/* var */ i = 0; i < array.length; i++)
        {
            model.append(array[i]);
        }
//#ELSE
        // NOTE: It's probably better to append everything at once.
        model.append(array);
//#END

        var subtitle = playerTab.subtitle;

        if (subtitle == "") return;

        for (/* var */ i = 0; i < count; i++)
        {
            if (subtitle != subtitles[i].source) continue;

            list.currentIndex = i;

            return;
        }
    }

    function pApplyItem(index)
    {
        if (index == -1)
        {
            playerTab.subtitle = "";

            panelSubtitles.clearIndex();
        }
        else playerTab.subtitle = player.subtitlesData[index].source;

        gui.updateTrackSubtitle(index);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ScrollList
    {
        id: list

        anchors.fill: parent

        currentIndex: -1

        model: ListModel { id: model }

        delegate: ComponentList
        {
            text: title

            itemText.elide: Text.ElideLeft

            function onPress()
            {
                if (list.currentIndex == index)
                {
                    list.currentIndex = -1;

                    return;
                }

                list.currentIndex = index;

                // NOTE: We want to hide the panel right away.
                panelSubtitles.collapse();
            }
        }

        onCurrentIndexChanged: if (pUpdate) pApplyItem(currentIndex)
    }
}
