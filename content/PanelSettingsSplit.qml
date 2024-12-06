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

BasePanelSettings
{
    id: panelSettingsSplit

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------

    /* read */ property alias page: loader.item

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    loader: loader

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onCompleted:
    {
        var settings = getSettings();

//#QT_4
        // NOTE Qt4: We can only append items one by one.
        for (/* var */ i = 0; i < settings.length; i++)
        {
            model.append(settings[i]);
        }
//#ELSE
        // NOTE: It's probably better to append everything at once.
        model.append(settings);
//#END
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------
    // BasePanelSettings reimplementation

    function getWidth()
    {
        var item = loader.item;

        if (item)
        {
             return borderSizeWidth + list.width + border.size + item.contentWidth;
        }
        else return borderSizeWidth + st.dp192;
    }

    function getHeight()
    {
        var size;

        var item = loader.item;

        if (item)
        {
             size = Math.min(loader.y + borderSizeHeight + item.contentHeight, gui.panelHeight);
        }
        else size = Math.min(loader.y + borderSizeHeight, gui.panelHeight);

        return Math.max(size, Math.max(st.dp320, list.count * list.itemSize - st.border_size)
                              + borderSizeHeight);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    List
    {
        id: list

        width: st.dp192

        currentIndex: panelSettingsSplit.currentIndex

        model: ListModel { id: model }

        delegate: ComponentList
        {
            text: title

            function onPress()
            {
//#QT_4
                selectTab(index);
//#ELSE
                Qt.callLater(selectTab, index);
//#END
            }
        }
    }

    BorderVertical
    {
        id: border

        anchors.left: list.right
    }

    LoaderWipe
    {
        id: loader

        anchors.left  : border.right
        anchors.right : parent.right
        anchors.top   : parent.top
        anchors.bottom: parent.bottom
    }
}
