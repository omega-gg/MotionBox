<a href="http://omega.gg/MotionBox"><img src="dist/pictures/MotionBox.png" alt="MotionBox" width="128px"></a>
---

[MotionBox](http://omega.gg/MotionBox) is a Video Browser for Motion Freedom.<br>
Built to access and traverse decentralized video sources.<br>
Built to load and play multiple video resources.<br>
[omega](http://omega.gg/about) is building MotionBox for the society of sharing.<br>

## The Video Browser
<a href="http://omega.gg/MotionBox/what"><img src="dist/pictures/TheVideoBrowser.png" alt="The Video Browser" width="512px"></a>

MotionBox accesses videos directly via [DuckDuckGo](http://en.wikipedia.org/wiki/DuckDuckGo).<br>
It streams video files, [Youtube](http://en.wikipedia.org/wiki/Youtube), [Dailymotion](http://en.wikipedia.org/wiki/Dailymotion) and [Vimeo](http://en.wikipedia.org/wiki/Vimeo).<br>
All of this inside multiple tabs and without ever showing an ad.<br>

## Technology

MotionBox is built in C++ with [Sky kit](http://omega.gg/Sky/sources).<br>
Sky is built on the [Qt framework](http://github.com/qtproject).<br>
The GUI uses QML. The player uses [VLC](http://github.com/videolan/vlc) core.<br>

## Platforms

- Windows XP and later.

Linux and OS-X are coming soon.

## Requirements

- [Sky](http://omega.gg/Sky/sources) latest version.
- [Qt](http://download.qt.io/official_releases/qt) 4.8.0 / 5.5.0 or later.
- [VLC](http://download.videolan.org/pub/videolan/vlc) 2.2.0 or later.
- [libtorrent](http://github.com/arvidn/libtorrent/releases) 1.1.0 or later.
- [Boost](http://www.boost.org/users/download) 1.55.0 or later.
- [OpenSSL](http://www.openssl.org/source) / [Win32OpenSSL](http://slproweb.com/products/Win32OpenSSL.html) 1.0.1 or later.

On Windows:
- [MinGW](http://sourceforge.net/projects/mingw) or [Git for Windows](http://git-for-windows.github.io) with g++ 4.9.2 or later.

Recommended:
- [Qt Creator](http://download.qt.io/official_releases/qtcreator) 3.6.0 or later.

## Configure

You can configure MotionBox with:

    sh configure.sh <qt4 | qt5 | clean> <win32>

- Edit [configure.sh](configure.sh) to check your dependencies.

## Build

You can build MotionBox with Qt Creator:
- Open [MotionBox.pro](MotionBox.pro).
- Click on "Build > Build all".

Or the console:

    qmake -r
    make (mingw32-make on Windows)

## Deploy

You can deploy MotionBox with:

    cd dist
    sh qrc <win32 | clean>
    cd ..
    sh deploy.sh <qt4 | qt5 | clean> <win32>

- Edit [dist/qrc.sh](dist/qrc.sh) and [deploy.sh](deploy.sh) to check your dependencies.

## License

Copyright (C) 2015 - 2016 MotionBox authors united with [omega](http://omega.gg/about).

### Authors

- Benjamin Arnaud aka [bunjee](http://bunjee.me) | <bunjee@omega.gg>

### GNU General Public License Usage

MotionBox may be used under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
of this file. Please review the following information to ensure the GNU General Public License
requirements will be met: https://www.gnu.org/licenses/gpl.html.
