#!/bin/sh

APPDIR="`dirname $0`"

export GDK_PIXBUF_MODULEDIR="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders"
export GDK_PIXBUF_MODULE_FILE="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GDK_PIXBUF_MODULEDIR"
export GTK_PATH="$APPDIR/usr/lib/gtk-2.0"
export GTK_IM_MODULE_FILE="$APPDIR/usr/lib/gtk-2.0:$GTK_PATH"
export PANGO_LIBDIR="$APPDIR/usr/lib"

exec $APPDIR/usr/local/stopwatch/bin/stopwatch.sh "$@"
