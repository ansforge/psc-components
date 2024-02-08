project = "prosanteconnect/${workspace.name}/psc-ecosystem-components/psc-elasticsearch-cleanup"

# Labels can be specified for organizational purposes.
labels = { "domaine" = "psc" }

runner {
  enabled = true
  profile = "secpsc-${workspace.name}"
  data_source "git" {
    url = "https://github.com/ansforge/psc-components.git"
    path = "psc-elasticsearch-cleanup"
    ignore_changes_outside_path = true
    ref = "${workspace.name}"
  }
  poll {
    enabled = false
  }
}
# An application to deploy.
app "prosanteconnect/psc-ecosystem-components/psc-elasticsearch-cleanup" {

  build {
    use "docker-pull" {
      image = var.image
      tag   = var.tag
      disable_entrypoint = true
    }
    registry {
      use "docker" {
        image = "prosanteconnect/es-cleanup"
        tag = var.tag
        username = var.registry_username
        password = var.registry_password
	      local = true
        }
    }
  }

  # Deploy to Nomad
  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/psc-elasticsearch-cleanup.nomad.tpl", {
        datacenter = var.datacenter
        image = var.image
        tag = var.tag
        nomad_namespace = var.nomad_namespace
      })

    }
  }
}

variable "datacenter" {
  type = string
  default = ""
  env = ["NOMAD_DATACENTER"]
}

variable "nomad_namespace" {
  type = string
  default = ""
  env = ["NOMAD_NAMESPACE"]
}

variable "registry_username" {
  type    = string
  default = ""
  env     = ["REGISTRY_USERNAME"]
  sensitive = true
}

variable "registry_password" {
  type    = string
  default = ""
  env     = ["REGISTRY_PASSWORD"]
  sensitive = true
}

variable "image" {
  type = string
  default = "untergeek/curator"
}

variable "tag" {
  type = string
  default = "5.8.4"
}
