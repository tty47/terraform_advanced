output "ip_container"{
    value = docker_container.docker_container.network_data[0].ip_address
}