#--- compute/main.tf

resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "aws_ami" "ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

data "template_file" "userdata" {
  count = length(var.subpub_ids)

  template = file("${path.module}/userdata.tpl")
  vars = {
    subnets = element(var.subpub_ids, count.index)
  }
}

resource "aws_instance" "ec2" {
  count = length(var.subpub_ids)

  instance_type           = var.instance_type
  ami                     = data.aws_ami.ami.id
  key_name                = aws_key_pair.keypair.id
  subnet_id               = element(var.subpub_ids, count.index)
  vpc_security_group_ids  = [var.sg_id]
  user_data               = data.template_file.userdata.*.rendered[count.index]
  tags = { 
    Name = format("%s_ec2_%d", var.project_name, count.index)
    project_name = var.project_name
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  count = length(var.subpub_ids)

  availability_zone = aws_instance.ec2[count.index].availability_zone
  size = 2
  tags = {
    Name = format("%s_ec2_%d_ebs", var.project_name, count.index)
    project_name = var.project_name
  }
}

resource "aws_volume_attachment" "ebs_att" {
  count = length(var.subpub_ids)

  device_name = "/dev/sdf"
  volume_id = aws_ebs_volume.ebs_volume[count.index].id
  instance_id = aws_instance.ec2[count.index].id
  force_detach = true
} 