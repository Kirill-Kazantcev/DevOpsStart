#!/bin/bash
echo "========================================="
echo "Полная очистка"
echo "========================================="

helm uninstall lab2-release --ignore-not-found
kubectl delete deployment lab2-app --ignore-not-found
kubectl delete service lab2-app-service --ignore-not-found

eval $(minikube docker-env)
docker rmi lab2-app:latest -f 2>/dev/null || true

echo "Очистка завершена"
