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

#include "DataLocal.h"

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>

//-------------------------------------------------------------------------------------------------
// Functions
//-------------------------------------------------------------------------------------------------

void DataLocal_patch(QString & data, const QString & api)
{
    qWarning("DataLocal_patch: Patching.");

    QString path = wControllerFile->pathStorage();

    WControllerFile::deleteFolder(path + "/backend");
    WControllerFile::deleteFolder(path + "/cache");
#ifndef SK_NO_TORRENT
    WControllerFile::deleteFolder(path + "/torrents");
#endif

    path += "/playlists/";

    WControllerFile::deleteFolder(path + "3"); // backends
    WControllerFile::deleteFolder(path + "4"); // related

    WControllerFile::deleteFile(path + "3.xml"); // backends
    WControllerFile::deleteFile(path + "4.xml"); // related

    // NOTE: We replace the first occurence after the 'version' tag.
    Sk::replaceFirst(&data, api, sk->version(), data.indexOf("version"));
}
