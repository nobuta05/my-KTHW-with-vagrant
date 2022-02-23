#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

for n in {0..1}; do
  cat <<EOF | vagrant ssh "server-${n}" -- sudo bash

mkdir -p /etc/etcd /var/lib/etcd

cp \
  /vagrant/certificates/ca.pem \
  /vagrant/certificates/k8s.pem \
  /vagrant/certificates/k8s-key.pem \
  /etc/etcd/

cp \
  "/vagrant/config/\$(hostname)-etcd.service" \
  /etc/systemd/system/etcd.service

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
EOF
done