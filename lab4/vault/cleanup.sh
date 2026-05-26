#!/bin/bash
echo "🧹 Остановка и удаление Vault контейнера..."
docker rm -f vault-lab 2>/dev/null
echo "Очистка завершена"
