#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

font="../../assets/3rdparty/fontawesome/6"

solid="$font/solid"

brands="$font/brands"

icons="pictures/icons"

#--------------------------------------------------------------------------------------------------
# Copy
#--------------------------------------------------------------------------------------------------

cp "$solid"/download.svg $icons

cp "$solid"/arrow-left.svg  $icons
cp "$solid"/arrow-right.svg $icons

cp "$solid"/up-right-and-down-left-from-center.svg $icons/expand-alt.svg
cp "$solid"/arrows-to-dot.svg                      $icons/expand.svg
cp "$solid"/bars.svg                               $icons

cp "$solid"/rotate-right.svg $icons/redo.svg

cp "$solid"/plus.svg        $icons
cp "$solid"/circle-plus.svg $icons/plus-circle.svg

cp "$solid"/magnifying-glass.svg $icons/search.svg

cp "$solid"/qrcode.svg $icons

cp "$solid"/quote-right.svg $icons
cp "$solid"/gear.svg        $icons/cog.svg
cp "$brands"/chromecast.svg $icons

cp "$solid"/clock-rotate-left.svg $icons/history.svg
cp "$solid"/lightbulb.svg         $icons
cp "$solid"/clock.svg             $icons
cp "$solid"/circle-nodes.svg      $icons

cp "$solid"/shuffle.svg $icons/random.svg

cp "$solid"/circle-info.svg $icons/info-circle.svg

cp "$solid"/earth-americas.svg $icons/globe-america.svg

cp "$solid"/link.svg       $icons
cp "$solid"/link-slash.svg $icons

cp "$solid"/pen.svg $icons

cp "$solid"/tv.svg     $icons
cp "$solid"/folder.svg $icons
cp "$solid"/rss.svg    $icons

cp "$solid"/video.svg $icons

cp "$solid"/house.svg $icons

cp "$solid"/list.svg $icons

cp "$solid"/power-off.svg $icons

cp "$solid"/heart.svg $icons
