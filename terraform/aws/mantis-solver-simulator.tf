variable "MANTIS_SOLVER_SIMULATOR_CONFIG" {
  type        = string
  description = "Path to the live NixOS config we want to deploy"
}

variable "MANTIS_COSMOS_MNEMONIC_SOLVER_SIMULATOR" {
  type      = string
  sensitive = true
}

resource "local_sensitive_file" "ssh_key_1" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns}"
}

data "template_file" "MANTIS_SOLVER_SIMULATOR_ENV" {
  template = "${file("${path.module}/env.tpl")}"
  vars = {
    MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_SOLVER_SIMULATOR
  }
}

resource "local_sensitive_file" "MANTIS_SOLVER_SIMULATOR_ENV" {
  depends_on = [ 
    var.MANTIS_COSMOS_MNEMONIC_SOLVER_SIMULATOR 
    ]

  content = data.template_file.MANTIS_SOLVER_SIMULATOR_ENV.rendered
  filename = "${path.module}/.terraform/1.env"
}

output "MANTIS_SOLVER_SIMULATOR_PUBLIC_DNS" {
  value = aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns
}

resource "aws_instance" "MANTIS_SOLVER_SIMULATOR" {
  root_block_device {
    volume_size = 128
  }
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

  lifecycle {
    ignore_changes = all# really need to ignore unrelevant only
  }
}

resource "ssh_resource" "MANTIS_SOLVER_SIMULATOR_DEPLOY" {
  host= aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns 
  user = "root"
  private_key = local_sensitive_file.ssh_key_1.filename
  commands = [
    "echo 42"
  ]

  provisioner "local-exec" {
    command = "ssh-keygen -R ${aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns} && ssh-keyscan ${aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns} >> ~/.ssh/known_hosts"
    when = create
    on_failure = fail
  }
}

resource "null_resource" "MANTIS_SOLVER_SIMULATOR_DEPLOY" {
  triggers = {
    MANTIS_SOLVER_SIMULATOR_CONFIG       = var.MANTIS_SOLVER_SIMULATOR_CONFIG
    MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_SOLVER_SIMULATOR
  }

  depends_on = [ ssh_resource.MANTIS_SOLVER_SIMULATOR_DEPLOY ]

  provisioner "local-exec" {
    on_failure = fail
    command = <<-EOT
      export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key_1.filename}"
      nix-copy-closure $TARGET ${var.MANTIS_SOLVER_SIMULATOR_CONFIG}          
      scp -i ${local_sensitive_file.ssh_key_1.filename} ${local_sensitive_file.MANTIS_SOLVER_SIMULATOR_ENV.filename} $TARGET:/root/.env
      ssh -i ${local_sensitive_file.ssh_key_1.filename} $TARGET '${var.MANTIS_SOLVER_SIMULATOR_CONFIG}/bin/switch-to-configuration switch && nix-collect-garbage'
      EOT
    environment = {
      TARGET = "root@${aws_instance.MANTIS_SOLVER_SIMULATOR.public_dns}"
    }
  }
}