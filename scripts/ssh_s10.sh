#!/bin/bash
# SSH to S10 Lite Termux via Tailscale proxy. Usage: ssh_s10.sh <remote command>
exec ssh -i /home/hatch/.ssh/id_ed25519 -p 8022 \
  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
  -o ConnectTimeout=15 -o BatchMode=yes \
  -o ProxyCommand='python3 ~/workspace/proxy_connect.py %h %p' \
  test@s10-lite-de-tutti "$@"
