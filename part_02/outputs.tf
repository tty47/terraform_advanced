output "ip_address" {
    value = aws_instance.jrmanes_ec2.public_ip
}

output "disk_size" {
    value = [ for disk in aws_instance.jrmanes_ec2.root_block_device : disk.volume_size]
}

output "private_key" {
    value = tls_private_key.devops_jrmanes.private_key_pem
}

output "public_key" {
    value = tls_private_key.devops_jrmanes.public_key_pem
}