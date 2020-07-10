#!/bin/sh

if [ "$#" != "3" ];then
    echo "$0 <os> <static|dynamic> <app>"
    exit
fi

#arch="amd64"
arch="`uname -m`"

#os="linux"
os="$1"
build="$2"
app="`basename $3`"

if [ "$arch" = "x86_64" ];then
    arch="amd64"
else
    arch="any"
fi

if [ ! -f "$app" ];then
    echo "$0 <os> <static|dynamic> <app>"
    exit
fi

if [ ! -x "`which appimagetool`" ]; then
    echo "appimagetool not found"
    exit
fi

if [ ! -x "`which linuxdeployqt`" ]; then
    echo "linuxdeployqt not found"
    exit
fi


rm *.tar *.tgz *.deb *.md5 *.AppImage 2>/dev/zero
rm -rf buildroot stopwatch.AppDir 2>/dev/zero



# 

#
#  stopwatch/etc/qt.conf
#
#  stopwatch/bin/stopwatch/qt.conf --> ../etc/qt.conf
#  stopwatch/bin/stopwatch
#  stopwatch/bin/stopwatch.sh
#  stopwatch/bin/languages  --> ../share/languages
#  stopwatch/bin/images     --> ../share/images
#
#  stopwatch/lib/
#  stopwatch/plugins/
#
#  stopwatch/share/languages/
#  stopwatch/share/images/
#  stopwatch/share/licenses/
#  stopwatch/share/version.txt
#  stopwatch/share/RELEASE
#
#  /usr/share/pixmaps/stopwatch.png --> stopwatch/share/images/logo.png
#  /usr/share/applications/stopwatch.desktop  --> stopwatch/share/stopwatch.desktop
#  /usr/local/bin/stopwatch  --> stopwatch/bin/stopwatch.sh
#  



script_path="`dirname $0`"

cd $script_path
script_path="`pwd`"
cd -

localshare="$script_path/share/$build"

if [ ! -d "$localshare" ];then
    echo "$localshare not exist"
    exit
fi


apppath="`dirname $app`"
cd $apppath
apppath="`pwd`"
cd -

appbin="`basename $app`"

version="`cat $script_path/../../player/appconfig/appconfig.h|grep THENEWPLAYER_VERSION_STRING|awk '{print $3'} | sed 's/\"//g'`"

if [ "$version" = "" ];then
    echo "can't find THENEWPLAYER_VERSION_STRING in src/player/appconfig/appconfig.h"
    exit
fi

version="`echo $version`"

x="`echo $version|cut -d. -f1`"
y="`echo $version|cut -d. -f2`"
z="`echo $version|cut -d. -f3`"
rev="`echo $version|cut -d. -f4`"

if [ "$rev" = "$version" ];then
    rev="1"
fi

#
# 1.2.3-rev1
#
date="`date +%Y%m%d`"
#version="$x"".""$y"".""$z""-""rev$rev"
version="$x"".""$y"".""$z""-""$rev"


echo "Populate directories and files ..."

cd $apppath
rm -rf buildroot 2>/dev/zero
mkdir buildroot
mkdir -p buildroot/usr/local/stopwatch
mkdir -p buildroot/usr/local/stopwatch/bin
mkdir -p buildroot/usr/local/stopwatch/lib
mkdir -p buildroot/usr/local/stopwatch/plugins
mkdir -p buildroot/usr/local/stopwatch/share
mkdir -p buildroot/usr/local/stopwatch/etc

mkdir -p buildroot/usr/local/stopwatch/share/images
mkdir -p buildroot/usr/local/stopwatch/share/languages
mkdir -p buildroot/usr/local/stopwatch/share/licenses

mkdir -p buildroot/usr/share/pixmaps
mkdir -p buildroot/usr/share/applications
mkdir -p buildroot/usr/local/bin

mkdir -p buildroot/usr/share/doc/stopwatch

if [ "$build" = "dynamic" ];then
    cp $localshare/qt.conf buildroot/usr/local/stopwatch/etc/
fi

cd buildroot/usr/local/stopwatch/bin


ln -s ../share/images    images
ln -s ../share/languages languages
ln -s ../share/licenses     licenses

cd $apppath
cp $appbin buildroot/usr/local/stopwatch/bin
cp $localshare/stopwatch.sh buildroot/usr/local/stopwatch/bin

chmod 755 buildroot/usr/local/stopwatch/bin/stopwatch 2>/dev/zero
chmod 755 buildroot/usr/local/stopwatch/bin/thenewplayerpro  2>/dev/zero
chmod 755 buildroot/usr/local/stopwatch/bin/*.sh             2>/dev/zero

echo "Changelog:" > changelog
echo "Software is upgraded to $version" >> changelog
echo "Date: $date" >> changelog

cat changelog|gzip -9 > buildroot/usr/share/doc/stopwatch/changelog.Debian.gz
rm changelog

cat $script_path/../../player/licenses/self/LICENSE  > buildroot/usr/share/doc/stopwatch/copyright


cp $script_path/../../player/images/logo.png buildroot/usr/local/stopwatch/share/images/

#convert -resize 48 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/share/pixmaps/stopwatch.png

convert -resize 32 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/local/stopwatch/share/images/stopwatch_32x32.png
convert -resize 48 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/local/stopwatch/share/images/stopwatch_48x48.png
convert -resize 64 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/local/stopwatch/share/images/stopwatch_64x64.png
convert -resize 128 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/local/stopwatch/share/images/stopwatch_128x128.png
convert -resize 256 buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/local/stopwatch/share/images/stopwatch_256x256.png

#cp buildroot/usr/local/stopwatch/share/images/stopwatch_48x48.png buildroot/usr/share/pixmaps/stopwatch.png
cp  buildroot/usr/local/stopwatch/share/images/logo.png buildroot/usr/share/pixmaps/stopwatch.png

chmod 755 buildroot/usr/local/stopwatch/bin/stopwatch

cd buildroot/usr/local/bin
ln -s ../stopwatch/bin/stopwatch.sh stopwatch
cd $apppath

#if [ "$build" = "dynamic" ];then
#    cp -r /usr/lib/x86_64-linux-gnu/qt5/plugins/* buildroot/usr/local/stopwatch/plugins/
#fi

cp -r $script_path/../../player/licenses/self buildroot/usr/local/stopwatch/share/licenses/

cp $script_path/../../player/languages/* buildroot/usr/local/stopwatch/share/languages/
cd buildroot/usr/local/stopwatch/share/languages/

tsfiles="*.ts"

echo "tsfiles=$tsfiles"

rm *.qm 2>/dev/null

for ts in $tsfiles;do
    lrelease $ts 
done

cd $apppath
cp $script_path/share/stopwatch.desktop buildroot/usr/local/stopwatch/share/
echo "$version" > buildroot/usr/local/stopwatch/share/version.txt

cp $script_path/share/stopwatch.desktop buildroot/usr/share/applications/

cd buildroot/usr/local/stopwatch



#if [ "$build" = "dynamic" ];then
#    echo "Copy libraries ..."
#    sh $script_path/copy_libs.sh bin/stopwatch
#fi

echo "Deploy libraries ..."

#https://github.com/probonopd/linuxdeployqt
#linuxdeployqt bin/stopwatch -appimage -unsupported-allow-new-glibc -always-overwrite -bundle-non-qt-libs -no-translations 
#linuxdeployqt bin/stopwatch -no-strip  -verbose=2 -unsupported-allow-new-glibc -always-overwrite -bundle-non-qt-libs -no-translations 
linuxdeployqt bin/stopwatch -no-strip  -unsupported-allow-new-glibc -always-overwrite -bundle-non-qt-libs -no-translations 

find $apppath/buildroot -iname AppRun -exec rm {} \;

rm -rf share/doc 2>/dev/zero
rm -f bin/qt.conf
#rm -rf translations

cd $apppath
cd buildroot/usr/local/stopwatch/bin

if [ "$build" = "dynamic" ];then
    ln -s ../etc/qt.conf     qt.conf
fi

echo "Create package information ..."

cd $apppath
mkdir buildroot/DEBIAN
touch buildroot/DEBIAN/control
touch buildroot/DEBIAN/md5sums

cp $localshare/DEBIAN/preinst  buildroot/DEBIAN/ 2>/dev/zero
cp $localshare/DEBIAN/postinst buildroot/DEBIAN/ 2>/dev/zero
cp $localshare/DEBIAN/prerm    buildroot/DEBIAN/ 2>/dev/zero
cp $localshare/DEBIAN/prerm    buildroot/DEBIAN/ 2>/dev/zero

chmod 755 buildroot/DEBIAN/preinst  2>/dev/zero
chmod 755 buildroot/DEBIAN/postinst 2>/dev/zero
chmod 755 buildroot/DEBIAN/prerm    2>/dev/zero
chmod 755 buildroot/DEBIAN/postrm   2>/dev/zero


size="`du -h buildroot|tail -n1|cut -f1`"


#depends="libva-dev,libva-drm2,libvdpau-dev,libva-x11-2,libgraphite2-3,libopenjp2-7,libfreetype6"
#depends="libva*,libvdpau*,libgraphite*,libopenjp*,libfreetype6,libfontconfig*,libpulse*"
#depends="libva*,libvdpau*,libgraphite2*,libopenjp2*,libfreetype6,libpulse*,libasound2,libxcb-glx*,libxkbcommon*,libdrm*,libuuid*"
#depends="$depends,libdbus*,libcap*,libpcre*,liblzma*,libogg*,libflac*,libvorbis*,libvorbisenc*,libsnd*,liblz4*"

#if [ "$build" = "dynamic" ];then
#    depends="libva2,libva-drm2,libva-x11-2,libvdpau1,libgraphite2-3,libopenjp2-7,libfreetype6,qt5-default,libqt5multimedia5,libqt5multimedia5-plugins,libqt5multimediagsttools5,libqt5multimediaquick5,libqt5multimediawidgets5,libssl-dev,librtmp1,libx265-dev,x265,libgcrypt20,libgnutls30"
#else
#    depends="libva2,libva-drm2,libva-x11-2,libvdpau1,libgraphite2-3,libopenjp2-7,libfreetype6,libicu-dev,libssl-dev,librtmp1,libx265-dev,x265,libgcrypt20,libgnutls30"
#fi

depends=""


echo "Package: stopwatch" >  buildroot/DEBIAN/control
echo "Version: $version"         >> buildroot/DEBIAN/control
echo "Section: media"            >> buildroot/DEBIAN/control
echo "Priority: optional"        >> buildroot/DEBIAN/control
echo "Architecture: $arch"       >> buildroot/DEBIAN/control 
echo "Depends: $depends"         >> buildroot/DEBIAN/control  #qt510base libgl1-mesa-dev
echo "Installed-Size: $size"     >> buildroot/DEBIAN/control
echo "Maintainer: sudormroot" >> buildroot/DEBIAN/control
#echo ""                          >> buildroot/DEBIAN/control
echo "Description: the best IPTV/vide/iso/blue-ray player for macOS and Linux" >> buildroot/DEBIAN/control


cd $apppath/buildroot
find usr -type f -print0|xargs -0 -I {} md5sum {} | tee -a ../buildroot/DEBIAN/md5sums

cd $apppath
#rm -f stopwatch-bin.$os.$build-build.$version.$arch.deb 2>/dev/zero

sudo chown -R root:staff buildroot
sudo dpkg -b buildroot stopwatch-bin.$os.$build-build.$version.$arch.deb

user="`id -n -u`"
group="`id -n -g`"

sudo chown -R $user:$group buildroot  *.deb

md5sum stopwatch-bin.$os.$build-build.$version.$arch.deb > stopwatch-bin.$os.$build-build.$version.$arch.deb.md5


#
# Create AppImage
#
echo "Create AppImage ..."
#https://docs.appimage.org/packaging-guide/manual.html

cp -r buildroot stopwatch.AppDir
rm -rf stopwatch.AppDir/DEBIAN

cd stopwatch.AppDir/
#ln -s usr/local/stopwatch/bin/stopwatch.sh         AppRun

cp $script_path/share/appimage/runapp.sh runapp.sh
chmod 755 runapp.sh
ln -s runapp.sh AppRun

ln -s usr/local/stopwatch/share/stopwatch.desktop  stopwatch.desktop
ln -s usr/local/stopwatch/share/images/logo.png           stopwatch.png

mkdir -p usr/share/icons/hicolor/256x256/apps/ 
convert -resize 256 usr/local/stopwatch/share/images/logo.png usr/share/icons/hicolor/256x256/apps/stopwatch.png

convert -resize 256 usr/local/stopwatch/share/images/logo.png .DirIcon


sed -i -e 's#/usr#././#g' usr/local/stopwatch/bin/stopwatch
strings usr/local/stopwatch/bin/stopwatch|grep /usr
# strace -echdir -f ./AppRun #verify 
find usr/local/stopwatch/lib -type f -exec sed -i -e 's#/usr#././#g' {} \;

#
# https://docs.appimage.org/packaging-guide/manual.html
#

#
# GDK-Pixbuf modules and cache file
# sudo apt install gtk+-2.0
#
cd  $apppath
sh $script_path/bundle-gtk2.sh stopwatch.AppDir

APPDIR=$apppath/stopwatch.AppDir

#
# GLib schemas
#
glib_prefix="$(pkg-config --variable=prefix glib-2.0)"
mkdir -p "$APPDIR/usr/share/glib-2.0/schemas/"
cp -a ${glib_prefix}/share/glib-2.0/schemas/* "$APPDIR/usr/share/glib-2.0/schemas"
cd "$APPDIR/usr/share/glib-2.0/schemas/"
glib-compile-schemas .


#
# Theme engines
#
mkdir -p "$APPDIR/usr/lib/gtk-2.0"
GTK_LIBDIR=$(pkg-config --variable=libdir gtk+-2.0)
GTK_BINARY_VERSION=$(pkg-config --variable=gtk_binary_version gtk+-2.0)
cp -a "${GTK_LIBDIR}/gtk-2.0/${GTK_BINARY_VERSION}"/* "$APPDIR/usr/lib/gtk-2.0"

#
# RSVG library
#

mkdir -p "$APPDIR/usr/lib"
RSVG_LIBDIR=$(pkg-config --variable=libdir librsvg-2.0)
if [ x"${RSVG_LIBDIR}" != "x" ]; then
export GDK_PIXBUF_MODULE_FILE="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
     echo "cp -a ${RSVG_LIBDIR}/librsvg*.so* $APPDIR/usr/lib"
     cp -a "${RSVG_LIBDIR}"/librsvg*.so* "$APPDIR/usr/lib"
fi




cd $apppath
appimagetool stopwatch.AppDir stopwatch-bin.$os.$build-build.$version.$arch.AppImage
md5sum stopwatch-bin.$os.$build-build.$version.$arch.AppImage > stopwatch-bin.$os.$build-build.$version.$arch.AppImage.md5
chmod 755 stopwatch-bin.$os.$build-build.$version.$arch.AppImage

tar czf stopwatch-bin.$os.$build-build.$version.$arch.raw.tgz buildroot stopwatch.AppDir
md5sum stopwatch-bin.$os.$build-build.$version.$arch.raw.tgz > stopwatch-bin.$os.$build-build.$version.$arch.raw.tgz.md5


tar cvf stopwatch-bin.$os.$build-build.$version.$arch.tar \
    stopwatch-bin.$os.$build-build.$version.$arch.raw.tgz \
    stopwatch-bin.$os.$build-build.$version.$arch.raw.tgz.md5 \
    stopwatch-bin.$os.$build-build.$version.$arch.AppImage  \
    stopwatch-bin.$os.$build-build.$version.$arch.AppImage.md5  \
    stopwatch-bin.$os.$build-build.$version.$arch.deb \
    stopwatch-bin.$os.$build-build.$version.$arch.deb.md5

cd $script_path

echo "-- Finished --"



