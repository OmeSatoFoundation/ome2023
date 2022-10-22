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
mount --bind ${OBJDIR} $MOUNT_POINT/$OBJDIR_EMU

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

# installation of material
LOCALE_CONF="LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:en LC_CTYPE=ja_JP.UTF-8 LC_NUMERIC=ja_JP.UTF-8 LC_TIME=ja_JP.UTF-8 LC_COLLATE=ja_JP.UTF-8 LC_MONETARY=ja_JP.UTF-8 LC_MESSAGES=ja_JP.UTF-8 LC_PAPER=ja_JP.UTF-8 LC_NAME=ja_JP.UTF-8 LC_ADDRESS=ja_JP.UTF-8 LC_TELEPHONE=ja_JP.UTF-8 LC_MEASUREMENT=ja_JP.UTF-8 LC_IDENTIFICATION=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8"


chroot $MOUNT_POINT sh -c "$LOCALE_CONF" apt update
chroot $MOUNT_POINT sh -c "apt install xdg-user-dirs-gtk ; LANG=C xdg-user-dirs-gtk-update --force"
chroot $MOUNT_POINT su -c 'xdg-user-dirs-update' pi
## TODO: summarize dependencies into "control" in a deb package with contesnts of obj (${OBJDIR})and here apt should call that package.
chroot $MOUNT_POINT apt install -y \
fcitx-mozc i2c-tools open-jtalk open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 build-essential zlib1g-dev libsdl2-dev libasound2-dev dnsutils nmap telnet nkf lirc fswebcam gimp vlc tuxtype ruby libgtk2.0-dev libglew-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libgles2-mesa-dev libegl1-mesa-dev open-jtalk open-jtalk-mecab-naist-jdic
chroot $MOUNT_POINT su -c "cd $OBJDIR_EMU; find ./ -type f -exec install -D \"{}\" $PREFIX_EMU/\"{}\" \\;"

# release resources
umount_sysfds
umount $MOUNT_POINT/boot
umount $MOUNT_POINT/$OBJDIR_EMU
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
