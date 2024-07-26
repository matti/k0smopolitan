#!/usr/bin/env bash

set -eEuo pipefail

if [[ ! -d /etc/k0s ]]; then
  mkdir /etc/k0s
  k0s config create > /etc/k0s/k0s.yaml
fi

(
  echo "Waiting for k0s to start..."
  until k0s kubectl get nodes; do
    echo "still waiting for k0s to start..."
    sleep 1
  done

  if [[ ! -f /tmp/jointoken ]]; then
    k0s token create --role=worker > /tmp/jointoken
  fi

  k0s kubeconfig admin > /tmp/kubeconfig

  echo "Applying k8s-unreachable-node-cleaner..."
  while true; do
    k0s kubectl apply -f https://raw.githubusercontent.com/matti/k8s-unreachable-node-cleaner/57aef714ae20489469ac332c2c44852cd501824f/k8s/all.yml && break

    echo "retrying apply of k8s-unreachable-node-cleaner..."
    sleep 1
  done
) &

exec k0s controller --config=/etc/k0s/k0s.yaml
