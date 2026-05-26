#!/bin/bash
set -e
echo "========================================="
echo "Часть 2: Helm апгрейд"
echo "Версия: 1.0.2 (розовый фон, 3 реплики)"
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        h1 { color: #fff; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
    </style>
</head>
<body>
    <h1>Лабораторная работа №2</h1>
    <p>Kubernetes + Helm</p>
    <p>Версия: 1.0.2</p>
    <p>Под: <span id="pod">загрузка...</span></p>
    <script>
        fetch('/hostname')
            .then(r => r.text())
            .then(data => document.getElementById('pod').innerText = data);
    </script>
</body>
</html>
HTML

# Меняем количество реплик на 3
sed -i 's/replicaCount: 2/replicaCount: 3/' helm-chart/values.yaml

eval $(minikube docker-env)
docker build --no-cache -t lab2-app:1.0.2 ./app
docker tag lab2-app:1.0.2 lab2-app:latest

# Обновляем values.yaml с новым тегом
sed -i 's/tag: 1.0.1/tag: 1.0.2/g' helm-chart/values.yaml

helm upgrade lab2-release ./helm-chart

echo ""
echo "⏳ Ожидание обновления подов..."
sleep 15

kubectl get pods
echo ""
echo "Доступ:"
minikube service lab2-app-service --url
