# Лабораторная работа №3: Nginx + HTTPS + Безопасность

## Цель работы
Настроить Nginx с поддержкой HTTPS, виртуальных хостов, alias и перенаправлением HTTP→HTTPS. Проверить уязвимости веб-сервера (path traversal, перебор страниц, информационные заголовки).

---

## Структура проекта

```marcdown

lab3/
├── nginx/
│ ├── Dockerfile
│ ├── conf.d/
│ │ ├── site1.conf              # Виртуальный хост site1.local
│ │ └── site2.conf              # Виртуальный хост site2.local
│ ├── ssl/
│ │ ├── site1.crt               # SSL сертификат site1.local
│ │ ├── site1.key               # Приватный ключ site1.local
│ │ ├── site2.crt               # SSL сертификат site2.local
│ │ └── site2.key               # Приватный ключ site2.local
│ └── www/
│ ├── site1/
│ │ ├── index.html              # Главная страница site1
│ │ ├── admin/
│ │ │ └── secret.txt            # Секретный файл (уязвимость)
│ │ └── static/                 # Папка для alias
│ └── site2/
│ └── index.html                # Главная страница site2
├── wordlists/
│ └── common.txt                # Wordlist для ffuf
├── scripts/
│ ├── deploy.sh                 # Запуск Nginx
│ └── cleanup.sh                # Остановка и очистка
├── screenshots/
│ ├── nginx-running.png
│ ├── ffuf-result.png
│ └── headers-info.png
├── docker-compose.yml
└── README.md

```

## Часть 1: Настройка Nginx

### 1.1 Создание SSL сертификатов

Для обеспечения HTTPS были сгенерированы самоподписанные SSL сертификаты для каждого виртуального хоста:

```bash
# Для site1.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout site1.key -out site1.crt \
    -subj "/CN=site1.local/O=DevOps Lab/C=RU"

# Для site2.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout site2.key -out site2.crt \
    -subj "/CN=site2.local/O=DevOps Lab/C=RU"
```
### 1.2 Конфигурация виртуальных хостов
Файлы конфигурации:
- site1.conf (основной сайт)
- site2.conf (портфолио)

### 1.3 Pet-проекты
Файлы Pet-проектов:
- site1.local
- site2.local

### Запуск выполняется через Docker
```bash
docker-compose up -d --build
docker ps
curl -k https://localhost:8443
```
Порт 8443 — проброшенный порт контейнера (443 → 8443)

## Часть 2: Проверка уязвимостей

### Уязвимость 1: Path Traversal
```bash
curl -k https://localhost:8443/admin/../../../../etc/passwd
```

Резульат:

```
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.31.1</center>
</body>
</html>
```
Nginx вернул 404 ошибку. Сервер защищён от обхода директорий.

### Уязвимость 2: Перебор страниц (ffuf) 

```bash
ffuf -u https://localhost:8443/FUZZ \
     -w ~/ITMO-DevOps-Labs-2026/lab3/wordlists/common.txt \
     -c -t 10 -k
```

Резульат:

```
:: Method           : GET
 :: URL              : https://localhost:8443/FUZZ
 :: Wordlist         : FUZZ: /home/kirak/ITMO-DevOps-Labs-2026/lab3/wordlists/common.txt
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 10
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
```

Найдена скрытая директория /admin (редирект 301)


### Уязвимость 3: Информация в заголовках

```bash
curl -I -k https://localhost:8443
```

Резульат:

```
HTTP/1.1 200 OK
Server: nginx/1.31.1
Date: Tue, 26 May 2026 02:38:59 GMT
Content-Type: text/html
Content-Length: 368
Last-Modified: Tue, 26 May 2026 02:19:44 GMT
Connection: keep-alive
ETag: "6a150340-170"
Accept-Ranges: bytes
```

Найдена версия сервера nginx/1.31.1