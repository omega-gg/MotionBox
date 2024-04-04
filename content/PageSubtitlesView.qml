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

    property string pSource

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        pSource = player.source;

        pUpdateList();
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function updateView()
    {
        model.clear();

        pUpdateList();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pUpdateList()
    {
        var array = new Array;

        var subtitles = player.subtitles;

        var count = subtitles.length;

        for (var i = 0; i < count; i++)
        {
            var source = subtitles[i];

            var title = controllerNetwork.extractUrlFileName(source);

            array.push({ "title": title, "source": source});
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
            if (subtitle != subtitles[i]) continue;

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
        else playerTab.subtitle = player.subtitles[index];

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

            onClicked:
            {
                if (list.currentIndex == index)
                {
                    list.currentIndex = -1;

                    return;
                }

                list.currentIndex = index;

                // NOTE: We want to hide the panel right away.
                buttonSubtitles.checked = false;
            }
        }

        onCurrentIndexChanged: pApplyItem(currentIndex)
    }
}
