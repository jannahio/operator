# syntax=docker/dockerfile:1

FROM ubuntu:23.04
RUN apt-get update && apt-get install -y python3 python3-pip libssl-dev wget \
    virtualenv git
ADD . /jannah-operator
WORKDIR /jannah-operator
RUN echo "ansiblepass" > ansible_defaultpass.txt
ENV ANSIBLE_VAULT_DEFAULT_PASS_FILE=/jannah-operator/ansible_defaultpass.txt
ENV HOME=
ENV BREAK_PACKAGES=--break-system-packages
#RUN wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_arm64.tar.gz
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
#RUN tar xvf yq_linux_arm64.tar.gz
#RUN mv yq_linux_arm64 /usr/bin/yq
RUN python3 -m pip install --break-system-packages molecule ansible-core

#RUN add-apt-repository ppa:rmescandon/yq
#RUN apt update
#RUN apt install yq -y
ENTRYPOINT ["make","charm-converge"]