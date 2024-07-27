#!/usr/bin/env bash

set -eEuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install -y --no-install-recommends \
  curl screen htop cron

if [[ ! -f /usr/local/bin/k0s ]]; then
  curl -sSLf https://get.k0s.sh | K0S_VERSION=v1.29.6+k0s.0 sh
fi

mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml
k0s install controller -c /etc/k0s/k0s.yaml

k0s start

echo "Waiting for k0s to start..."
until k0s kubectl get nodes; do
  echo "still waiting for k0s to start..."
  sleep 1
done

if [[ ! -f /root/jointoken ]]; then
  k0s token create --role=worker > /root/jointoken
fi

k0s kubeconfig admin > /root/kubeconfig

echo "Applying k8s-unreachable-node-cleaner..."
while true; do
  k0s kubectl apply -f https://raw.githubusercontent.com/matti/k8s-unreachable-node-cleaner/ced02131ff34d4c721f93deb6ce65c0d7a9ccca9/k8s/all.yml && break

  echo "retrying apply of k8s-unreachable-node-cleaner..."
  sleep 1
done
