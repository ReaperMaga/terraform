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

  ports {
    internal = 80
    external = 80
  }
  command = [
    "--api=true",
    "--api.dashboard=true",
    "--providers.docker=true",
    "--entrypoints.http.address=:80",
    "--entrypoints.http.address=:443",

    "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=0",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.email=${var.acme_email}",
    "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
  ]
  env = [
    "CLOUDFLARE_DNS_API_TOKEN=${var.cloudflare_api_token}"
  ]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    volume_name = docker_volume.traefik_acme.name
    container_path = "/letsencrypt"
  }
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

resource "docker_volume" "traefik_acme" {
  name = "traefik_acme"
}
