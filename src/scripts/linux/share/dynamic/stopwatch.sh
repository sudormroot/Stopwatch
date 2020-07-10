#!/bin/sh

realpath="`realpath $0`"
appname="`basename $realpath | cut -d. -f1`"

dirname="`dirname $realpath`"
cd $dirname
dirname="`pwd`"
cd -

tmp="${dirname#?}"

if [ "${dirname%$tmp}" != "/" ]; then
    dirname=$PWD/$dirname
fi

libpath="$dirname/../lib"
cd $libpath
libpath="`pwd`"
cd -

#export LD_LIBRARY_PATH=$libpath:$LD_LIBRARY_PATH


#this option is in qt.conf
#pluginpath="$dirname/../plugins"
#cd $pluginpath
#pluginpath="`pwd`"
#cd -

export QT_QPA_PLATFORM_PLUGIN_PATH=$pluginpath:$QT_QPA_PLATFORM_PLUGIN_PATH

#export QT_DEBUG_PLUGINS=1

#
# update
#


#export GDK_PIXBUF_MODULEDIR="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders"
#export GDK_PIXBUF_MODULE_FILE="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GDK_PIXBUF_MODULEDIR"
#export GTK_PATH="$APPDIR/usr/lib/gtk-2.0"
#export GTK_IM_MODULE_FILE="$APPDIR/usr/lib/gtk-2.0:$GTK_PATH"
#export PANGO_LIBDIR="$APPDIR/usr/lib"

exec "$dirname/$appname" "$@"


