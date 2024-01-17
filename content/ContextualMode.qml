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
    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // Private

    function pVideoIndex(output)
    {
        if      (output == AbstractBackend.OutputAudio) return  0;
        else if (output == AbstractBackend.OutputMedia) return  1;
        else                                            return -1;
    }

    function pApply(index)
    {
        if (index) player.output = AbstractBackend.OutputMedia;
        else       player.output = AbstractBackend.OutputAudio;
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    ButtonCheckSettings
    {
        checked: (player.sourceMode == AbstractBackend.SourceSafe)

        text: qsTr("Safe mode")

        onCheckClicked:
        {
            var mode;

            if (checked) mode = AbstractBackend.SourceSafe;
            else         mode = AbstractBackend.SourceDefault;

            if (player.sourceMode == mode)
            {
                areaContextual.hidePanels();

                return;
            }

            // FIXME: This is a hack to keep the current frame while loading the other sources.
            if (player.hasStarted)
            {
                // NOTE: We close the split view before reloading the track.
                if (highlightedTab) tabs.currentTab = highlightedTab;

                if (player.isPlaying)
                {
                    player.stop();

                    player.sourceMode = mode;

                    player.play();
                }
                else
                {
                    player.stop();

                    player.sourceMode = mode;
                }
            }
            else player.sourceMode = mode;
        }
    }

    ButtonsCheck
    {
        anchors.left : parent.left
        anchors.right: parent.right

        model: ListModel {}

        currentIndex : pVideoIndex(player.output)
        currentActive: pVideoIndex(player.outputActive)

        Component.onCompleted:
        {
//#QT_4
            // NOTE Qt4: We can only append items one by one.
            model.append({ "title": qsTr("Audio") });
            model.append({ "title": qsTr("Video") });
//#ELSE
            model.append(
            [
                { "title": qsTr("Audio") },
                { "title": qsTr("Video") }
            ]);
//#END
        }

        onPressed: pApply(currentIndex)
    }
}
