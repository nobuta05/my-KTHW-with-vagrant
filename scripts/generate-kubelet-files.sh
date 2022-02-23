#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../


# kubelet config files
for n in {0..1}; do
  cat > "./config/agent-${n}-kubelet-config" <<EOF

kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/k8s/ca.pem"
authorization:
  mode: Webhook
cgroupDriver: systemd
clusterDomain: "cluster.local"
clusterDNS:
- "10.32.0.10"
podCIDR: "10.2${n}.0.0/16"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "10m"
tlsCertFile: "/var/lib/kubelet/agent-${n}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/agent-${n}-key.pem"
EOF
done

#----------------------------------------------------------------
# kubelet service file
for n in {0..1}; do
  cat > "./config/agent-${n}-kubelet.service" <<EOF
[Unit]
Description=k8s kubelet
After=crio.service
Requires=crio.service

# --image-pull-progress-deadline=2m \\
# --network-plugin=cni \\
# --register-node=true \\
# --runtime-request-timeout=5m \\
[Service]
ExecStart=kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/crio/crio.sock \\
  --image-service-endpoint=unix:///var/run/crio/crio.sock \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done

cd ${originDir}