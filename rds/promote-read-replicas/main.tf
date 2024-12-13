resource "aws_db_subnet_group" "all" {
  name       = "main"
  subnet_ids = data.aws_subnets.default_subnets.ids
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier              = var.rds_cluster_name
  engine                          = "aurora-postgresql"
  availability_zones              = var.availability_zones
  backup_retention_period         = 7
  preferred_backup_window         = "07:00-09:00"
  manage_master_user_password     = true
  master_username                 = "admin"
  skip_final_snapshot             = var.skip_final_snapshot
  db_subnet_group_name            = aws_db_subnet_group.all.id
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  database_name                   = var.db_name
  vpc_security_group_ids          = [aws_security_group.rds_postgresql_sg.id]
}

resource "aws_rds_cluster_instance" "primary_instance" {
  cluster_identifier  = aws_rds_cluster.primary.id
  instance_class      = var.db_type
  engine              = aws_rds_cluster.primary.engine
  publicly_accessible = var.publicly_accessible
}

resource "aws_rds_cluster_instance" "read_replica" {
  cluster_identifier  = aws_rds_cluster.primary.id
  instance_class      = var.db_type
  engine              = aws_rds_cluster.primary.engine
  publicly_accessible = var.publicly_accessible
}

resource "aws_iam_role_policy_attachment" "lambda_attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "promote_read_replica" {
  function_name = "promote-read-replica"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      DB_INSTANCE_ID    = aws_rds_cluster.primary.id
      SNS_TOPIC_ARN     = aws_sns_topic.notify.arn
      SECRET_NAME       = aws_rds_cluster.primary.master_user_secret[0].secret_arn
      SUBNET_GROUP_NAME = aws_db_subnet_group.all.name
    }
  }

  source_code_hash = data.archive_file.lambda.output_base64sha256
  filename         = "python.zip"
}

resource "aws_sns_topic" "notify" {
  name = "rds-disaster-recovery"
}



resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each = toset(var.emails)

  topic_arn = aws_sns_topic.notify.arn
  protocol  = "email"
  endpoint  = each.value
}
