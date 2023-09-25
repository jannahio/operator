# syntax=docker/dockerfile:1

FROM ubuntu:23.04
RUN apt-get update && apt-get install -y python3 python3-pip
ADD . /jannah_graphql
WORKDIR /jannah_graphql
RUN python3 -m pip install --break-system-packages -r requirements.txt
ENTRYPOINT ["python3","manage.py","runserver"]