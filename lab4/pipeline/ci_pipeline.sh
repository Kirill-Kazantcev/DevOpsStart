#!/bin/bash

echo "========================================="
echo "CI/CD Pipeline with Hashicorp Vault"
echo "========================================="

VAULT_TOKEN="my-root-token"
VAULT_API_URL="http://127.0.0.1:8200/v1/secret/data/lab4-data"

echo ""
echo "Получение секрета из Vault..."

# Получаем секрет через API (без вывода в консоль)
RESPONSE=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_API_URL)

# Извлекаем пароль из JSON ответа (без вывода)
SECRET_PASSWORD=$(echo "$RESPONSE" | grep -o '"db_password":"[^"]*"' | cut -d'"' -f4)

# Проверка на ошибки (без вывода пароля)
if [[ -z "$SECRET_PASSWORD" ]]; then
    echo "Ошибка: не удалось получить секрет из Vault"
    exit 1
fi

echo "Секрет успешно получен из защищенного хранилища"

# Имитация использования секрета (НЕ ВЫВОДИМ ПАРОЛЬ!)
echo ""
echo "Запуск деплоя приложения..."
echo "Аутентификация в базе данных..."
sleep 1
echo "Деплой завершен успешно!"

# Очистка переменной из памяти
unset SECRET_PASSWORD

echo ""
echo "========================================="
echo "Пайплайн завершен успешно"
echo "========================================="
