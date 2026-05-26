#!/bin/bash
set -e
echo "========================================="
echo "Часть 2: Установка через Helm"
echo "Версия: 1.0.1 (синий фон)"
echo "========================================="

cd ~/ITMO-DevOps-Labs-2026/lab2

# Очистка старых ресурсов перед установкой
helm uninstall lab2-release --ignore-not-found
kubectl delete deployment lab2-app --ignore-not-found
kubectl delete service lab2-app-service --ignore-not-found

# Создаём HTML для версии 1.0.1 (синий фон)
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        h1 { color: #ffd700; }
    </style>
</head>
<body>
    <h1>Лабораторная работа №2</h1>
    <p>Kubernetes + Helm</p>
    <p>Версия: 1.0.1</p>
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
docker build --no-cache -t lab2-app:1.0.1 ./app
docker tag lab2-app:1.0.1 lab2-app:latest

# Обновляем values.yaml
cat > helm-chart/values.yaml << 'EOF'
name: lab2-app
replicaCount: 2

image:
  repository: lab2-app
  tag: 1.0.1
  pullPolicy: Never

service:
  type: NodePort
  nodePort: 30080
EOF

# Установка Helm
echo "Установка Helm chart..."
helm install lab2-release ./helm-chart

echo ""
echo "Статус подов:"
kubectl get pods

echo ""
echo "Доступ:"
minikube service lab2-app-service --url