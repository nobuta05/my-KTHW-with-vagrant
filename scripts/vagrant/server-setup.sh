#!/bin/bash
set -euo pipefail

echo "[START] In server"
pacman -S \
  kube-apiserver kube-controller-manager kube-scheduler \
  --noconfirm

ETCD_VER=v3.5.2

curl \
  -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
  -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

mkdir -p /tmp/etcd-${ETCD_VER}-linux-amd64
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz \
  -C /tmp/etcd-${ETCD_VER}-linux-amd64/ \
  --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/