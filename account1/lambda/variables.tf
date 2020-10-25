#--- lambda/variables.tf ---
variable "project_name" {
  description = "project name is used as resource tag"
  type        = string
}
# variable "subprv_ids" {
#   description = "ids of private subnets"
#   type        = list(string)
# }
# variable "vpc_cidr" {
#   description = "cidr of vpc"
#   type        = string
# }
# variable "vpc_id" {
#   description = "id of vpc"
#   type        = string
# }
