#!/bin/bash

set -e

BASE_DIR=$(dirname $0)
export PATH=$PATH:$BASE_DIR/packages

PORT=9988
IP={{ groups.master[0] }}
NAME=test
IMAGE=testdemps/simple-http
NUM_REPLICAS=8
NUM_TESTS=1
CURL="curl --connect-timeout 1"

while getopts ":r:i:n:" o; do
    case "${o}" in
        r) NUM_REPLICAS=$OPTARG ;;
        i) IP=$OPTARG ;;
        n) NUM_TESTS=$OPTARG ;;
        *)
            echo unknown argument supplied 1>&2
			exit
            ;;
    esac
done

kubectl delete deployment,service $NAME || true

kubectl run $NAME --image=$IMAGE --port=$PORT --env="PORT=$PORT" --replicas=$NUM_REPLICAS
kubectl expose deployment $NAME --type NodePort

NODE_PORT=$(kubectl get svc $NAME --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
TEST_URL=http://${IP}:${NODE_PORT}

echo -e "\ntest URL: $TEST_URL\n"

while [ "$(kubectl get deployments | grep "^$NAME" | egrep -ow $NUM_REPLICAS | wc -w)" != 4 ];do
    echo -n "."
    sleep 1
done
echo -e "\nconnecting:\n"

for((i=0;i<$NUM_TESTS;i++)) {
    timeout 2 $CURL $TEST_URL
}

