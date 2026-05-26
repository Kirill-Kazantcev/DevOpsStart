#!/bin/bash

echo "Запуск Hashicorp Vault..."

# Удаляем старый контейнер, если есть
docker rm -f vault-lab 2>/dev/null

# Запускаем Vault в dev режиме с необходимыми правами
docker run -d --name vault-lab \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=my-root-token' \
  hashicorp/vault server -dev -dev-listen-address="0.0.0.0:8200"

sleep 5

# Проверяем, что контейнер работает
if ! docker ps | grep -q vault-lab; then
    echo "Ошибка: контейнер не запустился"
    docker logs vault-lab
    exit 1
fi

echo "Vault запущен на http://localhost:8200"
echo "Root token: my-root-token"

# Записываем секрет
docker exec -e VAULT_ADDR='http://127.0.0.1:8200' \
  -e VAULT_TOKEN='my-root-token' \
  vault-lab vault kv put secret/lab4-data db_password="VAULT_SUPER_SECRET_2026"

if [ $? -eq 0 ]; then
    echo "Секрет secret/lab4-data создан"
else
    echo "Ошибка при создании секрета"
fi
