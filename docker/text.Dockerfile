# syntax=docker/dockerfile:1.4
# The MIT License (MIT)
# Copyright (c) 2016 Kaito Udagawa
# Copyright (c) 2016-2018 3846masa
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Modified by Yohei Shimmyo in 2022

# Switch the base image that includes latex runtime.
# Enter remote name (ghcr.io/.../...:...) to use remote base image (default).
# If remote name fails, use local name (buildenv).
# Find the remote image name and tags at
# https://github.com/OmeSatoFoundation/ome-doc/pkgs/container/ome-doc%2Ftypesetenv
ARG BASE_IMAGE=ghcr.io/omesatofoundation/ome-doc/texlive:latest

FROM ubuntu:25.10 AS texlive
# Install packages being dependent on texlive installation.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get --no-install-recommends install -y \
    ca-certificates \
    curl \
    perl \
    tar \
    xz-utils \
    ;
WORKDIR /install-tl-unx
RUN --mount=type=bind,source=docker/texlive.profile,target=./texlive.profile \
    curl -LO https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2023/install-tl-unx.tar.gz && \
    tar -xzf ./install-tl-unx.tar.gz --strip-components=1 && \
    ./install-tl \
        --no-interaction \
        --profile ./texlive.profile \
        --repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2023/tlnet-final/
ENV PATH=$PATH:/opt/texlive/2023/bin/x86_64-linux
# Install depending texlive packages
RUN tlmgr update --self && \
  tlmgr install \
  bbding \
  collection-fontsrecommended \
  collection-langjapanese \
  collection-latexextra \
  latexmk \
  light-latex-make \
  ;


FROM ubuntu:25.10 AS font
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get --no-install-recommends install -y \
    ca-certificates \
    curl \
    tar \
    unar \
    xz-utils \
    ;
WORKDIR /root/fonts
RUN mkdir -p /usr/share/fonts/TTF && \
    curl -L --remote-name-all \
        https://github.com/liberationfonts/liberation-fonts/files/7261482/liberation-fonts-ttf-2.1.5.tar.gz \
        https://moji.or.jp/wp-content/ipafont/IPAexfont/IPAexfont00401.zip \
        https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
        https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip \
        && \
    tar -xvf liberation-fonts-ttf-2.1.5.tar.gz -C /usr/share/fonts/TTF && \
    ls && \
    echo "IPAexfont00401.zip" "NotoSansCJKjp-hinted.zip" "NotoSerifCJKjp-hinted.zip" | xargs -n 1 unar -d -f -o /usr/share/fonts/TTF
WORKDIR /usr/share/fonts/TTF
RUN curl -L --remote-name-all \
        https://github.com/google/fonts/raw/main/ofl/bizudgothic/BIZUDGothic-Bold.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudgothic/BIZUDGothic-Regular.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudmincho/BIZUDMincho-Bold.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudmincho/BIZUDMincho-Regular.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudpgothic/BIZUDPGothic-Bold.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudpgothic/BIZUDPGothic-Regular.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudpmincho/BIZUDPMincho-Bold.ttf \
        https://github.com/google/fonts/raw/main/ofl/bizudpmincho/BIZUDPMincho-Regular.ttf \
        ;

COPY <<EOF /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif CJK JP</family>
        </prefer>
    </alias>
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans CJK JP</family>
        </prefer>
    </alias>
</fontconfig>
EOF


FROM ubuntu:25.10 AS buildenv_pre
# Copy texlive
COPY --from=texlive --link /opt/texlive/2023 /opt/texlive/2023
COPY --from=font --link /usr/share/fonts/TTF /usr/share/fonts/TTF
COPY --from=font --link /etc/fonts/local.conf /etc/fonts/local.conf
ENV PATH=$PATH:/opt/texlive/2023/bin/x86_64-linux
# Install Runtime Dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get --no-install-recommends install -y \
    fontconfig \
    ghostscript \
    inkscape \
    ncurses-bin \
    ;
# Generate system font cache & lualatex font names db
RUN fc-cache -f && luaotfload-tool -fu

# Build a utility to copy artifacts
FROM golang:1.25-trixie AS copy_llmk_object_build
WORKDIR /copy_llmk_object
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=bind,source=tools/copy_llmk_object/,target=/copy_llmk_object,rw=true \
    go build -o build/copy_llmk_object cmd/copy_llmk_object.go && \
    mkdir /artifacts && \
    cp build/copy_llmk_object /artifacts/copy_llmk_object

FROM buildenv_pre as buildenv
COPY --from=copy_llmk_object_build --link /artifacts/copy_llmk_object /usr/bin/copy_llmk_object

FROM ${BASE_IMAGE} AS build
# Specify which source to be built. Default is one at project root.
# For example: --build-arg TARGET=05/
# TODO: make a top-level tex source that includes all chapters as one book.
ARG TARGET=.
WORKDIR /build/tex
RUN --mount=type=bind,source=.,target=.,rw=true \
    mkdir /artifacts && \
    cd ${TARGET} && \
    llmk && \
    # export intermediate/object files \
    # file list inherits https://github.com/wtsnjp/llmk/blob/e9949790d4acd007b58aa80d60aa2b4c18953134/llmk.lua#L58 \
    /usr/bin/copy_llmk_object /artifacts


FROM scratch AS final
COPY --from=build /artifacts /
