job "elasticsearch" {

  type = "service"
  datacenters = ["${datacenter}"]
  namespace = "${nomad_namespace}"

  vault {
    policies = ["forge"]
    change_mode = "restart"
  }

  group "elasticsearch" {
    count = 1

    // Volume portworx CSI
    volume "elasticsearch" {
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      type            = "csi"
      read_only       = false
      source          = "vs-${nomad_namespace}-psc-elasticsearch"
    }

    affinity {
      attribute = "$\u007Bnode.class\u007D"
      value     = "compute"
    }

    network {
      port "es" { to = 9200 }
      port "ed" { to = 9300 }
    }
    task "elasticsearch" {
      driver = "docker"

      // Monter le volume portworx CSI
      volume_mount {
        volume      = "elasticsearch"
        destination = "/usr/share/elasticsearch/data"
        read_only   = false
      }

      template {
        change_mode = "noop"
        destination = "local/elasticsearch.yml"
        data = <<EOF
cluster.name: "docker-cluster"
network.host: 0.0.0.0
s3.client.scaleway.endpoint: "s3.fr-par.scw.cloud"
EOF
      }

      template {
        change_mode = "restart"
        destination = "local/install_and_run_elasticsearch.sh"
        data = <<EOF
cd /usr/share/elasticsearch
bin/elasticsearch-plugin install -b repository-s3
{{ with secret "forge/scaleway/s3" }}
bin/elasticsearch-keystore create
echo {{ .Data.data.access_key }} | bin/elasticsearch-keystore add s3.client.scaleway.access_key
echo {{ .Data.data.secret_key }} | bin/elasticsearch-keystore add s3.client.scaleway.secret_key
{{ end }}
exec /bin/tini -- /usr/local/bin/docker-entrypoint.sh eswrapper
EOF
      }

      config {
        image = "${image}:${tag}"
        ports = ["es", "ed"]

        mount {
          type = "bind"
          target = "/usr/share/elasticsearch/config/elasticsearch.yml"
          source = "local/elasticsearch.yml"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }

        entrypoint = [
          "/bin/bash",
          "/local/install_and_run_elasticsearch.sh"
        ]
      }

      resources {
        cpu = 1000
        memory = 2048
      }

      env = {
        "discovery.type" = "single-node"
      }

      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-elasticsearch"
        tags = ["global","elasticsearch"]
        port = "es"
        check {
          name = "alive"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
