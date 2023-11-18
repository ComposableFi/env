variable "live_config_path" {
  type        = string
  description = "Path to the live NixOS config we want to deploy"
}

resource "null_resource" "nixos_deployment" {
  triggers = {
    live_config_path = var.live_config_path
    public_dns = aws_instance.mantis_server.public_dns
    CI_SSH_KEY = var.CI_SSH_KEY
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh-keyscan ${aws_instance.mantis_server.public_dns} >> ~/.ssh/known_hosts
      nix-copy-closure $TARGET ${var.live_config_path}
      echo "${base64decode(var.CI_SSH_KEY)}" > ~/.ssh/${aws_instance.mantis_server.public_dns}
      ssh -i ~/.ssh/${aws_instance.mantis_server.public_dns} $TARGET '${var.live_config_path}/bin/switch-to-configuration switch && nix-collect-garbage'
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