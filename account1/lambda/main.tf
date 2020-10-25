#--- lambda/main.tf

#---------------
# Data Providers
#---------------

data "aws_region" "current" { }

data "aws_caller_identity" "current" {}

data "archive_file" "log_event" {
  type        = "zip"
  source_file = "./lambda/log_event.py"
  output_path = "log_event.zip"
}

data "archive_file" "create_snapshot" {
  type        = "zip"
  source_file = "./lambda/create_snapshot.py"
  output_path = "create_snapshot.zip"
}

data "archive_file" "delete_snapshot" {
  type        = "zip"
  source_file = "./lambda/delete_snapshot.py"
  output_path = "delete_snapshot.zip"
}

data "archive_file" "copy_snapshot_to_another_region" {
  type        = "zip"
  source_file = "./lambda/copy_snapshot_to_another_region.py"
  output_path = "copy_snapshot_to_another_region.zip"
}

data "archive_file" "share_snapshot" {
  type        = "zip"
  source_file = "./lambda/share_snapshot.py"
  output_path = "share_snapshot.zip"
}


#-------------------
# Locals
#-------------------
locals {
  region  = data.aws_region.current.name
  account = data.aws_caller_identity.current.account_id
}

#-------------------
# Roles and Policies
#-------------------

resource "aws_iam_role" "log_event" {
    name = format("%s_log_event", var.project_name)

    tags = { 
      Name = format("%s_log_event", var.project_name)
      project_name = var.project_name
    }

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "lambda_logging" {
    name   = "lambda_logging"
    role   = aws_iam_role.log_event.id
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${local.region}:${local.account}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${local.account}:log-group:/aws/lambda/log_event:*"
            ]
        }
    ]
}
POLICY
}

# resource "aws_iam_role_policy_attachment" "ENI-Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
#   role       = aws_iam_role.log_event.id
# }


resource "aws_iam_role" "lambda_snapshot" {
    name = format("%s_lambda_snapshot", var.project_name)

    tags = { 
      Name = format("%s_lambda_snapshot", var.project_name)
      project_name = var.project_name
    }

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "lambda_snapshot" {
    name   = "lambda_snapshot"
    role   = aws_iam_role.lambda_snapshot.id
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${local.region}:${local.account}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${local.region}:${local.account}:log-group:/aws/lambda/log_event:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot",
                "ec2:CopySnapshot",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:ModifySnapshotAttribute",
                "ec2:ResetSnapshotAttribute"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
POLICY
}


#----------------
# Lambda Function
#----------------

resource "aws_lambda_function" "log_event" {
  filename          = "log_event.zip"
  function_name     = "log_event"
  role              = aws_iam_role.log_event.arn
  handler           = "log_event.lambda_handler"
  runtime           = "python3.8"
  description       = "A function to log to CloudWatch."
  source_code_hash  = data.archive_file.log_event.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      "account_id"  = local.account
      "region"      = local.region
    }
  }

#  vpc_config {
#    subnet_ids         = var.subprv_ids
#    security_group_ids = aws_security_group.sg_log_event.*.id
#  }

  tags = { 
    Name = format("%s_log_event", var.project_name)
    project_name = var.project_name
  }
}

resource "aws_lambda_function" "create_snapshot" {
  filename          = "create_snapshot.zip"
  function_name     = "create_snapshot"
  role              = aws_iam_role.lambda_snapshot.arn
  handler           = "create_snapshot.lambda_handler"
  runtime           = "python3.8"
  description       = "A function to create a snapshot."
  source_code_hash  = data.archive_file.create_snapshot.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      "account_id"  = local.account
      "region"      = local.region
    }
  }

  tags = { 
    Name = format("%s_create_snapshot", var.project_name)
    project_name = var.project_name
  }
}

resource "aws_lambda_function" "delete_snapshot" {
  filename          = "delete_snapshot.zip"
  function_name     = "delete_snapshot"
  role              = aws_iam_role.lambda_snapshot.arn
  handler           = "delete_snapshot.lambda_handler"
  runtime           = "python3.8"
  description       = "A function to delete a snapshot."
  source_code_hash  = data.archive_file.delete_snapshot.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      "account_id"  = local.account
      "region"      = local.region
    }
  }

  tags = { 
    Name = format("%s_delete_snapshot", var.project_name)
    project_name = var.project_name
  }
}

resource "aws_lambda_function" "copy_snapshot_to_another_region" {
  filename          = "copy_snapshot_to_another_region.zip"
  function_name     = "copy_snapshot_to_another_region"
  role              = aws_iam_role.lambda_snapshot.arn
  handler           = "copy_snapshot_to_another_region.lambda_handler"
  runtime           = "python3.8"
  description       = "A function to delete a snapshot."
  source_code_hash  = data.archive_file.copy_snapshot_to_another_region.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      "account_id"  = local.account
      "region"      = local.region
    }
  }

  tags = { 
    Name = format("%s_copy_snapshot_to_another_region", var.project_name)
    project_name = var.project_name
  }
}

resource "aws_lambda_function" "share_snapshot" {
  filename          = "share_snapshot.zip"
  function_name     = "share_snapshot"
  role              = aws_iam_role.lambda_snapshot.arn
  handler           = "share_snapshot.lambda_handler"
  runtime           = "python3.8"
  description       = "A function to share a snapshot with another account."
  source_code_hash  = data.archive_file.share_snapshot.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      "account_id"  = local.account
      "region"      = local.region
    }
  }

  tags = { 
    Name = format("%s_share_snapshot", var.project_name)
    project_name = var.project_name
  }
}
