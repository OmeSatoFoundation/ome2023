# Build the Distribution ISO in Oracle VirtualBox
This project originally supposes a filesystem of a native Linux to make an ISO file.
Windows users, on the other hands, are able to make the ISO file using their virtualization technologies.
Followings describes instructions on virtual machines or WSL over a Windows system.

## WSL
TBD. See https://github.com/OmeSatoFoundation/ome2023/issues/97

## Oracle VM VirtualBox and Vagrant
### General Procedure
- Install Oracle VM VirtualBox and Vagrant
- Build a box of Debian Bullseye
- Run a build script in the VM

### Prerequisites
Install below items on the host machine. We confirmed the build operation with the below composition.

- Windows 11 23H2
- [Oracle VM VirtualBox](https://www.virtualbox.org/) 7.0.18
- [Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) 2.4.1

Open a terminal (e.g. MS PowerShell) and install [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) [e3da795](https://github.com/dotless-de/vagrant-vbguest/commit/e3da79581df4356c0052e8771f572d1825e35024).

```
vagrant plugin install vagrant-vbguest
```

### Boot an environment
Open a terminal (e.g. MS PowerShell).
Change directory into `ome2023/vm` and run `vagrant up`.

```bash
cd ./vm
vagrant up
```

This takes a while.

### Connect to the environment

```bash
vagrant ssh
```

to connect to the environment via ssh.
User and password are default (both are `vagrant`).

Promote to root from `vagrant` user.

```bash
sudo su
```

Generate a ssh key pair

```
ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519
```

Then register the public key on GitHub.com.

```
cat /root/.ssh/id_ed25519.pub
```

Of course you also can apply existing keys by yourself.
See https://docs.github.com/en/authentication/connecting-to-github-with-ssh for more details.

### Run the build script
The later procedures are almost same as the instructions for Linux users on [../../README.md](../../README.md) but use of docker.
Briefly, run below.

```
eval $(ssh-agent -s)
ssh-add
git clone git@github.com:OmeSatoFoundation/ome2023.git --recurse
cd ome2023 && \
aclocal -I m4 && \
automake -a -c && \
autoconf && \
./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local && \
make -j$(nproc) && \
./contrib/scripts/install.bash -f
```

### Copy the image into the host FS
`ome2023/vm/shared` on the host is mounted on `/mnt/shared` on the guest.
Copy the derived `.img` file into `/mnt/shared` and pick it from the host to flash onto SD cards or anything.
Refer https://ome-edu.nshimizu.com/index.php?plugin=attach&refer=FrontPage&openfile=appendix_2023.pdf for example.

`-o` option will be available to write the `.img` file directly to `/mnt/shared` after [#22](https://github.com/OmeSatoFoundation/ome2023/pull/22) is merged.
