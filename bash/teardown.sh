#!/bin/bash

set -x

kubectl delete -f kube/services/redis-master.yml
kubectl delete -f kube/services/redis-sentinel.yml
kubectl delete -f kube/services/postgres-master.yml
kubectl delete -f kube/services/pybossa-webservers.yml

kubectl delete -f kube/deployments/redis-master.yml
kubectl delete -f kube/deployments/redis-sentinel.yml
kubectl delete -f kube/deployments/postgres-master.yml
kubectl delete -f kube/deployments/pybossa-webservers.yml
kubectl delete -f kube/deployments/pybossa-workers.yml
kubectl delete -f kube/deployments/pybossa-rqscheduler.yml

kubectl delete -f kube/persistent-volume-claims/postgres-master-db.yml
kubectl delete -f kube/persistent-volume-claims/pybossa-uploads.yml

