resource "aws_s3_bucket" "bucket" {
  bucket = "building-scalable-monitoring-system-example"

  tags = {
    Name = "Monitoring"
  }
}

resource "aws_cloudwatch_metric_alarm" "bucket_is_too_big" {
  alarm_name          = "bucket-is-too-big"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  period              = var.period
  threshold           = var.threshold
  namespace           = "AWS/S3"
  statistic           = "Average"
  metric_name         = "BucketSizeBytes"
  treat_missing_data  = "ignore"
  alarm_actions       = [aws_sns_topic.alarm.arn]
  dimensions = {
      BucketName = aws_s3_bucket.bucket.id
  }
}

resource "aws_sns_topic" "alarm" {
  name = "bucket-is-too-big-alarm-topic"
}

data "aws_iam_policy_document" "alarm_sns_topic_policy" {
  statement {
    actions = ["SNS:Publish"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [aws_sns_topic.alarm.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_metric_alarm.bucket_is_too_big.arn]
    }
  }
}

resource "aws_sns_topic_policy" "alarm_sns_topic_policy" {
  arn = aws_sns_topic.alarm.arn
  policy = data.aws_iam_policy_document.alarm_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "email" {
  endpoint  = var.email
  protocol  = "email"
  topic_arn = aws_sns_topic.alarm.arn
}