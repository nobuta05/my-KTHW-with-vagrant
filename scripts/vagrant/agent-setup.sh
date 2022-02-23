#!/bin/bash
set -euo pipefail

echo "[START] In agent"
pacman -S net-tools --noconfirm

case "$(hostname)" in
agent-0)
  route add -net 10.21.0.0/16 gw 192.168.199.21
  route add -net 10.22.0.0/16 gw 192.168.199.22
  ;;
agent-1)
  route add -net 10.20.0.0/16 gw 192.168.199.20
  route add -net 10.22.0.0/16 gw 192.168.199.22
  ;;
agent-2)
  route add -net 10.20.0.0/16 gw 192.168.199.20
  route add -net 10.21.0.0/16 gw 192.168.199.21
  ;;
*)
  route add -net 10.20.0.0/16 gw 192.168.199.20
  route add -net 10.21.0.0/16 gw 192.168.199.21
  route add -net 10.22.0.0/16 gw 192.168.199.22
  ;;
esac

# swap off # ここらへんが正しく動作しているか要確認
swapoff -a
sed -i "s/^\/swap/## \/swap/g" /etc/fstab