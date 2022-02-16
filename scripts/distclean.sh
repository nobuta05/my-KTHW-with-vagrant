#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

rm -rfv ./certificates/*.pem
rm -rfv ./certificates/*.csr

cd ${originDir}