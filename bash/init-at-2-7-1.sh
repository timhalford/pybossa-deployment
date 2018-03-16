#!/bin/bash

. bash/common.sh

eval $(minikube docker-env)

docker build \
	-t pybossa:2.7.1 \
	--build-arg PYBOSSA_VERSION=2.7.1 \
       	docker/pybossa

kubectl apply -f kube/persistent-volume-claims/pybossa-uploads.yml

kubectl apply -f kube/deployments/pybossa-webservers.yml
kubectl apply -f kube/deployments/pybossa-workers.yml
kubectl apply -f kube/deployments/pybossa-rqscheduler.yml

kubectl apply -f kube/services/pybossa-webservers.yml

PYBOSSA_URL=$(pybossa_url)
echo -e "\nPyBossa running at ${PYBOSSA_URL}\n"

