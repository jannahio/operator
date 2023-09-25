# syntax=docker/dockerfile:1
FROM quay.io/centos/centos:stream9
RUN dnf module install -y nodejs:18/common
RUN dnf install -y git
ADD . /JannahIonic
WORKDIR /JannahIonic
RUN npm i -D -E vite --legacy-peer-deps
RUN npm install -g @ionic/cli
RUN ionic build
RUN npm install --legacy-peer-deps
ENTRYPOINT ["ionic","serve"]