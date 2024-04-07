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

ColumnAuto
{
    id: contextualLinks

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isLoaded: false

    /* read */ property string source

    /* read */ property variant titles: [ qsTr("Default"),
                                          qsTr("144p"),
                                          qsTr("240p"),
                                          qsTr("360p"),
                                          qsTr("480p"),
                                          qsTr("720p"),
                                          qsTr("1080p"),
                                          qsTr("1440p"),
                                          qsTr("2160p")]

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onLinksLoaded(medias, audios)
        {
            var arrayA = new Array;
            var arrayB = new Array;

            for (var i = 0; i <= AbstractBackend.Quality2160; i++)
            {
                var title = titles[i];

                var source = medias[i];

                if (source) arrayA.push({ "title": title, "source": source});

                source = audios[i];

                if (source == "") continue;

                var index = arrayB.length + 1;

                arrayB.push({ "title": qsTr("Audio %1").arg(index), "source": source});
            }

//#QT_4
            //-------------------------------------------------------------------------------------
            // NOTE Qt4: We can only append items one by one.

            for (/* var */ i = 0; i < arrayA.length; i++)
            {
                modelVideo.append(arrayA[i]);
            }

            for (/* var */ i = 0; i < arrayB.length; i++)
            {
                modelAudio.append(arrayB[i]);
            }

            //-------------------------------------------------------------------------------------
//#ELSE
            // NOTE: It's probably better to append everything at once.
            modelVideo.append(arrayA);
            modelAudio.append(arrayB);
//#END

            isLoaded = true;
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load(source)
    {
        contextualLinks.source = source;

        // NOTE: This call triggers pLoadLinks.
        buttonSafe.checked = true;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pLoadLinks()
    {
        isLoaded = false;

        modelVideo.clear();
        modelAudio.clear();

        core.loadLinks(source, buttonSafe.checked);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Component
    {
        id: item

        Item
        {
            anchors.left : parent.left
            anchors.right: parent.right

            height: button.height

            ButtonPush
            {
                anchors.left : parent.left
                anchors.right: button.left

                text: title

                itemText.horizontalAlignment: Text.AlignLeft
            }

            ButtonPushIcon
            {
                id: button

                anchors.right: parent.right

                icon          : st.icon16x16_external
                iconSourceSize: st.size16x16

                onClicked:
                {
                    gui.openSource(source);

                    areaContextual.hidePanels();
                }
            }
        }
    }

    ButtonCheckSettings
    {
        id: buttonSafe

        text: qsTr("Safe mode")

        onCheckedChanged: pLoadLinks()
    }

    BarSettings
    {
        text: qsTr("Video")

        visible: listVideo.visible
    }

    Repeater
    {
        id: listVideo

        visible: (count)

        model: ListModel { id: modelVideo }

        delegate: item
    }

    BarSettings
    {
        text: qsTr("Audio")

        visible: listAudio.visible
    }

    Repeater
    {
        id: listAudio

        visible: count

        model: ListModel { id: modelAudio }

        delegate: item
    }
}
