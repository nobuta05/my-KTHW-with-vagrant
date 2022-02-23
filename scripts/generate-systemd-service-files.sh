#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

# for kube-API server
for n in {0..1}; do
  cat > "./config/server-${n}-kube-apiserver.service" <<EOF
[Unit]
Description=Kubernetes API Server

[Service]
ExecStart=kube-apiserver \\
  --advertise-address=192.168.199.1${n} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/k8s/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/k8s/ca.pem \\
  --etcd-certfile=/var/lib/k8s/k8s.pem \\
  --etcd-keyfile=/var/lib/k8s/k8s-key.pem \\
  --etcd-servers=https://192.168.199.10:2379,https://192.168.199.11:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/k8s/encrypt-config.yaml \\
  --kubelet-certificate-authority=/var/lib/k8s/ca.pem \\
  --kubelet-client-certificate=/var/lib/k8s/k8s.pem \\
  --kubelet-client-key=/var/lib/k8s/k8s-key.pem \\
  --runtime-config=api/all=true \\
  --service-account-key-file=/var/lib/k8s/ca-key.pem \\
  --service-account-signing-key-file=/var/lib/k8s/ca-key.pem \\
  --service-account-issuer=api \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/k8s/k8s.pem \\
  --tls-private-key-file=/var/lib/k8s/k8s-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done

#---------------------------------------------------------------

# for kube-controller-manager
for n in {0..1}; do
  cat > "./config/server-${n}-kube-controller-manager.service" <<EOF
[Unit]
Description=Kubernetes Controller Manager

[Service]
ExecStart=kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=nobuta-05-k8s \\
  --cluster-signing-cert-file=/var/lib/k8s/ca.pem \\
  --cluster-signing-key-file=/var/lib/k8s/ca-key.pem \\
  --kubeconfig=/var/lib/k8s/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/k8s/ca.pem \\
  --service-account-private-key-file=/var/lib/k8s/ca-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done

#---------------------------------------------------------------

# for etcd
for n in {0..1}; do
  cat > "./config/server-${n}-etcd.service" <<EOF
[Unit]
Description=etcd

[Service]
ExecStart=etcd \\
  --name server-${n} \\
  --cert-file=/etc/etcd/k8s.pem \\
  --key-file=/etc/etcd/k8s-key.pem \\
  --peer-cert-file=/etc/etcd/k8s.pem \\
  --peer-key-file=/etc/etcd/k8s-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://192.168.199.1${n}:2380 \\
  --listen-peer-urls https://192.168.199.1${n}:2380 \\
  --listen-client-urls https://192.168.199.1${n}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://192.168.199.1${n}:2379 \\
  --initial-cluster-token etcd-server-0 \\
  --initial-cluster server-0=https://192.168.199.10:2380,server-1=https://192.168.199.11:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done

#---------------------------------------------------------------

# for scheduler
for n in {0..2}; do
  cat > "./config/server-${n}-kube-scheduler.service" <<EOF

[Unit]
Description="k8s scheduler

[Service]
ExecStart=kube-scheduler \\
  --leader-elect=true \\
  --kubeconfig=/var/lib/k8s/kube-scheduler.kubeconfig \\
  --v=2

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done

cd ${originDir}
