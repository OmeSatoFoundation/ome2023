# IT未来塾講義用 Raspberry Pi OS
## Prerequisites

## Image Build
### Docker

```bash 
docker build . -t ome2023
docker run --rm -ti -v $(pwd):/ome2023-0.1.0 -v $(pwd)/obj:/obj --workdir=/ome2023-0.1.0 ome2023 sh -c 'aclocal -I m4 && automake -a -c && autoconf && ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/obj && make -j6 && make install'
sudo contrib/scripts/install.bash #TODO: run in container
```
