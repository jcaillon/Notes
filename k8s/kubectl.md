# Kubectl

## Basic crud

```bash
kubectl create deployment <name>
kubectl edit deployment <name>
kubectl delete deployment <name>
```

## Status

```bash
kubectl get nodes -o wide --all-namespaces
kubectl get pod
kubectl get services
kubectl get endpoints # endpoints = list of nodeIP:nodePort matching the selector/target port for a service
kubectl get replicaset
kubectl get deployment
kubectl get ingress
```

## Debug pods

```bash
kubectl logs <pod name>
kubectl exec- it <pod name> -- /bin/bash
```