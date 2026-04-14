# 子ども IT 未来塾講義用 Raspberry Pi OS
このドキュメントでは演習で使用する例題 HSP ソースファイルや OpenJTalk 等の演習環境がプリインストールされた Raspberry Pi OS の拡張をビルドする。
拡張の詳細については [CONTRIBUTING.md](./CONTRIBUTING.md) を参照すること。

## Build for Windows Users
Check [build_in_vm/index.md](build_in_vm/index.md).

## Build for Linux Users
### Prerequisites
- qemu-aarch64-static と適当な binfmt 設定
    - debian 系なら `apt install qemu-user-static`
- Docker Desktop Server https://docs.docker.com/engine/install/ (Desktop でもおそらく可)

### Detailed Procedure
リポジトリをクローンする

```bash
git clone git@github.com:OmeSatoFoundation/ome2023.git --recurse
```

`--recurse` オプションを忘れないこと。もし忘れてしまったら、リポジトリのディレクトリで

```bash
git submodule update --init
```

を実行する。

初回のみ、講座用Raspberry Pi OS作成に使うコンテナイメージををビルドする。

```bash
docker build . -f docker/os.Dockerfile -t ome2023
```


ビルドを始める前に毎回，前回の作業用 `.img` ファイルが残っていないか確認する．

```bash
rm -f 2022-09-22-raspios-bullseye-arm64.img  # ファイル名は異なる場合がある
```

ssh 鍵の登録をし，コンテナでスクリプトを実行することで Raspberry Pi OS のイメージがホストのカレントディレクトリに生成される．

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa  # or any key you registers in github.com.
IMG_NAME=itschool-raspberrypi-os-$(date -Is | sed s/:/_/g).img  # For example
docker run --rm -ti --privileged \
  -v /dev/:/dev \
  -v "$(pwd):/work" \
  -w /work \
  -v "$SSH_AUTH_SOCK:/ssh-agent" \
  -e SSH_AUTH_SOCK=/ssh-agent \
  -e IMG_NAME="$IMG_NAME" \
  ome2023 sh -c '
    aclocal -I m4 &&
    automake -a -c &&
    autoconf &&
    ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local &&
    make -j"$(nproc)" &&
    ./contrib/scripts/install.bash -f -o "obj/${IMG_NAME}"
  ' &&
( cd "obj/" && 7z a "${IMG_NAME}.7z" "${IMG_NAME}" ; ) &&  # Optionally you can make a compressed archive
md5sum "obj/${IMG_NAME}" > "obj/${IMG_NAME}.md5" # Optionally you can make a verification hash
```

作成された `.img` ファイルは、元の Raspberry Pi と同じ用に SD カード等に書き込んで使用する。
[Etcher](https://etcher-docs.balena.io/), [GNU coreutils dd](https://www.gnu.org/software/coreutils/manual/coreutils.html#dd-invocation)
等が使える。

## Modification of Lecture Materials
ディレクトリ `01/material`, `02/material`, ..., `08/material` に変更を加えた際には，

```bash
find 01/material 02/material 03/material 04/material 05/material 06/material 07/material 08/material -type f | sort
```

を実行し，その結果で `Makefile.am` の `nobase_dist_omedata_DATA` を更新すること．
