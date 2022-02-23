#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

# CNI(Container Network Interface)の
# configファイル生成

for n in {0..1}; do
  cat > "./config/agent-${n}-10-bridge.conf" <<EOF
{
  "cniVersion": "0.3.1",
  "name": "crio",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "isMasq": true,
  "hairpinMode": true,
  "ipam": {
    "type": "host-local",
    "ranges": [
      [{"subnet": "10.2${n}.0.0/16"}]
    ],
    "routes": [{"dst": "0.0.0.0/0"}]
  }
}
EOF
done

cd ${originDir}