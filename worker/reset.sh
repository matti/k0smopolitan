#!/usr/bin/env bash

set -eEuo pipefail
set -x

rm -rf /etc/k0s
rm -rf /var/lib/k0s

if [[ -f /tmp/kubeconfig ]]; then
  rm -rf /tmp/kubeconfig
fi
if [[ -f /tmp/jointoken ]]; then
  rm -rf /tmp/jointoken
fi
