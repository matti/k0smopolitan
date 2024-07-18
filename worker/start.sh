#!/usr/bin/env bash

set -eEuo pipefail
set -x

ip_address="$(hostname -I | cut -d' ' -f1)"

hostname_now=$(date +"%Y-%m-%d-%H-%M-%S")
hostname_ipaddress="${ip_address//./-}"

hostnamectl set-hostname "${hostname_now}-${hostname_ipaddress}"

modprobe nbd max_part=8

rm -rf /mnt/ramdisks
mkdir -p /mnt/ramdisks

ramdisk_size_total_mb=$(( 12 * 1024 ))
ramdisk_size_usable_mb=$(( ramdisk_size_total_mb - 10 ))

mount -t tmpfs -o size="${ramdisk_size_total_mb}m" tmpfs /mnt/ramdisks
qemu-img create -o preallocation=full -f qcow2 /mnt/ramdisks/var-lib-k0s-containerd.qcow2 "${ramdisk_size_usable_mb}m"
qemu-nbd --connect=/dev/nbd0 /mnt/ramdisks/var-lib-k0s-containerd.qcow2

mkfs.ext4 /dev/nbd0

mkdir -p /var/lib/k0s/containerd
mount /dev/nbd0 /var/lib/k0s/containerd

until [[ -f "$HOME/jointoken" ]] do
  echo "still waiting for jointoken..."
  sleep 1
done

exec k0s worker --token-file="$HOME/jointoken"
