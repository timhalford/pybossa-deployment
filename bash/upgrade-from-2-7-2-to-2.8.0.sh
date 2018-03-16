#!/bin/bash

set -x

. bash/common.sh


eval $(minikube docker-env)

docker build \
	-t pybossa:2.8.0 \
	--build-arg PYBOSSA_VERSION=2.8.0 \
       	docker/pybossa

POLLER_PID=$(run_poller upgrade-from-2-7-2-to-2-8-0 /api/helpingmaterial)

kubectl create -f kube/jobs/pybossa-migration-2-8-0.yml
while true; do
	MIGRATION_STATUS=$(kubectl get jobs pybossa-migration -o jsonpath='{.status.conditions[0].type}')
	test ! -z "$MIGRATION_STATUS" && break
	sleep 1
done

if test $MIGRATION_STATUS = "Complete"; then
	kubectl delete job pybossa-migration
	kubectl apply -f kube/deployments/pybossa-webservers.yml
	kubectl apply -f kube/deployments/pybossa-workers.yml
	kubectl apply -f kube/deployments/pybossa-rqscheduler.yml
	kubectl rollout status deploy/pybossa-webservers
else
	echo "Deployment failed due to migration failure"
fi


kill $POLLER_PID

