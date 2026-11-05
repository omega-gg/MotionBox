//=================================================================================================
/*
    Copyright (C) 2015-2026 MotionBox authors united with omega. <http://omega.gg/about>

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
    id: baseContextualLinks

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

    /* mandatory */ property Component delegate

    // NOTE: We only want the links when they can be downloaded.
    property bool checkDownload: false

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: core

        /* QML_CONNECTION */ function onLinksLoaded(medias, audios, canDownload)
        {
            isLoaded = true;

            if (checkDownload && canDownload == false) return;

            var i;

            for (i = 0; i <= AbstractBackend.Quality2160; i++)
            {
                if (medias[i] == "") continue;

                modelVideo.append({ "title": titles[i], "source": medias[i], "quality": i,
                                    "audio": false });
            }

            var index = 1;

            // NOTE: The audios are listed once each, from the lowest quality to the highest.
            for (i = 0; i <= AbstractBackend.Quality2160; i++)
            {
                if (audios[i] == "") continue;

                modelAudio.append({ "title": qsTr("Audio %1").arg(index), "source": audios[i],
                                    "quality": i, "audio": true });

                index++;
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function load(source)
    {
        baseContextualLinks.source = source;

        pLoadLinks();
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

        delegate: baseContextualLinks.delegate
    }

    BarSettings
    {
        text: qsTr("Audio")

        visible: listAudio.visible
    }

    Repeater
    {
        id: listAudio

        visible: (count)

        model: ListModel { id: modelAudio }

        delegate: baseContextualLinks.delegate
    }

    LabelAction
    {
        text: (isLoaded) ? qsTr("Nothing here")
                         : qsTr("Loading...")

        visible: (listVideo.visible == false && listAudio.visible == false)
    }
}
