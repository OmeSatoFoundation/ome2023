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

# Julius dependencies
RUN apt update \
    && apt install -y \
    libasound2-dev \
    libsdl2-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists
