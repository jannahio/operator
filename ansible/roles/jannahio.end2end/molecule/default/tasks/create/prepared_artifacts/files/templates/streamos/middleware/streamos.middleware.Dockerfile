# syntax=docker/dockerfile:1
FROM {{ Jannah.stages.bootstrap.deploy.helm_values.images.middleware.dockerfiles.streamos.from }}
RUN dnf install -y gcc python3-pip python3
ADD . /jannah_graphql
WORKDIR /jannah_graphql
RUN python3 -m pip install -r requirements.txt
RUN python3 manage.py makemigrations
RUN python3 manage.py migrate
ENTRYPOINT ["python3","manage.py","runserver", "0.0.0.0:{{ Jannah.stages.bootstrap.deploy.helm_values.images.middleware.port }}"]