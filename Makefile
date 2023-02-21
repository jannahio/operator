WORKING_DIR=$(shell pwd)
PYTHON3_BIN=$(shell which python3)
PIP3_BIN=$(shell which pip3)
ANSIBLE_VAULT_DEFAULT_PASS_FILE=$(HOME)/.jannah-operator/ansible_defaultpass.txt
JANNAH_PYTHON=$(WORKING_DIR)/jannah-python
PYTHONPATH ?= $(WORKING_DIR)

# encrypts credentials from environment values and store into molecule config file
jannah-boot-credentials:
	ls -lrt $(WORKING_DIR)/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml
	# Make sure $(HOME)/.jannah-operator/ is available
	if [ -d "$(HOME)/.jannah-operator/" ]; \
	then \
	   echo "found $(HOME)/.jannah-operator/.  Assuming laptop has been provisioned"; \
	else \
	   echo "Error: $(HOME)/.jannah-operator/ not found"; \
	   echo "Please follow laptop provisioning instructions at https://operator.jannah.io/boot/"; \
	fi

	cp $(WORKING_DIR)/ansible/roles/jannahio.day1day2/tasks/bootstrap_config/files/templates/molecule.bootstrap.template.yml \
	$(HOME)/.jannah-operator/molecule.yml

	@echo $(ANSIBLE_VAULT_DEFAULT_PASSWORD) > $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_USERNAME)" --output=$(HOME)/.jannah-operator/GITHUB_USERNAME_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_USERNAME |= load("$(HOME)/.jannah-operator/GITHUB_USERNAME_ECRYPTED.txt")'  ~/.jannah-operator/molecule.yml
	@rm $(HOME)/.jannah-operator/GITHUB_USERNAME_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(GITHUB_TOKEN)" --output=$(HOME)/.jannah-operator/GITHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.github.GITHUB_TOKEN |= load("$(HOME)/.jannah-operator/GITHUB_TOKEN_ECRYPTED.txt")'  ~/.jannah-operator/molecule.yml
	@rm $(HOME)/.jannah-operator/GITHUB_TOKEN_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_USERNAME)" --output=$(HOME)/.jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.USERNAME |= load("$(HOME)/.jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt")'  ~/.jannah-operator/molecule.yml
	@rm $(HOME)/.jannah-operator/DOCKERHUB_USERNAME_ECRYPTED.txt

	@ansible-vault encrypt_string --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) "$(DOCKERHUB_TOKEN)" --output=$(HOME)/.jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.credentials.dockerhub.PASSWORD |= load("$(HOME)/.jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt")'  ~/.jannah-operator/molecule.yml
	@rm $(HOME)/.jannah-operator/DOCKERHUB_TOKEN_ECRYPTED.txt
	@yq -i '.provisioner.inventory.group_vars.all.Jannah.global.ansible.working_dir = "$(WORKING_DIR)"' ~/.jannah-operator/molecule.yml


jannah-python-backup: jannah-boot-credentials
	if [ -d "/tmp/jannah-python.backup" ]; \
    then \
    	mv -f $(JANNAH_PYTHON) /tmp/$(JANNAH_PYTHON).backup; \
    	cp $(HOME)/.jannah-operator/molecule.yml /tmp/molecule.yml.backup; \
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
    $(JANNAH_PYTHON)/bin/pip3 install -r $(WORKING_DIR)/requirements/requirements.txt;\
    . $(JANNAH_PYTHON)/bin/activate;\

jannah-config: jannah-python
	# Make sure the molecule config is available
	if [ -f "$(HOME)/.jannah-operator/molecule.yml" ]; \
    then \
       echo "found all: $(HOME)/.jannah-operator/molecule.yml"; \
    else \
       echo "Error: all not found at: $(HOME)/.jannah-operator/molecule.yml"; \
       echo "Please provide all at: $(HOME)/.jannah-operator/molecule.yml"; \
    fi

    # Make sure the ANSIBLE_VAULT_DEFAULT_PASS_FILE is available
	if [ -f "$(ANSIBLE_VAULT_DEFAULT_PASS_FILE)" ]; \
	then \
	   echo "found ANSIBLE_VAULT_DEFAULT_PASS_FILE: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	else \
	   echo "Error: ANSIBLE_VAULT_DEFAULT_PASS_FILE not found at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	   echo "Please provide ANSIBLE_VAULT_DEFAULT_PASS_FILE at: $(ANSIBLE_VAULT_DEFAULT_PASS_FILE)"; \
	fi

	chown -R $(USER) $(WORKING_DIR)/
	cp -v $(HOME)/.jannah-operator/molecule.yml $(WORKING_DIR)/ansible/group_vars/all

	. $(JANNAH_PYTHON)/bin/activate;\
    which molecule;\
    which ansible-playbook;
	pushd ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags d1d2-generate-molecule-configurations;\
    popd;

jannah-day1-day2: jannah-config
	pushd ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) \
    --tags "blog-service-install,d1d2-ux-dev-env-setup,d1d2-blockchain-dev-env-setup"; \
    popd;

jannah-requirements: jannah-config
	pushd ansible/operators/ansible_based/jannah-operator && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ playbooks/requirements.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags blog-service-install;\
    popd;

bootstrap-clean: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) cleanup;\
	popd;

bootstrap-destroy: bootstrap-clean
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) prepare;\
	popd;

bootstrap-prepare: bootstrap-destroy
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) prepare;\
	popd;

bootstrap-converge:  jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) converge;\
	popd;

bootstrap-test: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) test;\
	popd;


charm-clean: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.charm && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) cleanup;\
	popd;

charm-destroy: bootstrap-clean
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.charm && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) prepare;\
	popd;

charm-prepare: bootstrap-destroy
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.charm && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) prepare;\
	popd;

charm-converge:  jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.charm && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) converge;\
	popd;

charm-test: jannah-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.charm && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) test;\
	popd;


clean: jannah-python-clean