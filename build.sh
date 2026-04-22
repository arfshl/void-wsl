#!/bin/sh
export RELEASE=20250202
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH=x86_64 ;;
    amd64) ARCH=x86_64 ;;
    aarch64) ARCH=aarch64 ;;
    arm64) ARCH=aarch64 ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
echo "RELEASE_EDGE=$RELEASE" >> "$GITHUB_OUTPUT"
echo "ARCH=$ARCH" >> "$GITHUB_OUTPUT"


# start build
curl -LO "https://repo-default.voidlinux.org/live/current/void-$ARCH-ROOTFS-$RELEASE.tar.xz"
curl -LO "https://repo-default.voidlinux.org/live/current/void-$ARCH-musl-ROOTFS-$RELEASE.tar.xz"
mkdir -p ./voidwsl
mkdir -p ./voidwsl-musl
sudo tar -xJpf void-$ARCH-ROOTFS-$RELEASE.tar.xz -C ./voidwsl
sudo tar -xJpf void-$ARCH-musl-ROOTFS-$RELEASE.tar.xz -C ./voidwsl-musl 
sudo cp ./wslconf/oobe.sh ./voidwsl/etc/oobe.sh
sudo cp ./wslconf/oobe.sh ./voidwsl-musl/etc/oobe.sh
sudo chmod 644 ./voidwsl/etc/oobe.sh
sudo chmod 644 ./voidwsl-musl/etc/oobe.sh
sudo chmod +x ./voidwsl/etc/oobe.sh
sudo chmod +x ./voidwsl-musl/etc/oobe.sh
sudo cp ./wslconf/wsl-distribution.conf ./voidwsl/etc/wsl-distribution.conf
sudo cp ./wslconf/wsl-distribution-musl.conf ./voidwsl-musl/etc/wsl-distribution.conf
sudo chmod 644 ./voidwsl/etc/wsl-distribution.conf
sudo chmod 644 ./voidwsl-musl/etc/wsl-distribution.conf
sudo mkdir -p ./voidwsl/usr/lib/wsl/
sudo mkdir -p ./voidwsl-musl/usr/lib/wsl/
sudo cp ./wslconf/icon.ico ./voidwsl/usr/lib/wsl/icon.ico
sudo cp ./wslconf/icon.ico ./voidwsl-musl/usr/lib/wsl/icon.ico

cat <<-EOF | sudo unshare -mpf bash -e -
sudo mount --bind /dev ./voidwsl/dev
sudo mount --bind /proc ./voidwsl/proc
sudo mount --bind /sys ./voidwsl/sys
sudo echo 'nameserver 1.1.1.1' >> ./voidwsl/etc/resolv.conf

sudo chroot ./voidwsl xbps-install -S
sudo chroot ./voidwsl xbps-install -u -y xbps
sudo chroot ./voidwsl xbps-install bash sudo shadow -y
EOF

cat <<-EOF | sudo unshare -mpf bash -e -
sudo mount --bind /dev ./voidwsl-musl/dev
sudo mount --bind /proc ./voidwsl-musl/proc
sudo mount --bind /sys ./voidwsl-musl/sys
sudo echo 'nameserver 1.1.1.1' >> ./voidwsl-musl/etc/resolv.conf

sudo chroot ./voidwsl-musl xbps-install -S
sudo chroot ./voidwsl-musl xbps-install -u -y xbps
sudo chroot ./voidwsl-musl xbps-install bash sudo shadow -y
EOF

cd ./voidwsl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../void-glibc-$ARCH.wsl

cd ./voidwsl-musl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../void-musl-$ARCH.wsl