job "psc-mongodb" {
  datacenters = ["${datacenter}"]
  type = "service"
  namespace = "${nomad_namespace}"

  vault {
    policies = ["psc-ecosystem"]
    change_mode = "restart"
  }

  group "psc-mongodb" {
    count = 1

    // Volume portworx CSI
    volume "mongodb" {
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      type            = "csi"
      read_only       = false
      source          = "vs-${nomad_namespace}-psc-mongodb"
    }
    volume "mongodb-config" {
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      type            = "csi"
      read_only       = false
      source          = "vs-${nomad_namespace}-psc-mongodb-config"
    }

    restart {
      attempts = 3
      delay = "60s"
      interval = "1h"
      mode = "fail"
    }

    affinity {
      attribute = "$\u007Bnode.class\u007D"
      value     = "compute"
    }


    network {
      port "db" { to = 27017 }
    }

    task "psc-mongodb" {
      driver = "docker"

      // Monter le volume portworx CSI 
      volume_mount {
        volume      = "mongodb"
        destination = "/data/db"
        read_only   = false
      }
      volume_mount {
        volume      = "mongodb-config"
        destination = "/data/configdb"
        read_only   = false
      }

      template {
        data = <<EOH
          MONGO_INITDB_ROOT_USERNAME = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.root_user }}{{ end }}
          MONGO_INITDB_ROOT_PASSWORD = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.root_pass }}{{ end }}
        EOH
        destination = "secrets/.env"
        change_mode = "restart"
        env = true
      }
      config {
        image = "${image}:${tag}"
        ports = ["db"]
      }
      resources {
        cpu    = 500
        memory = 1536
      }
      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-$\u007BNOMAD_JOB_NAME\u007D"
        port = "db"
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "30s"
          timeout      = "5s"
          failures_before_critical = 5
          port         = "db"
        }
      }
    }
  }
}
