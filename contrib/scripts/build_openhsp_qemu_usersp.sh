#!/bin/sh
# Supposed to be run in contrib/OpenHSP/
# TODO: stop using qemu and use a cross toolchain
set -e

IMAGE_NAME=../2022-09-22-raspios-bullseye-arm64.img
CLEANLIST=$IMAGE_NAME
QEMU_STATIC=/usr/bin/qemu-aarch64-static
ROOTFS=rootfs

if [ ! -e $IMAGE_NAME ]; then
    curl -L -o $IMAGE_NAME.xz https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64.img.xz
    xz -kd $IMAGE_NAME
fi

# Extract archive files
DEVFD=$(losetup -P --show -f $IMAGE_NAME)
mount -o ro ${DEVFD}p1 boot
mount -o ro ${DEVFD}p2 sysroot
/bin/sh -c "cd sysroot; find ./ | cpio -pdaum ../$ROOTFS"
find boot | cpio -pdaum $ROOTFS
umount boot sysroot
rmdir boot sysroot

# Configure qemu emulation
mkdir $ROOTFS/OpenHSP
cp $QEMU_STATIC $ROOTFS/usr/bin/
mount -t sysfs sysfs $ROOTFS/sys
mount -t proc proc $ROOTFS/proc
mount -t devtmpfs udev $ROOTFS/dev
mount -t devpts devpts $ROOTFS/dev/pts
mount --bind ../OpenHSP $ROOTFS/OpenHSP

LOCALE_CONF="LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:en LC_CTYPE=ja_JP.UTF-8 LC_NUMERIC=ja_JP.UTF-8 LC_TIME=ja_JP.UTF-8 LC_COLLATE=ja_JP.UTF-8 LC_MONETARY=ja_JP.UTF-8 LC_MESSAGES=ja_JP.UTF-8 LC_PAPER=ja_JP.UTF-8 LC_NAME=ja_JP.UTF-8 LC_ADDRESS=ja_JP.UTF-8 LC_TELEPHONE=ja_JP.UTF-8 LC_MEASUREMENT=ja_JP.UTF-8 LC_IDENTIFICATION=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8"

chroot $ROOTFS sh -c "$LOCALE_CONF cd /OpenHSP; setup.sh"

umount $ROOTFS/OpenHSP $ROOTFS/sys $ROOTFS/proc $ROOTFS/dev $ROOTFS/dev/pts
