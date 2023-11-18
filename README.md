

# How this was setup?

Created AWS S3 storage buckets to store Terraform states.s

Added some SSH private key and some stash derived crypto accounts and limited AWS credentials to CI.

These are used to setup infrastructure via Terraform.

# How each node instance deployed?

On top of base Terraform instance template build from NixOs,
NixOs with configuration for specific node is activated via SSH.

Relevant crypto mnemonics are mounted from CI.

SSH key of node "owner" is mounted to machine for debugging.

**On PR Terraform plans infra deployment and NixOs version activation**

**On PUSH Terraform plan applied, along with NixOs new version**

All machines are built locally and run via QEMU. Linux only.