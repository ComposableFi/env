terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    ssh = {
      source = "loafoe/ssh"
      version = "2.7.0"
    }    
  }
  required_version = ">= 1.2.0"
}


terraform {
  backend "s3" {
    bucket = "composablefi-env-terraform-aws"
    key    = "default"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "bootstrap_img_path" {
  description = "Path to the server bootstrap image."
  type        = string
}

variable "CI_SSH_KEY" {
  type      = string
  sensitive = true
}



resource "aws_security_group" "mantis_security_group" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ami" "mantis_ami" {
  name                = "mantis_server_ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot_import.mantis_import.id
  }
}

resource "aws_s3_bucket" "mantis_bucket" {

}

resource "aws_s3_object" "image_upload" {
  bucket = aws_s3_bucket.mantis_bucket.id
  key    = "nixos_bootstrap.vhd"
  source = var.bootstrap_img_path
}

resource "aws_ebs_snapshot_import" "mantis_import" {
  role_name = aws_iam_role.vmimport_role.id
  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = aws_s3_bucket.mantis_bucket.id
      s3_key    = aws_s3_object.image_upload.id
    }
  }
  lifecycle {
    replace_triggered_by = [
      aws_s3_object.image_upload
    ]
  }
}

resource "aws_iam_role_policy_attachment" "vmpimport_attach" {
  role       = aws_iam_role.vmimport_role.id
  policy_arn = aws_iam_policy.vmimport_policy.arn
}

resource "aws_iam_role" "vmimport_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "vmie.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:Externalid" = "vmimport"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "vmimport_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.mantis_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.mantis_bucket.id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:ModifySnapshotAttribute",
          "ec2:CopySnapshot",
          "ec2:RegisterImage",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

