#!/bin/bash


echo "========================================="
echo "Тестирование изоляции"
echo "========================================="

cd ~/ITMO-DevOps-Labs-2026/lab1/compose

# Даем время на healthcheck
sleep 3

# 1. Проверка сетей контейнеров
echo ""
echo "1. Сети контейнеров:"
for container in app1 app2; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        networks=$(docker inspect $container --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null)
        echo "  $container: $networks"
    else
        echo "  $container: не запущен"
    fi
done

# 2. Проверка изоляции (ping по имени)
echo ""
echo "2. Проверка сетевой изоляции (ping по имени):"

if docker ps --format '{{.Names}}' | grep -q "app1"; then
    echo -n "  app1 → app2: "
    if docker exec app1 ping -c 2 -W 2 app2 2>&1 | grep -q "bad address\|Name does not resolve"; then
        echo "НЕТ соединения (изоляция работает)"
    else
        echo "ЕСТЬ соединение (изоляция НЕ работает)"
    fi
else
    echo "  app1 → app2: app1 не запущен"
fi

if docker ps --format '{{.Names}}' | grep -q "app2"; then
    echo -n "  app2 → app1: "
    if docker exec app2 ping -c 2 -W 2 app1 2>&1 | grep -q "bad address\|Name does not resolve"; then
        echo "НЕТ соединения (изоляция работает)"
    else
        echo "ЕСТЬ соединение (изоляция НЕ работает)"
    fi
else
    echo "  app2 → app1: app2 не запущен"
fi

# 3. Проверка изоляции (показать IP адреса)
echo ""
echo "3. IP адреса контейнеров:"

if docker ps --format '{{.Names}}' | grep -q "app1"; then
    IP1=$(docker inspect app1 --format='{{range $k, $v := .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
    echo "  IP app1: $IP1"
fi

if docker ps --format '{{.Names}}' | grep -q "app2"; then
    IP2=$(docker inspect app2 --format='{{range $k, $v := .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
    echo "  IP app2: $IP2"
fi

# 4. Проверка HTTP доступности
echo ""
echo "4. Проверка HTTP доступности:"
echo -n "  app1 (порт 8081): "
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8081 2>/dev/null || echo "Ошибка"
echo -n "  app2 (порт 8082): "
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8082 2>/dev/null || echo "Ошибка"

# 5. Проверка healthcheck
echo ""
echo "5. Проверка Healthcheck:"
for container in app1 app2; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        status=$(docker inspect $container --format='{{.State.Health.Status}}' 2>/dev/null)
        echo "  $container: ${status:-'no healthcheck'}"
    fi
done

# 6. Проверка лимитов ресурсов
echo ""
echo "6. Проверка лимитов ресурсов:"
for container in app1 app2; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        mem_limit=$(docker inspect $container --format='{{.HostConfig.Memory}}' 2>/dev/null)
        mem_limit_mb=$((mem_limit / 1024 / 1024))
        cpu_limit=$(docker inspect $container --format='{{.HostConfig.NanoCpus}}' 2>/dev/null)
        cpu_limit_cores=$(echo "scale=2; $cpu_limit / 1000000000" | bc 2>/dev/null || echo "0.5")
        echo "  $container: RAM=${mem_limit_mb}MB, CPU=${cpu_limit_cores} ядер"
    fi
done

echo ""
echo "========================================="
echo "Тестирование изоляции завершено"
echo "========================================="