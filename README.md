# Upgrading PyBossa With Minimal Downtime

## Demo
This demo will walkthrough the deployment of PyBossa upgrades, including database migrations, on Kubernetes, with an emphasis on minimizing downtime.

The deployment uses an insecure and minimal configuration of PyBossa with features such as caching disabled for simplicity.

You are encouraged to run this demo on the Virtual Machine provided, which has been provisioned with the demo system dependencies and where the Docker images have been prebuilt. This repo has been cloned to `~/pybossa-deployment`.

### System Dependenciess
* Minikube (tested with v0.25.0)
* Docker (tested with 17.10.0-ce)

### Setup & Teardown

Minikube must be running with Kubernetes version 1.8.0. If you are on the provided Virtual Machine, Minkube has already been started and you can ignore this step.

To setup the project run:
```bash
bash/setup.sh
```
This will:
* Build Docker images and create Kubernetes components for pyBossa service dependencies.
* Populate the PyBossa database with a sample project and task runs.

To teardown the project run:
```bash
bash/teardown.sh
```

Which will delete the Kubernetes components created throughout the demo.


### Step 1: Initializing PyBossa at version 2.7.1
Run:
```bash
git checkout v2.7.1
bash/init-at-2-7-1.sh
```

PyBossa 2.7.1 will be our staring point for upgrading. The command will print out the PyBossa URL for inspection.

### Step 2: Upgrading PyBossa to version 2.7.2
This is a simple upgrade that does not require a database migration.

Run a successful upgrade:
```bash
git checkout v2.7.2
bash/upgrade-from-2-7-1-to-2-7-2.sh
```
 A log of response codes for requests made to the home page during the deployment can be found at `logs/upgrade-from-2-7-1-to-2-7-2.log`. Kubernetes will do a rolling deployment, so the response codes should all be 200.

### Step 3: Upgrading PyBossa to version 2.8.0
A slighly more advanced upgrade that requires a database migration that will not affect the running previous version.

Run a failing upgrade with no database migration:
```bash
git checkout v2.8.0
bash/failing-upgrade-from-2-7-2-to-2-8-0.sh
```
A log of response codes for requests to the helpingmaterial API endpoint, the target of the migration, can be found at `logs/failing-upgrade-from-2-7-2-to-2-8-0.log`. The rollout will not complete due to the helpingingmaterial API endpoint returning error status codes and will be rolled back within 45 seconds. The response codes in the log file should all be 200.

Run a successful upgrade with the database migration before the rollout:
```bash
git checkout v2.8.0
bash/upgrade-from-2-7-2-to-2-8-0.sh
```

A log of response codes for requests to the helpingmaterial API endpoint, the target of the migration, can be found at `logs/upgrade-from-2-7-2-to-2-8-0.log`. The migration is made before the rollout, with the latter not happening if the former fails. The response codes shoud all be 200.

## Considerations

### Persistence
* Postgres - Use highly available & durable network block storage persistent volumes, either from a cloud provider (such as AWS EBS) or running on the Kubernetes cluster (such as Ceph Block Device) and maintain regular database backups incase of human error. Alternatively the database could be an external service to the cluster, managed by a cloud provider (such as AWS RDS)
* PyBossa Uploads - Use highly available & durable network file system persistent volumes, either from a cloud provider (such as AWS EFS) or running on the kubernetes cluster(such as Ceph FS).

### Performance
* Monitor container resource consumption, and instances of memory overconsumption, through Kubernetes for all the deployments in order to inform fine tuning of deployment and job container resources.

### Networking
* Use Kubernetes Service components for DNS based service discovery.
* Choose infrastructure that offers low-latency high bandwidth links between nodes in the Kubernetes cluster, and between the Kubernetes cluster and any external services, to minimize any performance loss due to lack of colocation of data and processing.

