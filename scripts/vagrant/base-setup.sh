#!/bin/bash
set -euo pipefail


pacman -S which inetutils --noconfirm
/sbin/rcvboxadd quicksetup all


pacman -S pacman-contrib --noconfirm
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.bak
rankmirrors -n 6 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

pacman -Syyu --noconfirm



cat <<EOF | sudo tee -a /etc/hosts

# KTHW vagrant machines
192.168.199.10  server-0
192.168.199.11  server-1
192.168.199.12  server-2

192.168.199.20  agent-0
192.168.199.21  agent-1
192.168.199.22  agent-2
EOF

