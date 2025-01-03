mkdir /src/static
python /src/manage.py makemigrations
python /src/manage.py migrate
python /src/manage.py createsuperuser --noinput --username admin --email admin@mail.com
python /src/manage.py runserver 0.0.0.0:8000