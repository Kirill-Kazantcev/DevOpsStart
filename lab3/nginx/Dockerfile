FROM nginx:alpine

# Копируем конфиги
COPY conf.d/* /etc/nginx/conf.d/
COPY ssl/* /etc/nginx/ssl/
COPY www /var/www/

# Создаём статические файлы для alias
RUN mkdir -p /var/www/site1/static && \
    echo "Это картинка" > /var/www/site1/static/logo.png

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
