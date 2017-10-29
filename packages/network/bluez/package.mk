################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="bluez"
PKG_VERSION="5.43"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.bluez.org/"
PKG_URL="http://www.kernel.org/pub/linux/bluetooth/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain dbus glib readline systemd"
PKG_SECTION="network"
PKG_SHORTDESC="bluez: Bluetooth Tools and System Daemons for Linux."
PKG_LONGDESC="Bluetooth Tools and System Daemons for Linux."

PKG_IS_ADDON="no"
PKG_AUTORECONF="yes"

if [ "$DEBUG" = "yes" ]; then
  BLUEZ_CONFIG="--enable-debug"
else
  BLUEZ_CONFIG="--disable-debug"
fi

if [ "$DEVTOOLS" = "yes" ]; then
  BLUEZ_CONFIG="$BLUEZ_CONFIG --enable-monitor --enable-test"
else
  BLUEZ_CONFIG="$BLUEZ_CONFIG --disable-monitor --disable-test"
fi

PKG_CONFIGURE_OPTS_TARGET="--disable-dependency-tracking \
                           --disable-silent-rules \
                           --disable-library \
                           --enable-udev \
                           --disable-cups \
                           --disable-obex \
                           --enable-client \
                           --enable-systemd \
                           --enable-tools \
                           --enable-datafiles \
                           --disable-experimental \
                           --enable-sixaxis \
                           --with-gnu-ld \
                           $BLUEZ_CONFIG \
                           storagedir=/storage/.cache/bluetooth"

pre_configure_target() {
# bluez fails to build in subdirs
  cd $ROOT/$PKG_BUILD
    rm -rf .$TARGET_NAME

  export LIBS="-ltermcap"
}

post_makeinstall_target() {
  rm -rf $INSTALL/usr/lib/systemd
  rm -rf $INSTALL/usr/bin/bccmd
  rm -rf $INSTALL/usr/bin/bluemoon
  rm -rf $INSTALL/usr/bin/ciptool
  rm -rf $INSTALL/usr/share/dbus-1

  rm -rf $INSTALL/etc/bluetooth
    ln -sf /storage/.config/bluetooth $INSTALL/etc/bluetooth

  mkdir -p $INSTALL/usr/config
    cp -PR $PKG_DIR/config/* $INSTALL/usr/config

  mkdir -p $INSTALL/usr/config/bluetooth
    cp -PR $ROOT/$PKG_BUILD/src/main.conf $INSTALL/usr/config/bluetooth
    sed -i $INSTALL/usr/config/bluetooth/main.conf \
        -e "s|^#\[Policy\]|\[Policy\]|g" \
        -e "s|^#AutoEnable.*|AutoEnable=true|g"
    cp -PR $ROOT/$PKG_BUILD/profiles/proximity/proximity.conf $INSTALL/usr/config/bluetooth
    cp -PR $ROOT/$PKG_BUILD/profiles/network/network.conf $INSTALL/usr/config/bluetooth
}

post_install() {
  enable_service bluetooth.service
  enable_service obex.service
}
