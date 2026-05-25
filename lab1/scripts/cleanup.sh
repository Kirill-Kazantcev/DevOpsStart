#!/bin/bash

# Очистка и сравнение образов

echo "========================================="
echo "Очистка и сравнение образов"
echo "========================================="

cd ~/ITMO-DevOps-Labs-2026/lab1

# Остановка compose
echo "1. Остановка контейнеров..."
cd compose
docker-compose -f good-docker-compose.yml down 2>/dev/null
cd ..

# Удаление образов
echo ""
echo "2. Удаление образов..."
docker rmi bad-nginx:latest 2>/dev/null
docker rmi good-nginx:latest 2>/dev/null
docker rmi compose-app1 2>/dev/null
docker rmi compose-app2 2>/dev/null

# Очистка неиспользуемых ресурсов
echo ""
echo "3. Очистка Docker..."
docker system prune -f

echo ""
echo "========================================="
echo "Очистка завершена"
echo "========================================="