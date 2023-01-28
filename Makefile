WORKING_DIR=$(shell pwd)
PYTHON3_BIN=$(shell which python3.9)
PIP3_BIN=$(shell which pip3.9)
ANSIBLE_VAULT_DEFAULT_PASS_FILE=$(HOME)/defaultpass.txt
JANNAH_PYTHON=$(WORKING_DIR)/jannah-python
PYTHONPATH ?= $(WORKING_DIR)

jannah-python-backup:
	if [ -d "/tmp/jannah-python.backup" ]; \
        then \
    	rm -rf /tmp/jannah-python.backup;\
    fi

jannah-python-clean: jannah-python-backup
	if [ -d "$(JANNAH_PYTHON)" ]; \
    	then \
        mv -f $(JANNAH_PYTHON) /tmp/; \
    fi


jannah-python:
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
    $(JANNAH_PYTHON)/bin/pip3.9 install -r $(WORKING_DIR)/requirements/requirements.txt;\
    . $(JANNAH_PYTHON)/bin/activate;



molecule-config: jannah-python
	# Make sure the molecule config is available
	if [ -f "$(HOME)/.jannah-bootstrap/all" ]; \
    then \
       echo "found all: $(HOME)/.jannah-bootstrap/all"; \
    else \
       echo "Error: all not found at: $(HOME)/.jannah-bootstrap/all"; \
       echo "Please provide all at: $(HOME)/.jannah-bootstrap/all"; \
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
	cp -v $(WORKING_DIR)/ansible/group_vars/all $(WORKING_DIR)/ansible/group_vars/all.backup
	cp -v $(HOME)/.jannah-bootstrap/all $(WORKING_DIR)/ansible/group_vars/all

	. $(JANNAH_PYTHON)/bin/activate;\
    which molecule;\
    which ansible-playbook;
	pushd ansible && \
    $(JANNAH_PYTHON)/bin/ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$(ANSIBLE_VAULT_DEFAULT_PASS_FILE) --tags d1d2-generate-molecule-configurations;\
    popd;

bootstrap-clean: molecule-config
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

bootstrap-converge:  molecule-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) converge;\
	popd;

bootstrap-test: molecule-config
	. $(JANNAH_PYTHON)/bin/activate;\
	pushd ansible/roles/jannahio.bootstrap && \
	molecule $(ANSIBLE_VERBOSE_LEVEL) test;\
	popd;