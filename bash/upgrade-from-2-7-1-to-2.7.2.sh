#!/bin/bash

. bash/common.sh


eval $(minikube docker-env)

docker build \
	-t pybossa:2.7.2 \
	--build-arg PYBOSSA_VERSION=2.7.2 \
       	docker/pybossa

POLLER_PID=$(run_poller upgrade-from-2-7-1-to-2-7-2)

kubectl apply -f kube/deployments/pybossa-webservers.yml
kubectl apply -f kube/deployments/pybossa-workers.yml
kubectl apply -f kube/deployments/pybossa-rqscheduler.yml
kubectl rollout status deploy/pybossa-webservers

kill $POLLER_PID

