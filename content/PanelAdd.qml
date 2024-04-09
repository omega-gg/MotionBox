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

PanelContextual
{
    id: panelAdd

    //---------------------------------------------------------------------------------------------
    // Properties
    //---------------------------------------------------------------------------------------------

    /* read */ property bool isExpanded: false
    /* read */ property bool isAdding  : false

    property int indexCurrent: -1

    /* read */ property int type: -1

    /* read */ property variant source: null
    /* read */ property variant target: null

    /* read */ property int sourceIndex: -1
    /* read */ property int sourceId   : -1

    //---------------------------------------------------------------------------------------------
    // Private

    property bool pAnimate          : false
    property int  pAnimationDuration: (pAnimate) ? st.duration_normal : 0

    property bool pFocus: false

    property int    pCount : pGetCount ()
    property string pAction: pGetAction()
    property string pName  : pGetName  ()

    //---------------------------------------------------------------------------------------------
    // Aliases
    //---------------------------------------------------------------------------------------------
    // Private

    property alias pFolder: modelFolder.folder

    //---------------------------------------------------------------------------------------------
    // Settings
    //---------------------------------------------------------------------------------------------

    minimumWidth: st.dp256 + borderSizeWidth

    minimumHeight: pGetMinimumHeight()

    maximumHeight: bar.height + st.itemList_height * 16 + barButtons.height + borderSizeHeight

    preferredWidth: (isExpanded) ? st.dp256 * 2 + borderVertical.size + borderSizeWidth
                                 : minimumWidth

    preferredHeight: pGetPreferredHeight()

    topMargin: barWindow.height + barTop.height - barTop.border.size

    bottomMargin: barControls.height - barControls.border.size

    //---------------------------------------------------------------------------------------------
    // States
    //---------------------------------------------------------------------------------------------

    states: State { name: "expanded"; when: isExpanded }

    transitions: Transition
    {
        SequentialAnimation
        {
            PauseAnimation { duration: pAnimationDuration }

            ScriptAction
            {
                script:
                {
                    if (isExpanded == false)
                    {
                        scrollFolder.visible = false;
                    }

                    pAnimate = false;

                    clip = false;
                }
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------------------

    Component.onDestruction:
    {
        if (target && target != library)
        {
            target.tryDelete();
        }
    }

    onVisibleChanged:
    {
        if (visible) return;

        label.enableAnimation = false;

        isAdding = false;

        pAnimate = false;
    }

    onPressed: panelAdd.setFocus()

    onIsActiveChanged:
    {
        if (isActive)
        {
            label.enableAnimation = false;

            isAdding = false;

            timerAdd.stop();

            if (target == null) setTargetDefault();

            if (listLibrary.currentId != -1)
            {
                if (target && (target.isFolder == false || target.isLoading == false))
                {
                    if (listFolder.currentId != -1)
                    {
                         listFolder.setFocus();
                    }
                    else listLibrary.setFocus();

                    pFocus = false;
                }
                else pFocus = true;
            }
            else
            {
                if (indexCurrent == 0)
                {
                    itemLibrary.setFocus();
                }
                else setFocus();

                pFocus = false;
            }

            if (type == 0 && target && (target.isFolder || target.parentFolder != library))
            {
                 pExpand(false);
            }
            else pCollapse(false);

            listLibrary.scrollToCurrentItem();
            listFolder .scrollToCurrentItem();
        }
        else
        {
            timerAdd.stop();

            if (itemNewA.isFocused || itemNewB.isFocused)
            {
                indexCurrent = -1;
            }

            pAnimate = false;
        }
    }

    onIndexCurrentChanged:
    {
        if (indexCurrent == 0)
        {
            listLibrary.currentId = -1;

            target = library;

            scrollLibrary.ensureVisible(0, 33);

            itemLibrary.setFocus();
        }
        else if (indexCurrent == 1 || indexCurrent == 2)
        {
            listLibrary.currentId = -1;

            target = null;

            scrollLibrary.ensureVisible(0, 33);

            itemNewA.setFocus();
        }
        else if (indexCurrent == 3)
        {
            listFolder.currentId = -1;

            target = library.createLibraryItemFromId(listLibrary.currentId);

            target.tryDelete();

            scrollFolder.ensureVisible(0, 33);

            itemNewB.setFocus();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Keys
    //---------------------------------------------------------------------------------------------

    /* QML_EVENT */ Keys.onPressed: function(event)
    {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
        {
            event.accepted = true;

            buttonAdd.triggerPressed();
        }
        else if ((event.key == Qt.Key_Up || event.key == Qt.Key_Down)
                 &&
                 event.modifiers == sk.keypad(Qt.NoModifier))
        {
            event.accepted = true;

            if (itemLibrary.visible)
            {
                itemLibrary.selectIndex();
            }
            else if (itemListA.visible)
            {
                itemListA.selectIndex();
            }
        }
        else if (event.key == Qt.Key_Plus && event.isAutoRepeat == false)
        {
            event.accepted = true;

            gui.panelAddHide();
        }
    }

    Keys.onReleased:
    {
        if (buttonAdd.isReturnPressed)
        {
            buttonAdd.triggerReleased();
        }
    }

    //---------------------------------------------------------------------------------------------
    // Connections
    //---------------------------------------------------------------------------------------------

    Connections
    {
        target: (library) ? library : null

        /* QML_CONNECTION */ function onCountChanged()
        {
            if (library.contains(listLibrary.currentId) == false)
            {
                listLibrary.currentId = -1;
            }
        }
    }

    Connections
    {
        target: (indexCurrent == -1
                 &&
                 panelAdd.target && panelAdd.target.isFolder) ? panelAdd.target : null

        /* QML_CONNECTION */ function onLoaded() { pApplyTarget(); }
    }

    Connections
    {
        target: (pFolder) ? pFolder : null

        /* QML_CONNECTION */ function onLoaded()
        {
            if (type == 0 && indexCurrent != 3 && listFolder.currentId == -1)
            {
                listFolder.currentId = modelFolder.idAt(0);
            }
        }

        /* QML_CONNECTION */ function onCountChanged()
        {
            if (pFolder.contains(listFolder.currentId) == false)
            {
                listFolder.currentId = -1;
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    // Animations
    //---------------------------------------------------------------------------------------------

    Behavior on x
    {
        PropertyAnimation
        {
            duration: pAnimationDuration

            easing.type: st.easing
        }
    }

    Behavior on width
    {
        PropertyAnimation
        {
            duration: pAnimationDuration

            easing.type: st.easing
        }
    }

    //---------------------------------------------------------------------------------------------
    // Functions
    //---------------------------------------------------------------------------------------------

    function setSource(type, item, index)
    {
        if (type < 0 || type > 2) return;

        source      = item;
        sourceIndex = index;

        if (type == 2)
        {
             sourceId = item.idAt(index);
        }
        else sourceId = -1;

        if (panelAdd.type == type) return;

        panelAdd.type = type;

        var idLibrary = -1;
        var idFolder  = -1;

        if (type == 0)
        {
            if (target == library)
            {
                indexCurrent = -1;

                target = null;
            }

            if (indexCurrent == -1)
            {
                 idLibrary = listLibrary.currentId;
            }
            else idLibrary = -1;

            idFolder = -1;
        }
        else
        {
            if (target && target.isPlaylist)
            {
                indexCurrent = 0;
            }

            idLibrary = listLibrary.currentId;
            idFolder  = listFolder .currentId;
        }
    }

    //---------------------------------------------------------------------------------------------

    function setTargetDefault()
    {
        var item = library.currentItem;

        if (target == item)
        {
            if (target == null)
            {
                if (type == 0)
                {
                    if (listLibrary.count)
                    {
                        listLibrary.currentId = modelLibrary.idAt(0);
                    }
                }
                else indexCurrent = 0;
            }
        }
        else if (type == 0)
        {
            if (item && item.isLocal)
            {
                if (item.isFolder)
                {
                    listLibrary.currentId = item.id;

                    item = item.currentItem;

                    if (item && item.isLocal)
                    {
                        listFolder.currentId = item.id;
                    }
                    else if (listFolder.count)
                    {
                        listFolder.currentId = modelFolder.idAt(0);
                    }
                    else listFolder.currentId = -1;
                }
                else listLibrary.currentId = item.id;
            }
            else if (listLibrary.count)
            {
                listLibrary.currentId = modelLibrary.idAt(0);
            }
        }
        else if (item && item.isFolder)
        {
            listLibrary.currentId = item.id;
        }
        else indexCurrent = 0;
    }

    //---------------------------------------------------------------------------------------------
    // Private

    function pExpand(animate)
    {
        timerCollapse.stop();

        scrollFolder.visible = true;

        if (isExpanded == false)
        {
            pAnimate = animate;

            clip = true;

            isExpanded = true;
        }
        else if (animate == false)
        {
            pAnimate = false;
        }
    }

    function pCollapse(animate)
    {
        if (isExpanded == false)
        {
            if (animate == false)
            {
                pAnimate = false;
            }
        }
        else if (animate)
        {
            scrollFolder.visible = false;

            timerCollapse.restart();
        }
        else
        {
            timerCollapse.stop();

            pAnimate = false;

            clip = true;

            isExpanded = false;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pOnCollapse()
    {
        pAnimate = true;

        clip = true;

        isExpanded = false;
    }

    //---------------------------------------------------------------------------------------------

    function pGetMinimumHeight()
    {
        var height = bar.height + st.itemList_height * 3 + barButtons.height + borderSizeHeight;

        if (preferredHeight < height)
        {
            return preferredHeight;
        }
        else return height;
    }

    function pGetPreferredHeight()
    {
        var height = bar.height + barButtons.height - barButtons.borderTop + borderSizeHeight;

        if (scrollFolder.visible)
        {
             return height + Math.max(scrollLibrary.contentHeight, scrollFolder.contentHeight);
        }
        else return height + scrollLibrary.contentHeight;
    }

    //---------------------------------------------------------------------------------------------

    function pGetCount()
    {
        if (sourceIndex == -1 && source && source.isPlaylist)
        {
            return source.selectedCount;
        }
        else return 1;
    }

    function pGetAction()
    {
        if (type == 2) return qsTr("Move");
        else           return qsTr("Add");
    }

    function pGetName()
    {
        if (type == 0)
        {
            if (pCount > 1) return qsTr("Tracks");
            else            return qsTr("Track");
        }
        else return qsTr("Playlist");
    }

    //---------------------------------------------------------------------------------------------

    function pSelectLibrary()
    {
        if (listLibrary.count)
        {
            listLibrary.setFocus();

            if (listLibrary.currentId == -1)
            {
                listLibrary.currentId = modelLibrary.idAt(0);
            }
        }
    }

    function pSelectFolder()
    {
        if (listFolder.count)
        {
            listFolder.setFocus();

            if (listFolder.currentId == -1)
            {
                listFolder.currentId = modelFolder.idAt(0);
            }
        }
    }

    //---------------------------------------------------------------------------------------------

    function pApplyTarget()
    {
        if (pFolder == target)
        {
            target.tryDelete();

            return;
        }

        pFolder = target;

        if (type == 0)
        {
            listFolder.currentId = modelFolder.idAt(0);

            pExpand(listLibrary.activeFocus);
        }
        else
        {
            listFolder.currentId = -1;

            pCollapse(listLibrary.activeFocus);
        }

        if (pFocus)
        {
            if (listFolder.currentId != -1)
            {
                listFolder.setFocus();
            }
            else if (listLibrary.currentId != -1)
            {
                listLibrary.setFocus();
            }
            else setFocus();

            pFocus = false;
        }
    }

    //---------------------------------------------------------------------------------------------

    function pAdd()
    {
        if      (type == 0) pAddTracks   ();
        else if (type == 1) pAddPlaylist ();
        else                pMovePlaylist();

        label.enableAnimation = true;

        isAdding = true;

        timerCollapse.stop();

        timerAdd.start();
    }

    //---------------------------------------------------------------------------------------------

    function pAddTracks()
    {
        var list;

        if (indexCurrent == 1)
        {
            pInsert(0, LibraryItem.Playlist, itemNewA.text);

            listLibrary.currentId = modelLibrary.idAt(0);
        }
        else if (indexCurrent == 3)
        {
            list = gui.getListFolder(target);

            if (list == null)
            {
                target.insertNewItem(0, LibraryItem.Playlist);

                target.setItemTitle(0, itemNewB.text);
            }
            else pInsert(0, LibraryItem.Playlist, itemNewB.text);

            listFolder.currentId = modelFolder.idAt(0);
        }

        list = gui.getListPlaylist(target);

        if (list)
        {
            list.copyTrackFrom(source, sourceIndex, -1, true);
        }
        else if (sourceIndex != -1)
        {
            source.copyTrackTo(sourceIndex, target);
        }
        else source.copySelectedTo(target);
    }

    function pAddPlaylist()
    {
        if (indexCurrent == 2)
        {
            pInsert(0, LibraryItem.Folder, itemNewA.text);

            listLibrary.currentId = modelLibrary.idAt(0);
        }

        var index;

        if (sourceIndex == -1)
        {
             index = source.currentIndex;
        }
        else index = sourceIndex;

        gui.copyPlaylist(source, index, target, 0);
    }

    function pMovePlaylist()
    {
        if (indexCurrent == 2)
        {
            pInsert(sourceIndex, LibraryItem.Folder, itemNewA.text);

            library.currentIndex = sourceIndex;

            // NOTE: We need to ensure that the folder gets created.
            library.currentItem.save(true);

            listLibrary.currentId = library.currentId;

            if (sourceIndex != -1 && source == library)
            {
                sourceIndex++;
            }
        }

        var index;

        if (sourceIndex == -1)
        {
             index = source.currentIndex;
        }
        else index = sourceIndex;

        gui.movePlaylist(source, index, target, 0);
    }

    //---------------------------------------------------------------------------------------------

    function pInsert(index, type, text)
    {
        var list = gui.listLibrary;

        if (library != list.folder)
        {
            library.insertNewItem(index, type);

            library.setItemTitle(index, text);
        }
        else list.insertItem(index, type, text, true);
    }

    //---------------------------------------------------------------------------------------------
    // Children
    //---------------------------------------------------------------------------------------------

    Timer
    {
        id: timerCollapse

        interval: st.panelAdd_durationCollapse

        onTriggered: pOnCollapse()
    }

    Timer
    {
        id: timerAdd

        interval: st.panelAdd_durationAdd

        onTriggered: areaContextual.hidePanels()
    }

    Component
    {
        id: component

        ComponentLibraryItem
        {
            isSelected: (id == currentId)

            isFocused: (list.activeFocus)

            icon: cover

            iconDefault:
            {
                if (type == LibraryItem.Playlist)
                {
                     return st.icon16x16_playlist;
                }
                else if (type == LibraryItem.Folder)
                {
                     return st.icon16x16_folder;
                }
                else return st.icon16x16_feed;
            }

            iconDefaultSize: st.size16x16

            text:
            {
                if (title == "")
                {
                    if (type == LibraryItem.Playlist || type == LibraryItem.PlaylistSearch)
                    {
                         return qsTr("Invalid Playlist");
                    }
                    else return qsTr("Invalid Folder");
                }
                else return title;
            }

            iconFillMode: Image.PreserveAspectCrop

            //-------------------------------------------------------------------------------------

            onPressed:
            {
                if (isAdding) return;

                list.setFocus();

                currentId = id;
            }

            onDoubleClicked:
            {
                if (buttonAdd.enabled
                    &&
                    (panelAdd.type == 0 && type == LibraryItem.Playlist)
                    ||
                    (panelAdd.type != 0 && type == LibraryItem.Folder))
                {
                    pAdd();
                }
            }

            //-------------------------------------------------------------------------------------

            function getId() { return id; }
        }
    }

    BarTitle
    {
        id: bar

        anchors.left : parent.left
        anchors.right: parent.right

        borderTop: 0

        BarTitleText
        {
            anchors.fill: parent

            text: pAction + " " + pName
        }

        ButtonPianoIcon
        {
            anchors.right: parent.right

            height: st.barTitle_height

            borderLeft : borderSize
            borderRight: 0

            visible: (item != barControls && (posX != -1 || posY != -1))

            enabled: (areaContextual.currentPanel != null)

            icon          : st.icon12x12_close
            iconSourceSize: st.size12x12

            onClicked: areaContextual.hidePanels()
        }
    }

    ScrollArea
    {
        id: scrollLibrary

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        anchors.top   : bar.bottom
        anchors.bottom: barButtons.top

        anchors.bottomMargin: -(barButtons.borderTop)

        width:
        {
            if (isExpanded)
            {
                return Math.round((panelWidth - borderVertical.size - borderSizeWidth) / 2);
            }
            else return panelWidth - borderSizeWidth;
        }

        contentHeight:
        {
            var size;

            if (listLibrary.height > 1) size = listLibrary.height;
            else                        size = 0;

            size += itemListA.height;

            if (type) size += listAddLibrary.height;

            return size;
        }

        singleStep     : st.list_itemSize
        wheelMultiplier: 1

        //-----------------------------------------------------------------------------------------
        // Functions
        //-----------------------------------------------------------------------------------------

        function updateView()
        {
            updateListHeight(listLibrary);
        }

        //-----------------------------------------------------------------------------------------
        // Events

        function onRangeUpdated()
        {
            updateView();
        }

        function onValueUpdated()
        {
            updateView();
        }

        //-----------------------------------------------------------------------------------------
        // Children
        //-----------------------------------------------------------------------------------------

        Item
        {
            id: listAddLibrary

            width: parent.width

            height: itemLibrary.height

            visible: (type > 0)

            ComponentLibraryItem
            {
                id: itemLibrary

                property int index: 0

                //---------------------------------------------------------------------------------

                iconWidth: 0

                text: qsTr("Library")

                itemIcon.visible: false

                //---------------------------------------------------------------------------------

                onPressed:
                {
                    setFocus();

                    selectIndex();
                }

                onDoubleClicked: if (buttonAdd.enabled) pAdd()

                //---------------------------------------------------------------------------------

                /* QML_EVENT */ Keys.onPressed: function(event)
                {
                    if (event.key == Qt.Key_Up
                        &&
                        event.modifiers == sk.keypad(Qt.NoModifier))
                    {
                        event.accepted = true;
                    }
                    else if (event.key == Qt.Key_Down
                             &&
                             event.modifiers == sk.keypad(Qt.NoModifier))
                    {
                        event.accepted = true;

                        if (itemListA.visible)
                        {
                            itemListA.selectIndex();
                        }
                        else pSelectLibrary();
                    }
                }
            }
        }

        ItemNew
        {
            id: itemNewA

            anchors.fill: itemListA

            visible: (indexCurrent == 1 || indexCurrent == 2)

            mode: (indexCurrent == 2) ? 2 : 1

            onIsFocusedChanged:
            {
                if (isFocused) return;

                text = "";

                if (indexCurrent == 1 || indexCurrent == 2)
                {
                    indexCurrent = -1;
                }
            }

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Up && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (itemLibrary.visible)
                    {
                        itemLibrary.selectIndex();
                    }
                }
                else if (event.key == Qt.Key_Down && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    pSelectLibrary();
                }
                else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                {
                    event.accepted = true;

                    buttonAdd.triggerPressed();
                }
                else if (event.key == Qt.Key_Escape)
                {
                    event.accepted = true;

                    indexCurrent = -1;

                    panelAdd.setFocus();
                }
            }

            function onKeyReleased(event)
            {
                if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                {
                    buttonAdd.triggerReleased();
                }
            }
        }

        ItemList
        {
            id: itemListA

            anchors.top: (listAddLibrary.visible) ? listAddLibrary.bottom
                                                  : parent.top

            visible: (itemNewA.visible == false)

            isFocused: true

            iconDefault    : st.icon20x20_addList
            iconDefaultSize: st.size20x20

            text: (type == 0) ? qsTr("New Playlist")
                              : qsTr("New Folder")

            onPressed: selectIndex()

            function selectIndex()
            {
                if (type) indexCurrent = 2;
                else      indexCurrent = 1;
            }
        }

        BaseList
        {
            id: listLibrary

            //-------------------------------------------------------------------------------------
            // Properties
            //-------------------------------------------------------------------------------------

            property int currentId: -1

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.top: itemListA.bottom

            model: ModelLibraryFolderFiltered
            {
                id: modelLibrary

                model: ModelLibraryFolder { folder: library }

                filter: (type == 0) ? undefined : LibraryItem.Folder

                local: true
            }

            delegate: component

            scrollArea: scrollLibrary

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onCurrentIdChanged:
            {
                if (currentId == -1)
                {
                    if (target && target != library)
                    {
                        target.tryDelete();

                        target = null;
                    }

                    pFolder = null;

                    listFolder.currentId = -1;

                    pCollapse(true);
                }
                else
                {
                    var oldTarget = target;

                    indexCurrent = -1;

                    target = library.createLibraryItemFromId(currentId);

                    scrollToCurrentItem();

                    if (target.isFolder == false)
                    {
                        if (oldTarget && oldTarget != library)
                        {
                            oldTarget.tryDelete();
                        }

                        pFolder = null;

                        listFolder.currentId = -1;

                        pCollapse(true);
                    }
                    else if (target.isLoading == false)
                    {
                        pApplyTarget();
                    }
                }
            }

            //-------------------------------------------------------------------------------------
            // Keys
            //-------------------------------------------------------------------------------------

            /* QML_EVENT */ Keys.onPressed: function(event)
            {
                var index;

                if (event.key == Qt.Key_Left && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (type == 0 && listFolder.count == 0)
                    {
                        timerCollapse.stop();

                        pOnCollapse();
                    }
                }
                else if (event.key == Qt.Key_Right && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (type == 0)
                    {
                        if (listFolder.count)
                        {
                            listFolder.setFocus();
                        }
                        else if (itemListB.visible)
                        {
                            itemListB.selectIndex();
                        }
                        else
                        {
                            timerCollapse.stop();

                            pOnCollapse();
                        }
                    }
                }
                else if (event.key == Qt.Key_Up && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    index = model.indexFromId(currentId);

                    if (index > 0)
                    {
                        currentId = model.idAt(index - 1);
                    }
                    else if (itemListA.visible)
                    {
                        itemListA.selectIndex();
                    }
                    else if (itemLibrary.visible)
                    {
                        itemLibrary.selectIndex();
                    }
                }
                else if (event.key == Qt.Key_Down && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    index = model.indexFromId(currentId);

                    if (index < (count - 1))
                    {
                        currentId = model.idAt(index + 1);
                    }
                }
            }

            //-------------------------------------------------------------------------------------
            // Functions
            //-------------------------------------------------------------------------------------

            function scrollToCurrentItem()
            {
                if (currentId == -1) return;

                var index = modelLibrary.indexFromId(currentId);

                scrollToItem(index);
            }
        }
    }

    BorderVertical
    {
        id: borderVertical

        anchors.left  : scrollLibrary.right
        anchors.top   : bar.bottom
        anchors.bottom: barButtons.top
    }

    ScrollArea
    {
        id: scrollFolder

        //-----------------------------------------------------------------------------------------
        // Settings
        //-----------------------------------------------------------------------------------------

        anchors.left: borderVertical.right

        anchors.top   : scrollLibrary.top
        anchors.bottom: scrollLibrary.bottom

        width:
        {
            if (isExpanded && pAnimate == false)
            {
                return parent.width - scrollLibrary.width - borderVertical.size;
            }
            else return scrollLibrary.width;
        }

        visible: false

        contentHeight: itemListB.height + listFolder.height

        singleStep     : st.list_itemSize
        wheelMultiplier: 1

        //-----------------------------------------------------------------------------------------
        // Functions
        //-----------------------------------------------------------------------------------------

        function updateView()
        {
            updateListHeight(listFolder);
        }

        //-----------------------------------------------------------------------------------------
        // Events

        function onRangeUpdated()
        {
            updateView();
        }

        function onValueUpdated()
        {
            updateView();
        }

        //-----------------------------------------------------------------------------------------
        // Children
        //-----------------------------------------------------------------------------------------

        ItemNew
        {
            id: itemNewB

            anchors.fill: itemListB

            visible: (indexCurrent == 3)

            colorA: st.itemList_colorSelectFocusA
            colorB: st.itemList_colorSelectFocusB

            onIsFocusedChanged:
            {
                if (isFocused == false)
                {
                    text = "";

                    if (indexCurrent == 3) indexCurrent = -1;
                }
            }

            function onKeyPressed(event)
            {
                if (event.key == Qt.Key_Left && text == "")
                {
                    event.accepted = true;

                    pSelectFolder();

                    listLibrary.setFocus();
                }
                else if (event.key == Qt.Key_Down && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    pSelectFolder();
                }
                else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                {
                    event.accepted = true;

                    buttonAdd.triggerPressed();
                }
                else if (event.key == Qt.Key_Escape)
                {
                    event.accepted = true;

                    indexCurrent = -1;

                    panelAdd.setFocus();
                }
            }

            function onKeyReleased(event)
            {
                if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter)
                {
                    buttonAdd.triggerReleased();
                }
            }
        }

        ItemList
        {
            id: itemListB

            visible: (itemNewB.visible == false)

            isFocused: true

            iconDefault    : st.icon20x20_addList
            iconDefaultSize: st.size20x20

            text: qsTr("New Playlist")

            onPressed: selectIndex()

            function selectIndex()
            {
                indexCurrent = 3;
            }
        }

        BaseList
        {
            id: listFolder

            //-------------------------------------------------------------------------------------
            // Properties
            //-------------------------------------------------------------------------------------

            property int currentId: -1

            //-------------------------------------------------------------------------------------
            // Settings
            //-------------------------------------------------------------------------------------

            anchors.left : parent.left
            anchors.right: parent.right

            anchors.top: itemListB.bottom

            model: ModelLibraryFolderFiltered
            {
                id: modelFolder

                model: ModelLibraryFolder { folder: null }

                filter: LibraryItem.Playlist

                local: true
            }

            delegate: component

            scrollArea: scrollFolder

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            onCurrentIdChanged:
            {
                if (currentId == -1) return;

                var oldTarget = target;

                indexCurrent = -1;

                target = model.folder.createLibraryItemFromId(currentId);

                scrollToCurrentItem();

                if (oldTarget) oldTarget.tryDelete();
            }

            //-------------------------------------------------------------------------------------
            // Events
            //-------------------------------------------------------------------------------------

            /* QML_EVENT */ Keys.onPressed: function(event)
            {
                var index;

                if (event.key == Qt.Key_Left && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    listLibrary.setFocus();
                }
                else if (event.key == Qt.Key_Right && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;
                }
                else if (event.key == Qt.Key_Up && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (currentId == -1) return;

                    index = model.indexFromId(currentId);

                    if (index > 0)
                    {
                        currentId = model.idAt(index - 1);
                    }
                    else if (itemListB.visible)
                    {
                        itemListB.selectIndex();
                    }
                }
                else if (event.key == Qt.Key_Down && event.modifiers == sk.keypad(Qt.NoModifier))
                {
                    event.accepted = true;

                    if (currentId == -1) return;

                    index = model.indexFromId(currentId);

                    if (index < (count - 1))
                    {
                        currentId = model.idAt(index + 1);
                    }
                }
            }

            //-------------------------------------------------------------------------------------
            // Functions
            //-------------------------------------------------------------------------------------

            function scrollToCurrentItem()
            {
                if (currentId == -1) return;

                var index = modelFolder.indexFromId(currentId);

                scrollToItem(index);
            }
        }
    }

    BarTitle
    {
        id: barButtons

        anchors.left  : parent.left
        anchors.right : parent.right
        anchors.bottom: parent.bottom

        borderTop   : borderSize
        borderBottom: 0

        LabelRoundAnimated
        {
            id: label

            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            enableAnimation: false

            text:
            {
                if (isAdding)
                {
                    if (type == 0)
                    {
                        return pCount + " " + pName + " " + qsTr("added");
                    }
                    else if (type == 1)
                    {
                        return pName + " " + qsTr("added");
                    }
                    else return pName + " " + qsTr("moved");
                }
                else return pCount;
            }

            //-------------------------------------------------------------------------------------
            // NOTE: We want a highlighted label.

            colorA: st.color_highlight
            colorB: st.color_highlight

            itemText.color: st.text2_color
        }

        ButtonPianoFull
        {
            id: buttonAdd

            anchors.right : parent.right
            anchors.top   : parent.top
            anchors.bottom: parent.bottom

            borderLeft : borderSize
            borderRight: 0

            spacing: st.dp2

            isFocused: enabled

            enabled:
            {
                if (isActive == false || isAdding || source == null)
                {
                    return false;
                }
                else if (indexCurrent != -1)
                {
                    if (indexCurrent == 0)
                    {
                        return (library.isFull == false);
                    }
                    else if (itemNewA.text || itemNewB.text)
                    {
                        return true;
                    }
                    else return false;
                }
                else if (target && target.isFull == false && target.isLoading == false)
                {
                    if (type == 0 && target.isPlaylist == false)
                    {
                         return false;
                    }
                    else return true;
                }
                else return false;
            }

            icon          : st.icon16x16_addBold
            iconSourceSize: st.size16x16

            text: (source) ? pAction + " " + pName : ""

            onClicked: pAdd()
        }
    }
}
