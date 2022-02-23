#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

for n in {0..2}; do
  cat > "./config/controller-${n}-kube-scheduler.service" <<EOF
[Unit]
Description=k8s scheduler

[Service]
ExecStart=kube-scheduler \\
  --leader-elect true \\
  --kubeconfig /var/lib/k8s/kube-scheduler.kubeconfig \\
  --v 2

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done