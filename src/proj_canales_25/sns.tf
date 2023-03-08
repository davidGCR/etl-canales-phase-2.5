locals {
  email_list = ["dchoqueluque.veox@gmail.com"]
}

resource "aws_sns_topic" "test_canales_25" {
  name = "test_canales_25"
}

resource "aws_sns_topic_subscription" "email-target" {
  for_each = toset(local.email_list)
  topic_arn = aws_sns_topic.test_canales_25.arn
  protocol  = "email"
  endpoint  = "${each.value}"
}