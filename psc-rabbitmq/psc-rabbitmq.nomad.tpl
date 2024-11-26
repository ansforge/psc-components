job "psc-rabbitmq" {
  datacenters = ["${datacenter}"]
  type = "service"
  namespace = "${nomad_namespace}"

  vault {
    policies = ["psc-ecosystem"]
    change_mode = "restart"
  }

  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "psc-rabbitmq" {
    count = 1
    // Volume portworx CSI
    volume "rabbitmq" {
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      type            = "csi"
      read_only       = false
      source          = "vs-${nomad_namespace}-rabbitmq"
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
      port "endpoint" { to = 5672 }
      port "management" { to = 15672 }
	  port "metrics" { to = 15692 }
    }

    task "psc-rabbitmq" {
      driver = "docker"

      // Monter le volume portworx CSI 
      volume_mount {
        volume      = "rabbitmq"
        destination = "/var/lib/rabbitmq"
        read_only   = false
      } 

      config {
        image = "${image}:${tag}"
        ports = ["endpoint","management","metrics"]
        hostname = "psc-rabbitmq"

        mount {
          type = "bind"
          target = "/etc/rabbitmq/conf.d/20-management.conf"
          source = "local/20-management.conf"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        mount {
          type = "bind"
          target = "/etc/rabbitmq/enabled_plugins"
          source = "local/enabled_plugins"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        #mount {
        #  type = "bind"
        #  target = "/etc/rabbitmq/definitions.json"
        #  source = "local/definitions.json"
        #  readonly = false
        #  bind_options {
        #    propagation = "rshared"
        #  }
        #}
      }
      template {
        data = <<EOH
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS = "-rabbitmq_management path_prefix \"/portal/tool/rabbitmq\""
RABBITMQ_DEFAULT_USER="{{ with secret "psc-ecosystem/${nomad_namespace}/rabbitmq" }}{{ .Data.data.user }}{{ end }}"
RABBITMQ_DEFAULT_PASS="{{ with secret "psc-ecosystem/${nomad_namespace}/rabbitmq" }}{{ .Data.data.password }}{{ end }}"
PUBLIC_HOSTNAME="{{ with secret "psc-ecosystem/${nomad_namespace}/admin-portal" }}{{ .Data.data.hostname }}{{ end }}"
EOH
        destination = "secrets/file.env"
        env = true
      }
      template {
        change_mode = "restart"
        destination = "local/20-management.conf"
        data = <<EOF
management.tcp.port = 15672
EOF
      }
      
      template {
        change_mode = "restart"
        destination = "local/enabled_plugins"
        data = <<EOF
[rabbitmq_management,rabbitmq_prometheus,rabbitmq_shovel_management].
EOF
      }
      
      #template { # TODO : this dead code should die...
      #  change_mode = "restart"
      #  destination = "local/definitions.json"
      #  data = <<EOF
#{
#	"queues": [
#		{
#		  "arguments": {},
#		  "auto_delete": false,
#		  "durable": true,
#		  "name": "file.upload",
#		  "vhost": "/",
#		  "type": "classic"
#		},
#		{
#		  "name": "ps-queue",
#		  "durable": true,
#		  "auto_delete": false,
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "name": "contact-queue.parking-lot",
#		  "durable": true,
#		  "auto_delete": false,
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "name": "contact-queue.dlq",
#		  "durable": true,
#		  "auto_delete": false,
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "name": "contact-queue",
#		  "durable": true,
#		  "auto_delete": false,
#		  "vhost": "/",
#		  "arguments": {
#			"x-dead-letter-exchange": "contact-queue.dlx"
#		  }
#		}
#	],
#	  "exchanges": [
#		{
#		  "name": "contact-messages-exchange",
#		  "type": "direct",
#		  "durable": true,
#		  "auto_delete": false,
#		  "internal": false,
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "name": "contact-queueexchange.parking-lot",
#		  "type": "fanout",
#		  "durable": true,
#		  "auto_delete": false,
#		  "internal": false,
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "name": "contact-queue.dlx",
#		  "type": "fanout",
#		  "durable": true,
#		  "auto_delete": false,
#		  "internal": false,
#		  "vhost": "/",
#		  "arguments": {}
#		}
#	],
#		"bindings": [
#		{
#		  "arguments": {},
#		  "destination": "file.upload",
#		  "destination_type": "queue",
#		  "routing_key": "file.upload",
#		  "vhost": "/",
#		  "source": "amq.topic"
#		},
#			{
#		  "source": "contact-messages-exchange",
#		  "destination": "contact-queue",
#		  "destination_type": "queue",
#		  "routing_key": "ROUTING_KEY_CONTACT_MESSAGES_QUEUE",
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "source": "contact-messages-exchange",
#		  "destination": "contact-queue",
#		  "destination_type": "queue",
#		  "routing_key": "contact-queue",
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "source": "contact-queue.dlx",
#		  "destination": "contact-queue.dlq",
#		  "destination_type": "queue",
#		  "routing_key": "",
#		  "vhost": "/",
#		  "arguments": {}
#		},
#		{
#		  "source": "contact-queueexchange.parking-lot",
#		  "destination": "contact-queue.parking-lot",
#		  "destination_type": "queue",
#		  "routing_key": "",
#		  "vhost": "/",
#		  "arguments": {}
#		}
#	]
#}
#EOF
#      }

      resources {
        cpu    = 100
        memory = 2048
      }
      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-$\u007BNOMAD_JOB_NAME\u007D"
        port = "endpoint"
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "10s"
          timeout      = "2s"
          port         = "endpoint"
        }
      }
	  service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-$\u007BNOMAD_JOB_NAME\u007D-metrics"
        port = "metrics"
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "10s"
          timeout      = "2s"
          port         = "metrics"
        }
      }
      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-$\u007BNOMAD_JOB_NAME\u007D-management"
        port = "management"
        check {
          name         = "alive"
          type         = "http"
          path         = "/portal/tool/rabbitmq/"
          interval     = "30s"
          timeout      = "2s"
          failures_before_critical = 5
          port         = "management"
        }
      }
    }
  }
}
