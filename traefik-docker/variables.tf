variable "api_dashboard_url" {
    type = string
    description = "Traefik API Dashboard"
    default = "traefik.local"
}

variable "cloudflare_api_token" {
  type = string
}

variable "acme_email" {
  type = string
}

variable "docker_host" {
  type = string
  default = "unix:///var/run/docker.sock"
}