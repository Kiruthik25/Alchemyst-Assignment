output "vpc_id" {
  value = module.network.vpc_id
}

output "public_instance_ip" {
  value = module.public_ec2.public_ip
}
