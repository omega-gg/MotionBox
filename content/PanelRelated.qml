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
    id: panelRelated

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExposed : false
    /* read */ property bool isExpanded: false

    property bool autoRefresh: true

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pLoading: (playlist != null && playlist.queryIsLoading)

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias isAnimated: itemSlide.isAnimated

    property alias playlist: scrollPlaylist.playlist

    //---------------------------------------------------------------------------------------------

    property alias buttonRefresh: buttonRefresh

    property alias list: scrollPlaylist.list

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    anchors.left  : parent.right
    anchors.top   : parent.top
    anchors.bottom: parent.bottom

    width: pGetWidth(parent.width)

    borderTop   : 0
    borderRight : 0
    borderBottom: 0

    visible: false

    shadowOpacity: (wall.isExposed)

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states:
    [
        State
        {
            name: "visibleExpanded"; when: (isExposed && isExpanded)

            AnchorChanges
            {
                target: panelRelated

                anchors.left : undefined
                anchors.right: parent.right
            }

            PropertyChanges
            {
                target: panelRelated

                width: Math.round(parent.width / 2)
            }
        },
        State
        {
            name: "visible"; when: isExposed

            AnchorChanges
            {
                target: panelRelated

                anchors.left : undefined
                anchors.right: parent.right
            }
        }
    ]

    transitions: Transition
    {
        SequentialAnimation
        {
            AnchorAnimation { duration: st.duration_normal }

            ScriptAction { script: pCompleteTransition() }
        }

        SequentialAnimation
        {
            NumberAnimation
            {
                property: "width"

                duration: st.duration_normal
            }

            ScriptAction { script: pCompleteTransition() }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function expose()
    {
        if (isExposed || actionCue.tryPush(gui.actionRelatedExpose)) return;

        visible = true;

        parent.wallExpand(parent.width - pGetWidth(parent.width), wall.height);

        isExposed = true;

        if (pCheckRefresh()) pRefresh();

        local.related = true;

        gui.startActionCue(st.duration_normal);
    }

    function collapse()
    {
        if (isExposed == false || actionCue.tryPush(gui.actionRelatedCollapse)) return;

        pClearRefresh();

        parent.wallExpand(parent.width, wall.height);

        isExposed  = false;
        isExpanded = false;

        local.related         = false;
        local.relatedExpanded = false;

        gui.startActionCue(st.duration_normal);
    }

    function toggleExpose()
    {
        if (isExposed) collapse();
        else           expose  ();
    }

    //---------------------------------------------------------------------------------------------

    function expand()
    {
        if (isExpanded || isExposed == false
            ||
            actionCue.tryPush(gui.actionRelatedExpand)) return;

        parent.wallExpand(Math.round(parent.width / 2), wall.height);

        isExpanded = true;

        local.relatedExpanded = true;

        gui.startActionCue(st.duration_normal);
    }

    function restore()
    {
        if (isExpanded == false || isExposed == false
            ||
            actionCue.tryPush(gui.actionRelatedRestore)) return;

        parent.wallExpand(parent.width - pGetWidth(parent.width), wall.height);

        isExpanded = false;

        local.relatedExpanded = false;

        gui.startActionCue(st.duration_normal);
    }

    function toggleExpand()
    {
        if (isExpanded) restore();
        else            expand ();
    }

    //---------------------------------------------------------------------------------------------

    function load(data)
    {
        saveScroll();

        related.loadTracks(data);

        local.cache = true;
    }

    function slide(data)
    {
        itemSlide.init();

        saveScroll();

        related.loadTracks(data);

        itemSlide.slideLeft();

        local.cache = true;
    }

    //---------------------------------------------------------------------------------------------

    function refresh()
    {
        pClearRefresh();

        pRefresh();
    }

    function refreshLater()
    {
        if (isExposed == false) return;

        if (pCheckRefresh())
        {
            var interval = timer.interval + st.panelRelated_durationMinimum;

            timer.interval = Math.min(interval, st.panelRelated_durationMaximum);

            timer.restart();
        }
        else pClearRefresh();
    }

    //---------------------------------------------------------------------------------------------

    function setPreviousPlaylist()
    {
        itemSlide.init();

        saveScroll();

        related.setPreviousPlaylist();

        itemSlide.slideRight();
    }

    function setNextPlaylist()
    {
        itemSlide.init();

        saveScroll();

        related.setNextPlaylist();

        itemSlide.slideLeft();
    }

    //---------------------------------------------------------------------------------------------

    function getWidth(width)
    {
        if (isExpanded)
        {
             return Math.round(width / 2);
        }
        else return pGetWidth(width);
    }

    //---------------------------------------------------------------------------------------------

    function saveScroll()
    {
        list.saveScroll();
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pGetWidth(width)
    {
        var size = Math.round(width / 3);

        var minimum = st.dp200 + borderLeft;
        var maximum = st.dp320 + borderLeft;

        if      (size < minimum) return minimum;
        else if (size > maximum) return maximum;
        else                     return size;
    }

    //---------------------------------------------------------------------------------------------

    function pCheckRefresh()
    {
        if (autoRefresh == false || related.isLoading)
        {
            return false;
        }
        else if (related.isEmpty
                 ||
                 (currentTab.playlist != playlist && currentTab.source != playlist.label))
        {
             return true;
        }
        else return false;
    }

    function pClearRefresh()
    {
        timer.stop();

        timer.interval = 0;
    }

    //---------------------------------------------------------------------------------------------

    function pRefresh()
    {
        saveScroll();

        related.loadTracks(currentTab.trackData);

        local.cache = true;
    }

    //---------------------------------------------------------------------------------------------

    function pCompleteTransition()
    {
        if (isExposed == false) visible = false;

        parent.wallRestore();
    }

    //---------------------------------------------------------------------------------------------
    // Childs
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: 0

        onTriggered:
        {
            stop();

            interval = 0;

            pRefresh();
        }
    }

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        onDoubleClicked: toggleExpand()

        ButtonPianoIcon
        {
            id: buttonLeft

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: height + borderSizeWidth

            checkable: true
            checked  : isExpanded

            icon          : st.icon24x24_slideLeft
            iconSourceSize: st.size24x24

            onClicked: toggleExpand()
        }

        ButtonPianoIcon
        {
            id: buttonRefresh

            anchors.left  : buttonLeft.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: st.dp36 + borderSizeWidth

            enabled: (isAnimated == false && currentTab.isValid)

            icon: (pLoading) ? st.icon24x24_abort
                             : st.icon24x24_refresh

            iconSourceSize: st.size24x24

            onClicked:
            {
                if (playlist && playlist.queryIsLoading)
                {
                    playlist.abortQuery();
                }
                else refresh();
            }
        }

        ButtonPianoIcon
        {
            id: buttonBackward

            anchors.left  : buttonRefresh.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: height + borderSizeWidth

            enabled: (isAnimated == false && playlist != null && playlist.isLoading == false
                      &&
                      related.hasPreviousPlaylist)

            icon          : st.icon16x16_previous
            iconSourceSize: st.size16x16

            onClicked: setPreviousPlaylist()
        }

        ButtonPianoIcon
        {
            id: buttonForward

            anchors.left  : buttonBackward.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            width: height + borderSizeWidth

            enabled: (isAnimated == false && playlist != null && playlist.isLoading == false
                      &&
                      related.hasNextPlaylist)

            icon          : st.icon16x16_next
            iconSourceSize: st.size16x16

            onClicked: setNextPlaylist()
        }

        //-----------------------------------------------------------------------------------------

        BarTitleText
        {
            anchors.left  : buttonForward.right
            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            text: qsTr("Related")
        }
    }

    ItemSlide
    {
        id: itemSlide

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.top   : bar.bottom
        anchors.bottom: parent.bottom

        durationAnimation: 260

        TextListDefault
        {
            anchors.left : parent.left
            anchors.right: parent.right
            anchors.top  : parent.top

            anchors.topMargin: st.dp20

            horizontalAlignment: Text.AlignHCenter

            visible: (scrollPlaylist.playlist == null)

            text: qsTr("No track selected")
        }

        ScrollPlaylist
        {
            id: scrollPlaylist

            anchors.fill: parent

            textDefault: qsTr("No related tracks")

            playlist: (related) ? related.currentItem : null

            enableLoad: false

            itemText.visible: (count == 1 && playlist != null && playlist.queryIsLoading == false)

            buttonLink.anchors.rightMargin: 0

            buttonLink.visible: (checkBox.visible && list.indexActive)

            delegate: ComponentTrack
            {
                background.gradient: Gradient
                {
                    GradientStop
                    {
                        position: 0.0

                        color:
                        {
                            if (isSelected)
                            {
                                if (isFocused == false)
                                {
                                    if (isHovered) return st.itemList_colorSelectHoverA;
                                    else           return st.itemList_colorSelectA;
                                }
                                else return st.itemList_colorSelectFocusA;
                            }
                            else if (isCurrent)
                            {
                                if (isHovered) return st.itemList_colorCurrentHoverA;
                                else           return st.itemList_colorCurrentA;
                            }
                            else if (isContextual)
                            {
                                if (index == 0)
                                {
                                    if (isHovered) return st.itemTab_colorContextualHoverA;
                                    else           return st.itemTab_colorHoverA;
                                }
                                else if (isHovered) return st.itemList_colorContextualHoverA;
                                else                return st.itemList_colorHoverA;
                            }
                            else if (isPressed)
                            {
                                return st.itemList_colorPressA;
                            }
                            else if (isHovered)
                            {
                                if (index == 0) return st.itemTab_colorHoverA;
                                else            return st.itemList_colorHoverA;
                            }
                            else if (index == 0)
                            {
                                return st.itemTab_colorA;
                            }
                            else if (isDefault)
                            {
                                return st.itemList_colorDefaultA;
                            }
                            else return st.itemList_colorA;
                        }
                    }

                    GradientStop
                    {
                        position: 1.0

                        color:
                        {
                            if (isSelected)
                            {
                                if (isFocused == false)
                                {
                                    if (isHovered) return st.itemList_colorSelectHoverB;
                                    else           return st.itemList_colorSelectB;
                                }
                                else return st.itemList_colorSelectFocusB;
                            }
                            else if (isCurrent)
                            {
                                if (isHovered) return st.itemList_colorCurrentHoverB;
                                else           return st.itemList_colorCurrentB;
                            }
                            else if (isContextual)
                            {
                                if (index == 0)
                                {
                                    if (isHovered) return st.itemTab_colorContextualHoverB;
                                    else           return st.itemTab_colorHoverB;
                                }
                                else if (isHovered) return st.itemList_colorContextualHoverB;
                                else                return st.itemList_colorHoverB;
                            }
                            else if (isPressed)
                            {
                                return st.itemList_colorPressB;
                            }
                            else if (isHovered)
                            {
                                if (index == 0) return st.itemTab_colorHoverB;
                                else            return st.itemList_colorHoverB;
                            }
                            else if (index == 0)
                            {
                                return st.itemTab_colorB;
                            }
                            else if (isDefault)
                            {
                                return st.itemList_colorDefaultB;
                            }
                            else return st.itemList_colorB;
                        }
                    }
                }
            }

            function onLink(index)
            {
                itemSlide.init();

                saveScroll();

                related.loadTracks(playlist.trackData(index));

                itemSlide.slideLeft();
            }

            BorderHorizontal
            {
                anchors.top: parent.top

                anchors.topMargin: st.dp32

                visible: (scrollPlaylist.count)
            }
        }
    }
}
