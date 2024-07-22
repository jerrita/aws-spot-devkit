run: conn

launch:
	terraform init
	terraform apply

host:
	ssh-keygen -R dev
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ip.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts

host6:
	ssh-keygen -R dev
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ipv6.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts 

build:
	terraform output -json | jq -r '.private_key.value' > edkey
	chmod 600 edkey
	scp -i edkey -r ./nixos root@dev:/etc
	ssh -i edkey root@dev "nix-shell -p cachix --run \"cachix use jerrita\" && nixos-rebuild switch"
	ssh dev "mkdir -p ~/.ssh && touch ~/.zshrc"
	scp ~/.ssh/id_rsa dev:~/.ssh

conn:
	ssh dev

del:
	terraform destroy

clean:
	rm *.tfstate*
	rm edkey
