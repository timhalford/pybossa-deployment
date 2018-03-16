FROM redis:3.2
COPY redis.conf /etc/
RUN chown redis /etc/redis.conf
CMD ["redis-server", "/etc/redis.conf", "--sentinel"]
