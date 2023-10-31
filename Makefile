run: conn

.PHONY: launch build conn del

launch:
	terraform init
	terraform apply

build:
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ip.value'))
	terraform output -json | jq -r '.private_key.value' > edkey
	chmod 600 edkey
	scp -i edkey -o StrictHostKeyChecking=no -r configuration.nix root@$(INSTANCE_IP):/etc/nixos/
	ssh -i edkey -o StrictHostKeyChecking=no root@$(INSTANCE_IP) "nixos-rebuild switch"
	scp -i ~/.ssh/edkey -o StrictHostKeyChecking=no -r ~/.ssh/id_rsa $(INSTANCE_IP):~/.ssh/
	sudo sed -i "s/.* dev/$(INSTANCE_IP) dev/g" /etc/hosts

conn:
	ssh -i ~/.ssh/edkey -o StrictHostKeyChecking=no $(INSTANCE_IP)

del:
	terraform destroy
