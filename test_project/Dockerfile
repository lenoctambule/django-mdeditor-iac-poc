FROM alpine:3.20

ENV DJANGO_SUPERUSER_PASSWORD=password
RUN apk update
RUN apk add python3 py-pip
COPY ./ /src
RUN pip install --no-cache-dir -r ./src/requirements.txt --break-system-packages
RUN python /src/manage.py makemigrations
RUN python /src/manage.py migrate
RUN python /src/manage.py createsuperuser --noinput --username admin --email admin@mail.com
RUN mkdir /src/static

ENTRYPOINT ["python", "/src/manage.py", "runserver", "0.0.0.0:8000"]