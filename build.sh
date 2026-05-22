#!/bin/sh
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH=amd64 ;;
    amd64) ARCH=amd64 ;;
    aarch64) ARCH=arm64 ;;
    arm64) ARCH=arm64 ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
echo "ARCH=$ARCH" >> "$GITHUB_OUTPUT"

# Fetch image manifest
manifest1=$(docker manifest inspect ghcr.io/void-linux/void-musl:latest)
manifest2=$(docker manifest inspect ghcr.io/void-linux/void-glibc:latest)
# Fetch image digest
digest1=$(echo "$manifest1" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
digest2=$(echo "$manifest2" | jq -r ".manifests[] | select(.platform.architecture == \"$ARCH\") | .digest")
# Pull and Export image
docker pull "ghcr.io/void-linux/void-musl:latest@${digest1}"
ocker pull "ghcr.io/void-linux/void-glibc:latest@${digest2}"
docker export $(docker create "ghcr.io/void-linux/void-musl:latest@${digest1}") | xz -T 0 > "$GITHUB_WORKSPACE/void.tar.xz"
docker export $(docker create "ghcr.io/void-linux/void-glibc:latest@${digest2}") | xz -T 0 > "$GITHUB_WORKSPACE/void-musl.tar.xz"
# start build
mkdir -p ./voidwsl
mkdir -p ./voidwsl-musl
sudo tar -xJpf void.tar.xz -C ./voidwsl
sudo tar -xJpf void-musl.tar.xz -C ./voidwsl-musl 
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
cd ..

cd ./voidwsl-musl
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../void-musl-$ARCH.wsl