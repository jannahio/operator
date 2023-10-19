# syntax=docker/dockerfile:1
FROM {{ Jannah.stages.bootstrap.deploy.helm_values.images.boot.dockerfiles.streamos.from }}
RUN dnf install -y gcc python3-pip python3 python3-devel openssl-devel python3-libselinux wget git
ADD . /jannah-operator
WORKDIR /jannah-operator
RUN echo "ansiblepass" > ansible_defaultpass.txt
ENV ANSIBLE_VAULT_DEFAULT_PASS_FILE=/jannah-operator/ansible_defaultpass.txt
ENV HOME=
ENV BREAK_PACKAGES=--break-system-packages
ENV BINARY=yq_linux_amd64
RUN python3 -m pip install molecule ansible-core virtualenv
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
ENTRYPOINT ["ls","-lrt"]