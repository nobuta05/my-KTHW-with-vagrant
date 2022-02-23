#!/bin/bash

set -euo pipefail

echo "[START] In LB"

pacman -S haproxy --noconfirm

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
cat > /etc/haproxy/haproxy.cfg <<EOF

global
  log       /dev/log  local0
  log       /dev/log  local1 notice
  chroot    /usr/share/haproxy
  maxconn   20000
  user      haproxy
  group     haproxy
  pidfile   /run/haproxy.pid
  # stats     socket  /run/haproxy/admin.sock mode  660 level admin
  # stats     timeout 30s
  daemon

  ca-base   /etc/ssl/serts
  crt-base  /etc/ssl/private
  ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS
  ssl-default-bind-options no-sslv3


defaults
  log       global
  mode      tcp
  option    tcplog
  option    dontlognull
  timeout   connect 5000
  timeout   client  50000
  timeout   server  50000

frontend k8s
  bind              192.168.199.40:6443
  default_backend   k8s_backend

backend k8s_backend
  balance   roundrobin
  mode      tcp
  server    server-0    192.168.199.10:6443 check inter 1000
  server    server-1    192.168.199.11:6443 check inter 1000
  server    server-2    192.168.199.12:6443 check inter 1000

EOF

systemctl restart haproxy
