FROM quay.io/operator-framework/ansible-operator:v1.14.0

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/

ENV ANSIBLE_VERBOSITY_JANNAH_JANNAH_JANNAH_IO=5
ENV ANSIBLE_DEBUG_LOGS=true
ENV ANSIBLE_DEBUG=true