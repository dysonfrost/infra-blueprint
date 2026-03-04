#!make
SHELL := /bin/bash

ASG_NAME             = $(shell cd terraform && terraform output -raw asg_name)
INVENTORY_FILE       = ansible/inventory.ini
SSH_CONFIG_FILE      = ansible/.ssh_config
SSH_PRIVATE_KEY_PATH ?= $(HOME)/.ssh/infra-blueprint.pem

.PHONY: help init plan apply destroy inventory ping deploy ssh-config get-key

help:
	@printf "Usage: source .env && make <target>\n\nTargets:\n\
	  get-key     Retrieve private key from SSM Parameter Store\n\
	  ssh-config  Generate .ssh_config file for SSM tunneling\n\
	  init        Initialize Terraform\n\
	  plan        Preview infrastructure changes\n\
	  apply       Provision infrastructure\n\
	  inventory   Generate Ansible inventory from running ASG instances\n\
	  ping        Verify SSH connectivity to all instances\n\
	  deploy      Full Ansible deployment (inventory + playbook)\n\
	  destroy     Tear down all infrastructure\n"

get-key:
	@rm -f $(SSH_PRIVATE_KEY_PATH) && \
	aws ssm get-parameter \
		--name "/infra-blueprint/ec2/private-key" \
		--with-decryption \
		--query "Parameter.Value" \
		--output text > $(SSH_PRIVATE_KEY_PATH) && \
	chmod 400 $(SSH_PRIVATE_KEY_PATH) && \
	echo "Private key saved to $(SSH_PRIVATE_KEY_PATH)"

ssh-config:
	@printf "Host i-* mi-*\n\
	  ProxyCommand sh -c \"aws ssm start-session --target %%h --document-name AWS-StartSSHSession --parameters 'portNumber=%%p'\"\n\
	  User ubuntu\n\
	  IdentityFile $(SSH_PRIVATE_KEY_PATH)\n" > $(SSH_CONFIG_FILE) && \
	echo "SSH config generated at $(SSH_CONFIG_FILE)"

init:
	@cd terraform && terraform init

plan:
	@cd terraform && terraform plan

apply:
	@cd terraform && terraform apply

destroy:
	@cd terraform && terraform destroy

inventory:
	@aws ec2 describe-instances \
		--filters \
			"Name=tag:aws:autoscaling:groupName,Values=$(ASG_NAME)" \
			"Name=instance-state-name,Values=running" \
		--query "Reservations[*].Instances[*].InstanceId" \
		--output text \
		--region $(AWS_REGION) | tr '\t' '\n' > /tmp/instance_ids && \
	printf "[webservers]\n$$(cat /tmp/instance_ids)\n\n[webservers:vars]\nansible_user=ubuntu\nansible_ssh_private_key_file=$(SSH_PRIVATE_KEY_PATH)\n" \
		> $(INVENTORY_FILE) && \
	rm /tmp/instance_ids && \
	echo "Inventory generated at $(INVENTORY_FILE)"

ping:
	@cd ansible && ansible webservers -m ping -i inventory.ini

deploy: inventory
	@cd ansible && ansible-playbook -i inventory.ini playbook.yml
