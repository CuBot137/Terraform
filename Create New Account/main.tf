# Set up provider
terraform {
  backend "s3" {
    profile = "conor"
    bucket  = "terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-central-1"  
  }
  required_version = "~> 1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    profile = "conor"
    region = "eu-central-1"
  
}
# Choose account alias
resource "aws_iam_account_alias" "alias" {
  account_alias = "conor-terraform"
}

# Create console users group
resource "aws_iam_group" "console_group"{
    name = "console"
}

# Create admin group
resource "aws_iam_group" "admin_group"{
    name = "admin"
}

resource "aws_iam_group_policy_attachment" "admin_attach"{
    group = aws_iam_group.admin_group.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Set password policy
resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = 32
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

# Enforce MFA
data "aws_caller_identity" "current"{}

module "enforce_mfa"{
    source = "terraform-module/enforce-mfa/aws"
    version = "0.12.5"
    policy_name = "managed-mfa-enforce"
    account_id = data.aws_caller_identity.current.account_id
    groups = [aws_iam_group.console_group.name]
    manage_own_signing_certificates = true
    manage_own_ssh_public_keys      = true
    manage_own_git_credentials      = true
}

# Create users
locals{
    users = [
        {
            name = "conor.lynam@zinkworks.com"
            groups = [aws_iam_group.admin_group.name]
        },
        {
            name = "shauna.martyn@zinkworks.com"
            groups = [aws_iam_group.console_group.name]
        }
    ]
}
resource "aws_iam_user" "user" {
    for_each = { for user in local.users : user.name => user}
    name = each.value.name
}

resource "aws_iam_user_group_membership" "user_group_membership" {
    for_each = { for user in local.users : user.name => user}
    user = aws_iam_user.user[each.key].name
    groups = each.value.groups
    depends_on = [
        aws_iam_user.user
    ]
}

# Set up budget alerts
locals {
  budget_alert_emails = [
    "conor.lynam@zinkworks.com",
    "shauna.martyn@zinkworks.com"
  ]
}

resource "aws_budgets_budget" "daily_budget" {
  name              = "daily-budget"
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "EUR"
  time_period_start = "2021-01-01_00:00"
  time_period_end   = "2085-01-01_00:00"
  time_unit         = "DAILY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.budget_alert_emails
  }
}

resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "50.0"
  limit_unit        = "EUR"
  time_period_end   = "2085-01-01_00:00"
  time_period_start = "2021-01-01_00:00"
  time_unit         = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = local.budget_alert_emails
  }
}