# syntax=docker/dockerfile:1

FROM ubuntu:23.04
RUN apt-get update && apt-get install -y nodejs npm git
ADD . /JannahIonic
WORKDIR /JannahIonic
RUN npm i -D -E vite --legacy-peer-deps
RUN npm install -g @ionic/cli
RUN ionic build
RUN npm install --legacy-peer-deps
ENTRYPOINT ["ionic","serve"]