#!/bin/bash

echo "========================================="
echo "Сборка и запуск"
echo "========================================="

set -e  # Остановка при ошибке

cd ~/ITMO-DevOps-Labs-2026/lab1

echo ""
echo "1. Сборка Dockerfile образов..."
cd docker

echo "  Сборка bad-nginx образа..."
docker build -f bad.Dockerfile -t bad-nginx:latest . 2>/dev/null

echo "  Сборка good-nginx образа..."
docker build -f good.Dockerfile -t good-nginx:latest . 2>/dev/null

echo ""
echo "2. Сравнение размеров образов:"
docker images --format "table {{.Repository}}\t{{.Size}}" | grep -E "bad-nginx|good-nginx"


echo ""
echo "3. Количество слоев:"
echo -n "  bad-nginx образа: "
docker history bad-nginx:latest 2>/dev/null | wc -l
echo -n "  good-nginx образа: "
docker history good-nginx:latest 2>/dev/null | wc -l

echo ""
echo "4. Запуск Docker Compose..."
cd ../compose

# Очистка перед запуском
docker-compose -f good-docker-compose.yml down 2>/dev/null
docker network prune -f 2>/dev/null

# Запуск
docker-compose -f good-docker-compose.yml up -d

sleep 5

echo ""
echo "5. Статус контейнеров:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "========================================="
echo "Сборка и запуск завершены"
echo "========================================="