#!/bin/sh

echo "Starting MotionBox..."

PATH=$(dirname "$(readlink -f "$0")")

export LD_LIBRARY_PATH="$PATH"

export QT_PLUGIN_PATH="$PATH"

"$PATH/MotionBox"
