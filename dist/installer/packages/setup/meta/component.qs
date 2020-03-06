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
*/
//=================================================================================================

//-------------------------------------------------------------------------------------------------
// Global functions
//-------------------------------------------------------------------------------------------------

function getPath(path)
{
    if (systemInfo.productType == "windows")
    {
         return path.replace(/\//g, "\\");
    }
    else return path;
}

//-------------------------------------------------------------------------------------------------
// Component
//-------------------------------------------------------------------------------------------------

function Component()
{
    installer.currentPageChanged.connect(this, Component.prototype.onCurrentPageChanged);
}

Component.prototype.createOperations = function()
{
    component.createOperations();

    component.addOperation("CreateShortcut", "@TargetDir@/MotionBox.exe",
                                             "@StartMenuDir@/MotionBox.lnk");
}

Component.prototype.onCurrentPageChanged = function(page)
{
    if (systemInfo.productType != "windows" || installer.isInstaller() == false) return;

    if (page == QInstaller.TargetDirectory)
    {
        var label = component.userInterface("form").label;

        label.text = "<b>Install type</b>:";

        var buttonA = component.userInterface("form").buttonA;
        var buttonB = component.userInterface("form").buttonB;

        buttonA.autoExclusive = false;
        buttonB.autoExclusive = false;

        buttonA.text    = "Standard";
        buttonA.checked = true;

        buttonB.text = "Progam Files (requires administrator rights to update)";

        buttonA.toggled.connect(this, Component.prototype.onButtonAClicked);
        buttonB.toggled.connect(this, Component.prototype.onButtonBClicked);

        var checkBox = component.userInterface("form").checkbox;

        checkBox.text    = "Create shortcut";
        checkBox.checked = true;

        installer.addWizardPageItem(component, "form", page);

        var edit = gui.currentPageWidget().TargetDirectoryLineEdit;

        edit.textChanged.connect(this, Component.prototype.onTargetChanged);
    }
    else if (page == QInstaller.ReadyForInstallation)
    {
        var checkBox = component.userInterface("form").checkbox;

        if (checkBox.checked)
        {
            component.addOperation("CreateShortcut", "@TargetDir@/MotionBox.exe",
                                                     "@DesktopDir@/MotionBox.lnk");
        }
    }
}

//-------------------------------------------------------------------------------------------------

Component.prototype.onButtonAClicked = function(checked)
{
    if (checked)
    {
        var edit = gui.currentPageWidget().TargetDirectoryLineEdit;

        edit.text = getPath(installer.value("RootDir") + "omega/MotionBox");
    }
}

Component.prototype.onButtonBClicked = function(checked)
{
    if (checked)
    {
        var edit = gui.currentPageWidget().TargetDirectoryLineEdit;

        edit.text = getPath(installer.value("ApplicationsDir") + "/MotionBox");
    }
}

//-------------------------------------------------------------------------------------------------

Component.prototype.onTargetChanged = function(text)
{
    var buttonA = component.userInterface("form").buttonA;
    var buttonB = component.userInterface("form").buttonB;

    if (text == getPath(installer.value("RootDir") + "omega/MotionBox"))
    {
        buttonA.checked = true;
        buttonB.checked = false;
    }
    else if (text == getPath(installer.value("ApplicationsDir") + "/MotionBox"))
    {
        buttonA.checked = false;
        buttonB.checked = true;
    }
    else
    {
        buttonA.checked = false;
        buttonB.checked = false;
    }
}
