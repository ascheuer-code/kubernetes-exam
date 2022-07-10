#!/bin/bash

# FROM https://computingforgeeks.com/deploy-and-manage-minio-storage-on-kubernetes/

#Step 1 – Create a StorageClass with WaitForFirstConsumer Binding Mode.

touch storageClass.yaml

echo "kind: StorageClass" >> storageClass.yml
echo "apiVersion: storage.k8s.io/v1" >> storageClass.yml
echo "metadata:" >> storageClass.yml
echo "  name: my-local-storage" >> storageClass.yml
echo "provisioner: kubernetes.io/no-provisioner" >> storageClass.yml
echo "volumeBindingMode: WaitForFirstConsumer" >> storageClass.yml

#Create the pod.

kubectl create -f storageClass.yml

#Step 2 – Create Local Persistent Volume. geht net

touch minio-pv.yml

echo "apiVersion: v1" >> minio-pv.yml
echo "kind: PersistentVolume" >> minio-pv.yml
echo "metadata:" >> minio-pv.yml
echo "  name: my-local-pv" >> minio-pv.yml
echo "spec:" >> minio-pv.yml
echo "  resources:" >> minio-pv.yml
echo "    requests:" >> minio-pv.yml
echo "       storage: 1Gi" >> minio-pv.yml
echo "  accessModes:" >> minio-pv.yml
echo "  - ReadWriteMany" >> minio-pv.yml
echo "  persistentVolumeReclaimPolicy: Retain" >> minio-pv.yml
echo "  storageClassName: my-local-storage" >> minio-pv.yml
echo "  local:" >> minio-pv.yml
echo "    path: /mnt/disk/vol1" >> minio-pv.yml
echo "  nodeAffinity:" >> minio-pv.yml
echo "    required:" >> minio-pv.yml
echo "      nodeSelectorTerms:" >> minio-pv.yml
echo "      - matchExpressions:" >> minio-pv.yml
echo "        - key: kubernetes.io/hostname" >> minio-pv.yml
echo "          operator: In" >> minio-pv.yml
echo "          values:" >> minio-pv.yml
echo "          - minikube" >> minio-pv.yml

DIRNAME="vol1"
sudo mkdir -p /mnt/disk/$DIRNAME 
sudo chmod 777 /mnt/disk/$DIRNAME

# create pod 

 kubectl create -f minio-pv.yml

# Step 3 – Create a Persistent Volume Claim

touch minio-pvc.yml

echo "apiVersion: v1" >> minio-pvc.yml
echo "kind: PersistentVolumeClaim" >> minio-pvc.yml
echo "metadata:" >> minio-pvc.yml
echo "  # This name uniquely identifies the PVC. This is used in deployment." >> minio-pvc.yml
echo "  name: minio-pvc-claim" >> minio-pvc.yml
echo "spec:" >> minio-pvc.yml
echo "  # Read more about access modes here: http://kubernetes.io/docs/user-guide/persistent-volumes/#access-modes" >> minio-pvc.yml
echo "  storageClassName: my-local-storage" >> minio-pvc.yml
echo "  accessModes:" >> minio-pvc.yml
echo "    # The volume is mounted as read-write by Multiple nodes" >> minio-pvc.yml
echo "    - ReadWriteMany" >> minio-pvc.yml
echo "  resources:" >> minio-pvc.yml
echo "    # This is the request for storage. Should be available in the cluster." >> minio-pvc.yml
echo "    requests:" >> minio-pvc.yml
echo "      storage: 1G" >> minio-pvc.yml


kubectl create -f minio-pvc.yml

# Step 4 – Create the MinIO Pod

touch Minio-Dep.yml

echo "apiVersion: apps/v1" >> Minio-dep.yml
echo "kind: Deployment" >> Minio-dep.yml
echo "metadata:" >> Minio-dep.yml
echo "  # This name uniquely identifies the Deployment" >> Minio-dep.yml
echo "  name: minio" >> Minio-dep.yml
echo "spec:" >> Minio-dep.yml
echo "  selector:" >> Minio-dep.yml
echo "    matchLabels:" >> Minio-dep.yml
echo "      app: minio # has to match .spec.template.metadata.labels" >> Minio-dep.yml
echo "  strategy:" >> Minio-dep.yml
echo "    # Specifies the strategy used to replace old Pods by new ones" >> Minio-dep.yml
echo "    # Refer: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy" >> Minio-dep.yml
echo "    type: Recreate" >> Minio-deb.yml
echo "  template:" >> Minio-deb.yml
echo "    metadata:" >> Minio-deb.yml
echo "      labels:" >> Minio-deb.yml
echo "        # This label is used as a selector in Service definition">> Minio-deb.yml
echo "        app: minio">> Minio-deb.yml
echo "    spec:">> Minio-deb.yml
echo "      # Volumes used by this deployment">> Minio-deb.yml
echo "      volumes:">> Minio-deb.yml
echo "      - name: data">> Minio-deb.yml
echo "        # This volume is based on PVC">> Minio-deb.yml
echo "        persistentVolumeClaim:">> Minio-deb.yml
echo "          # Name of the PVC created earlier">> Minio-deb.yml
echo "          claimName: minio-pvc-claim">> Minio-deb.yml
echo "      containers:">> Minio-deb.yml
echo "      - name: minio">> Minio-deb.yml
echo "        # Volume mounts for this container">> Minio-deb.yml
echo "        volumeMounts:">> Minio-deb.yml
echo "        # Volume 'data' is mounted to path '/data'">> Minio-deb.yml
echo "        - name: data ">> Minio-deb.yml
echo "          mountPath: /data">> Minio-deb.yml
echo "        # Pulls the latest Minio image from Docker Hub">> Minio-deb.yml
echo "        image: minio/minio">> Minio-deb.yml
echo "        args:">> Minio-deb.yml
echo "        - server">> Minio-deb.yml
echo "        - /data">> Minio-deb.yml
echo "        env:">> Minio-deb.yml
echo "        # MinIO access key and secret key">> Minio-deb.yml
echo "        - name: MINIO_ACCESS_KEY">> Minio-deb.yml
echo "          value: "minio"">> Minio-deb.yml
echo "        - name: MINIO_SECRET_KEY">> Minio-deb.yml
echo "          value: "minio123"">> Minio-deb.yml
echo "        ports:">> Minio-deb.yml
echo "        - containerPort: 9000">> Minio-deb.yml
echo "        # Readiness probe detects situations when MinIO server instance">> Minio-deb.yml
echo "        # is not ready to accept traffic. Kubernetes doesn't forward">> Minio-deb.yml
echo "        # traffic to the pod while readiness checks fail.">> Minio-deb.yml
echo "        readinessProbe:">> Minio-deb.yml
echo "          httpGet:">> Minio-deb.yml
echo "            path: /minio/health/ready">> Minio-deb.yml
echo "            port: 9000">> Minio-deb.yml
echo "          initialDelaySeconds: 120">> Minio-deb.yml
echo "          periodSeconds: 20">> Minio-deb.yml
echo "        # Liveness probe detects situations where MinIO server instance">> Minio-deb.yml
echo "        # is not working properly and needs restart. Kubernetes automatically">> Minio-deb.yml
echo "        # restarts the pods if liveness checks fail.">> Minio-deb.yml
echo "        livenessProbe:">> Minio-deb.yml
echo "          httpGet:">> Minio-deb.yml
echo "            path: /minio/health/live">> Minio-deb.yml
echo "            port: 9000">> Minio-deb.yml
echo "          initialDelaySeconds: 120">> Minio-deb.yml
echo "          periodSeconds: 20">> Minio-deb.yml

#apply config

docker pull minio/minio
docker tag minio/minio localhost:5000/minio
docker push localhost:5000/minio
docker image rm minio/minio

kubectl create -f Minio-Dep.yml

 
# Step 5 – Deploy the MinIO Service

touch Minio-svc.yml

echo "apiVersion: v1" >> Minio-svc.yml
echo "kind: Service" >> Minio-svc.yml
echo "metadata:" >> Minio-svc.yml
echo "  # This name uniquely identifies the service" >> Minio-svc.yml
echo "  name: minio-service" >> Minio-svc.yml
echo "spec:" >> Minio-svc.yml
echo "  type: LoadBalancer" >> Minio-svc.yml
echo "  ports:" >> Minio-svc.yml
echo "    - name: http" >> Minio-svc.yml
echo "      port: 9000" >> Minio-svc.yml
echo "      targetPort: 9000" >> Minio-svc.yml
echo "      protocol: TCP" >> Minio-svc.yml
echo "  selector:" >> Minio-svc.yml
echo "    # Looks for labels `app:minio` in the namespace and applies the spec" >> Minio-svc.yml
echo "    app: minio" >> Minio-svc.yml

kubectl create -f Minio-svc.yml

kubectl get svc

## Step 6 kann man überspringen

# Step 6 – Access the MinIO Web UI

# At this point, the MinIO service has been exposed on port 32278, proceed and access the web UI using the URL http://Node_IP:32278

# Step 7 – Manage MinIO using MC client

##For amd64
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# Move the file to your path and make it executable:

sudo cp mc /usr/local/bin/
sudo chmod +x /usr/local/bin/mc

#verify installation

mc --version

## hier kann man bis mc ls play minio alles überspringen

# list all bukets

mc ls play minio

#You can list files in a bucket say test bucket with the command:

##mc ls play minio/test

#Create a new bucket using the syntax:

## mc mb minio/<your-bucket-name>

# for help use

mc --help

#how to copy things in and out

## https://docs.min.io/minio/baremetal/reference/minio-mc/mc-cp.html

