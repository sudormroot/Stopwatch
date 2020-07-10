#!/bin/sh

mkdir /tmp/stopwatch.iconset

sips -z 512 512 stopwatch.png --out /tmp/stopwatch.iconset/icon_256x256@2x.png
sips -z 512 512 stopwatch.png --out /tmp/stopwatch.iconset/icon_512x512.png
cp stopwatch.png /tmp/stopwatch.iconset/icon_512x512@2x.png

iconutil -c icns /tmp/stopwatch.iconset

mv /tmp/stopwatch.icns .

rm -rf /tmp/stopwatch.iconset
