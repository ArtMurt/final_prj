FROM debian:12-slim as builder

RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests -y install curl ca-certificates php php-fpm && \
    curl -o /etc/apt/trusted.gpg.d/angie-signing.gpg https://angie.software/keys/angie-signing.gpg && \
    echo "deb https://download.angie.software/angie/debian/12 bookworm main" | tee /etc/apt/sources.list.d/angie.list > /dev/null && \
    apt-get update && \
    apt-get install -y angie

COPY www.conf /etc/php/8.2/fpm/pool.d/
COPY default.conf /etc/angie/http.d/default.conf
COPY index.php /usr/share/angie/html/

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "php-fpm8.2 --daemonize --fpm-config /etc/php/8.2/fpm/php-fpm.conf --pid /run/php/php8.2-fpm.pid && angie -g 'daemon off;'"]