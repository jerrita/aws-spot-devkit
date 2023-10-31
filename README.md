# AWS Spot DevKit

This repo will let you launch a dev machine on aws with cheap cost (spot).

Edit main.tf and configuration.nix before launch.

You may need to allocate a ipv6 cidr on default VPC before using.

## Usage

```bash
make launch       # launch instance
make host/host6   # select connection type (ipv4/v6)
make build        # build nixos
make              # connect and dev
make del          # del instance
```
