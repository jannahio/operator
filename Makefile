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

jannah-day1-day2: jannah-config
	pushd ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags blog-service-install;

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

docker-desktop-set-full-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
docker-desktop-set-local-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
docker-desktop-set-standalone-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "docker-desktop"' ~/jannah-operator/molecule.yml
kind-set-full-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "full"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
kind-set-local-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "local"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml
kind-set-standalone-mode:
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.type  = "standalone"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.stages.bootstrap.deploy.destination  = "kind"' ~/jannah-operator/molecule.yml

docker-desktop-full-mode: jannah-python docker-desktop-set-full-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME
docker-desktop-local-mode: jannah-python docker-desktop-set-local-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME
docker-desktop-standalone-mode: jannah-python docker-desktop-set-standalone-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME

kind-full-mode: jannah-python kind-set-full-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME
kind-local-mode: jannah-python kind-set-local-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME
kind-standalone-mode: jannah-python kind-set-standalone-mode jannah-config molecule-destroy molecule-reset molecule-converge
	@sleep WAIT_TIME

docker-desktop-matrix: docker-desktop-full-mode docker-desktop-local-mode docker-desktop-standalone-mode
	@sleep WAIT_TIME
kind-matrix: kind-full-mode kind-local-mode kind-standalone-mode
	@sleep WAIT_TIME

jannah-deployments: kind-matrix docker-desktop-matrix

clean: molecule-destroy jannah-python-clean

