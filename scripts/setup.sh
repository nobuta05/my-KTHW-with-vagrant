#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

source ./scripts/distclean.sh
source ./scripts/generate-certs.sh
source ./scripts/generate-kubeconfig.sh
source ./scripts/generate-cni-config.sh
source ./scripts/generate-systemd-service-files.sh
source ./scripts/generate-kubelet-files.sh

vagrant up --parallel

source ./scripts/setup-etcd.sh
source ./scripts/setup-controller-services.sh

# "Unable to connect to the server: x509: certificate signed by unknown authority"
# というエラーが出るが、何度か試すと通ることがある。
vagrant reload

source ./scripts/setup-kubelet-api-cluster-role.sh
source ./scripts/setup-agent-services.sh

vagrant reload
