variable "MANTIS_BLACKBOX_CONFIG_PATH" {
  type = string
}

resource "local_sensitive_file" "ssh_key_blackbox" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.MANTIS_BLACKBOX.public_dns}"
}


resource "null_resource" "MANTIS_BLACKBOX_deploy" {
  triggers = {
    image = var.MANTIS_BLACKBOX_CONFIG_PATH
    host  = aws_instance.MANTIS_BLACKBOX.public_dns
  }

  depends_on = [ aws_instance.MANTIS_BLACKBOX ]
  
  provisioner "local-exec" {
    command = <<-EOT
      ssh-keyscan ${aws_instance.MANTIS_BLACKBOX.public_dns} >> ~/.ssh/known_hosts
      export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key_blackbox.filename}"            
      nix-copy-closure $TARGET ${var.MANTIS_BLACKBOX_CONFIG_PATH}          
      ssh -i ${local_sensitive_file.ssh_key_blackbox.filename} $TARGET '${var.MANTIS_BLACKBOX_CONFIG_PATH}/bin/switch-to-configuration switch && nix-collect-garbage'
      EOT
    environment = {
      TARGET = "root@${aws_instance.MANTIS_BLACKBOX.public_dns}"
    }
  }
}

output "MANTIS_BLACKBOX_PUBLIC_HOST" {
  value = aws_instance.MANTIS_BLACKBOX.public_dns
}

resource "aws_instance" "MANTIS_BLACKBOX" {
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.medium"
  root_block_device {
    volume_size = 128
  }
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

  provisioner "local-exec" {
    command = "sleep 30 && ssh-keygen -R ${self.public_dns} && ssh-keyscan ${self.public_dns} >> ~/.ssh/known_hosts"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = all # really need to ignore unrelevant only
  }
}
