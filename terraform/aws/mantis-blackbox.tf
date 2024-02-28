variable "MANTIS_BLACKBOX_CONFIG_PATH" {
  type = string
}

resource "local_sensitive_file" "ssh_key_blackbox" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.mantis_blackbox.public_dns}"
}


resource "null_resource" "mantis_blackbox_deployment" {
  triggers = {
    image = var.MANTIS_BLACKBOX_CONFIG_PATH
    host  = aws_instance.mantis_blackbox.public_dns
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh-keyscan ${aws_instance.mantis_blackbox.public_dns} >> ~/.ssh/known_hosts
      export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key_blackbox.filename}"            
      nix-copy-closure $TARGET ${var.MANTIS_BLACKBOX_CONFIG_PATH}          
      ssh -i ${local_sensitive_file.ssh_key_blackbox.filename} $TARGET '${var.MANTIS_BLACKBOX_CONFIG_PATH}/bin/switch-to-configuration switch && nix-collect-garbage'
      EOT
    environment = {
      TARGET = "root@${aws_instance.mantis_blackbox.public_dns}"
    }
  }
}

output "MANTIS_BLACKBOX_PUBLIC_HOST" {
  value = aws_instance.mantis_blackbox.public_dns
}

resource "aws_instance" "mantis_blackbox" {
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      private_key = base64decode(var.CI_SSH_KEY)
    }
    inline = ["echo 'SSH confirmed!'"]
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${self.public_ip} >> ~/.ssh/known_hosts"
  }

  lifecycle {
    ignore_changes = all
  }
}