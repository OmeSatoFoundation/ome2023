#!/usr/bin/env bash
apt update
apt install -y \
autoconf \
automake \
build-essential \
cloud-guest-utils \
curl \
debhelper \
devscripts \
dh-make \
dpkg \
dpkg-dev \
fdisk \
gawk \
git \
libtool \
make \
qemu-user-static \
wget

# Install git-lfs
curl -L -o git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.2.0/git-lfs-linux-amd64-v3.2.0.tar.gz
tar xvf git-lfs.tar.gz
sh -c 'cd git-lfs-3.2.0  && ./install.sh && git lfs install'
rm -rf git-lfs-3.2.0 git-lfs.tar.gz

# Install crosstools
dpkg --add-architecture arm64
sed -i '/^deb-src/d' /etc/apt/sources.list
sed -i 's/^deb/deb [arch=amd64,arm64]/g' /etc/apt/sources.list
apt update
apt install -y \
dpkg-cross \
g++-aarch64-linux-gnu \
libasound2-dev:arm64 \
libcurl4-openssl-dev:arm64 \
libegl1-mesa-dev:arm64 \
libgles2-mesa-dev:arm64 \
libglew-dev:arm64 \
libgtk2.0-dev:arm64 \
libsdl2-dev:arm64 \
libsdl2-dev:arm64 \
libsdl2-image-dev:arm64 \
libsdl2-mixer-dev:arm64 \
libsdl2-ttf-dev:arm64 \
zlib1g-dev:arm64

# Avoid dubious ownership
git config --global --add safe.directory /work

mkdir -p /root/.ssh/ || /bin/true
echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /root/.ssh/known_hosts

rm -rf /var/lib/apt/lists
