#!/bin/sh

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

Sky="../../Sky"

SkyComponents="$Sky/src/SkyComponents"

#--------------------------------------------------------------------------------------------------

content="../content"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $1 != "win32" -a $1 != "clean" ]; then

    echo "Usage: qrc <win32 | clean>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -f qrc/*.qml

rm -rf qrc/pictures
rm -rf qrc/text

if [ $1 = "clean" ]; then

    exit 0
fi

echo ""

#--------------------------------------------------------------------------------------------------
# QML
#--------------------------------------------------------------------------------------------------

echo "COPYING QML"

cp "$SkyComponents"/*.qml qrc

cp "$content"/*.qml qrc

rm -f qrc/Dev*.qml

#--------------------------------------------------------------------------------------------------
# Pictures
#--------------------------------------------------------------------------------------------------

echo "COPYING pictures"

cp -r "$SkyComponents"/pictures qrc

cp -r "$content"/pictures qrc

#--------------------------------------------------------------------------------------------------
# Text
#--------------------------------------------------------------------------------------------------

echo "COPYING text"

cp -r "$content"/text qrc

echo ""

#--------------------------------------------------------------------------------------------------
# Deployer
#--------------------------------------------------------------------------------------------------

"$Sky"/deploy/deployer qrc/ MotionBox.qrc