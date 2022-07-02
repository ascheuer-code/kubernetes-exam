#!/bin/bash

# FROM https://www.rabbitmq.com/kubernetes/operator/install-operator.html

## Installing RabbitMQ Cluster Operator in a Kubernetes Cluster ##

# The Operator requires
# Kubernetes 1.19 or above
# RabbitMQ DockerHub image 3.8.8+

kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

kubectl krew install rabbitmq #-> doesen work because if no krew installed

# Run this command to download and install krew:
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
#Add the $HOME/.krew/bin directory to your PATH environment variable. To do this, update your .bashrc or .zshrc file and append the following line:
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# The kubectl rabbitmq plugin provides commands for managing RabbitMQ clusters. The plugin can be installed using krew:

kubectl krew install rabbitmq

kubectl rabbitmq help

kubectl rabbitmq install-cluster-operator

# adding cluster operator to local registry

docker pull rabbitmqoperator/cluster-operator
docker tag rabbitmqoperator/cluster-operator localhost:5000/rabbitmqoperator
docker push localhost:5000/rabbitmqoperator
docker image remove rabbitmqoperator/cluster-operator



## Using RabbitMQ Cluster Kubernetes Operator ##

# FROM https://www.rabbitmq.com/kubernetes/operator/using-operator.html

#Before configuring your app to use RabbitMQ Cluster Kubernetes Operator, ensure that RabbitmqCluster Custom Resource is deployed to your Kubernetes cluster and is available.

kubectl get customresourcedefinitions.apiextensions.k8s.io

# Create a RabbitMQ Instance

# First, create a YAML file to define a RabbitmqCluster resource named rabbitmqcluster.yaml

touch rabbitmqcluster.yaml

echo "apiVersion: v1" >> rabbitmqcluster.yaml
echo "kind: ServiceAccount" >> rabbitmqcluster.yaml
echo "metadata:" >> rabbitmqcluster.yaml
echo "  name: rabbitmqcluster" >> rabbitmqcluster.yaml

# Next, apply the definition by running:

kubectl apply -f rabbitmqcluster.yaml

#Then verify that the process was successful by running:

kubectl get all -l app.kubernetes.io/name=rabbitmqcluster


# not essential cause of local registry

#Now update the Operator Service Account by running:

#kubectl -n rabbitmq-system patch serviceaccount \
#rabbitmq-cluster-operator -p '{"imagePullSecrets": [{"name": "rabbitmq-cluster-registry-access"}]}'

# get now your preffered configuration from the page above or use this one

echo "spec:" >> rabbitmqcluster.yaml
echo "  image: rabbitmq" >> rabbitmqcluster.yaml
echo "  replicas: 1" >> rabbitmqcluster.yaml
echo "  persistence:" >> rabbitmqcluster.yaml
echo "    storage: 2Gi" >> rabbitmqcluster.yaml
echo "  service:" >> rabbitmqcluster.yaml
echo "    type: LoadBalancer" >> rabbitmqcluster.yaml
echo "  resources:" >> rabbitmqcluster.yaml
echo "    requests:" >> rabbitmqcluster.yaml
echo "      cpu: 800m" >> rabbitmqcluster.yaml
echo "      memory: 300Mi" >> rabbitmqcluster.yaml
echo "    limits:" >> rabbitmqcluster.yaml
echo "      cpu: 1000m" >> rabbitmqcluster.yaml
echo "      memory: 800Mi" >> rabbitmqcluster.yaml

## RabbitMQ Cluster Kubernetes Operator Quickstart ##

# FROM https://www.rabbitmq.com/kubernetes/operator/quickstart-operator.html

# Next, let's access the Management UI.

username="$(kubectl get secret rabbitmqcluster-default-user -o jsonpath='{.data.username}' | base64 --decode)"
echo "username: $username"
password="$(kubectl get secret rabbitmqcluster-default-user -o jsonpath='{.data.password}' | base64 --decode)"
echo "password: $password"

kubectl port-forward "service/hello-world" 15672

# now open a browser to http://localhost:15672 and use the credentials that are printed

# Using the kubectl rabbitmq plugin, the Management UI can be accessed using:

# dosent work -> kubectl rabbitmq manage rabbitmqcluster




## Connect An Application To The Cluster ##

# The next step would be to connect an application to the RabbitMQ Cluster in order to use its messaging capabilities. The perf-test application is frequently used within the RabbitMQ community for load testing RabbitMQ Clusters.

# FROM https://github.com/rabbitmq/rabbitmq-perf-test

username="$(kubectl get secret rabbitmqcluster-default-user -o jsonpath='{.data.username}' | base64 --decode)"
password="$(kubectl get secret rabbitmqcluster-default-user -o jsonpath='{.data.password}' | base64 --decode)"
service="$(kubectl get service rabbitmqcluster -o jsonpath='{.spec.clusterIP}')"
kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri amqp://$username:$password@$service

# These steps are automated in the kubectl rabbitmq plugin which may simply be run as:

#  unknown command dunno why ->kubectl rabbitmq perf-test rabbitmqcluster

# We can now view the perf-test logs by running:

kubectl logs --follow perf-test

# done for today at https://www.rabbitmq.com/kubernetes/operator/quickstart-operator.html 
# Next Steps could be interresting

