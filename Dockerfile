FROM debian:bullseye

RUN apt update \
    && apt install -y \
    autoconf \
    automake \
    build-essential \
    curl \
    debhelper \
    devscripts \
    dh-make \
    dpkg \
    dpkg-dev \
    git \
    libtool \
    make \
    wget \
    cloud-guest-utils \
    fdisk \
    gawk \
    && rm -rf /var/lib/apt/lists

# Install git-lfs
WORKDIR /download
RUN curl -L -o git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.2.0/git-lfs-linux-amd64-v3.2.0.tar.gz \
    && tar xvf git-lfs.tar.gz \
    && cd git-lfs-3.2.0 \
    && ./install.sh \
    && git lfs install

# Install crosstools
## TODO: use toolchain-ng
RUN dpkg --add-architecture arm64 \
    && sed -i 's/^deb/deb [arch=amd64,arm64]/g' /etc/apt/sources.list \
    && apt update \
    && apt install -y \
    dpkg-cross \
    g++-aarch64-linux-gnu \
    libasound2-dev:arm64 \
    libcurl4-openssl-dev:arm64 \
    libcurl4-openssl-dev:arm64 \
    libegl1-mesa-dev:arm64 \
    libgles2-mesa-dev:arm64 \
    libglew-dev:arm64 \
    libgpiod-dev:arm64 \
    libgtk2.0-dev:arm64 \
    libsdl2-dev:arm64 \
    libsdl2-dev:arm64 \
    libsdl2-image-dev:arm64 \
    libsdl2-mixer-dev:arm64 \
    libsdl2-ttf-dev:arm64 \
    zlib1g-dev:arm64 \
    && rm -rf /var/lib/apt/lists

# Install qemu to build OpenHSP
RUN apt update \
    && apt install -y \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists

# Avoid dubious ownership
RUN git config --global --add safe.directory /work

WORKDIR /work
