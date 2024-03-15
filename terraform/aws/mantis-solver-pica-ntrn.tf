variable "live_config_path_1" {
  type        = string
  description = "Path to the live NixOS config we want to deploy"
}

variable "MANTIS_COSMOS_MNEMONIC_1" {
  type      = string
  sensitive = true
}

resource "local_sensitive_file" "ssh_key_1" {
  content  = base64decode(var.CI_SSH_KEY)
  filename = "${path.module}/.terraform/${aws_instance.mantis_server_ntrn.public_dns}"
}

data "template_file" "mantis-solver-pica-ntrn-env" {
  template = "${file("${path.module}/env.tpl")}"
  vars = {
    MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_1
  }
}

resource "local_sensitive_file" "mantis-solver-pica-ntrn-env" {
  depends_on = [ 
    var.MANTIS_COSMOS_MNEMONIC_1 
    ]

  content = data.template_file.mantis-solver-pica-ntrn-env.rendered
  filename = "${path.module}/.terraform/1.env"

}


# resource "null_resource" "mantis_server_ntrn_deploy" {
#   triggers = {
#     live_config_path       = var.live_config_path_1
#     public_dns             = aws_instance.mantis_server_ntrn.public_dns
#     MANTIS_COSMOS_MNEMONIC = var.MANTIS_COSMOS_MNEMONIC_1
#   }

#   depends_on = [ aws_instance.mantis_server_ntrn ]

#   provisioner "local-exec" {
#     on_failure = fail
#     command = <<-EOT
#       ssh-keyscan ${aws_instance.mantis_server_ntrn.public_dns} >> ~/.ssh/known_hosts
#       export NIX_SSHOPTS="-i ${local_sensitive_file.ssh_key_1.filename}"
            
#       nix-copy-closure $TARGET ${var.live_config_path_1}          
#       scp -i ${local_sensitive_file.ssh_key_1.filename} ${local_sensitive_file.mantis-solver-pica-ntrn-env.filename} $TARGET:/root/.env
#       ssh -i ${local_sensitive_file.ssh_key_1.filename} $TARGET '${var.live_config_path_1}/bin/switch-to-configuration switch && nix-collect-garbage'
#       EOT
#     environment = {
#       TARGET = "root@${aws_instance.mantis_server_ntrn.public_dns}"
#     }
#   }
# }

output "MANTIS_SERVER_NTRN_PUBLIC_DNS" {
  value = aws_instance.mantis_server_ntrn.public_dns
}

resource "aws_instance" "mantis_server_ntrn" {
  root_block_device {
    volume_size = 128
  }
  ami                    = aws_ami.mantis_ami.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.mantis_security_group.id]

    provisioner "local-exec" {
    command = "sleep 30 && ssh-keygen -R ${self.public_dns} && ssh-keyscan ${self.public_dns} >> ~/.ssh/known_hosts"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = all# really need to ignore unrelevant only
  }
}