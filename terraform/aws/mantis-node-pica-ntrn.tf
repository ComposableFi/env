# variable "MANTIS_COSMOS_MNEMONIC_1" {
#   type = string
#   sensitive = true
# }

# resource "local_sensitive_file" "ssh_key_1" {
#   content  = base64decode(var.CI_SSH_KEY)
#   filename = "${path.module}/.terraform/${aws_instance.mantis_server_1.public_dns}"
# }

# resource "local_sensitive_file" "env_1" {
#   content  = "export MANTIS_COSMOS_MNEMONIC='${var.MANTIS_COSMOS_MNEMONIC}'"
#   filename = "${path.module}/.terraform/1.env"
# }


# resource "null_resource" "nixos_deployment_1" {
#   triggers = {
#     live_config_path = var.live_config_path
#     public_dns = aws_instance.mantis_server_1s.public_dns
#     MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_1
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#       ssh-keyscan ${aws_instance.mantis_server_1.public_dns} >> ~/.ssh/known_hosts
#       export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key_1.filename}"
            
#       nix-copy-closure $TARGET ${var.live_config_path}          
#       scp -i ${local_sensitive_file.ssh_key_.filename} ${local_sensitive_file.env_1.filename} $TARGET:/tmp/.env
#       ssh -i ${local_sensitive_file.ssh_key_1.filename} $TARGET '${var.live_config_path}/bin/switch-to-configuration switch && nix-collect-garbage'
#       EOT
#     environment = {
#       TARGET = "root@${aws_instance.mantis_server_1.public_dns}"
#     }
#   }
# }

# output "public_ip_1s" {
#   value = aws_instance.mantis_server_1.public_dns
# }

# resource "aws_instance" "mantis_server_1" {
#   ami                    = aws_ami.mantis_ami.id
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

#   provisioner "remote-exec" {
#     connection {
#       host = self.public_ip
#       private_key = base64decode(var.CI_SSH_KEY)
#     }
#     inline = [ "echo 'SSH confirmed!'" ]
#   }

#   provisioner "local-exec" {
#     command = "ssh-keyscan ${self.public_ip} >> ~/.ssh/known_hosts"
#   }

#   lifecycle {
#     ignore_changes = all
#   }
# }