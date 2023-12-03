# Define required providers, AWS and PGP
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 3.0"
    }

    pgp = {
      source = "ekristen/pgp"
    }
  }
}
# Set AWS provider configuration
provider "aws" {
  region = "ap-northeast-2"
}

# IAM Groups
resource "aws_iam_group" "administrator" {
  name = "Administrator"
  path = "/users/"
}

resource "aws_iam_group" "management" {
  name = "Management"
  path = "/users/"
}

resource "aws_iam_group" "devops" {
  name = "Devops"
  path = "/users/"
}

resource "aws_iam_group" "contractor" {
  name = "Contractor"
  path = "/users/"
}

# IAM Users
resource "aws_iam_user" "darth_sidious" {
  name = "DarthSidious"
  path = "/users/"
}

resource "aws_iam_user" "darth_vader" {
  name = "DarthVader"
  path = "/users/"
}

resource "aws_iam_user" "darth_tyranus" {
  name = "DarthTyranus"
  path = "/users/"
}

resource "aws_iam_user" "darth_maul" {
  name = "DarthMaul"
  path = "/users/"
}

# Add Users to IAM Groups
resource "aws_iam_user_group_membership" "darth_sidious_membership" {
  user  = aws_iam_user.darth_sidious.name
  groups = [aws_iam_group.administrator.name]
}

resource "aws_iam_user_group_membership" "darth_vader_membership" {
  user  = aws_iam_user.darth_vader.name
  groups = [aws_iam_group.management.name]
}

resource "aws_iam_user_group_membership" "darth_tyranus_membership" {
  user  = aws_iam_user.darth_tyranus.name
  groups = [aws_iam_group.devops.name]
}

resource "aws_iam_user_group_membership" "darth_maul_membership" {
  user  = aws_iam_user.darth_maul.name
  groups = [aws_iam_group.contractor.name]
}

# IAM Policies
variable "admin_policy_json" {
  default = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
JSON
}

variable "management_policy_json" {
  default = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "billing:*",
        "ec2:*",
        "cognito-identity:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
JSON
}

variable "devops_policy_json" {
  default = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "organizations:DescribeOrganization",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
JSON
}

variable "contractor_policy_json" {
  default = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:Describe*",
      "Resource": "*"
    }
  ]
}
JSON
}


# IAM Group Policies
resource "aws_iam_group_policy" "admin_policy" {
  name   = "admin_policy"
  group  = aws_iam_group.administrator.name
  policy = var.admin_policy_json
}

resource "aws_iam_group_policy" "management_policy" {
  name   = "management_policy"
  group  = aws_iam_group.management.name
  policy = var.management_policy_json
}

resource "aws_iam_group_policy" "devops_policy" {
  name   = "devops_policy"
  group  = aws_iam_group.devops.name
  policy = var.devops_policy_json
}

resource "aws_iam_group_policy" "contractor_policy" {
  name   = "contractor_policy"
  group  = aws_iam_group.contractor.name
  policy = var.contractor_policy_json
}


locals {
  users = {
    "DarthSidious" = {
      name = "DarthSidious"
      email = "darth.sidious@example.com"
      pgp_key = "PGP KEY FOR DARTH SIDIOUS"
    }
    "DarthVader" = {
      name = "DarthVader"
      email = "darth.vader@example.com"
      pgp_key = "PGP KEY FOR DARTH VADER"
    }
    "DarthTyranus" = {
      name = "DarthTyranus"
      email = "darth.tyranus@example.com"
      pgp_key = "PGP KEY FOR DARTH TYRANUS"
    }
    "DarthMaul" = {
      name = "DarthMaul"
      email = "darth.maul@example.com"
      pgp_key = "PGP KEY FOR DARTH MAUL"
    }
  }
}


locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = "us-west-2"  # Replace with your desired AWS region
  console_link   = "https://${var.aws_account_id}.signin.aws.amazon.com/console"
}

data "aws_caller_identity" "current" {}
#
output "console_link" {
  value = local.console_link
}

#resource "local_file" "console_link_txt_file" {
#  content  = local.console_link
#  filename = "console_link.txt"
#}

variable "aws_account_id" {

  description = "AWS Account ID"
  #default     = "your_actual_default_value"
}

output "password_change_prompt" {
  value = "You will be prompted to change your password upon your initial login."
}





resource "aws_iam_access_key" "darth_sidious_access_key" {
  user = aws_iam_user.darth_sidious.name
  depends_on = [aws_iam_user.darth_sidious]
}

resource "pgp_key" "darth_sidious_login_key" {
  name = "DarthSidious"
  email = "darth.siduos@example.com"
  comment = "PGP Key for DarthSidious"
}

resource "aws_iam_user_login_profile" "darth_sidious_login" {
  user = aws_iam_user.darth_sidious.name
  pgp_key = pgp_key.darth_sidious_login_key.public_key_base64
  password_reset_required = true

  depends_on = [
    aws_iam_user.darth_sidious,
    pgp_key.darth_sidious_login_key,
  ]

}

data "pgp_decrypt" "darth_sidious_password_decrypt" {
  ciphertext = aws_iam_user_login_profile.darth_sidious_login.encrypted_password
  ciphertext_encoding = "base64"
  private_key = pgp_key.darth_sidious_login_key.private_key
}


output "darth_sidious_credentials" {
  value = {
    "DarthSidious" = {
      "console_link" = local.console_link
      "key"      = aws_iam_access_key.darth_sidious_access_key.id
      "secret"   = aws_iam_access_key.darth_sidious_access_key.secret
      "password" = data.pgp_decrypt.darth_sidious_password_decrypt.plaintext
    }
  }
  sensitive = true
}


output "darth_sidious_username" {
  value       = local.users["DarthSidious"].name
  description = "The username of Darth Sidious."
}

resource "local_file" "DarthSidious_username_txt_file" {
  content = local.users["DarthSidious"].name
  filename = "DarthSidious_username.txt"
}

output "darth_sidious_password" {
  value       = data.pgp_decrypt.darth_sidious_password_decrypt.plaintext
  description = "The Login Password"
  sensitive = true
}

resource "local_file" "password_txt_file" {
  content = data.pgp_decrypt.darth_sidious_password_decrypt.plaintext
  filename = "DarthSidious_password.txt"
}

resource "local_file" "DarthSidious_combined_credentials" {
  content = <<EOF
  Console_Link:  = ${local.console_link}
  Username: ${local_file.DarthSidious_username_txt_file.content}
  Password: ${data.pgp_decrypt.darth_sidious_password_decrypt.plaintext}
  EOF
  filename = "DarthSidious_combined_credentials.txt"
}

resource "aws_iam_access_key" "darth_vader_access_key" {
  user = aws_iam_user.darth_vader.name
  depends_on = [aws_iam_user.darth_vader]
}

resource "pgp_key" "darth_vader_login_key" {
  name    = "DarthVader"
  email   = "darth.vader@example.com"
  comment = "PGP Key for DarthVader"
}

resource "aws_iam_user_login_profile" "darth_vader_login" {
  user                   = aws_iam_user.darth_vader.name
  pgp_key                = pgp_key.darth_vader_login_key.public_key_base64
  password_reset_required = true

  depends_on = [
    aws_iam_user.darth_vader,
    pgp_key.darth_vader_login_key,
  ]
}

data "pgp_decrypt" "darth_vader_password_decrypt" {
  ciphertext          = aws_iam_user_login_profile.darth_vader_login.encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.darth_vader_login_key.private_key
}

output "darth_vader_credentials" {
  value = {
    "DarthVader" = {
      "key"      = aws_iam_access_key.darth_vader_access_key.id
      "secret"   = aws_iam_access_key.darth_vader_access_key.secret
      "password" = data.pgp_decrypt.darth_vader_password_decrypt.plaintext
    }
  }
  sensitive = true
}

output "darth_vader_username" {
  value       = local.users["DarthVader"].name
  description = "The username of Darth Vader."
}

resource "local_file" "DarthVader_username_txt_file" {
  content = local.users["DarthVader"].name
  filename = "DarthVader_username.txt"
}


output "darth_vader_password" {
  value       = data.pgp_decrypt.darth_vader_password_decrypt.plaintext
  description = "The Login Password"
  sensitive = true
}

resource "local_file" "DarthVader_password_txt_file" {
  content = data.pgp_decrypt.darth_vader_password_decrypt.plaintext
  filename = "DarthVader_password.txt"
}


resource "local_file" "DarthVader_combined_credentials" {
  content = <<EOF
  Console_Link:  = ${local.console_link}
  Username: ${local_file.DarthVader_username_txt_file.content}
  Password: ${data.pgp_decrypt.darth_vader_password_decrypt.plaintext}
  EOF
  filename = "DarthVader_combined_credentials.txt"
}



resource "aws_iam_access_key" "darth_tyranus_access_key" {
  user = aws_iam_user.darth_tyranus.name
  depends_on = [aws_iam_user.darth_tyranus]
}

resource "pgp_key" "darth_tyranus_login_key" {
  name    = "DarthTyranus"
  email   = "darth.tyranus@example.com"
  comment = "PGP Key for DarthTyranus"
}

resource "aws_iam_user_login_profile" "darth_tyranus_login" {
  user                   = aws_iam_user.darth_tyranus.name
  pgp_key                = pgp_key.darth_tyranus_login_key.public_key_base64
  password_reset_required = true

  depends_on = [
    aws_iam_user.darth_tyranus,
    pgp_key.darth_tyranus_login_key,
  ]
}

data "pgp_decrypt" "darth_tyranus_password_decrypt" {
  ciphertext          = aws_iam_user_login_profile.darth_tyranus_login.encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.darth_tyranus_login_key.private_key
}

output "darth_tyranus_credentials" {
  value = {
    "DarthTyranus" = {
      "key"      = aws_iam_access_key.darth_tyranus_access_key.id
      "secret"   = aws_iam_access_key.darth_tyranus_access_key.secret
      "password" = data.pgp_decrypt.darth_tyranus_password_decrypt.plaintext
    }
  }
  sensitive = true
}

output "darth_tyranus_username" {
  value       = local.users["DarthTyranus"].name
  description = "The username of Darth Tyranus."
}

resource "local_file" "DarthTyranus_username_txt_file" {
  content = local.users["DarthTyranus"].name
  filename = "DarthTyranus_username.txt"
}

output "darth_tyranus_password" {
  value       = data.pgp_decrypt.darth_tyranus_password_decrypt.plaintext
  description = "The Login Password"
  sensitive = true
}

resource "local_file" "DarthTyranus_password_txt_file" {
  content = data.pgp_decrypt.darth_tyranus_password_decrypt.plaintext
  filename = "DarthTyranus_password.txt"
}


resource "local_file" "DarthTyranus_combined_credentials" {
  content = <<EOF
  Console_Link:  = ${local.console_link}
  Username: ${local_file.DarthTyranus_username_txt_file.content}
  Password: ${data.pgp_decrypt.darth_tyranus_password_decrypt.plaintext}
  EOF
  filename = "DarthTyranus_combined_credentials.txt"
}





resource "aws_iam_access_key" "darth_maul_access_key" {
  user = aws_iam_user.darth_maul.name
  depends_on = [aws_iam_user.darth_maul]
}

resource "pgp_key" "darth_maul_login_key" {
  name    = "DarthMaul"
  email   = "darth.maul@example.com"
  comment = "PGP Key for DarthMaul"
}

resource "aws_iam_user_login_profile" "darth_maul_login" {
  user                   = aws_iam_user.darth_maul.name
  pgp_key                = pgp_key.darth_maul_login_key.public_key_base64
  password_reset_required = true

  depends_on = [
    aws_iam_user.darth_maul,
    pgp_key.darth_maul_login_key,
  ]
}

data "pgp_decrypt" "darth_maul_password_decrypt" {
  ciphertext          = aws_iam_user_login_profile.darth_maul_login.encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.darth_maul_login_key.private_key
}


output "darth_maul_credentials" {
  value = {
    "DarthMaul" = {
      "key"      = aws_iam_access_key.darth_maul_access_key.id
      "secret"   = aws_iam_access_key.darth_maul_access_key.secret
      "password" = data.pgp_decrypt.darth_maul_password_decrypt.plaintext
    }
  }
  sensitive = true
}

output "darth_maul_username" {
  value       = local.users["DarthMaul"].name
  description = "The username of Darth Maul."
}
resource "local_file" "DarthMaul_username_txt_file" {
  content = local.users["DarthMaul"].name
  filename = "DarthMaul_username.txt"
}

output "darth_maul_password" {
  value       = data.pgp_decrypt.darth_maul_password_decrypt.plaintext
  description = "The Login Password"
  sensitive = true
}

resource "local_file" "DarthMaul_password_txt_file" {
  content = data.pgp_decrypt.darth_maul_password_decrypt.plaintext
  filename = "DarthMaul_password.txt"
}

resource "local_file" "DarthMaul_combined_credentials" {
  content = <<EOF
  Console_Link:  = ${local.console_link}
  Username: ${local_file.DarthMaul_username_txt_file.content}
  Password: ${data.pgp_decrypt.darth_maul_password_decrypt.plaintext}
  EOF
  filename = "DarthMaul_combined_credentials.txt"
}

