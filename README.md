# Coworking Space Service Extension
## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup
#### 1. Create cluster

1. 
```bash
eksctl create cluster --name my-eks-cluster --version 1.30 --region us-east-1 --nodegroup-name my-eks-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
```

2. 
```
aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster
kubectl config current-context
kubectl cluster-info
```
#### 2. Setup DB for postgresql-service pod

1. 
```bash
kubectl get namespace
kubectl get storageclass

NAME   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2    kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  17m

kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml
kubectl get pods

kubectl exec -it postgresql-77d75d45d5-rpl6s -- bash
psql -U myuser -d mydatabase
    Name    | Owner  | Encoding | Locale Provider |  Collate   |   Ctype    | ICU Locale | ICU Rules | Access privileges
------------+--------+----------+-----------------+------------+------------+------------+-----------+-------------------
 mydatabase | myuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           |
 postgres   | myuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           |
 template0  | myuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/myuser        +
            |        |          |                 |            |            |            |           | myuser=CTc/myuser
 template1  | myuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/myuser        +
            |        |          |                 |            |            |            |           | myuser=CTc/myuser
(4 rows)

\q and exit - exit 

kubectl apply -f postgresql-service.yaml

kubectl get svc

kubectl describe svc <DATABASE_SERVICE_NAME>.
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes           ClusterIP   10.100.0.1       <none>        443/TCP    25m
postgresql-service   ClusterIP   10.100.138.163   <none>        5432/TCP   3m41s

```

2. Deploy seed files
```
$ kubectl cp 1_create_tables.sql postgresql-77d75d45d5-rpl6s:/tmp/1_create_tables.sql

$ kubectl exec -it postgresql-77d75d45d5-rpl6s -- bash
root@postgresql-77d75d45d5-rpl6s:/# psql --host=postgresql-service -U myuser -d mydatabase -p 5432 -f /tmp/1_create_tables.sql

```
3. Verifying The Application
* Generate report for check-ins grouped by dates
` curl a0cfefaaccd5a4d4aadeb693061f9fed-58466606.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage`

* Generate report for check-ins grouped by users
`$ curl a0cfefaaccd5a4d4aadeb693061f9fed-58466606.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits`