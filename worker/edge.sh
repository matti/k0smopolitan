#!/usr/bin/env bash

set -eEuo pipefail
set -x

cd /root/k0smopolitan

until git pull ; do
  echo "still waiting for git pull..."
  sleep 1
done

exec /root/k0smopolitan/worker/start.sh
