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

// Sk includes
#include <WApplication>

// Core includes
#include "ControllerCore.h"

//-------------------------------------------------------------------------------------------------
// Functions
//-------------------------------------------------------------------------------------------------

int main(int argc, char * argv[])
{
    QApplication * application = WApplication::create(argc, argv);

    if (application == NULL) return 0;

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(ControllerCore);

    core->applyArguments(argc, argv);

    //---------------------------------------------------------------------------------------------

#ifndef SK_DEPLOY
    sk->setQrc(false);
#endif

    sk->startScript();

    return application->exec();
}
