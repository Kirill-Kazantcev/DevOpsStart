FROM ubuntu:latest

#1: Раздельные RUN (много слоев)
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get clean

#2: Копирование всего контекста
COPY . /var/www/html

#3: Запуск от root + лишние порты
USER root
EXPOSE 80 443 8080 3000 5000

#4: Отсутствие healthcheck

#5: Нет обработки сигналов
CMD ["nginx"]