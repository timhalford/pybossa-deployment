#!/bin/bash

. bash/common.sh


eval $(minikube docker-env)

docker build \
	        -t pybossa:2.8.0 \
		        --build-arg PYBOSSA_VERSION=2.8.0 \
			        docker/pybossa

POLLER_PID=$(run_poller failing-upgrade-from-2-7-2-to-2-8-0 /api/helpingmaterial)

kubectl apply -f kube/deployments/pybossa-webservers.yml
kubectl apply -f kube/deployments/pybossa-workers.yml
kubectl apply -f kube/deployments/pybossa-rqscheduler.yml
kubectl rollout status deploy/pybossa-webservers

kill $POLLER_PID

