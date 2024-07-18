#!/usr/bin/env bash

set -eEuo pipefail
set -x

ip_address="$(hostname -I | cut -d' ' -f1)"

hostname_now=$(date +"%Y-%m-%d-%H-%M-%S")
hostname_ipaddress="${ip_address//./-}"

hostnamectl set-hostname "${hostname_now}-${hostname_ipaddress}"

until [[ -f "$HOME/jointoken" ]] do
  echo "still waiting for jointoken..."
  sleep 1
done

exec k0s worker --token-file="$HOME/jointoken"
