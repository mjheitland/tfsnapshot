# general
project_name="tfsnapshot"

# networking
region="eu-west-1"
vpc_cidr="10.0.0.0/16"
subpub_cidrs = [
  "10.0.0.0/24",
  #"10.0.2.0/24",
]
subprv_cidrs = [
  #"10.0.1.0/24",
  #"10.0.3.0/24",
]
access_ip     = "0.0.0.0/0"
service_ports = [
  { # ssh
    from_port = 22,
    to_port   = 22
  },
  # { # http
    # from_port = 80,
    # to_port   = 80
  # },
  # { # https
    # from_port = 443, 
    # to_port   = 443
  # } 
]

#--- compute
key_name        = "tfsnapshot_key"
public_key_path = "~/.ssh/id_rsa.pub"
instance_type   = "t2.micro"
