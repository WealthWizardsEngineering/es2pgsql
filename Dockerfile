FROM alpine

RUN apk add --update curl libpq postgresql-client && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /app
COPY data.sh /app/data.sh


CMD /app/data.sh
