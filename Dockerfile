FROM debian:bullseye

RUN apt update \
    && apt install -y \
    autoconf \
    automake \
    build-essential \
    curl \
    debhelper \
    dh-make \
    dpkg \
    dpkg-dev \
    git \
    libtool \
    make \
    && rm -rf /var/lib/apt/lists

# Install git-lfs
WORKDIR /download
RUN curl -L -o git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.2.0/git-lfs-linux-amd64-v3.2.0.tar.gz \
    && tar xvf git-lfs.tar.gz \
    && cd git-lfs-3.2.0 \
    && ./install.sh

# Install crosstools
## TODO: use toolchain-ng
RUN dpkg --add-architecture arm64 \
    && sed -i 's/^deb/deb [arch=amd64,arm64]/g' /etc/apt/sources.list \
    && apt update \
    && apt install -y \
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
    zlib1g-dev:arm64 \
    && rm -rf /var/lib/apt/lists \

WORKDIR /work
