# IT未来塾講義用 Raspberry Pi OS
## Prerequisites
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
次のコマンドを実行することで、コンテナ上で作成されたRaspberry Pi OSのイメージがローカルに置かれる。

```bash 
docker build . -t ome2023
docker run --rm -ti -v /dev/:/dev --privileged -v $(pwd):/work -v --workdir=/work ome2023 sh -c 'aclocal -I m4 && automake -a -c && autoconf && ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local && make -j6 && ./contrib/scripts/install.bash'
```
