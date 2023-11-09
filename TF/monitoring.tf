resource "aws_cloudtrail" "dev-cloudtrail-bucket" {
  name = "dev-cloudtrail"
  s3_bucket_name = aws_s3_bucket.dev-cloudtrail-bucket.id
  enable_log_file_validation = true
}

# A VPC attachment to capture IP traffic for a specific VPC. 
# Logs are sent to a dedicated S3 Bucket. 
resource "aws_flow_log" "dev-flow-log" {
  log_destination      = aws_cloudwatch_log_group.dev-cloudwatch-log-group.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.dev-vpc.id
}

resource "aws_cloudwatch_log_group" "dev-cloudwatch-log-group" {
  name = "dev-cloudwatch-log-group"
}

# Create a metric alarm that sends a message to an SNS topic if the alarm changes state
resource "aws_cloudwatch_metric_alarm" "dev-cloudwatch-metric-alarm" {
  alarm_name          = "example"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric checks cpu utilization"
  alarm_actions       = [aws_sns_topic.dev-sns-topic.arn]
}

resource "aws_sns_topic" "dev-sns-topic" {
  name = "dev-sns-topic"
}

module "eks_monitoring_logging" {
  source = "shamimice03/eks-monitoring-logging/aws"
  cluster_name = resource.aws_eks_cluster.dev-cluster.name
  aws_region = "us-west-2" 
  namespace = "amazon-cloudwatch"
  enable_cwagent = true
  enable_fluent_bit = true

  # Attach CloudWatchAgentServerPolicy to EKS nodegroup roles
  nodegroup_roles = [
    "kubecloud-eks-private-nodegroup",
    "kubecloud-eks-public-nodegroup",
  ]
}

resource "aws_cloudwatch_metric_alarm" "eks-cpu-alarm" {
  alarm_name          = "eks-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric checks cpu utilization"
  alarm_actions       = [aws_sns_topic.aws_sns_topic.dev-sns-topic.arn]
}

resource "aws_sns_topic_subscription" "dev-sns-subscription" {
  topic_arn = aws_sns_topic.dev-sns-topic.arn
  protocol  = "email"
  endpoint  = "example@example.com"
}
