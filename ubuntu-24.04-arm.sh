#!/bin/bash
# run me as root
set -e

tmpdir=$(pwd)/build/ubuntu-24.04-arm

if [[ ! -d $tmpdir ]]; then
    mkdir -p $tmpdir
    debootstrap --arch=arm64 --variant=minbase noble $tmpdir http://ports.ubuntu.com/
fi

echo "ubuntu-24.04" > $tmpdir/etc/hostname
echo "root:root" | chroot $tmpdir chpasswd

chroot "$tmpdir" apt update
chroot "$tmpdir" apt install -y systemd systemd-sysv sudo iproute2 openssh-server
mkdir -p "$tmpdir/etc/systemd/network"

rm -rf "$tmpdir/dev"/*
mkdir -p "$tmpdir/dev" "$tmpdir/proc" "$tmpdir/sys" "$tmpdir/run"
chmod 755 "$tmpdir/dev"

rm -f "$tmpdir/etc/machine-id"
: > "$tmpdir/etc/machine-id"
rm -f "$tmpdir/etc/ssh/ssh_host_"* 2>/dev/null || true

tar --numeric-owner -cpf ubuntu-24.04-arm64-matt.tar -C $tmpdir .
xz -T0 ubuntu-24.04-arm64-matt.tar