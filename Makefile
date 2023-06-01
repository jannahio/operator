SHELL=/bin/bash
WORKING_DIR=$(shell pwd)
PYTHON3_BIN=$(shell which python3)
PIP3_BIN=$(shell which pip3)
ANSIBLE_VAULT_DEFAULT_PASS_FILE=$(HOME)/jannah-operator/ansible_defaultpass.txt
JANNAH_PYTHON=$(WORKING_DIR)/jannah-python
PYTHONPATH ?= $(WORKING_DIR)

include boot.env.sh
# encrypts credentials from environment values and store into molecule config file
jannah-boot-credentials:
	mkdir -vp "$(HOME)/jannah-operator/"
	ls -lrt $(WORKING_DIR)/charm/src/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml
	# Make sure $(HOME)/jannah-operator/ is available
	if [ -d "$(HOME)/jannah-operator/" ]; \
	then \
	   echo "found $(HOME)/jannah-operator/.  Assuming laptop has been provisioned"; \
	else \
	   echo "Error: $(HOME)/jannah-operator/ not found"; \
	   echo "Please follow laptop provisioning instructions at https://operator.jannah.io/boot/"; \
	fi

	cp $(WORKING_DIR)/charm/src/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml \
	$(HOME)/jannah-operator/molecule.yml

	@echo $(ANSIBLE_VAULT_DEFAULT_PASSWORD) > $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_USERNAME)" --output=$(HOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_USERNAME |= load("$(HOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(HOME)/jannah-operator/GITHUB_USERNAME_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_TOKEN)" --output=$(HOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_TOKEN |= load("$(HOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(HOME)/jannah-operator/GITHUB_TOKEN_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_USERNAME)" --output=$(HOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt;
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.USERNAME |= load("$(HOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml;
	@rm $(HOME)/jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt;

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_TOKEN)" --output=$(HOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_EMAIL)" --output=$(HOME)/jannah-operator/DOCKERHUB_EMAIL_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.PASSWORD |= load("$(HOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.EMAIL |= load("$(HOME)/jannah-operator/DOCKERHUB_EMAIL_ECRYPTED.txt")'  ~/jannah-operator/molecule.yml
	@rm $(HOME)/jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.global.ansible.working_dir = "$(WORKING_DIR)"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.env.MOLECULE_EPHEMERAL_DIRECTORY = "$(WORKING_DIR)/tmp/EPHEMERAL"' ~/jannah-operator/molecule.yml
	@yq -i '.provisioner.inventory.host_vars.localhost.ansible_python_interpreter = "$(JANNAH_PYTHON)/bin/python3"' ~/jannah-operator/molecule.yml


jannah-python-backup: jannah-boot-credentials
	if [ -d "/tmp/jannah-python.backup" ]; \
    then \
    	mv -f $(JANNAH_PYTHON) /tmp/$(JANNAH_PYTHON).backup; \
    	cp $(HOME)/jannah-operator/molecule.yml /tmp/molecule.yml.backup; \
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
		$(PIP3_BIN) install --upgrade pip;\
		$(PIP3_BIN) install virtualenv;\
		virtualenv --always-copy $(JANNAH_PYTHON);\
	fi
	. $(JANNAH_PYTHON)/bin/activate;\
    $(JANNAH_PYTHON)/bin/pip3 install -r $(WORKING_DIR)/charm/requirements.txt;\
    . $(JANNAH_PYTHON)/bin/activate;\

#jannah-molecule: jannah-python
#	if [ -d "$(JANNAH_PYTHON)/github/molecule" ]; \
#	then \
#	   echo "$(JANNAH_PYTHON)/github/molecule."; \
#	else \
#	   mkdir -vp $(JANNAH_PYTHON)/github; \
#	   pushd $(JANNAH_PYTHON)/github/ && \
#       git clone -n https://github.com/ansible-community/molecule;\
#       popd; \
#	fi
#	pushd $(JANNAH_PYTHON)/github/molecule && \
#	git checkout -b Jannah_Ansible 01dc3f75356c6401f2fc077847b354c8a298b458;\
#	popd;\
#	. $(JANNAH_PYTHON)/bin/activate;\
#    $(JANNAH_PYTHON)/bin/python3 -m pip install -U setuptools pip tox molecule molecule-plugins[podman] molecule-plugins[docker];\
#    $(JANNAH_PYTHON)/bin/pip3 install -e $(JANNAH_PYTHON)/github/molecule;

jannah-config: jannah-python
	# Make sure the molecule config is available
	if [ -f "$(HOME)/jannah-operator/molecule.yml" ]; \
    then \
       echo "found all: $(HOME)/jannah-operator/molecule.yml"; \
    else \
       echo "Error: all not found at: $(HOME)/jannah-operator/molecule.yml"; \
       echo "Please provide all at: $(HOME)/jannah-operator/molecule.yml"; \
    fi

    # Make sure the ANSIBLE_VAULT_DEFAULT_PASS_FILE is available
	if [ -f "$(ANSIBLE_VAULT_DEFAULT_PASS_FILE)" ]; \
	then \
	   echo "found ANSIBLE_VAULT_DEFAULT_PASS_FILE: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	else \
	   echo "Error: ANSIBLE_VAULT_DEFAULT_PASS_FILE not found at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	   echo "Please provide ANSIBLE_VAULT_DEFAULT_PASS_FILE at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	fi

	cp -v $(HOME)/jannah-operator/molecule.yml $(WORKING_DIR)/charm/src/ansible/group_vars/all

	. $(JANNAH_PYTHON)/bin/activate;\
    which molecule;\
    which ansible-playbook;
	pushd charm/src/ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags d1d2-generate-molecule-configurations;\
    popd;


jannah-day1-day2: jannah-config
	pushd ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags blog-service-install;\
    popd;

charm-clean: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) cleanup;\
	popd;

charm-reset:
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) reset;\

charm-destroy: charm-reset
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) destroy;\
	popd;

# default molecule scenario test matrix: dependency, create, prepare
charm-create: jannah-config charm-reset charm-destroy
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) create;\



charm-converge:  jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) converge;\
	popd;

charm-test: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd charm/src/ansible/roles/jannahio.end2end && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) test;\
	popd;


clean: charm-destroy jannah-python-clean