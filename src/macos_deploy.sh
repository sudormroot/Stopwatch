#!/bin/sh


QT_VER="5.9.1"
QT_PATH="$HOME/Qt/$QT_VER"

MACDEPLOYQT="macdeployqt"



if [ "$1" = "" ];then
	echo "Usage:"
	echo "$0 <qt mac bundle path>"
	exit -1
fi


top_dir="`dirname $0`""/.."

cd $top_dir
top_dir="`pwd`"
cd -

top_dir="`dirname $top_dir`""/""`basename $top_dir`"

bundle="$1"

cd $bundle
bundle="`pwd`"
cd -

bundle_path=`dirname $bundle`
bundle_name=`basename $bundle`

bundle="$bundle_path""/""$bundle_name"

echo "bundle=$bundle"
echo "top_dir=$top_dir"

cd $bundle/Contents/MacOS

pwd

cd -

cd $bundle_path
$MACDEPLOYQT $bundle_name -verbose=2 -dmg
cd -


