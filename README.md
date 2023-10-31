# AWS Spot DevKit

This repo will let you launch a dev machine on aws with cheap cost (spot).

Edit main.tf and configuration.nix before launch.

## Usage

```bash
make launch # launch instance
make build  # build nixos
make        # connect and dev
make del    # del instance
```
