run: conn

launch:
	terraform init
	terraform apply

host:
	ssh-keygen -R dev
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ip.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts  # I'm MacOS, maybe you need change this

host6:
	ssh-keygen -R dev
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ipv6.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts  # I'm MacOS, maybe you need change this

build:
	terraform output -json | jq -r '.private_key.value' > edkey
	chmod 600 edkey
	scp -i edkey -r configuration.nix root@dev:/etc/nixos/
	ssh -i edkey root@dev "nixos-rebuild switch"
	ssh dev "mkdir -p ~/.ssh && touch ~/.zshrc"
	scp -r ~/.ssh/id_rsa dev:~/.ssh/id_rsa

conn:
	ssh dev

del:
	terraform destroy
