#!/bin/sh

realpath="`realpath $0`"

appname="`basename $realpath | cut -d. -f1`"

dirname="`dirname $realpath`"
cd $dirname
dirname="`pwd`"
cd -

exec "$dirname/$appname" "$@"
