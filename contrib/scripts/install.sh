#!/bin/bash
set -eux

usage_exit() {
    echo "Usage: $0 [-hf] ome2019_branch_name" 1>&2
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

apt update
apt install -y qemu-user-static

if [ ! -e OpenHSP ]; then
    git clone https://github.com/onitama/OpenHSP.git
    sed -i "s/make/make -j10/g" OpenHSP/setup.sh
fi

if [ ! -e julius ]; then
    git clone https://github.com/julius-speech/julius.git -b v4.6 
fi
if [ ! -e dictation-kit-4.5 ]; then
    wget  "https://osdn.net/frs/redir.php?m=gigenet&f=julius%2F71011%2Fdictation-kit-4.5.zip" -O dictation-kit-4.5.zip
    unzip dictation-kit-4.5.zip
fi

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

e2fsck -fn ${DEVICE_PATH}p2 && resize2fs ${DEVICE_PATH}p2 


# mount
MOUNT_POINT=mount_point
mkdir -p $MOUNT_POINT/boot
mount ${DEVICE_PATH}p2 $MOUNT_POINT
mount ${DEVICE_PATH}p1 $MOUNT_POINT/boot

sed $MOUNT_POINT/boot/config.txt -i -e 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/g'
rsync -auvP --chown=1000:1000 OpenHSP $MOUNT_POINT/home/pi --exclude .git
rsync -auvP --chown=1000:1000 julius $MOUNT_POINT/home/pi --exclude .git
rsync -auvP --chown=1000:1000 dictation-kit-4.5 $MOUNT_POINT/home/pi

MOUNT_SYSFD_TARGETS="$MOUNT_POINT/proc $MOUNT_POINT/sys $MOUNT_POINT/dev $MOUNT_POINT/dev/shm $MOUNT_POINT/dev/pts"
MOUNT_SYSFD_SRCS="proc sysfs devtmpfs tmpfs devpts"

umount_sysfds () {
    for i in $(echo $MOUNT_SYSFD_SRCS | wc -w); do
        SRC=$(echo $MOUNT_SYSFD_SRCS | cut -d " " -f $i)
        TARGET=$(echo $MOUNT_SYSFD_TARGETS | cut -d " " -f $i)
        umount $TARGET || /bin/true
    done
}

for i in $(echo $MOUNT_SYSFD_SRCS | wc -w); do
    SRC=$(echo $MOUNT_SYSFD_SRCS | cut -d " " -f $i)
    TARGET=$(echo $MOUNT_SYSFD_TARGETS | cut -d " " -f $i)
    mount -t $SRC $SRC $TARGET
done

#update-binfmts --enable qemu-aarch64
cp /usr/bin/qemu-aarch64-static $MOUNT_POINT/usr/bin

LOCALE_CONF="LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:en LC_CTYPE=ja_JP.UTF-8 LC_NUMERIC=ja_JP.UTF-8 LC_TIME=ja_JP.UTF-8 LC_COLLATE=ja_JP.UTF-8 LC_MONETARY=ja_JP.UTF-8 LC_MESSAGES=ja_JP.UTF-8 LC_PAPER=ja_JP.UTF-8 LC_NAME=ja_JP.UTF-8 LC_ADDRESS=ja_JP.UTF-8 LC_TELEPHONE=ja_JP.UTF-8 LC_MEASUREMENT=ja_JP.UTF-8 LC_IDENTIFICATION=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8"


chroot $MOUNT_POINT sh -c '$LOCALE_CONF' apt update
chroot $MOUNT_POINT sh -c "apt install xdg-user-dirs-gtk ; LANG=C xdg-user-dirs-gtk-update --force"
chroot $MOUNT_POINT su -c 'xdg-user-dirs-update' pi
chroot $MOUNT_POINT sh -c "cd /home/pi/OpenHSP; ./setup.sh"
chroot $MOUNT_POINT sh -c "cd /home/pi/julius; ./configure --build=aarch64-unknown-linux-gnu --with-mictype=alsa; make -j4; make install"

# umount
umount_sysfds
umount $MOUNT_POINT/boot
umount $MOUNT_POINT

e2fsck -fn ${DEVICE_PATH}p2
# Truncate filesystem and partition
if [ $RESIZE2FS_FORCE ]; then
    E2FS_P2_BLOCK_SIZE=$(e2fsck -fn ${DEVICE_PATH}p2 2>/dev/null | tail -n 1 | sed -E 's;.* ([0-9]+)/[0-9]+ blocks$;\1;')
    echo $E2FS_P2_BLOCK_SIZE
    resize2fs -f ${DEVICE_PATH}p2 $E2FS_P2_BLOCK_SIZE
    e2fsck -fn ${DEVICE_PATH}p2
else
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
