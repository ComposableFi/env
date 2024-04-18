variable "MANTIS_SOLVER_CONFIG_PATH" {
  type        = string
  description = "Path to the live NixOS config we want to deploy"
}

variable "MANTIS_COSMOS_MNEMONIC_SOLVER" {
  type      = string
  sensitive = true
}

resource "local_sensitive_file" "ssh_key" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.MANTIS_SOLVER.public_dns}"
}

resource "local_sensitive_file" "env_0" {
  content  = "export MANTIS_COSMOS_MNEMONIC='${var.MANTIS_COSMOS_MNEMONIC_SOLVER}'"
  filename = "${path.module}/.terraform/0.env"
}

output "MANTIS_SOLVER_PUBLIC_DNS" {
  value = aws_instance.MANTIS_SOLVER.public_dns
}

resource "aws_instance" "MANTIS_SOLVER" {
  root_block_device {
    volume_size = 128
  }  
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]


  lifecycle {
    ignore_changes = all # really need to ignore unrelevant only
  }
}



  # provisioner "local-exec" {
  #   command = "sleep 30 && ssh-keygen -R ${self.public_dns} && ssh-keyscan ${self.public_dns} >> ~/.ssh/known_hosts"
  #   on_failure = continue
  # }




# resource "null_resource" "MANTIS_SOLVER_DEPLOY" {
#   triggers = {
#     MANTIS_SOLVER_CONFIG_PATH     = var.MANTIS_SOLVER_CONFIG_PATH
#     public_dns             = aws_instance.MANTIS_SOLVER.public_dns
#     MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_SOLVER
#   }

#   depends_on = [ aws_instance.MANTIS_SOLVER ]

#   provisioner "local-exec" {
#     command = <<-EOT
#       ssh-keyscan ${aws_instance.MANTIS_SOLVER.public_dns} >> ~/.ssh/known_hosts
#       export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key.filename}"
            
#       nix-copy-closure $TARGET ${var.MANTIS_SOLVER_CONFIG_PATH}          
#       scp -i ${local_sensitive_file.ssh_key.filename} ${local_sensitive_file.env_0.filename} $TARGET:/root/.env
#       ssh -i ${local_sensitive_file.ssh_key.filename} $TARGET '${var.MANTIS_SOLVER_CONFIG_PATH}/bin/switch-to-configuration switch && nix-collect-garbage'
#       EOT
#     environment = {
#       TARGET = "root@${aws_instance.MANTIS_SOLVER.public_dns}"
#     }
#   }
# }