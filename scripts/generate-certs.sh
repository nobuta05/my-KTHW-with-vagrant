#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../certificates

# Question
# 認証局によって署名されたクライアント証明書が存在することと
# k8sクラスタがアクセスを認めていること、
# この2つは同値と考えてよいのか

# 1. 認証局自身の証明書生成
# 証明書署名要求ファイル(csr-info.json)から
# 認証局の鍵を生成
# -bare のパラメタとして "ca" を与えることで
# 生成物のprefixにcaが付与
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# 2. admin userのクライアント証明書生成
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=k8s \
  admin-csr.json | cfssljson -bare admin

# 3. agent(kubelet in worker nodes)のクライアント証明書生成
for n in {0..1}; do
  cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=k8s \
    "agent-${n}-csr.json" | cfssljson -bare "agent-${n}"
done

# 4. kube-controler-managerのクライアント証明書生成
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=k8s \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

# 5. kube-proxy(各nodeで動作しk8s関連のネットワーク制御を管理するプロセス)の
#    クライアント証明書作成
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=k8s \
   kube-proxy-csr.json | cfssljson -bare kube-proxy

# 6. kube-schedulerのクライアント証明書生成
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=k8s \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

# 7. API server <-> etcd のための証明書作成
##   要確認: 192.168.199.40が必要か
##   要確認: API server <-> kubectl のための
##          クライアント証明書としても使われているっぽい？
##          systemd file for api-serverを見ると、
##          etcdとkubectlの2箇所でk8s.pemが使われている
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=k8s \
  -hostname=192.168.199.40,192.168.199.10,192.168.199.11,127.0.0.1,kubernetes.default \
  k8s-csr.json | cfssljson -bare k8s



cd ${originDir}