resource "aws_sns_topic" "test_canales_25" {
  name = "test_canales_25"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.test_canales_25.arn
  protocol  = "email"
  endpoint  = "dchoqueluque.veox@gmail.com"
}