variable "instance_type" {
  type = string
  default = "t2.medium"
}
variable "instance_ami" {
  type = string
  default = "ami-0c7217cdde317cfec"
}
variable "vpccidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "keyname" {
  type = string
  default = "deployer-key"
}
variable "pubkey" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDttlPdTIG5+yllaxSTayJZmLDzo35sxRrhA+5uGZP6x/5RGt/vtfSkWgyHkCCBYMa9T/s3T7QDkYHEGi5ob2r2qkEXjhnY+P/OUHZ38gR5B5uAbvQ+yqL1qb0mfBl+TdjCU/5GrN5PjpJvHY1F6P7wNyQMH/+437xz+Xdlt4uKvc4ED4fJISwwDmmmONQQZQ6uljD2PAq5FotJnle6b3a4KP/laM6VI66ELZTqFcjMw7/orviEvHNlFjgeLHTU5bmHJHo2GDb6U7D47N1Dby3flT8rFvPbZ4N2A+1F1eW6FGD5bYcaTcSDD5oldlOo4lrAVpknV9qm9cyMiNN3Zla1"
}
variable "pubsubcidr" {
  type = string
  default = "10.0.1.0/24"
}
variable "privsubcidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "domain_name" {
  type = string
  default = "develop.internal"
}