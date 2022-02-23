#!/bin/bash
# set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

for n in {0..1}; do
  cat <<EOF | vagrant ssh "server-${n}" -- sudo bash

mkdir -p /var/lib/k8s

cp \
  /vagrant/certificates/ca.pem \
  /vagrant/certificates/ca-key.pem \
  /vagrant/certificates/k8s.pem \
  /vagrant/certificates/k8s-key.pem \
  /vagrant/config/encrypt-config.yaml \
  /vagrant/config/kube-controller-manager.kubeconfig \
  /vagrant/config/kube-scheduler.kubeconfig \
  /var/lib/k8s/

cp \
  "/vagrant/config/\$(hostname)-kube-apiserver.service" \
  /etc/systemd/system/kube-apiserver.service

cp \
  "/vagrant/config/\$(hostname)-kube-scheduler.service" \
  /etc/systemd/system/kube-scheduler.service

cp \
  "/vagrant/config/\$(hostname)-kube-controller-manager.service" \
  /etc/systemd/system/kube-controller-manager.service

systemctl daemon-reload
services="kube-apiserver kube-scheduler kube-controller-manager"
systemctl enable \${services}
systemctl restart \${services}
EOF
done