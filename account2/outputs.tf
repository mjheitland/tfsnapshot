output "project_name" {
  value = var.project_name
}

#--- networking
output "vpc_id" {
  value = module.networking.vpc_id
}
output "igw_id" {
  value = module.networking.igw_id
}
output "subpub_ids" {
  value = module.networking.subpub_ids
}
output "subprv_ids" {
  value = module.networking.subprv_ids
}
output "sg_id" {
  value = module.networking.sg_id
}
output "rtpub_ids" {
  value = module.networking.rtpub_ids
}
output "rtprv_ids" {
  value = module.networking.rtprv_ids
}

#--- compute
output "keypair_id" {
  value = module.compute.keypair_id
}
output "ec2_ids" {
  value = module.compute.ec2_ids
}
output "ec2_public_ips" {
  value = module.compute.ec2_public_ips
}
output "ebs_volumes" {
  value = module.compute.ebs_volumes
}

#--- lambdas
output "log_event" {
  value = module.lambda.log_event
}
output "create_snapshot" {
  value = module.lambda.create_snapshot
}
output "delete_snapshot" {
  value = module.lambda.delete_snapshot
}
output "copy_snapshot_to_another_region" {
  value = module.lambda.copy_snapshot_to_another_region
}
output "share_snapshot" {
  value = module.lambda.share_snapshot
}
