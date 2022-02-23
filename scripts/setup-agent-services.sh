#!/bin/bash
# set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

for n in {0..1}; do
  cat <<EOF | vagrant ssh "agent-${n}" -- sudo bash

yes | pacman -S socat gpgme conntrack-tools cri-o kubectl kubelet kube-proxy

mkdir -p \
  /etc/containers \
  /etc/cni/net.d \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/k8s

cp /vagrant/config/\$(hostname)-10-bridge.conf /etc/cni/net.d/10-bridge.conf

cp /vagrant/config/registries.conf /etc/containers/
cp /vagrant/config/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

cp /vagrant/certificates/ca.pem /var/lib/k8s/
cp /vagrant/certificates/\$(hostname).pem /vagrant/certificates/\$(hostname)-key.pem /var/lib/kubelet/
cp /vagrant/config/\$(hostname).kubeconfig /var/lib/kubelet/kubeconfig
cp /vagrant/config/\$(hostname)-kubelet-config /var/lib/kubelet/kubelet-config.yaml

cp /vagrant/config/\$(hostname)-kubelet.service /etc/systemd/system/kubelet.service
cp /vagrant/config/kube-proxy.service /etc/systemd/system/

systemctl daemon-reload
services="crio kubelet kube-proxy"
systemctl enable \${services}
systemctl restart \${services}
EOF
done