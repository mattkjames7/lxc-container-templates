#!/bin/bash
# run me as root
set -e

BUILD_DIR=${1:-$(pwd)/build}
BUILD_DIR=$BUILD_DIR/ubuntu-24.04

if [[ ! -d $BUILD_DIR ]]; then
    mkdir -p $BUILD_DIR
    debootstrap --arch=amd64 --variant=minbase noble $BUILD_DIR http://archive.ubuntu.com/ubuntu/
fi

echo "ubuntu-24.04" > $BUILD_DIR/etc/hostname
echo "root:root" | chroot $BUILD_DIR chpasswd

chroot "$BUILD_DIR" apt update
chroot "$BUILD_DIR" apt install -y systemd systemd-sysv sudo iproute2 openssh-server
mkdir -p "$BUILD_DIR/etc/systemd/network"

rm -rf "$BUILD_DIR/dev"/*
mkdir -p "$BUILD_DIR/dev" "$BUILD_DIR/proc" "$BUILD_DIR/sys" "$BUILD_DIR/run"
chmod 755 "$BUILD_DIR/dev"

rm -f "$BUILD_DIR/etc/machine-id"
: > "$BUILD_DIR/etc/machine-id"
rm -f "$BUILD_DIR/etc/ssh/ssh_host_"* 2>/dev/null || true

filename="ubuntu-24.04-amd64-$(date +%Y%m%d%H%M%S).tar"
tar --numeric-owner -cpf "$filename" -C $BUILD_DIR .
xz -T0 "$filename"
