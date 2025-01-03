FROM alpine:3.20

ENV DJANGO_SUPERUSER_PASSWORD=password
RUN apk update
RUN apk add python3 py-pip
COPY ./requirements.txt /
RUN pip install --no-cache-dir -r ./requirements.txt --break-system-packages
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]