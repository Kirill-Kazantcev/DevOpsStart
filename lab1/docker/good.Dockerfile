FROM nginx:1.25-alpine 
#1: Фиксированная версия, официальный образ

#2: Копируем только нужную папку
COPY ./app /usr/share/nginx/html

#3: Непривилегированный пользователь
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup && \
    chown -R appuser:appgroup /usr/share/nginx/html /var/cache/nginx /var/log/nginx

USER appuser

#4: Только нужный порт
EXPOSE 80

#5: Healthcheck + правильный CMD
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]