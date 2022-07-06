#!/bin/bash

# MinIO supports no more than one MinIO Tenant per Namespace. The following kubectl command creates a new namespace for the MinIO Tenant.

# can be skiped?

kubectl create namespace minio-tenant-1

#The MinIO Operator Console supports creating a namespace as part of the Tenant Creation procedure.

# The MinIO Kubernetes Operator automatically generates Persistent Volume Claims (PVC) as part of deploying a MinIO Tenant.

#The plugin defaults to creating each PVC with the default Kubernetes Storage Class. If the default storage class cannot support the generated PVC, the tenant may fail to deploy.

#MinIO Tenants require that the StorageClass sets volumeBindingMode to WaitForFirstConsumer. The default StorageClass may use the Immediate setting, which can cause complications during PVC binding. MinIO strongly recommends creating a custom StorageClass for use by PV supporting a MinIO Tenant.

#he following StorageClass object contains the appropriate fields for supporting a MinIO Tenant using MinIO DirectCSI-managed drives:

# FROM https://github.com/minio/directpv

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: direct-csi-min-io
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

#!!!! MinIO recommends using the MinIO DirectCSI Driver to automatically provision Persistent Volumes from locally attached drives. This procedure assumes MinIO DirectCSI is installed and configured.

# FROM https://github.com/minio/directpv/blob/master/docs/installation.md

# Install kubectl directpv plugin
kubectl krew install directpv

#Run kubectl directpv to verify that the installation worked
kubectl directpv

#If the error Error: unknown command "directpv" for "kubectl" is shown, try adding $HOME/.krew/bin to your $PATH

#This will list all available drives in the kubernetes cluster.
kubectl directpv drives ls

#if all drives are not listed, try again in a few seconds
#drives mounted at /(root) are not shown in the list by default. They are marked as Unavailable
#drives marked Available can be formatted and managed by directpv
#drives marked as InUse or Ready are already managed by directpv
#using --all flag will list all drives, including those marked Unavailable

#Add available drives

kubectl directpv drives format --drives /dev/xvdb,/dev/xvdc --nodes directpv-1,directpv-2,directpv-3,directpv-4 # needs to be changed?

#This will format selected drives and mark them Ready to be used by directpv.

Notes:

#formatting will erase all data on the drives. Double check to make sure that only intended drives are specified
#Unavailable drives cannot be formatted
#--drives is a string list flag, i.e. a comma separated list of drives can be specified using this flag
#--nodes is a string list flag, i.e. a comma separated list of nodes can be specified using this flag
#both --drives and --nodes understand glob format. i.e. the above command can be shortened to kubectl directpv drives format --drives '/dev/xvd*' --nodes directpv-*. Using this can lead to unintended data loss. Use at your own risk.


#Verify installation

kubectl directpv info

## OR QUICK INSTALL SEE BELOW

# Use the plugin to install directpv in your kubernetes cluster
kubectl directpv install

# Ensure directpv has successfully started
kubectl directpv info

# List available drives in your cluster
kubectl directpv drives ls

# Select drives that directpv should manage and format
kubectl directpv drives format --drives /dev/sd{a...f} --nodes directpv-{1...4}

# 'directpv' can now be specified as the storageclass in PodSpec.VolumeClaimTemplates

## LOCAL PVC WITHOUT FUCKING DIRECTCSI DRIVER

# For clusters which cannot deploy MinIO DirectCSI, use Local Persistent Volumes. The following example YAML describes a local persistent volume:

#The following YAML describes a local PV:

apiVersion: v1
kind: PersistentVolume
metadata:
   name: <PV-NAME>
spec:
   capacity:
      storage: 1Ti
   volumeMode: Filesystem
   accessModes:
   - ReadWriteOnce
   persistentVolumeReclaimPolicy: Retain
   storageClassName: local-storage
   local:
      path: </mnt/disks/ssd1>
   nodeAffinity:
      required:
         nodeSelectorTerms:
         - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
              - <NODE-NAME>

#Replace values in brackets <VALUE> with the appropriate value for the local drive.











