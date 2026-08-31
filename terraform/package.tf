data "archive_file" "producer" {
  type        = "zip"
  source_dir  = "${path.module}/../src/producer"
  output_path = "${path.module}/producer.zip"
}

data "archive_file" "consumer" {
  type        = "zip"
  source_dir  = "${path.module}/../src/consumer"
  output_path = "${path.module}/consumer.zip"
}
