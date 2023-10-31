run: conn

ami:
	aws ec2 describe-images \
		--region ap-southeast-2 \
		--filters Name=owner-id,Values=080433136561 \
		| jq '.Images | map(select(.Architecture == "arm64")) | sort_by(.CreationDate) | reverse | map({ ImageId, Description }) | .[0]'

launch:
	terraform init
	terraform apply

host:
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ipv6.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts  # I'm MacOS, maybe you need change this

host6:
	$(eval INSTANCE_IP := $(shell terraform output -json | jq -r '.instance_ipv6.value'))
	sudo sed -i "" "s/.*\ dev/$(INSTANCE_IP)\ dev/g" /etc/hosts  # I'm MacOS, maybe you need change this

build:
	terraform output -json | jq -r '.private_key.value' > edkey
	chmod 600 edkey
	scp -i edkey -o StrictHostKeyChecking=no -r configuration.nix root@dev:/etc/nixos/
	ssh -i edkey -o StrictHostKeyChecking=no root@dev "nixos-rebuild switch"
	ssh -o StrictHostKeyChecking=no dev "mkdir -p ~/.ssh && touch ~/.zshrc"
	scp -o StrictHostKeyChecking=no -r ~/.ssh/id_rsa dev:~/.ssh/id_rsa

conn:
	ssh -o StrictHostKeyChecking=no dev

del:
	terraform destroy
