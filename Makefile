SHELL=/bin/bash
WORKING_DIR=$(shell pwd)
PYTHON3_BIN=$(shell which python3)
PIP3_BIN=$(shell which pip3)
JANNAHHOME ?= $(HOME)
ANSIBLE_VAULT_DEFAULT_PASS_FILE ?= $(JANNAHHOME)/jannah-operator/ansible_defaultpass.txt
JANNAH_PYTHON=$(WORKING_DIR)/jannah-python
PYTHONPATH ?= $(WORKING_DIR)
BREAK_PACKAGES ?=
WAIT_TIME ?= 0

include boot.env.sh
# encrypts credentials from environment values and store into molecule config file
jannah-boot-credentials:
	mkdir -vp "$(JANNAHHOME)/jannah-operator/"
	ls -lrt $(WORKING_DIR)/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml
	# Make sure $(JANNAHHOME)/jannah-operator/ is available
	if [ -d "$(JANNAHHOME)/jannah-operator/" ]; \
	then \
	   echo "found $(JANNAHHOME)/jannah-operator/.  Assuming laptop has been provisioned"; \
	else \
	   echo "Error: $(JANNAHHOME)/jannah-operator/ not found"; \
	   echo "Please follow laptop provisioning instructions at https://operator.jannah.io/boot/"; \
	fi
# configurations patches	
	@yq -i \
        'with(.; .provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.helm_values.common.repository = .provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.helm_values.images.registry.name )' \
        $(WORKING_DIR)/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml
	cp $(WORKING_DIR)/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml \
	$(JANNAHHOME)/jannah-operator/molecule.yml

	@echo $(ANSIBLE_VAULT_DEFAULT_PASSWORD) > $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_USERNAME)" --output=$(JANNAHHOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_USERNAME |= load("$(JANNAHHOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(JANNAHHOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_TOKEN)" --output=$(JANNAHHOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_TOKEN |= load("$(JANNAHHOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(JANNAHHOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_USERNAME)" --output=$(JANNAHHOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt;
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.USERNAME |= load("$(JANNAHHOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml;
	@rm $(JANNAHHOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt;

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_TOKEN)" --output=$(JANNAHHOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_EMAIL)" --output=$(JANNAHHOME)/jannah-operator/DOCKERHUB_EMAIL_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.PASSWORD |= load("$(JANNAHHOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.EMAIL |= load("$(JANNAHHOME)/jannah-operator/DOCKERHUB_EMAIL_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(JANNAHHOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.global.ansible.working_dir = "$(WORKING_DIR)"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.env.MOLECULE_EPHEMERAL_DIRECTORY = "$(WORKING_DIR)/tmp/EPHEMERAL"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.host_vars.localhost.ansible_python_interpreter = "$(JANNAH_PYTHON)/bin/python3"' ~/jannah-operator/molecule.yml
	


jannah-python-backup: jannah-boot-credentials
	if [ -d "/tmp/jannah-python.backup" ]; \
    then \
    	mv -f $(JANNAH_PYTHON) /tmp/$(JANNAH_PYTHON).backup; \
    	cp $(JANNAHHOME)/jannah-operator/molecule.yml /tmp/molecule.yml.backup; \
    fi

jannah-python-clean: jannah-python-backup
	if [ -d "$(JANNAH_PYTHON)" ]; \
    	then \
        rm -rf $(JANNAH_PYTHON);\
        rm $(ANSIBLE_VAULT_DEFAULT_PASS_FILE);\
    fi

jannah-python: jannah-boot-credentials
	echo "$(PYTHONPATH)";
	if [ -d "$(JANNAH_PYTHON)" ]; \
		then \
		echo "$(JANNAH_PYTHON) is present";\
		else \
		echo "$(JANNAH_PYTHON) is NOT present. Creating it now:";\
		$(PIP3_BIN) install $(BREAK_PACKAGES) --upgrade pip;\
		$(PIP3_BIN) install $(BREAK_PACKAGES) virtualenv;\
		virtualenv $(JANNAH_PYTHON);\
	fi
	. $(JANNAH_PYTHON)/bin/activate;\
    $(JANNAH_PYTHON)/bin/pip3 install $(BREAK_PACKAGES) -r $(WORKING_DIR)/requirements.txt;\
    . $(JANNAH_PYTHON)/bin/activate;\

jannah-config:
	# Make sure the molecule config is available
	if [ -f "$(JANNAHHOME)/jannah-operator/molecule.yml" ]; \
    then \
       echo "found all: $(JANNAHHOME)/jannah-operator/molecule.yml"; \
    else \
       echo "Error: all not found at: $(JANNAHHOME)/jannah-operator/molecule.yml"; \
       echo "Please provide all at: $(JANNAHHOME)/jannah-operator/molecule.yml"; \
    fi

    # Make sure the ANSIBLE_VAULT_DEFAULT_PASS_FILE is available
	if [ -f "$(ANSIBLE_VAULT_DEFAULT_PASS_FILE)" ]; \
	then \
	   echo "found ANSIBLE_VAULT_DEFAULT_PASS_FILE: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	else \
	   echo "Error: ANSIBLE_VAULT_DEFAULT_PASS_FILE not found at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	   echo "Please provide ANSIBLE_VAULT_DEFAULT_PASS_FILE at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	fi

	cp -v $(JANNAHHOME)/jannah-operator/molecule.yml $(WORKING_DIR)/ansible/group_vars/all;
	. $(JANNAH_PYTHON)/bin/activate;
	ansible-playbook -i inventory/ ansible/site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags d1d2-generate-molecule-configurations;\

# jannah-day1-day2: jannah-config
# 	pushd ansible && \
#     $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags blog-service-install;

molecule-clean: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) cleanup;\
	popd;

molecule-reset:
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) reset;\

molecule-destroy: molecule-reset
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) destroy;\
	popd;

# default molecule scenario test matrix: dependency, create, prepare
molecule-create: jannah-config molecule-reset molecule-destroy
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) create;\



molecule-converge:  jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) converge;\
	popd;

molecule-verify: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) verify;\
	popd;

molecule-test: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) test;\
	popd;

# TODO: Write a Makefile function for setting vatriables for the deployment matrix. 
# Or use the config bootstrap ansible role to create various molecule config files for the matrix permutations
# add .provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.architecture

# ---------------------------------- Docker Desktop Kubernete Deployment Matrix Settings----------------------------------------------
# If deploy mode is dev, native Jannah services (jannah-frontend, jannah-middleware) are deployed in local containers. 
# Local development deployment (full Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-full-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (full Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-full-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (full Kubeflow) to K8 cluster on docker-desktop,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-full-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (full Kubeflow) to K8 cluster on docker-desktop,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-full-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (local Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-local-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (local Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-local-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (local Kubeflow) to K8 cluster on docker-desktop,
# using StreamOS containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-local-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (local Kubeflow) to K8 cluster on docker-desktop,
# using StreamOS containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-local-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (standalone Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-standalone-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (standalone Kubeflow) to K8 cluster on docker-desktop,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-standalone-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (standalone Kubeflow) to K8 cluster on docker-desktop,
# using StreamOS containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-standalone-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (standalone Kubeflow) to K8 cluster on docker-desktop,
# using StreamOS containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-docker-desktop-standalone-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml


# ---------------------------------- Kind Cluster Deployment Matrix Settings ----------------------------------------------
# Local development deployment (full Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-full-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (full Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-full-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (full Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-full-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (full Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-full-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (local Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-local-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (local Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-local-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (local Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-local-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (local Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-local-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (standalone Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-standalone-ubuntu-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (standalone Kubeflow) to created Kind cluster,
# using Ubuntu containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-standalone-ubuntu-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "ubuntu"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Local development deployment (standalone Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-standalone-streamos-dev-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "dev"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml
# Production deployment (standalone Kubeflow) to created Kind cluster,
# using StreamOs containers for native Jannah services (jannah-frontend, jannah-middleware).
set-to-kind-cluster-standalone-streamos-production-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.os  = "streamos"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.mode  = "production"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.wait_time  = $(WAIT_TIME)' ~/jannah-operator/molecule.yml

# Install Jannah
install: jannah-config molecule-destroy molecule-reset molecule-converge molecule-verify
# Un Install Jannah
uninstall: jannah-config molecule-destroy molecule-reset
# Test Jannah
test: jannah-config molecule-destroy molecule-reset molecule-test

#Ironic, but we created the virtual Python environment and molecule configurations before we clean up the environment.
clean: jannah-python set-to-kind-cluster-full-ubuntu-dev-mode \
jannah-config molecule-destroy \
set-to-docker-desktop-full-ubuntu-dev-mode \
jannah-config molecule-destroy jannah-python-clean


deploy-to-docker-desktop-full-ubuntu-dev-mode: jannah-python set-to-docker-desktop-full-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-full-ubuntu-production-mode: jannah-python set-to-docker-desktop-full-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-full-streamos-dev-mode: jannah-python  set-to-docker-desktop-full-streamos-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-full-streamos-production-mode: jannah-python set-to-docker-desktop-full-streamos-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-local-ubuntu-dev-mode: jannah-python set-to-docker-desktop-local-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-local-ubuntu-production-mode: jannah-python set-to-docker-desktop-local-ubuntu-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-local-streamos-dev-mode: jannah-python set-to-docker-desktop-local-streamos-dev-mode install 
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-local-streamos-production-mode: jannah-python set-to-docker-desktop-local-streamos-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-standalone-ubuntu-dev-mode: jannah-python set-to-docker-desktop-standalone-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-standalone-ubuntu-production-mode: jannah-python set-to-docker-desktop-standalone-ubuntu-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-standalone-streamos-dev-mode: jannah-python  set-to-docker-desktop-standalone-streamos-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-docker-desktop-standalone-streamos-production-mode: jannah-python set-to-docker-desktop-standalone-streamos-production-mode install
	@sleep $(WAIT_TIME)


deploy-to-kind-cluster-full-ubuntu-dev-mode: jannah-python set-to-kind-cluster-full-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-full-ubuntu-production-mode: jannah-python set-to-kind-cluster-full-ubuntu-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-full-streamos-dev-mode: jannah-python set-to-kind-cluster-full-streamos-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-full-streamos-production-mode: jannah-python set-to-kind-cluster-full-streamos-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-local-ubuntu-dev-mode: jannah-python set-to-kind-cluster-local-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-local-ubuntu-production-mode: jannah-python set-to-kind-cluster-local-ubuntu-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-local-streamos-dev-mode: jannah-python set-to-kind-cluster-local-streamos-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-local-streamos-production-mode: jannah-python set-to-kind-cluster-local-streamos-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-standalone-ubuntu-dev-mode: jannah-python set-to-kind-cluster-standalone-ubuntu-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-standalone-ubuntu-production-mode: jannah-python set-to-kind-cluster-standalone-ubuntu-production-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-standalone-streamos-dev-mode: jannah-python set-to-kind-cluster-standalone-streamos-dev-mode install
	@sleep $(WAIT_TIME)
deploy-to-kind-cluster-standalone-streamos-production-mode: jannah-python set-to-kind-cluster-standalone-streamos-production-mode install
	@sleep $(WAIT_TIME)


# Deploy Docker Desktop Matrix
deploy-docker-desktop-matrix: deploy-to-docker-desktop-full-ubuntu-dev-mode \
deploy-to-docker-desktop-full-ubuntu-production-mode \
deploy-to-docker-desktop-full-streamos-dev-mode \
deploy-to-docker-desktop-full-streamos-production-mode \
deploy-to-docker-desktop-local-ubuntu-dev-mode \
deploy-to-docker-desktop-local-ubuntu-production-mode \
deploy-to-docker-desktop-local-streamos-dev-mode \
deploy-to-docker-desktop-local-streamos-production-mode \
deploy-to-docker-desktop-standalone-ubuntu-dev-mode \
deploy-to-docker-desktop-standalone-ubuntu-production-mode \
deploy-to-docker-desktop-standalone-streamos-dev-mode \
deploy-to-docker-desktop-standalone-streamos-production-mode

deploy-completed-docker-desktop-matrix: deploy-to-docker-desktop-full-ubuntu-dev-mode \
deploy-to-docker-desktop-local-ubuntu-dev-mode \
deploy-to-docker-desktop-standalone-ubuntu-dev-mode;

# Deploy Kind Cluster Matrix
deploy-kind-matrix: deploy-to-kind-cluster-full-ubuntu-dev-mode \
deploy-to-kind-cluster-full-ubuntu-production-mode \
deploy-to-kind-cluster-full-streamos-dev-mode \
deploy-to-kind-cluster-full-streamos-production-mode \
deploy-to-kind-cluster-local-ubuntu-dev-mode \
deploy-to-kind-cluster-local-ubuntu-production-mode \
deploy-to-kind-cluster-local-streamos-dev-mode \
deploy-to-kind-cluster-local-streamos-production-mode \
deploy-to-kind-cluster-standalone-ubuntu-dev-mode \
deploy-to-kind-cluster-standalone-ubuntu-production-mode \
deploy-to-kind-cluster-standalone-streamos-dev-mode \
deploy-to-kind-cluster-standalone-streamos-production-mode

deploy-completed-kind-matrix: deploy-to-kind-cluster-full-ubuntu-dev-mode \
deploy-to-kind-cluster-local-ubuntu-dev-mode \
deploy-to-kind-cluster-standalone-ubuntu-dev-mode

jannah-deployments: deploy-docker-desktop-matrix clean deploy-kind-matrix

ansible-cleanup: 
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_cleanup;


ansible-destroy: ansible-cleanup
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_destroy;

ansible-prepare: ansible-destroy
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_prepare;

ansible-converge: ansible-prepare
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_converge;	

ansible-verify: ansible-converge
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_verify;

ansible-test: ansible-verify
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_destroy;

jannah-deployment-with-ansible: jannah-python set-to-kind-cluster-full-ubuntu-dev-mode jannah-config
	. $(JANNAH_PYTHON)/bin/activate;
	WAIT_TIME=60 ansible-playbook -i ansible/inventory/ ansible/site.yml $(ANSIBLE_VERBOSE_LEVEL) \
	--connection=local \
	--vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) 
	--tags \
	molecule_cleanup,\
	molecule_destroy,\
	molecule_create,\
	molecule_prepare,\
	molecule_converge,\
	molecule_verify;