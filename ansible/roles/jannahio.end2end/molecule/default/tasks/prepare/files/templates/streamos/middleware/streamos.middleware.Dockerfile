# syntax=docker/dockerfile:1
FROM quay.io/centos/centos:stream9
RUN dnf install -y gcc python3-pip python3
ADD . /jannah_graphql
WORKDIR /jannah_graphql
RUN python3 -m pip install -r requirements.txt
ENTRYPOINT ["python3","manage.py","runserver"]