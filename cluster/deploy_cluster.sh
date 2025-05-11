#!/bin/bash

kubectl apply -f secret.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f ingress.yaml

echo "Waiting for LoadBalancer IP..."
while [[ -z "$IP" ]]; do
  sleep 2
  IP=$(kubectl get svc ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
done

echo "Backend IP: $IP"
kubectl set env deployment frontend-deployment REACT_APP_BACKEND_URL="http://$IP"

kubectl apply -f frontend-deployment.yaml
