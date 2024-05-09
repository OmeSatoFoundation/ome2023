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

# add github fingerprint
mkdir -p /root/.ssh/ || /bin/true
echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /root/.ssh/known_hosts

# Check if git-lfs installed
set +e
git lfs install
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "git-lfs is required but not installed. Visit https://git-lfs.com/ and install git-lfs."
    exit 1
fi
set -e

git lfs pull

OBJDIR=./obj # Destination where binaries, executables and the other files are cross-compiled. Supposed this script to be ran at project root ome2023/.
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
mount --bind /etc/resolv.conf $MOUNT_POINT/etc/resolv.conf

sed $MOUNT_POINT/boot/config.txt -i -e 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/g'

MOUNT_SYSFD_TARGETS=("$MOUNT_POINT/proc" "$MOUNT_POINT/sys" "$MOUNT_POINT/dev" "$MOUNT_POINT/dev/shm" "$MOUNT_POINT/dev/pts")
MOUNT_SYSFD_SRCS=("proc" "sysfs" "devtmpfs" "tmpfs" "devpts")

umount_sysfds () {
    for (( i=0; i<${#MOUNT_SYSFD_TARGETS[@]}; i++ )); do
        umount -f -l ${MOUNT_SYSFD_TARGETS[$i]} || /bin/true
    done
}

## mount sysfd
for (( i=0; i<${#MOUNT_SYSFD_TARGETS[@]}; i++ )); do
    mount -t ${MOUNT_SYSFD_SRCS[$i]} ${MOUNT_SYSFD_SRCS[$i]} ${MOUNT_SYSFD_TARGETS[$i]}
done

cp $(which qemu-aarch64-static) $MOUNT_POINT/usr/bin
cp $(which qemu-aarch64-static) $MOUNT_POINT/usr/local/bin

# Package-related configuration
chroot $MOUNT_POINT sh -c "apt update"

## Install depending packages
## TODO: summarize dependencies into "control" in a deb package with contesnts of obj (${OBJDIR})and here apt should call that package.
chroot $MOUNT_POINT apt install -y \
fcitx-mozc i2c-tools open-jtalk open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 build-essential zlib1g-dev libsdl2-dev libasound2-dev dnsutils nmap telnet nkf lirc fswebcam gimp vlc tuxtype ruby libgtk2.0-dev libglew-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libgles2-mesa-dev libegl1-mesa-dev open-jtalk open-jtalk-mecab-naist-jdic
make DESTDIR=$(realpath $MOUNT_POINT) install

# Place .config/user-dirs.locale with ja_JP in /etc/skel to supress locale-inconsistent dialogue.
## piwiz creates a new user by moving the default user pi: `usermod -m -d "/home/$NEWNAME" "$NEWNAME"`.
## as in userconf-pi/userconf.
chroot $MOUNT_POINT su pi -c 'LANG=C xdg-user-dirs-update'
mkdir -p /home/pi/.config
echo "ja_JP" > /home/pi/.config/user-dirs.locale

# Enable I2C and SPI before the initial boot.
## How to find raspi-config usage:
## Get its latest source code at https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config
## or reproductive one at https://github.com/RPi-Distro/raspi-config/blob/408bde537671de6df2d9b91564e67132f98ffa71/raspi-config
## Then find the command-line entrypoint. It's 2913rd line at the permalink.
## The positional parameter `nonint` takes following parameter and `raspi-config` the rest by running `"$@"`.
## You can run arbitrary shell commands here; Typically, you want tu run functions defined in `raspi-config`
## e.g. do_spi. The shell function `do_spi` takes another parameter 0 or 1 that indicates if the script enables or
## disables SPI functionality. As well as ordinary shell script, you can pass the argument after a space character following
## `do_spi`.
##
## `dtparam` command and `modprobe` command in `raspi-config` raise errors but you can ignore them
## because they just cannot access the device tree, etc. These hardware-affecting commands will (might) run
## at later launch on an atcual hardware.
## TODO:
## >  wrote all the steps normally done through raspi-config
## https://github.com/RPi-Distro/raspi-config/issues/120#issuecomment-1445825945
chroot $MOUNT_POINT raspi-config nonint do_spi 0
chroot $MOUNT_POINT raspi-config nonint do_i2c 0

# Enable IR device
sed -i -e "s/#dtoverlay=gpio-ir,gpio_pin=17/dtoverlay=gpio-ir,gpio_pin=4/g" $MOUNT_POINT/boot/config.txt
sed -i -e "s/#dtoverlay=gpio-ir-tx,gpio_pin=18/dtoverlay=gpio-ir-tx,gpio_pin=13/g" $MOUNT_POINT/boot/config.txt
sed -i -e "s/driver *= *devinput/driver = default/g" $MOUNT_POINT/etc/lirc/lirc_options.conf
sed -i -e "s/device *= *auto/device = \/dev\/lirc0/g" $MOUNT_POINT/etc/lirc/lirc_options.conf

# A WORKAROUND to put executable on webserver.py
chmod +x $MOUNT_POINT/usr/local/share/ome/07/www/webserver.py $MOUNT_POINT/usr/local/share/ome/08/www/webserver.py

# remove APT cache
rm -rf $MOUNT_POINT/var/lib/apt/lists/*

# release resources
umount_sysfds
umount -f -l $MOUNT_POINT/boot
umount -f -l $MOUNT_POINT/etc/resolv.conf
umount -f -l $MOUNT_POINT

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
