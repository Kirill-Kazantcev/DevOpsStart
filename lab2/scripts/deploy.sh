#!/bin/bash
set -e
echo "========================================="
echo "Часть 1: Деплой через kubectl"
echo "Версия: 1.0.0 (серый фон)"
echo "========================================="

cd ~/ITMO-DevOps-Labs-2026/lab2

cat > app/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Lab 2: Kubernetes + Helm</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 100px;
            background: #f0f0f0;
            color: #333;
        }
        h1 { color: #0db7ed; }
    </style>
</head>
<body>
    <h1>Лабораторная работа №2</h1>
    <p>Kubernetes + Helm</p>
    <p>Версия: 1.0.0</p>
    <p>Под: <span id="pod">загрузка...</span></p>
    <script>
        fetch('/hostname')
            .then(r => r.text())
            .then(data => document.getElementById('pod').innerText = data);
    </script>
</body>
</html>
HTML

eval $(minikube docker-env)
docker build --no-cache -t lab2-app:1.0.0 ./app
docker tag lab2-app:1.0.0 lab2-app:latest

kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

sleep 5
kubectl get pods
echo ""
echo "Доступ:"
minikube service lab2-app-service --url
