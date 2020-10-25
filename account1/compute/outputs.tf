#--- compute/outputs.tf
output "keypair_id" {
  value = "${join(", ", aws_key_pair.keypair.*.id)}"
}
output "ec2_ids" {
  value = "${join(", ", aws_instance.ec2.*.id)}"
}
output "ec2_public_ips" {
  value = "${join(", ", aws_instance.ec2.*.public_ip)}"
}
output "ebs_volumes" {
  value = "${join(", ", aws_ebs_volume.ebs_volume.*.id)}"
}
