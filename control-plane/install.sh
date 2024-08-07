#!/usr/bin/env bash

set -eEuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive

gateway=$1
ip_address=$2

apt-get update
apt-get upgrade -y

apt-get install -y --no-install-recommends \
  curl screen htop cron

curl -sSLf https://get.k0s.sh | K0S_VERSION=v1.29.6+k0s.0 sh

echo """
# k0smopolitan
network:
  ethernets:
    ens18:
      addresses:
        - ${ip_address}/24
      routes:
        - to: default
          via: ${gateway}
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
  version: 2
""" > /etc/netplan/50-cloud-init.yaml

printf "@reboot screen -dmS k0s bash -l -c '/root/k0smopolitan/control-plane/start.sh'\n" | crontab


rm -rf /etc/k0s
rm -rf /var/lib/k0s

if [[ -f /tmp/kubeconfig ]]; then
  rm -rf /tmp/kubeconfig
fi
if [[ -f /tmp/jointoken ]]; then
  rm -rf /tmp/jointoken
fi

reboot
