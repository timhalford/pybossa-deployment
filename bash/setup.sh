#!/bin/bash

set -e
set -x

eval $(minikube docker-env)

docker build \
	-t redis-sentinel:3.2.0 \
	docker/redis-sentinel

kubectl apply -f kube/persistent-volume-claims/postgres-master-db.yml

kubectl apply -f kube/deployments/redis-master.yml
kubectl apply -f kube/deployments/redis-sentinel.yml
kubectl apply -f kube/deployments/postgres-master.yml

kubectl apply -f kube/services/redis-master.yml
kubectl apply -f kube/services/redis-sentinel.yml
kubectl apply -f kube/services/postgres-master.yml

while true; do
	if test "$(kubectl get deployment postgres-master -o jsonpath='{.status.readyReplicas}')" == "1"; then
		break;
	fi
	sleep 1
done
sleep 5

cat data/pybossa.sql |
	kubectl run \
		--restart=Never \
		--env='PGPASSWORD=postgres' \
		--rm \
	       	-i \
	       	--image=postgres:9.6 \
	       	postgres-master-restore \
	       	-- \
	       	psql -U postgres -h postgres-master -d postgres

