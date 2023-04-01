output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.bucket_is_too_big.alarm_name
}

output "s3_object_uri" {
  value = "s3://${aws_s3_bucket.bucket.bucket}/"
}
