<a href="http://omega.gg/MotionBox"><img src="dist/icon.png" alt="MotionBox" width="128px"></a>
---
[![Discord](https://img.shields.io/discord/705770212485496852)](http://omega.gg/discord)
[![azure](https://dev.azure.com/bunjee/MotionBox/_apis/build/status/omega-gg.MotionBox)](https://dev.azure.com/bunjee/MotionBox/_build)
[![travis](http://api.travis-ci.org/omega-gg/MotionBox.svg)](http://travis-ci.org/omega-gg/MotionBox)
[![appveyor](https://ci.appveyor.com/api/projects/status/ct0kbo659jviskec?svg=true)](https://ci.appveyor.com/project/3unjee/MotionBox)
[![GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl.html)

[MotionBox](http://omega.gg/MotionBox) is a video player designed for the Internet.<br>
Built to access and browse decentralized video sources.<br>
Built to load and play multiple video resources.<br>
[omega](http://omega.gg/about) is building MotionBox to empower people.<br>

## MotionBox Video Browser
<a href="http://omega.gg/MotionBox"><img src="dist/pictures/MotionBox.png" alt="Video Browser" width="512px"></a>

MotionBox accesses videos directly via [DuckDuckGo](http://en.wikipedia.org/wiki/DuckDuckGo).<br>
It streams [Torrents](http://en.wikipedia.org/wiki/BitTorrent), [Youtube](http://en.wikipedia.org/wiki/Youtube), [Dailymotion](http://en.wikipedia.org/wiki/Dailymotion), [Vimeo](http://en.wikipedia.org/wiki/Vimeo) and [SoundCloud](http://en.wikipedia.org/wiki/SoundCloud).<br>
All of this inside multiple tabs and without ever showing an ad.<br>

## For Motion Freedom

- Freedom to access video resources on the Internet.
- Freedom to browse decentralized video sources.
- Freedom to share video content with the world.

## Technology

MotionBox is built in C++ with [Sky kit](http://omega.gg/Sky/sources) on the [Qt framework](http://github.com/qtproject).<br>
The GUI is powered by QML and rendered with OpenGL.<br>
The video player is based on [VLC](http://github.com/videolan/vlc) and [libtorrent](http://en.wikipedia.org/wiki/libtorrent).<br>

## Platforms

- Windows XP and later.
- macOS 64 bit.
- Linux 32 bit and 64 bit.
- Android 32 bit and 64 bit (experimental).

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

## Quickstart

You can configure and build MotionBox with a single line:

    sh build.sh <win32 | win64 | macOS | linux | android> all

For instance you would do that for Windows 64 bit:

    * open Git Bash *
    git clone https://github.com/omega-gg/MotionBox.git
    cd MotionBox
    sh build.sh win64 all

That's a convenient way to configure and build everything the first time.

Note: This will create the 3rdparty and Sky folder in the parent directory.

## Building

Alternatively, you can run each step of the build yourself by calling the following scripts:

Install the dependencies:

    sh 3rdparty.sh <win32 | win64 | macOS | linux | android> [all]

Configure the build:

    sh configure.sh <win32 | win64 | macOS | linux | android> [sky | clean]

Build the application:

    sh build.sh <win32 | win64 | macOS | linux | android> [all | deploy | clean]

Deploy the application and its dependencies:

    sh deploy.sh <win32 | win64 | macOS | linux | android> [clean]

## License

Copyright (C) 2015 - 2020 MotionBox authors | http://omega.gg/MotionBox.

### Authors

- Benjamin Arnaud aka [bunjee](http://bunjee.me) | <bunjee@omega.gg>

### GNU General Public License Usage

MotionBox may be used under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
of this file. Please review the following information to ensure the GNU General Public License
requirements will be met: https://www.gnu.org/licenses/gpl.html.

### Private License Usage

MotionBox licensees holding valid private licenses may use this file in accordance with the private
license agreement provided with the Software or, alternatively, in accordance with the terms
contained in written agreement between you and MotionBox authors. For further information contact
us at contact@omega.gg.
