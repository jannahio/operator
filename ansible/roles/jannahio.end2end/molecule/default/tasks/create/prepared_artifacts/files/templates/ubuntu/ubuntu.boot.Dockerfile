# syntax=docker/dockerfile:1
FROM {{ Jannah.stages.bootstrap.deploy.helm_values.images.boot.dockerfiles.ubuntu.from }}
RUN apt-get update && apt-get install -y python3 python3-pip libssl-dev wget \
    virtualenv git
ADD . /jannah-operator
WORKDIR /jannah-operator
RUN echo "ansiblepass" > ansible_defaultpass.txt
ENV ANSIBLE_VAULT_DEFAULT_PASS_FILE=/jannah-operator/ansible_defaultpass.txt
ENV HOME=
ENV BREAK_PACKAGES=--break-system-packages
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
RUN python3 -m pip install --break-system-packages molecule ansible-core
ENTRYPOINT ["ls","-lrt"]