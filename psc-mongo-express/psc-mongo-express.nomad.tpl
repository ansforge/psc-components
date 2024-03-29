job "psc-mongo-express" {
  datacenters = ["${datacenter}"]
  type = "service"
  namespace = "${nomad_namespace}"

  vault {
    policies = ["psc-ecosystem"]
    change_mode = "restart"
  }

  group "psc-mongo-express" {
    count = 1

    affinity {
      attribute = "$\u007Bnode.class\u007D"
      value     = "compute"
    }

    restart {
      attempts = 3
      delay = "60s"
      interval = "1h"
      mode = "fail"
    }

    network {
      port "ui" { to = 8081 }
    }

    task "psc-mongo-express" {
      driver = "docker"
      template {
        data = <<EOH
ME_CONFIG_MONGODB_SERVER = {{ range service "${nomad_namespace}-psc-mongodb" }}{{ .Address }}{{ end }}
ME_CONFIG_MONGODB_PORT = {{ range service "${nomad_namespace}-psc-mongodb" }}{{ .Port }}{{ end }}
ME_CONFIG_MONGODB_ADMINUSERNAME = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.root_user }}{{ end }}
ME_CONFIG_MONGODB_ADMINPASSWORD = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.root_pass }}{{ end }}
ME_CONFIG_SITE_BASEURL = "/psc-db/"
ME_CONFIG_MONGODB_ENABLE_ADMIN = true
ME_CONFIG_BASICAUTH_USERNAME = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.express_user }}{{ end }}
ME_CONFIG_BASICAUTH_PASSWORD = {{ with secret "psc-ecosystem/${nomad_namespace}/mongodb" }}{{ .Data.data.express_pass }}{{ end }}
EOH
        destination = "secrets/file.env"
        change_mode = "restart"
        env = true
      }
      template {
        change_mode = "restart"
        destination = "local/file.env"
        env = true
        data = <<EOF
PUBLIC_HOSTNAME={{ with secret "psc-ecosystem/${nomad_namespace}/admin" }}{{ .Data.data.admin_public_hostname }}{{ end }}
EOF
      }
      config {
        image = "${image}"
        ports = ["ui"]
      }
      resources {
        cpu    = 1000
        memory = 512
      }
      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-$\u007BNOMAD_JOB_NAME\u007D"
        port = "ui"
        tags = ["urlprefix-$\u007BPUBLIC_HOSTNAME\u007D/psc-db/"]
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "30s"
          timeout      = "5s"
          failures_before_critical = 5
          port         = "ui"
        }
      }
    }
  }
}
