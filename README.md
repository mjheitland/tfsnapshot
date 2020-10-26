# Copy EBS snapshot from account1/region1 to account2/region2

account1 and account2 (all resoruce names are prefixed with "tfsnapshot"):
(account2 is an exact copy of account1 with its own .terraform folder and TF files and two differences in code: different region and different profile)
+ 1 VPC
+ 1 internet gateway
+ 1 public subnet(s)  (number can be easily modified changing variables in terraform.tfvars)
+ 0 private subnet(s) (number can be easily modified changing variables in terraform.tfvars)
+ 1 security group (opens port 22 to dev.tfvars/access_ip for ssh)
+ 1 public route table (opening the ingress ports listed in dev.tfvars)
+ 0 private default route table (will automatically be associated with all unattached subnets)
+ 1 key pair to secure ssh access (uses local public key pair file as defined in dev.tfvars)
+ 1 ec2 instance
+ 1 ebs volume attached to ec2 instance
+ 1 role for log_event
+ 1 role for *_snapshot
+ 1 lambda "log_event"
+ 1 lambda "create_snapshot"
+ 1 lambda "copy_snapshot_to_another_region"
+ 1 lambda "delete_snapshot"
+ 1 lambda "share_snapshot"

## Terraform commands
    
* terraform init

* terraform apply -var-file=dev.tfvars -auto-approve
    
* terraform destroy -var-file=dev.tfvars -auto-approve

## To delete Terraform state files
rm -rfv **/.terraform # remove all recursive subdirectories
    
## Mount attached EBS block device under Linux
[Mount Instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html)
Terraform creates and attaches an EBS block device to the ec2 instance,
once the ec2 instance boots, the volume gets mounted automatically using user data template

## How to create and share a snapshot with another account in another region
Run the following lambdas in this sequence (use <copy_snapshot_id> as snapshot_id for share_snapshot):
+ create_snapshot (region, volume_id) => (snapshot_id)
+ copy_snapshot_to_another_region: (source_region, destionation_region, snapshot_id) => (copy_snapshot_id)
+ delete_snapshot: (region, snapshot_id)
+ share_snapshot: (region, snapshot_id, owner_account_id, other_account_id)
