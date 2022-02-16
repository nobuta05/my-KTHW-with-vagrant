#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

# 0. 以下で作成されるconfigファイルはLBに配備される(?)

# 1. k8sクラスタの設定作成とkubeconfigファイルの生成
# このconfigファイル自体はクライアントが保有する
# よって格納される情報は主に以下の通り
# * 接続先
# * 認証局の証明書
kubectl config set-cluster nobuta05-k8s \
  \ # 認証局の証明書(not 秘密鍵)
  --certificate-authority="./certificates/ca.pem" \
  \ # 証明書をconfigファイル内に埋め込む
  --embed-certs=true \
  \ # k8sクラスタのエンドポイント
  --server=https://192.168.199.10:6443 \
  \ # configファイルの出力先
  --kubeconfig="./config/kube-proxy.kubeconfig"

# 2. k8sクラスタへ接続するクライアント情報をconfigファイルへ追加
# (要確認) k8sクラスタ側は、以下のクライアントのauthenticationをどのように行っているか
kubectl config set-credentials kube-proxy \
  --client-certificate="./"
