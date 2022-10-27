# IT未来塾講義用 Raspberry Pi OS
## Prerequisites
QEMU > 5.2

QEMU == 3.1+dfsg-8+deb10u9 では apt 実行中にランタイムエラーが起こることを確認している。 QEMU 5.2 と 7.1 で動作確認済み。 https://github.com/docker/buildx/issues/1170

## Image Build
### Docker

```bash 
docker build . -t ome2023
docker run --rm -ti -v $(pwd):/work -v --workdir=/work ome2023 sh -c 'aclocal -I m4 && automake -a -c && autoconf && ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local && make -j6'
sudo contrib/scripts/install.bash #TODO: run in container
```
