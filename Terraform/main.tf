terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "6"
  image_id = "fd83j4siasgfq4pi1qif"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "6"
  image_id = "fd83j4siasgfq4pi1qif"
}

resource "yandex_compute_disk" "boot-disk-3" {
  name     = "boot-disk-3"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "6"
  image_id = "fd83j4siasgfq4pi1qif"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/anna/Загрузки/Cyber-ED2024/S-470-7/S-410-7_S-224_Безопасность окружения приложений/Task_01_02/terraform/terraform/meta.txt")}"
  }

}

resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/anna/Загрузки/Cyber-ED2024/S-470-7/S-410-7_S-224_Безопасность окружения приложений/Task_01_02/terraform/terraform/meta.txt")}"
  }

}

resource "yandex_compute_instance" "vm-3" {
  name = "terraform3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-3.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("/home/anna/Загрузки/Cyber-ED2024/S-470-7/S-410-7_S-224_Безопасность окружения приложений/Task_01_02/terraform/terraform/meta.txt")}"
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

resource "local_file" "private_key-1" {
  content  = "[osquery]\nosquery-1 ansible_host=${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} ansible_user=anna"
  filename = "ansible/hosts"
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

resource "local_file" "private_key-2" {
  content  = "[osquery]\nosquery-2 ansible_host=${yandex_compute_instance.vm-2.network_interface.0.nat_ip_address} ansible_user=anna"
  filename = "ansible/hosts"
}

output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface.0.ip_address
}

output "external_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface.0.nat_ip_address
}

resource "local_file" "private_key-3" {
  content  = "[osquery]\nosquery-3 ansible_host=${yandex_compute_instance.vm-3.network_interface.0.nat_ip_address} ansible_user=anna"
  filename = "ansible/hosts"
}

resource "null_resource" "baz-1" {
  connection {
    type = "ssh"
    user = "anna"
    #password = var.root_password
    host = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install ca-certificates curl git",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian   bookworm stable | sudo tee /etc/apt/sources.list.d/docker.list",
      "sudo apt update",
      "sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo docker pull artmurt/final_prjmgmt:latest",
      "sudo docker run -d --name final_prjmgmt -p 80:80 artmurt/final_prjmgmt:latest",
      "sudo docker exec -it final_prjmgmt sed -i 's/127.0.0.1:8080;/${yandex_compute_instance.vm-2.network_interface.0.ip_address}:8080; server ${yandex_compute_instance.vm-3.network_interface.0.ip_address}:8080;/g' /etc/angie/http.d/default.conf",
      "sudo docker exec -it final_prjmgmt angie -s reload"
    ]
  }
  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "baz-2" {
  connection {
    type = "ssh"
    user = "anna"
    #password = var.root_password
    host = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install ca-certificates curl git",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian   bookworm stable | sudo tee /etc/apt/sources.list.d/docker.list",
      "sudo apt update",
      "sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo docker pull artmurt/final_prj:latest",
      "sudo docker run -d --name final_prj -p 8080:80 artmurt/final_prj:latest",
      "sudo docker exec -it final_prj sed -i 's/#access_log/allow ${yandex_compute_instance.vm-1.network_interface.0.ip_address}; deny all; #access_log/g' /etc/angie/http.d/default.conf",
      "sudo docker exec -it final_prj angie -s reload"
    ]
  }
  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "baz-3" {
  connection {
    type = "ssh"
    user = "anna"
    #password = var.root_password
    host = yandex_compute_instance.vm-3.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install ca-certificates curl git",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian   bookworm stable | sudo tee /etc/apt/sources.list.d/docker.list",
      "sudo apt update",
      "sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo docker pull artmurt/final_prj:latest",
      "sudo docker run -d --name final_prj -p 8080:80 artmurt/final_prj:latest",
      "sudo docker exec -it final_prj sed -i 's/#access_log/allow ${yandex_compute_instance.vm-1.network_interface.0.ip_address}; deny all; #access_log/g' /etc/angie/http.d/default.conf",
      "sudo docker exec -it final_prj angie -s reload"
    ]
  }
  triggers = {
    always_run = timestamp()
  }
}
