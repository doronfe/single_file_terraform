terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_network" "myapp_network" {
  name = "myapp_network"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "app" {
  name = "hashicorp/http-echo:latest"
}

resource "docker_container" "app" {
  image = docker_image.app.image_id
  name  = "app"
  ports {
    internal = 5678
    external = 5678
  }
  command = ["-text", "hello world!!!"]
  networks_advanced {
    name = docker_network.myapp_network.name
  }
}

data "template_file" "nginx_config" {
  template = <<-EOF
  events {}

  http {
    server {
      listen 80;  # Listen on port 80 for HTTP
      server_name myapp.local;

      location / {
        proxy_pass http://app:5678;  # Forward requests to the app service
      }
    }
  }
  EOF
}

resource "local_file" "nginx_conf" {
  content  = data.template_file.nginx_config.rendered
  filename = "${path.cwd}/nginx.conf"

}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.name
  ports {
    internal = 443
    external = 443
  }
  volumes {
    host_path      = local_file.nginx_conf.filename
    container_path = "/etc/nginx/nginx.conf"
  }
  volumes {
    host_path      = "/path/to/your/ssl/nginx.crt"
    container_path = "/etc/nginx/ssl/nginx.crt"
  }
  volumes {
    host_path      = "/path/to/your/ssl/nginx.key"
    container_path = "/etc/nginx/ssl/nginx.key"
  }
  privileged = true
  networks_advanced {
    name = docker_network.myapp_network.name
  }
}


output "nginx_ip" {
  value = docker_container.nginx.network_data[0].ip_address
}

resource "null_resource" "update_hosts" {
  provisioner "local-exec" {
    command = <<EOT
    #!/bin/bash
    NGINX_IP="${self.triggers.nginx_ip}"
    HOSTNAME="myapp.local"
    
    echo "$NGINX_IP $HOSTNAME" | sudo tee -a /etc/hosts
    
    echo "Updated /etc/hosts with $NGINX_IP $HOSTNAME"
    EOT
  }
  triggers = {
    nginx_ip = docker_container.nginx.network_data[0].ip_address
  }
  depends_on = [docker_container.nginx]
}