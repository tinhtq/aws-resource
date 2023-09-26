data "aws_caller_identity" "current" {}

resource "aws_connect_instance" "aws" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = "${data.aws_caller_identity.current.account_id}-kinesis-connect"
  outbound_calls_enabled   = true
}

resource "aws_connect_instance_storage_config" "config" {
  instance_id   = aws_connect_instance.aws.id
  resource_type = "CONTACT_TRACE_RECORDS"

  storage_config {
    kinesis_stream_config {
      stream_arn = aws_kinesis_stream.stream.id
    }
    storage_type = "KINESIS_STREAM"
  }
}
data "aws_connect_security_profile" "sp_kinesis" {
  instance_id = aws_connect_instance.aws.id
  name        = "Admin"
}

data "aws_connect_routing_profile" "kinesis" {
  instance_id = aws_connect_instance.aws.id
  name        = "Basic Routing Profile"
}

resource "aws_connect_user" "example" {
  instance_id        = aws_connect_instance.aws.id
  name               = "admin"
  password           = "passWord123"
  routing_profile_id = data.aws_connect_routing_profile.kinesis.routing_profile_id

  security_profile_ids = [
    data.aws_connect_security_profile.sp_kinesis.security_profile_id
  ]

  identity_info {
    first_name = "Admin"
    last_name  = "User"
  }

  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}
data "aws_connect_queue" "queue" {
  instance_id = aws_connect_instance.aws.id
  name        = "BasicQueue"
}

resource "aws_connect_contact_flow" "sample_data_analyst" {
  instance_id = aws_connect_instance.aws.id
  name        = "Sample-Demo-Kinesis"
  description = "Contact Flow Description"
  type        = "CONTACT_FLOW"
  content = templatefile("${path.module}/files/contact_flow.json.tmpl", {
    queueArn = data.aws_connect_queue.queue.arn
  })
}
