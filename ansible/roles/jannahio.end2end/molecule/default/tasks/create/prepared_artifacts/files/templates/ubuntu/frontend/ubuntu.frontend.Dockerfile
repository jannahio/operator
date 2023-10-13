# syntax=docker/dockerfile:1

FROM {{ Jannah.stages.bootstrap.deploy.helm_values.images.frontend.dockerfiles.ubuntu.from }}
RUN apt-get update && apt-get install -y nodejs npm git
ADD . /JannahIonic
WORKDIR /JannahIonic
RUN npm i -D -E vite --legacy-peer-deps
RUN npm install -g @ionic/cli
RUN ionic build
RUN npm install --legacy-peer-deps
ENTRYPOINT ["ionic","serve", "--external","--no-livereload", "--prod", "--no-open", "--port", "{{ Jannah.stages.bootstrap.deploy.helm_values.images.frontend.port }}"]