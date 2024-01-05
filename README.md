

# How this was setup?

Created AWS S3 storage buckets to store Terraform states.

Added some SSH private key and some stash derived crypto accounts and limited AWS credentials to CI.

These are used to setup infrastructure via Terraform and give unique identities to running nodes.

# How each node instance deployed?

On top of base Terraform instance template build from NixOs,
NixOs with configuration for specific node is activated via SSH.

Relevant crypto mnemonics are mounted from CI.

SSH key of node "owner" is authorized to machine for debugging (and even out if CI immutable deploy from same nix file from local machine).

**On PR Terraform plans infra deployment and NixOs version activation**

**On PUSH Terraform plan applied, along with NixOs new version**

All machines are built locally and run via QEMU. Linux only.


# Why it the way it is ?

Kudos to this person https://jonascarpay.com/posts/2022-09-19-declarative-deployment.html and my several attempt doing nix+tf all the ways possible.

Here is summary of my attempts https://discourse.nixos.org/t/unknown-values-propagation-in-nix-like-in-hcl/26743

Also this one https://github.com/Effect-TS/infra was set is analog of this repo in general. 

# Security

Sure I should also setup security advisory to GitHub hooks and other scanners, to check TF and NIX must not leak secrets, I just did not. 

Nothing ~~big money~~ serious is in run for now :)

Anyway bots on cold wallet should tip only needed for operation for hot. 

Use stash rotating accounts for real CryptoOps, etc.
