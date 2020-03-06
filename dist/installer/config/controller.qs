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

function getUserName()
{
    if (systemInfo.productType == "windows")
    {
         return installer.environmentVariable("UserName");
    }
    else return "";
}

//-------------------------------------------------------------------------------------------------

function getPathData()
{
    if (systemInfo.productType == "windows")
    {
        var path = installer.environmentVariable("LocalAppData");

        return path.replace(/\\/g, "/") + "/MotionBox";
    }
    else return "";
}

//-------------------------------------------------------------------------------------------------
// Controller
//-------------------------------------------------------------------------------------------------

function Controller() {}

Controller.prototype.IntroductionPageCallback = function()
{
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
    var widget = gui.currentPageWidget();

    var name = getUserName();

    if (name)
    {
         widget.title = "Welcome " + name;
    }
    else widget.title = "Welcome";
}

Controller.prototype.ComponentSelectionPageCallback = function()
{
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function()
{
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function()
{
    if (installer.isUpdater())
    {
        gui.clickButton(buttons.FinishButton);
    }
    else if (installer.isUninstaller())
    {
        var path = getPathData();

        if (path == "" || installer.fileExists(path) == false) return;

        var text = "<br><p><b>Remaining files</b>:<p>"
                   +
                   "<ul><li>User folder: <a href='file:///" + path + "'>"
                   +
                   path + "</a></li></ul>";

        var label = gui.currentPageWidget().MessageLabel;

        label.text += text;

        label.openExternalLinks = true;
    }
}
