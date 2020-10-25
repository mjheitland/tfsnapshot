#--- lambda/outputs.tf ---
output "region" {
  value = local.region
}
output "log_event" {
  value = aws_lambda_function.log_event.handler
}
output "create_snapshot" {
  value = aws_lambda_function.create_snapshot.handler
}
output "delete_snapshot" {
  value = aws_lambda_function.delete_snapshot.handler
}
output "copy_snapshot_to_another_region" {
  value = aws_lambda_function.copy_snapshot_to_another_region.handler
}
output "share_snapshot" {
  value = aws_lambda_function.share_snapshot.handler
}
