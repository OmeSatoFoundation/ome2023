#!/bin/bash
set -eux

usage_exit() {
    echo "Usage: $0 [-hf]" 1>&2
    echo ""
    echo "Description"
    echo "  Create a distribution based on Raspberry pi OS for ome2023 lecture."
    echo ""
    echo "  This script is supposed to run at the project root, i.e. ome2023/. Example: bash contrib/scripts/install.sh"
    echo ""
    echo "  -f"
    echo "        forces resize2fs to proceed with the filesystem resize operation,"
    echo "        overriding some safety checks which resize2fs normally enforces."
    echo "  -h"
    echo "        display this help and exit"
    exit 1
}

RESIZE2FS_FORCE=
while getopts h:f OPT
do
    case $OPT in
        f) RESIZE2FS_FORCE=-f
            ;;
        h) usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

OBJDIR=./obj # Destination where binaries, executables and the other files are cross-compiled. Supposed this script to be ran at project root ome2023/.
OBJDIR_EMU=/ome2023
PREFIX_EMU=/usr/local

IMG_NAME=2022-09-22-raspios-bullseye-arm64.img
if [ ! -e $IMG_NAME ]; then
    if [ ! -e ${IMG_NAME}.xz ]; then
        wget https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64.img.xz
    fi
    xz -dkv ${IMG_NAME}.xz
fi

# expand img size
truncate -s $((7800000000/512*512)) $IMG_NAME
DEVICE_PATH=$(losetup -P -f --show ${IMG_NAME})

set +e
growpart $DEVICE_PATH 2
EXITCODE=$?
if [ $EXITCODE -ne 0 ] && [ $EXITCODE -ne 1 ]; then
    echo "growpart unexpectedly exited."
    exit $EXITCODE
fi
set -e

e2fsck -fy ${DEVICE_PATH}p2 && resize2fs ${DEVICE_PATH}p2 


# preparation of emulation
MOUNT_POINT=mount_point
mkdir -p $MOUNT_POINT/boot
mount ${DEVICE_PATH}p2 $MOUNT_POINT
mount ${DEVICE_PATH}p1 $MOUNT_POINT/boot
## mount object files which are to be stored in /usr/local.
mkdir -p $MOUNT_POINT/$OBJDIR_EMU
mount --bind . $MOUNT_POINT/$OBJDIR_EMU
mount --bind /etc/resolv.conf $MOUNT_POINT/etc/resolv.conf

sed $MOUNT_POINT/boot/config.txt -i -e 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/g'

MOUNT_SYSFD_TARGETS="$MOUNT_POINT/proc $MOUNT_POINT/sys $MOUNT_POINT/dev $MOUNT_POINT/dev/shm $MOUNT_POINT/dev/pts"
MOUNT_SYSFD_SRCS="proc sysfs devtmpfs tmpfs devpts"

umount_sysfds () {
    for i in $(echo $MOUNT_SYSFD_SRCS | wc -w); do
        SRC=$(echo $MOUNT_SYSFD_SRCS | cut -d " " -f $i)
        TARGET=$(echo $MOUNT_SYSFD_TARGETS | cut -d " " -f $i)
        umount $TARGET || /bin/true
    done
}

## mount sysfd
for i in $(echo $MOUNT_SYSFD_SRCS | wc -w); do
    SRC=$(echo $MOUNT_SYSFD_SRCS | cut -d " " -f $i)
    TARGET=$(echo $MOUNT_SYSFD_TARGETS | cut -d " " -f $i)
    mount -t $SRC $SRC $TARGET
done

cp $(which qemu-aarch64-static) $MOUNT_POINT/usr/bin
cp $(which qemu-aarch64-static) $MOUNT_POINT/usr/local/bin


# Configure locales
chroot $MOUNT_POINT sh -c 'echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen'
chroot $MOUNT_POINT locale-gen
chroot $MOUNT_POINT update-locale LANG=ja_JP.UTF-8 LANGUAGE=
chroot $MOUNT_POINT dpkg-reconfigure -fnoninteractive locales

# Configure timezone

chroot $MOUNT_POINT sh -c "echo \"Asia/Tokyo\" > /etc/timezone"
chroot $MOUNT_POINT ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
chroot $MOUNT_POINT dpkg-reconfigure -fnoninteractive tzdata

# Configure keyboard
echo '
XKBMODEL="pc101"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
' > $MOUNT_POINT/etc/default/keyboard
chroot $MOUNT_POINT dpkg-reconfigure -fnoninteractive keyboard-configuration

# Package-related configuration
chroot $MOUNT_POINT sh -c "apt update"

## Use ascii directory names for user directories (e.g. $HOME/Downloads)
chroot $MOUNT_POINT sh -c "LANG=C xdg-user-dirs-update"
rm $MOUNT_POINT/home/pi/.config/user-dirs.locale # disable initial check of locale coincidence by xdg-user-dirs-gtk-update

## Install depending packages
## TODO: summarize dependencies into "control" in a deb package with contesnts of obj (${OBJDIR})and here apt should call that package.
chroot $MOUNT_POINT apt install -y \
fcitx-mozc i2c-tools open-jtalk open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 build-essential zlib1g-dev libsdl2-dev libasound2-dev dnsutils nmap telnet nkf lirc fswebcam gimp vlc tuxtype ruby libgtk2.0-dev libglew-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libgles2-mesa-dev libegl1-mesa-dev open-jtalk open-jtalk-mecab-naist-jdic
chroot $MOUNT_POINT su -c "cd $OBJDIR_EMU; make install"

# Remove the initial wizard and change pw into `raspberry`
## /usr/lib/userconf-pi/userconf calls /usr/bin/cancel-rename and then
## /usr/bin/cancel-rename calls raspi-config to launch a desktop.
chroot $MOUNT_POINT /usr/lib/userconf-pi/userconf pi pi 'pi:5CSPR.F8pkaas'
chroot $MOUNT_POINT sh -c "echo \"[Desktop Entry]\nType=Application\nName=Select HDMI Audio\nExec=sh -c '/usr/bin/hdmi-audio-select; sudo rm /etc/xdg/autostart/hdmiaudio.desktop'\" > /etc/xdg/autostart/hdmiaudio.desktop"


# release resources
umount_sysfds
umount $MOUNT_POINT/boot
umount $MOUNT_POINT/$OBJDIR_EMU
umount $MOUNT_POINT/etc/resolv.conf
umount $MOUNT_POINT

# Truncate filesystem and partition
if [ $RESIZE2FS_FORCE ]; then
    E2FS_P2_BLOCK_SIZE=$(e2fsck -fy ${DEVICE_PATH}p2 2>/dev/null | tail -n 1 | sed -E 's;.* ([0-9]+)/[0-9]+ blocks$;\1;')
    echo $E2FS_P2_BLOCK_SIZE
    e2fsck -fy ${DEVICE_PATH}p2
    resize2fs -f ${DEVICE_PATH}p2 $E2FS_P2_BLOCK_SIZE
    e2fsck -fy ${DEVICE_PATH}p2
else
    e2fsck -fy ${DEVICE_PATH}p2
    resize2fs -M ${DEVICE_PATH}p2
fi
P2_BLOCK_COUNT=$(dumpe2fs -h ${DEVICE_PATH}p2 2>/dev/null | grep "Block count" | gawk -F':' -e '{print $2}' | xargs)
P2_BLOCK_SIZE=$(dumpe2fs -h ${DEVICE_PATH}p2 2>/dev/null | grep "Block size" | gawk -F':' -e '{print $2}' | xargs)
P2_START_SECTOR=$(fdisk -l ${DEVICE_PATH} | grep ${DEVICE_PATH}p2 | gawk '{print $2}')

fdisk -w never -W never ${DEVICE_PATH} <<EEOF
d
2
n
p
2
$P2_START_SECTOR
$((P2_START_SECTOR + (P2_BLOCK_COUNT*P2_BLOCK_SIZE/512)))
w
EEOF

TARGET_FILENAME=itschool-raspbian-$(date "+%Y-%m-%dT%H.%M.%S").img
# truncate -s ${FINAL_SIZE} $TARGET_FILENAME
#COUNT=$(LANG=C fdisk -l ${DEVICE_PATH} | grep -i 'Disk /dev' | sed 's/^.* \([0-9]\+\) sectors$/\1/g')
COUNT=$(($(fdisk -l ${DEVICE_PATH} | grep ${DEVICE_PATH}p2 | gawk '{print $3}')+1))
BS=$(LANG=C fdisk -l ${DEVICE_PATH} | grep -i 'Units: ' | sed 's/^.* \([0-9]\+\) bytes$/\1/g')
dd if=${IMG_NAME} of=${TARGET_FILENAME} bs=$BS count=$COUNT status=progress

losetup -d $DEVICE_PATH
rm -rf $MOUNT_POINT
