#!/bin/bash

set -e

BASE_DIR=$(dirname $(readlink -f $0))
KUBECTL=${BASE_DIR}/packages/kubectl
CERT_DIR=${BASE_DIR}/certs
CA=${CERT_DIR}/ca.pem
# TODO change this ip
KUBERNETES_PUBLIC_IP_ADDRESS={{ groups.master[0] }}
CLUSTER_NAME=kubernetes-the-hard-way

chmod +x $KUBECTL

# configure kubectl
$KUBECTL config set-cluster $CLUSTER_NAME \
  --certificate-authority=$CA \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_IP_ADDRESS}:6443

$KUBECTL config set-credentials admin --token chAng3m3

$KUBECTL config set-context default-context \
  --cluster=$CLUSTER_NAME \
  --user=admin

$KUBECTL config use-context default-context

# test connection to kubernetes cluster
$KUBECTL get componentstatuses
echo "" # empty line
$KUBECTL get nodes
