# IT未来塾講義用 Raspberry Pi OS
## Prerequisites
- qemu-aarch64-static と適当な binfmt 設定
    - debian 系なら `apt install qemu-user-static`
- Docker Desktop Server https://docs.docker.com/engine/install/ (Desktop でもおそらく可)

## Image Build
リポジトリをクローンする

```bash
git clone git@github.com:OmeSatoFoundation/ome2023.git --recurse
```

`--recurse` オプションを忘れないこと。もし忘れてしまったら、リポジトリのディレクトリで

```bash
git submodule update --init
```

を実行する。

### Docker
ビルドを始める前に，前回の作業用 `.img` ファイルが残っていないか確認する．

```bash
rm -f 2022-09-22-raspios-bullseye-arm64.img
```

ssh 鍵の登録をし，コンテナでスクリプトを実行することで Raspberry Pi OS のイメージが現在時刻付きのファイル名とともにホストのカレントディレクトリに生成される．

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa  # or any key you registers in github.com.
docker run --rm -ti -v /dev/:/dev --privileged -v $(pwd):/work -v --workfdir=/work -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ome2023 sh -c 'aclocal -I m4 && automake -a -c && autoconf && ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local && make -j$(nproc) && ./contrib/scripts/install.bash -f'
```


## Modification of Lecture Materials
ディレクトリ `01/`, `02/`, ..., `08/` に変更を加えた際には，

```bash
find 01 02 03 04 05 06 07 08 -type f | sort
```

を実行し，その結果で `Makefile.am` の `nobase_dist_omedata_DATA` を更新してください．
