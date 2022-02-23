#!/bin/bash
set -euo pipefail

originDir=$(pwd)
dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd ${dir}/../

# 各agentのkube-proxyで利用するために配備される

## 1. k8sクラスタの設定作成とkubeconfigファイルの生成
##    このconfigファイル自体はクライアントが保有する
##    よって格納される情報は主に以下の通り
##    * 接続先
##    * 認証局の証明書

# 認証局の証明書(not 秘密鍵)
# 証明書をconfigファイル内に埋め込む
# k8sクラスタのエンドポイント
# configファイルの出力先
kubectl config set-cluster nobuta05-k8s \
  --certificate-authority="./certificates/ca.pem" \
  --embed-certs=true \
  --server=https://192.168.199.10:6443 \
  --kubeconfig="./config/kube-proxy.kubeconfig"

## 2. k8sクラスタへ接続するクライアント情報をconfigファイルへ追加
##    (要確認) k8sクラスタ側は、以下のクライアントのauthenticationをどのように行っているか
##    仮説: 認証局の署名がある証明書を持っているクライアントは認証
kubectl config set-credentials kube-proxy \
  --client-certificate="./certificates/kube-proxy.pem" \
  --client-key="./certificates/kube-proxy-key.pem" \
  --embed-certs=true \
  --kubeconfig="./config/kube-proxy.kubeconfig"

## 3. configファイルにコンテキストを設定
##    * username
kubectl config set-context default \
  --cluster=nobuta05-k8s \
  --user=kube-proxy \
  --kubeconfig="./config/kube-proxy.kubeconfig"

## 4. 現在のコンテキストをkubeconfigファイルに設定
kubectl config use-context default \
  --kubeconfig="./config/kube-proxy.kubeconfig"


#-------------------------------------------------------

# agent毎にkubeconfigファイル生成
# 恐らくagent毎のkubectlで使うために利用する
for n in {0..1}; do
  kubectl config set-cluster nobuta05-k8s \
    --certificate-authority="./certificates/ca.pem" \
    --embed-certs=true \
    --server=https://192.168.199.10:6443 \
    --kubeconfig="./config/agent-${n}.kubeconfig"
  
  kubectl config set-credentials  system:node:agent-${n} \
    --client-certificate="./certificates/agent-${n}.pem" \
    --client-key="./certificates/agent-${n}-key.pem" \
    --embed-certs=true \
    --kubeconfig="./config/agent-${n}.kubeconfig"
  
  kubectl config set-context default \
    --cluster=nobuta05-k8s \
    --user=system:node:agent-${n} \
    --kubeconfig="./config/agent-${n}.kubeconfig"
  
  kubectl config use-context default \
    --kubeconfig="./config/agent-${n}.kubeconfig"

done

#-------------------------------------------------------

# kube-controller-manager用にkubeconfigファイル生成
kubectl config set-cluster nobuta05-k8s \
  --certificate-authority="./certificates/ca.pem" \
  --embed-certs=true \
  --server=https://192.168.199.10:6443 \
  --kubeconfig="./config/kube-controller-manager.kubeconfig"

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate="./certificates/kube-controller-manager.pem" \
  --client-key="./certificates/kube-controller-manager-key.pem" \
  --embed-certs=true \
  --kubeconfig="./config/kube-controller-manager.kubeconfig"

kubectl config set-context default \
  --cluster=nobuta05-k8s \
  --user=system:kube-controller-manager \
  --kubeconfig="./config/kube-controller-manager.kubeconfig"

kubectl config use-context default \
  --kubeconfig="./config/kube-controller-manager.kubeconfig"

#-------------------------------------------------------

# kube-scheduler用のkubeconfigファイル生成
kubectl config set-cluster nobuta05-k8s \
  --certificate-authority="./certificates/ca.pem" \
  --embed-certs=true \
  --server=https://192.168.199.10:6443 \
  --kubeconfig="./config/kube-scheduler.kubeconfig"

kubectl config set-credentials system:kube-scheduler \
  --client-certificate="./certificates/kube-scheduler.pem" \
  --client-key="./certificates/kube-scheduler-key.pem" \
  --embed-certs=true \
  --kubeconfig="./config/kube-scheduler.kubeconfig"

kubectl config set-context default \
  --cluster=nobuta05-k8s \
  --user=system:kube-scheduler \
  --kubeconfig="./config/kube-scheduler.kubeconfig"

kubectl config use-context default \
  --kubeconfig="./config/kube-scheduler.kubeconfig"

#-------------------------------------------------------

# admin用のkubeconfigファイル生成
kubectl config set-cluster nobuta05-k8s \
  --certificate-authority="./certificates/ca.pem" \
  --embed-certs=true \
  --server=https://192.168.199.40:6443
#   --kubeconfig="./config/admin.kubeconfig"

kubectl config set-credentials admin \
  --client-certificate="./certificates/admin.pem" \
  --client-key="./certificates/admin-key.pem"
#   --kubeconfig="./config/admin.kubeconfig"

kubectl config set-context k8s-the-hard-way \
  --cluster=nobuta05-k8s \
  --user=admin
#   --kubeconfig="./config/admin.kubeconfig"

kubectl config use-context k8s-the-hard-way
#   --kubeconfig="./config/admin.kubeconfig"

cd ${originDir}