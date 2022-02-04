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
    id: buttonsBrowse

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property int count: model.count

    /* read */ property bool isAnimated: false

    property int currentIndex: -1

    property bool enableAnimation: true

    property variant itemLeft  : null
    property variant itemRight : null
    property variant itemBottom: null

    //---------------------------------------------------------------------------------------------
    // Private

    property ListModel pModel: ListModel {}

    property variant pItems: pGetItems()

    property int pPreferredWidth: 0

    property int pCount: count
    property int pId   : -1

    property int pDurationAnimation: (st.animate && enableAnimation) ? st.duration_fast : 0

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    property alias model: repeater.model

    //---------------------------------------------------------------------------------------------
    // Signals
    //---------------------------------------------------------------------------------------------

    signal pressed(int index)

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    onWidthChanged: pUpdateWidth()

    onEnableAnimationChanged:
    {
        if (enableAnimation || timer.running == false) return;

        timer.stop();

        isAnimated = false;

        while (pApplyItem());
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function setFocus()
    {
        if (count)
        {
            pItemAt(0).setFocus();
        }
    }

    //---------------------------------------------------------------------------------------------

    function pushItem(title, cover /* "" */)
    {
        if (cover == undefined)
        {
            cover = "";
        }

        if (pId == 1)
        {
            pId = 0;

            pSetItem(pCount, title, cover);

            pCount++;

            return;
        }

        if (pPopItems(1, 1))
        {
            pSetItem(pCount, title, cover);

            pCount++;

            return;
        }

        pCount++;

        pModel.append({ "id": 0, "title": title, "cover": Qt.resolvedUrl(cover) });

        pStart();
    }

    //---------------------------------------------------------------------------------------------

    function clearItems()
    {
        if (pCount == 0) return;

        var size = pCount;

        pCount = 0;

        if (pId == 0)
        {
            pId = 1;

            pClearItem(count - 1);

            if (size == 1) return;

            size--;
        }

        size -= pPopItems(size, 0);

        if (size == 0) return;

        while (size)
        {
            pModel.append({ "id": 1 });

            size--;
        }

        pStart();
    }

    //---------------------------------------------------------------------------------------------

    function getWidth()
    {
        if (count == 0) return 0;

        var item = pItemAt(count - 1);

        return item.x + item.width;
    }

    // NOTE: Returns the immediate count base on the temporary model.
    function getCount()
    {
        return pCount;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pStart()
    {
        if (enableAnimation)
        {
            if (timer.running) return;

            pProcessItem();

            timer.start();
        }
        else
        {
            pProcessItem();

            while (pApplyItem());
        }
    }

    //---------------------------------------------------------------------------------------------

    function pProcessItem()
    {
        var item = pModel.get(0);

        if (item.id == 0)
        {
            pAddItem(item);
        }
        else pRemoveItem();

        pModel.remove(0);
    }

    function pApplyItem()
    {
        if (pId == 1)
        {
            var index = count - 1;

            if (model.get(index).ready == false)
            {
                model.remove(index);
            }
        }

        if (pModel.count)
        {
            pProcessItem();

            return true;
        }
        else
        {
            pId = -1;

            return false;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pPopItems(size, id)
    {
        var index = 0;
        var count = 0;

        while (index < pModel.count)
        {
            var itemId = pModel.get(index).id;

            if (itemId == id)
            {
                pModel.remove(index);

                count++;

                if (count == size)
                {
                    return count;
                }
            }
            else index++;
        }

        return count;
    }

    //---------------------------------------------------------------------------------------------

    function pAddItem(item)
    {
        pId = 0;

        model.append({ "ready": true, "title": item.title, "cover": item.cover });

        isAnimated = enableAnimation;

        pUpdatePreferredWidth();
    }

    function pRemoveItem()
    {
        pId = 1;

        isAnimated = enableAnimation;

        model.get(count - 1).ready = false;

        pUpdateWidth();
    }

    //---------------------------------------------------------------------------------------------

    function pSetItem(index, title, cover)
    {
        var item = model.get(index);

        item.ready = true;

        item.title = title;
        item.cover = Qt.resolvedUrl(cover);

        pUpdateWidth();

        timer.restart();
    }

    function pClearItem(index, title)
    {
        model.get(index).ready = false;

        pUpdateWidth();

        timer.restart();
    }

    //---------------------------------------------------------------------------------------------

    function pUpdateWidth()
    {
        var width = buttonsBrowse.width;

        if (width > pPreferredWidth)
        {
            for (var i = 0; i < pItems.length; i++)
            {
                var item = pItems[i];

                item.currentWidth = item.preferredWidth;
            }

            return;
        }

        var items = new Array;

        var length = pItems.length;

        for (/* var */ i = 0; i < length; i++)
        {
            items.push(pItems[i]);
        }

        while (length)
        {
            var buttonWidth = width / length;

            var index = 0;

            while (index < items.length)
            {
                /* var */ item = items[index];

                if (item.preferredWidth < buttonWidth)
                {
                    item.currentWidth = item.preferredWidth;

                    width -= item.currentWidth;

                    items.splice(index, 1);
                }
                else index++;
            }

            if (items.length == length)
            {
                for (/* var */ i = 0; i < length; i++)
                {
                    items[i].currentWidth = buttonWidth;
                }

                return;
            }

            length = items.length;
        }
    }

    function pUpdatePreferredWidth()
    {
        pPreferredWidth = 0;

        for (var i = 0; i < pItems.length; i++)
        {
            pPreferredWidth += pItems[i].preferredWidth;
        }

        pUpdateWidth();
    }

    //---------------------------------------------------------------------------------------------

    function pItemAt(index)
    {
        return repeater.itemAt(index);
    }

    function pGetItems()
    {
        var array = new Array;

        for (var i = 0; i < count; i++)
        {
            var item = pItemAt(i);

            array.push(item);
        }

        return array;
    }

    //---------------------------------------------------------------------------------------------

    function pGetX(index)
    {
        if (index < 1) return 0;

        var item = pItemAt(index - 1);

        return Math.round(item.x + item.width);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timer

        interval: pDurationAnimation

        repeat: true

        onTriggered:
        {
            if (pApplyItem()) return;

            timer.stop();

            isAnimated = false;
        }
    }

    Repeater
    {
        id: repeater

        anchors.fill: parent

        model: ListModel {}

        delegate: Loader
        {
            //-------------------------------------------------------------------------------------
            // Properties
            //-------------------------------------------------------------------------------------

            property int preferredWidth: (children.length) ? children[0].getWidth() : 0

            property int currentWidth: 0

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            width: (ready) ? currentWidth : 0

            height: repeater.height

            x: pGetX(index)

            clip: (ready == false)

            sourceComponent: Component
            {
                ButtonPianoFull
                {
                    property int margins: iconWidth + spacing + paddingRight + borderRight

                    anchors.fill: parent

                    spacing: padding

                    checkable: true
                    checked  : (index == currentIndex)

                    icon          : cover
                    iconSourceSize: st.size32x32

                    enableFilter: false

                    text: title

                    itemLeft: (index == 0) ? buttonsBrowse.itemLeft
                                           : pItemAt(index - 1)

                    itemRight: (index == count - 1) ? buttonsBrowse.itemRight
                                                    : pItemAt(index + 1)

                    itemBottom: buttonsBrowse.itemBottom

                    font.pixelSize: st.barTitleText_pixelSize

                    background.clip: (isAnimated)

                    itemText.anchors.fill: undefined

                    itemText.anchors.left  : itemText.parent.left
                    itemText.anchors.top   : itemText.parent.top
                    itemText.anchors.bottom: itemText.parent.bottom

                    itemText.width: currentWidth - margins

                    onPressed: buttonsBrowse.pressed(index)

                    /* QML_EVENT */ Keys.onPressed: function(event)
                    {
                        if (event.key == Qt.Key_Escape)
                        {
                            event.accepted = true;

                            window.clearFocus();
                        }
                    }

                    function getWidth()
                    {
                        return sk.textWidth(font, text) + margins;
                    }
                }
            }

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onPreferredWidthChanged: pUpdatePreferredWidth()

            //-------------------------------------------------------------------------------------
            // Animations
            //-------------------------------------------------------------------------------------

            Behavior on width
            {
                enabled: isAnimated

                PropertyAnimation
                {
                    duration: pDurationAnimation

                    easing.type: st.easing
                }
            }

            //-------------------------------------------------------------------------------------
            // Functions
            //-------------------------------------------------------------------------------------

            function getIndex() { return index; }

            //-------------------------------------------------------------------------------------

            function setFocus()
            {
                if (children.length)
                {
                    children[0].setFocus();
                }
            }
        }
    }
}
