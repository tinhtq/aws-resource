resource "aws_kinesis_stream" "stream" {
  name             = "aws-connect-kinesis"
  shard_count      = 1
  retention_period = 48
  kms_key_id       = aws_kms_key.custom_key.id
  encryption_type = "KMS"
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}
