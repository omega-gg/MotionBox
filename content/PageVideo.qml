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

Column
{
    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------
    // NOTE: We have to rely on these properties to avoid binding loops in BasePanelSettings.

    /* read */ property int contentWidth : st.dp192
    /* read */ property int contentHeight: row.y + row.height

    //---------------------------------------------------------------------------------------------
    // Private

    property int pRepeat: local.repeat

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    // NOTE: We need to forceLayout and processEvents to get the proper contentHeight.
    Component.onCompleted: forceLayout()

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function pStringVideo()
    {
        var output = player.output;

        if (output == AbstractBackend.OutputAudio) return qsTr("Audio");
        else                                       return qsTr("Video");
    }

    function pIndexVideo(output)
    {
        if      (output == AbstractBackend.OutputAudio) return  0;
        else if (output == AbstractBackend.OutputMedia) return  1;
        else                                            return -1;
    }

    function pClickVideo(index)
    {
        if (index == 0)
        {
             player.output = AbstractBackend.OutputAudio;
        }
        else player.output = AbstractBackend.OutputMedia;
    }

    //---------------------------------------------------------------------------------------------
    // BasePanelSettings events

    // NOTE: We need to forceLayout and processEvents to get the proper contentHeight.
    function onShow()
    {
        sk.processEvents();
    }

    //---------------------------------------------------------------------------------------------
    // Quality

    function pActiveQuality()
    {
        return (player.qualityActive == player.quality);
    }

    function pStringQuality()
    {
        var quality = player.quality;

        if      (quality == AbstractBackend.Quality144)  return qsTr("144p");
        else if (quality == AbstractBackend.Quality240)  return qsTr("240p");
        else if (quality == AbstractBackend.Quality360)  return qsTr("360p");
        else if (quality == AbstractBackend.Quality480)  return qsTr("480p");
        else if (quality == AbstractBackend.Quality720)  return qsTr("720p");
        else if (quality == AbstractBackend.Quality1080) return qsTr("1080p");
        else if (quality == AbstractBackend.Quality1440) return qsTr("1440p");
        else if (quality == AbstractBackend.Quality2160) return qsTr("2160p");
        else                                             return qsTr("Invalid");
    }

    function pIndexQuality(quality)
    {
        return quality - 1;
    }

    function pClickQuality(index)
    {
        player.quality = index + 1;
    }

    //---------------------------------------------------------------------------------------------
    // Video

    function pStringRatio()
    {
        var mode = player.fillMode;

        if      (mode == AbstractBackend.Stretch)           return qsTr("Stretch");
        else if (mode == AbstractBackend.PreserveAspectFit) return qsTr("Fit");
        else                                                return qsTr("Expand");
    }

    function pIndexRatio()
    {
        var mode = player.fillMode;

        if      (mode == AbstractBackend.Stretch)           return 2;
        else if (mode == AbstractBackend.PreserveAspectFit) return 0;
        else                                                return 1;
    }

    function pClickRatio(index)
    {
        if (index == 0)
        {
            player.fillMode = AbstractBackend.PreserveAspectFit;
        }
        else if (index == 1)
        {
            player.fillMode = AbstractBackend.PreserveAspectCrop;
        }
        else player.fillMode = AbstractBackend.Stretch;
    }

    //---------------------------------------------------------------------------------------------
    // Quality

    function pStringSpeed()
    {
        var speed = player.speed;

        if (speed == 1)
        {
            return qsTr("Normal");
        }
        else return speed;
    }

    function pIndexSpeed()
    {
        var speed = player.speed;

        if      (speed == 0.25) return  0;
        else if (speed == 0.5)  return  1;
        else if (speed == 0.75) return  2;
        else if (speed == 1)    return  3;
        else if (speed == 1.25) return  4;
        else if (speed == 1.5)  return  5;
        else if (speed == 2)    return  6;
        else                    return -1;
    }

    function pClickSpeed(index)
    {
        var speed;

        if      (index == 0) speed = 0.25;
        else if (index == 1) speed = 0.5;
        else if (index == 2) speed = 0.75;
        else if (index == 3) speed = 1;
        else if (index == 4) speed = 1.25;
        else if (index == 5) speed = 1.5;
        else                 speed = 2; // index == 6

        player.speed = speed;
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    ButtonCheckLabel
    {
        anchors.left : parent.left
        anchors.right: parent.right

        checked: local.autoPlay

        text: qsTr("Autoplay")

        itemText.horizontalAlignment: Text.AlignLeft

        onCheckClicked: local.autoPlay = checked
    }

    BarSettings
    {
        borderTop: borderSize

        text: qsTr("Output")
    }

    ButtonsCheck
    {
        id: buttonsVideo

        anchors.left : parent.left
        anchors.right: parent.right

        model: ListModel {}

        currentIndex : pIndexVideo(player.output)
        currentActive: pIndexVideo(player.outputActive)

        Component.onCompleted:
        {
            model.append(
            [
                { "title": qsTr("Audio") },
                { "title": qsTr("Video") }
            ]);
        }

        onPressed: pClickVideo(currentIndex)
    }

    BarSettings
    {
        borderTop: borderSize

        text: qsTr("Quality")
    }

    ButtonSettings
    {
        id: buttonQuality

        marginY: buttonsVideo.y - buttonQuality.y

        settings: [{ "title": qsTr("144p")  },
                   { "title": qsTr("240p")  },
                   { "title": qsTr("360p")  },
                   { "title": qsTr("480p")  },
                   { "title": qsTr("720p")  },
                   { "title": qsTr("1080p") },
                   { "title": qsTr("1440p") },
                   { "title": qsTr("2160p") }]

        active: pActiveQuality()

        text: pStringQuality()

        currentIndex: pIndexQuality(player.quality)
        activeIndex : pIndexQuality(player.qualityActive)

        function onClick(index) { pClickQuality(index) }
    }

    BarSettings { text: qsTr("Ratio") }

    ButtonSettings
    {
        settings: [{ "title": qsTr("Fit")     },
                   { "title": qsTr("Expand")  },
                   { "title": qsTr("Stretch") }]

        text: pStringRatio()

        currentIndex: pIndexRatio(player.fillMode)

        function onClick(index) { pClickRatio(index) }
    }

    BarSettings { text: qsTr("Speed") }

    ButtonSettings
    {
        id: buttonSpeed

        marginY: buttonsVideo.y - buttonSpeed.y

        settings: [{ "title": qsTr("0.25")   },
                   { "title": qsTr("0.5")    },
                   { "title": qsTr("0.75")   },
                   { "title": qsTr("Normal") },
                   { "title": qsTr("1.25")   },
                   { "title": qsTr("1.5")    },
                   { "title": qsTr("2")      }]

        text: pStringSpeed()

        currentIndex: pIndexSpeed()

        function onClick(index) { pClickSpeed(index) }
    }

    BarSettings { text: qsTr("Playback") }

    Row
    {
        id: row

        ButtonPushFull
        {
            id: buttonShuffle

            width: Math.round(contentWidth / 2)

            checkable: true
            checked  : local.shuffle

            icon          : st.icon16x16_shuffle
            iconSourceSize: st.size16x16

            text: qsTr("Shuffle")

            onClicked: local.shuffle = !(checked)
        }

        ButtonPushFull
        {
            width: buttonShuffle.width

            checkable: true
            checked  : (pRepeat > 0)

            icon: (pRepeat == 2) ? st.icon16x16_repeatOne
                                 : st.icon16x16_repeat

            iconSourceSize: st.size16x16

            text: (pRepeat == 2) ? qsTr("Rep. 1")
                                 : qsTr("Repeat")

            onClicked:
            {
                pRepeat = (pRepeat + 1) % 3;

                player.repeat = pRepeat;
            }
        }
    }
}
