variable "live_config_path_0" {
  type        = string
  description = "Path to the live NixOS config we want to deploy"
}

variable "MANTIS_COSMOS_MNEMONIC_0" {
  type = string
  sensitive = true
}

resource "local_sensitive_file" "ssh_key" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.mantis_server.public_dns}"
}

resource "local_sensitive_file" "env_0" {
  content  = "export MANTIS_COSMOS_MNEMONIC='${var.MANTIS_COSMOS_MNEMONIC_0}'"
  filename = "${path.module}/.terraform/0.env"
}


resource "null_resource" "nixos_deployment" {
  triggers = {
    live_config_path_0 = var.live_config_path_0
    public_dns = aws_instance.mantis_server.public_dns
    MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_0
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh-keyscan ${aws_instance.mantis_server.public_dns} >> ~/.ssh/known_hosts
      export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key.filename}"
            
      nix-copy-closure $TARGET ${var.live_config_path_0}          
      scp -i ${local_sensitive_file.ssh_key.filename} ${local_sensitive_file.env_0.filename} $TARGET:/root/.env
      ssh -i ${local_sensitive_file.ssh_key.filename} $TARGET '${var.live_config_path_0}/bin/switch-to-configuration switch && nix-collect-garbage'
      EOT
    environment = {
      TARGET = "root@${aws_instance.mantis_server.public_dns}"
    }
  }
}

output "public_ip" {
  value = aws_instance.mantis_server.public_dns
}

resource "aws_instance" "mantis_server" {
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      private_key = base64decode(var.CI_SSH_KEY)
    }
    inline = [ "echo 'SSH confirmed!'" ]
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${self.public_ip} >> ~/.ssh/known_hosts"
  }

  lifecycle {
    ignore_changes = all
  }
}