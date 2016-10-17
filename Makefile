#!/usr/bin/make -f

###
 # colors!
###
# colorize some of the output, see http://dcmnt.me/1XYnkPe for more information
COLOR_OFF = \x1b[0m
COLOR_OK = \x1b[32;01m
COLOR_ERR = \x1b[31;01m
COLOR_WARN = \x1b[33;01m
COLOR_MUTE = \x1b[30;01m
COLOR_BRIGHT = \x1b[37;01m
COLOR_OFF = \x1b[0m

SIGN_OK = $(COLOR_OK)  ✓$(COLOR_OFF)
SIGN_ERR = $(COLOR_ERR)  ✗$(COLOR_OFF)

###
 # configuration
###
.DEFAULT_GOAL := help

AMI_SLUG = centos-7
ANSIBLE_GROUP = packer
ANSIBLE_VERBOSITY_LEVEL = vv
ANSIBLE_TAGS_SKIP =
AWS_PROFILE = cultivatedops
AWS_REGION = eu-west-1
FORCE_DEREGISTER = false
INSTANCE_TYPE = m3.medium
PLAYBOOKS_DIR = ./files/playbooks
SFTP_COMMAND = /usr/libexec/openssh/sftp-server -e
SSH_PTY = false
SSH_TIMEOUT = 5m
SSH_USERNAME = centos
SPOT_PRICE = 0
SPOT_PRICE_AUTO_PRODUCT = Linux/UNIX (Amazon VPC)
TIMESTAMP = $(strip $(shell date +%s))
USER_DATA_FILE = ./files/scripts/user-data.sh

AMI_SLUG_BASE = base
AMI_DESCRIPTION_BASE = CentOS 7.x-based image with extra hardening
AMI_NAME_BASE = cltvt-$(AMI_SLUG)-$(AMI_SLUG_BASE)
PLAYBOOK_FILE_BASE = $(PLAYBOOKS_DIR)/$(AMI_SLUG_BASE).yml
RSPEC_TARGET_BASE = $(AMI_SLUG_BASE)
SOURCE_AMI_BASE = ami-7abd0209

# check for availability of Packer
ifeq ($(shell which packer >/dev/null 2>&1; echo $$?), 1)
	PACKER_AVAILABLE = false
else
	PACKER_AVAILABLE = true
	PACKER_PATH = $(shell which packer)
	PACKER_VERSION = $(shell packer version | grep -m 1 -o '[0-9]*\.[0-9]*\.[0-9]')
endif
# end: check for availability of Packer

# check for availability of AWS CLI
ifeq ($(shell which aws >/dev/null 2>&1; echo $$?), 1)
	AWSCLI_AVAILABLE = false
else
	AWSCLI_AVAILABLE = true
	AWSCLI_PATH = $(shell which aws)
endif
# end: check for availability of AWS CLI

# check for availability of jq
ifeq ($(shell which jq >/dev/null 2>&1; echo $$?), 1)
	JQ_AVAILABLE = false
else
	JQ_AVAILABLE = true
	JQ_PATH=$(shell which jq)
endif
# end: check for availability of Packer

###
 # Targets
###
.PHONY: help
help:
	@echo
	@echo "$(COLOR_BRIGHT)  CULTIVATED OPS$(COLOR_OFF)"
	@echo "$(COLOR_MUTE)  Packer Image for \`$(AMI_SLUG)\`$(COLOR_OFF)"
	@echo
	@echo	"$(COLOR_BRIGHT)   Options:$(COLOR_OFF)"
	@echo "     make check $(COLOR_MUTE).........$(COLOR_OFF) checks if all local dependencies are available"
	@echo
	@echo "     make $(AMI_SLUG_BASE) $(COLOR_MUTE)..........$(COLOR_OFF) builds \`$(AMI_SLUG_BASE)\` image"
	@echo
	@echo "     make debug target $(COLOR_MUTE)..$(COLOR_OFF) builds image in debug mode"
	@echo "     make force target $(COLOR_MUTE)..$(COLOR_OFF) builds image in forced mode"
	@echo
	@echo	"$(COLOR_BRIGHT)   Notes:$(COLOR_OFF)"
	@echo "     $(COLOR_WARN)\"force\"$(COLOR_OFF) mode overwrites any existing artifacts with the same name."
	@echo

.PHONY: debug
debug:
	$(eval PACKER_DEBUG := -debug)
	@echo "Enabling debug mode for Packer"

.PHONY: force
force:
	$(eval PACKER_FORCE := -force)
	$(EVAL FORCE_DEREGISTER := true)
	@echo "Enabling forced building mode for Packer"
	@echo "$(COLOR_WARN)WARN: this will overwrite existing artifacts.$(COLOR_OFF)"
	@echo

PACKER= \
	export AWS_PROFILE="$(AWS_PROFILE)" && \
	packer \
		build \
			$(PACKER_DEBUG) \
			$(PACKER_FORCE) \
			-var "ansible_group=$(ANSIBLE_GROUP)" \
			-var "ansible_verbosity_level=$(ANSIBLE_VERBOSITY_LEVEL)" \
			-var "ansible_tags_skip=$(ANSIBLE_TAGS_SKIP)" \
			-var "force_deregister=$(FORCE_DEREGISTER)" \
			-var "instance_type=$(INSTANCE_TYPE)" \
			-var "region=$(AWS_REGION)" \
			-var "sftp_command=$(SFTP_COMMAND)" \
			-var "spot_price=$(SPOT_PRICE)" \
			-var "spot_price_auto_product=$(SPOT_PRICE_AUTO_PRODUCT)" \
			-var "ssh_username=$(SSH_USERNAME)" \
			-var "ssh_pty=$(SSH_PTY)" \
			-var "ssh_timeout=$(SSH_TIMEOUT)" \
			-var "timestamp=$(TIMESTAMP)" \
			-var "user_data_file=$(USER_DATA_FILE)"

.PHONY: check
check:
	@echo
	@echo "Checking local dependencies..."

# BEGIN: check for `packer` availability
	@echo
	@echo "Packer"

ifeq ($(PACKER_AVAILABLE), true)
	@echo "$(SIGN_OK) found binary at \"$(PACKER_PATH)\""
	@echo "$(SIGN_OK) found version \"$(PACKER_VERSION)\""
else
	@echo "$(SIGN_ERR) unable to find \"packer\""
	@EXIT_WITH_ERROR = true
endif
# END: check for `packer` availability

# BEGIN: check for `aws` availability
	@echo
	@echo "AWS CLI"

ifeq ($(AWSCLI_AVAILABLE), true)
	@echo "$(SIGN_OK) found binary at \"$(AWSCLI_PATH)\""
else
	@echo "$(SIGN_ERR) unable to find \"aws\""
	@EXIT_WITH_ERROR = true
endif
# END: check for `aws` availability

# BEGIN: check for `jq` availability
	@echo
	@echo "jq"

ifeq ($(JQ_AVAILABLE), true)
	@echo "$(SIGN_OK) found binary at \"$(JQ_PATH)\""
else
	@echo "$(SIGN_ERR) unable to find \"jq\""
	@EXIT_WITH_ERROR = true
endif
# END: check for `jq` availability

	@echo

ifeq ($(EXIT_WITH_ERROR), true)
	exit 1
endif

.PHONY: base
base:
	@echo && \
	echo "Building \`$(AMI_SLUG_BASE)\` image using \`$(SOURCE_AMI_BASE)\`" && \
	echo && \
	$(PACKER) \
		-var "ami_name=$(AMI_NAME_BASE)" \
		-var "ami_description=$(AMI_DESCRIPTION_BASE)" \
		-var "ami_slug=$(AMI_SLUG_BASE)" \
		-var "playbook_file=$(PLAYBOOK_FILE_BASE)" \
		-var "rspec_target=$(RSPEC_TARGET_BASE)" \
		-var "source_ami=$(SOURCE_AMI_BASE)" \
		"image.json"

	@echo && \
	echo "Building image using \`$(SOURCE_AMI)\`" && \
	echo && \
	$(PACKER) \
		-var "ami_name=$(AMI_NAME)" \
		-var "ami_description=$(AMI_DESCRIPTION)" \
		-var "ami_slug=$(AMI_SLUG)" \
		-var "playbook_file=$(PLAYBOOK_FILE)" \
		-var "rspec_target=$(RSPEC_TARGET)" \
		-var "source_ami=$(SOURCE_AMI)" \
		"image.json"
