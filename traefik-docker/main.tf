terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_network" "traefik" {
  name     = "traefik"
  internal = false
}

resource "docker_image" "traefik" {
  name = "traefik:v3.1"
}

resource "docker_container" "traefik_container" {
  image   = docker_image.traefik.image_id
  name    = "traefik"
  restart = "always"
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  ports {
    internal = 80
    external = 80
  }
  command = [
    "--api=true",
    "--api.dashboard=true",
    "--providers.docker=true",
    "--entrypoints.http.address=:80"
  ]
  labels {
    label = "traefik.http.routers.traefik.rule"
    value = "Host(`${var.api_dashboard_url}`)"
  }
  labels {
    label = "traefik.http.routers.traefik.service"
    value = "api@internal"
  }
  networks_advanced {
    name = docker_network.traefik.name
  }
}
