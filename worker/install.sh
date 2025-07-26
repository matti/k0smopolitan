#!/usr/bin/env bash

set -eEuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install -y --no-install-recommends \
  curl screen htop cron qemu-utils

curl -sSLf https://get.k0s.sh | K0S_VERSION=v1.29.6+k0s.0 sh

printf "@reboot screen -dmS k0s bash -l -c '/root/k0smopolitan/worker/edge.sh'\n" | crontab

rm -rf /root/jointoken

reboot
