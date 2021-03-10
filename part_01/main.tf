terraform { 
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
        null = {
            source = "hashicorp/null"
        }
    }
}

provider docker {
}

provider null {
}

resource "null_resource" "inventory"{
    provisioner "local-exec" {
        command = "rm -f inventory.txt"
    }
}
resource "docker_container" "container_nginx"{ 
    for_each = toset(var.containers)
    name = each.key
    image = docker_image.imagen_nginx.latest

    provisioner "local-exec" {
        command = "echo ${self.name}=${self.network_data[0].ip_address} >> inventory.txt"
    }
    
    connection {
        type        = "ssh"
        host        = self.network_data[0].ip_address
        user        = "root"
        password    = "root"
        port        = 22
    }
    provisioner "remote-exec" {
        inline = [
            "echo ${self.name}=${self.network_data[0].ip_address} >> inventory.txt"
            ]
    }
    
    
}

resource "docker_image" "imagen_nginx"{ 
    name = var.container_image
}


resource "null_resource" "duplicar_inventory"{
    triggers = {
        nada = join("",values(docker_container.container_nginx)[*].ip_address)
    }
    provisioner "local-exec" {
        command = "cp inventory.txt inventory.backup"
    }
}

