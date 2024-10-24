FROM debian:12-slim as builder

RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests -y install curl ca-certificates && \
    curl -o /etc/apt/trusted.gpg.d/angie-signing.gpg https://angie.software/keys/angie-signing.gpg && \
    echo "deb https://download.angie.software/angie/debian/12 bookworm main" | tee /etc/apt/sources.list.d/angie.list > /dev/null && \
    apt-get update && \
    apt-get install -y angie

COPY default.conf /etc/angie/http.d/default.conf

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "angie -g 'daemon off;'"]