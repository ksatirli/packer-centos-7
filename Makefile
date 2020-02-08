#!/usr/bin/make -f

###
 # colors!
###
# colorize some of the output, see http://dcmnt.me/1XYnkPe for more information
STYLE_OFF = \x1b[0m
STYLE_OK = \x1b[32;01m
STYLE_ERR = \x1b[31;01m
STYLE_WARN = \x1b[33;01m
STYLE_MUTE = \x1b[30;01m
STYLE_BRIGHT = \x1b[37;01m
STYLE_OFF = \x1b[0m
STYLE_UNDERLINE = \x1b[4m

SIGN_OK = $(STYLE_OK)  ✓$(STYLE_OFF)
SIGN_ERR = $(STYLE_ERR)  ✗$(STYLE_OFF)
SIGN_WARN = $(STYLE_WARN) !$(STYLE_OFF)

###
 # configuration
###
.DEFAULT_GOAL := help

AMI_SLUG = centos-7
AMI_NAME_SUFFIX_ENCRYPTED = -encrypted
ANSIBLE_DEBUG =
ANSIBLE_GROUP = packer
ANSIBLE_ROLE_FILE = ./files/vars/ansible-roles.yml
ANSIBLE_ROLES_PATH = ./files/roles/
ANSIBLE_TAGS_SKIP =
ANSIBLE_VERBOSITY_LEVEL = vv
AWS_PROFILE = your-profile
AWS_REGION = eu-west-1
DELETE_ON_TERMINATION = true
ENCRYPT_BOOT = false
FORCE_DEREGISTER = false
INSTANCE_TYPE = m3.medium
KEEP_RELEASES = 3
ON_ERROR = ask
PLAYBOOKS_DIR = ./files/playbooks
PACKER_PLUGIN_PATH = $(HOME)/.packer.d/plugins
PACKER_POSTPROCESSOR_1 = "github.com/wata727/packer-post-processor-amazon-ami-management"
PACKER_PROVISIONER_1 = "github.com/unifio/packer-provisioner-serverspec"
SFTP_COMMAND = /usr/libexec/openssh/sftp-server -e
shutdown_behavior = terminate
SOURCE_AMI_MOST_RECENT = true
SOURCE_AMI_VIRTUALIZATION_TYPE = hvm
SOURCE_AMI_ROOT_DEVICE_TYPE = ebs
SOURCE_AMI_NAME_BASE = CentOS Linux 7 x86_64 HVM EBS 1602
SOURCE_AMI_OWNER_BASE = 679593333241
SOURCE_AMI_NAME_SSM = $(AMI_NAME_BASE)
SOURCE_AMI_OWNER_SSM = 669117663053
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
PLAYBOOK_FILE_BASE = ./files/playbooks/base.yml
RSPEC_TARGET_BASE = $(AMI_SLUG_BASE)

AMI_SLUG_SSM = ssm
AMI_DESCRIPTION_SSM = $(AMI_DESCRIPTION_BASE) and Amazon SSM Agent
AMI_NAME_SSM = cltvt-$(AMI_SLUG)-$(AMI_SLUG_SSM)
PLAYBOOK_FILE_SSM = $(PLAYBOOKS_DIR)/$(AMI_SLUG_SSM).yml
RSPEC_TARGET_SSM = $(AMI_SLUG_SSM)

# check for availability of Ruby
# Version must be higher than 2.1 for awsspec.
# Hold my beer. This ain't gonna be pretty. https://dcmnt.me/2kuR8lR
RUBY_PATH = $(shell which ruby)
RUBY_VERSION = $(shell ruby --version | grep -m 1 -o '[0-9]*\.[0-9]*\.[0-9]')
RUBY_VER_MAJOR := $(shell echo $(RUBY_VERSION) | cut -f1 -d.)
RUBY_VER_MINOR := $(shell echo $(RUBY_VERSION) | cut -f2 -d.)
RUBY_GT_2_1 := $(shell [ $(RUBY_VER_MAJOR) -gt 2 -o \( $(RUBY_VER_MAJOR) -eq 2 -a $(RUBY_VER_MINOR) -ge 1 \) ] && echo true)

ifeq ($(RUBY_GT_2_1),true)
	RUBY_AVAILABLE = true
else
	RUBY_AVAILABLE = false
endif
# end: check for availability of Ruby

# check for availability of Golang
ifeq ($(shell which go >/dev/null 2>&1; echo $$?), 1)
	GO_AVAILABLE = false
else
	GO_AVAILABLE = true
	GO_PATH = $(shell which go)
	GO_VERSION = $(shell go version | grep -m 1 -o '[0-9]*\.[0-9]*\.[0-9]')
endif
# end: check for availability of Golang

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

###
 # Targets
###
.PHONY: help
help:
	@echo
	@echo "$(STYLE_BRIGHT)CULTIVATED OPS$(STYLE_OFF)"
	@echo "$(STYLE_MUTE)  Packer Image for \`$(AMI_SLUG)\`$(STYLE_OFF)"
	@echo
	@echo	"$(STYLE_BRIGHT) OPTIONS:$(STYLE_OFF)"
	@echo "     make install-dependencies $(STYLE_MUTE)...$(STYLE_OFF) installs required Packer plugins and Ansible roles from Galaxy"
	@echo "     make check $(STYLE_MUTE)..................$(STYLE_OFF) checks if all local dependencies are available"
	@echo
	@echo "     make $(STYLE_UNDERLINE)$(AMI_SLUG_BASE)$(STYLE_OFF) $(STYLE_MUTE)...................$(STYLE_OFF) builds \`$(AMI_SLUG_BASE)\` image"
	@echo "     make $(STYLE_UNDERLINE)$(AMI_SLUG_SSM)$(STYLE_OFF) $(STYLE_MUTE)....................$(STYLE_OFF) builds \`$(AMI_SLUG_SSM)\` image"
	@echo
	@echo "     make debug-packer $(STYLE_UNDERLINE)target$(STYLE_OFF) $(STYLE_MUTE)....$(STYLE_OFF) builds target image and enables debug mode for Packer"
	@echo "     make debug-ansible $(STYLE_UNDERLINE)target$(STYLE_OFF) $(STYLE_MUTE)...$(STYLE_OFF) builds target image and enables debug mode for Ansible"
	@echo "     make encrypted $(STYLE_UNDERLINE)target$(STYLE_OFF) $(STYLE_MUTE).......$(STYLE_OFF) builds target image and enables debug mode for Packer"
	@echo "     make force $(STYLE_UNDERLINE)target$(STYLE_OFF) $(STYLE_MUTE)...........$(STYLE_OFF) builds target image in forced mode"
	@echo
	@echo	"$(STYLE_BRIGHT) NOTES:$(STYLE_OFF)"
	@echo "     $(STYLE_WARN)\"force\"$(STYLE_OFF) mode overwrites any existing artifacts with the same name."
	@echo "     $(STYLE_WARN)\"encrypted\"$(STYLE_OFF) mode create a copy of the AMI with an encrypted boot volume."
	@echo

.PHONY: debug
debug:
	@echo "$(SIGN_WARN) The \`debug\` target is an application-specific switch."
	@echo
	@echo "   * To enable debug mode in Packer, pass \`debug-packer\` before passing a target image"
	@echo "   * To enable debug mode in Ansible, pass \`debug-ansible\` before passing a target image"
	@echo
	@exit 1

.PHONY: debug-packer
debug-packer:
	$(eval PACKER_DEBUG := -debug)
	@echo "$(SIGN_WARN) Enabling debug mode for Packer"

.PHONY: debug-ansible
debug-ansible:
	$(eval ANSIBLE_DEBUG := -$(ANSIBLE_VERBOSITY_LEVEL))
	@echo "$(SIGN_WARN) Enabling debug mode for Ansible"

.PHONY: encrypted
encrypted:
	$(eval ENCRYPT_BOOT = true)
	@echo "$(SIGN_WARN) Enabling encryption for EBS volumes"

.PHONY: force
force:
	$(eval PACKER_FORCE := -force)
	$(EVAL FORCE_DEREGISTER := true)
	@echo "Enabling forced building mode for Packer"
	@echo "$(STYLE_WARN)WARN: this will overwrite existing artifacts.$(STYLE_OFF)"
	@echo

.PHONY: on-error
	$(eval PACKER_ONERROR := -on-error=$(ON_ERROR)) \
	@echo "Setting on-error mode to \`$(ON_ERROR)\`"

PACKER= \
	export AWS_PROFILE="$(AWS_PROFILE)" && \
	packer \
		build \
			$(PACKER_DEBUG) \
			$(PACKER_FORCE) \
			$(PACKER_ONERROR) \
			-var "ansible_debug=$(ANSIBLE_DEBUG)" \
			-var "ansible_group=$(ANSIBLE_GROUP)" \
			-var "ansible_tags_skip=$(ANSIBLE_TAGS_SKIP)" \
			-var "delete_on_termination=$(DELETE_ON_TERMINATION)" \
			-var "encrypt_boot=$(ENCRYPT_BOOT)" \
			-var "force_deregister=$(FORCE_DEREGISTER)" \
			-var "instance_type=$(INSTANCE_TYPE)" \
			-var "keep_releases=$(KEEP_RELEASES)" \
			-var "region=$(AWS_REGION)" \
			-var "shutdown_behavior=$(shutdown_behavior)" \
			-var "sftp_command=$(SFTP_COMMAND)" \
      -var "source_ami_most_recent=$(SOURCE_AMI_MOST_RECENT)" \
      -var "source_ami_virtualization_type=$(SOURCE_AMI_VIRTUALIZATION_TYPE)" \
      -var "source_ami_root_device_type=$(SOURCE_AMI_ROOT_DEVICE_TYPE)" \
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

# BEGIN: check for `golang` availability
	@echo
	@echo "Go"

ifeq ($(GO_AVAILABLE), true)
	@echo "$(SIGN_OK) found binary at \"$(GO_PATH)\""
	@echo "$(SIGN_OK) found version \"$(GO_VERSION)\""
else
	@echo "$(SIGN_ERR) unable to find \"go\""
	@EXIT_WITH_ERROR = true
endif
# END: check for `golang` availability

# BEGIN: check for `ruby` availability
	@echo
	@echo "Ruby"

ifeq ($(RUBY_AVAILABLE), true)
	@echo "$(SIGN_OK) found binary at \"$(RUBY_PATH)\""
	@echo "$(SIGN_OK) found version \"$(RUBY_VERSION)\""
else
	@echo "$(SIGN_ERR) unable to find \"ruby\""
	@EXIT_WITH_ERROR = true
endif
# END: check for `ruby` availability

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

	@echo

ifeq ($(EXIT_WITH_ERROR), true)
	exit 1
endif

.PHONY: install-dependencies
install-dependencies:
	@echo && \
	echo "Installing dependencies..." && \
	echo && \
	if [ ! -d "$(PACKER_PLUGIN_PATH)" ]; then mkdir -p "$(PACKER_PLUGIN_PATH)"; fi && \
	export GOPATH="$(HOME)/.go" && \
	go get "$(PACKER_PROVISIONER_1)" && \
	cp "$$GOPATH/bin/$(shell basename $(PACKER_PROVISIONER_1))" "$(PACKER_PLUGIN_PATH)" && \
	go get "$(PACKER_POSTPROCESSOR_1)" && \
	cp "$$GOPATH/bin/$(shell basename $(PACKER_POSTPROCESSOR_1))" "$(PACKER_PLUGIN_PATH)" && \
	echo "$(SIGN_OK) installed Packer plugins in \`$(PACKER_PLUGIN_PATH)\`" && \
	echo  && \
	ansible-playbook \
		$(ANSIBLE_DEBUG) \
		--extra-vars="role_file=$(ANSIBLE_ROLE_FILE) roles_path=$(ANSIBLE_ROLES_PATH)" \
		"$(PLAYBOOKS_DIR)/prep-control-master.yml" && \
	echo  && \
	echo "$(SIGN_OK) installed Ansible Roles"

.PHONY: base
base:
	@echo && \
	echo "Building \`$(AMI_SLUG_BASE)\` image" && \
	echo && \
	$(PACKER) \
		-var "ami_name=$(AMI_NAME_BASE)$(AMI_NAME_SUFFIX_ENCRYPTED)" \
		-var "ami_description=$(AMI_DESCRIPTION_BASE)" \
		-var "ami_slug=$(AMI_SLUG_BASE)" \
		-var "playbook_file=$(PLAYBOOK_FILE_BASE)" \
		-var "rspec_target=$(RSPEC_TARGET_BASE)" \
    -var "source_ami_name=$(SOURCE_AMI_NAME_BASE)" \
    -var "source_ami_owner=$(SOURCE_AMI_OWNER_BASE)" \
		"image.json"

.PHONY: ssm
ssm:
	@echo && \
	echo "Building \`$(AMI_SLUG_SSM)\` image" && \
	echo && \
	$(PACKER) \
		-var "ami_name=$(AMI_NAME_SSM)" \
		-var "ami_description=$(AMI_DESCRIPTION_SSM)" \
		-var "ami_slug=$(AMI_SLUG_SSM)" \
		-var "playbook_file=$(PLAYBOOK_FILE_SSM)" \
		-var "rspec_target=$(RSPEC_TARGET_SSM)" \
		-var "source_ami_name=$(SOURCE_AMI_NAME_SSM)" \
    -var "source_ami_owner=$(SOURCE_AMI_OWNER_SSM)" \
		"image.json"
