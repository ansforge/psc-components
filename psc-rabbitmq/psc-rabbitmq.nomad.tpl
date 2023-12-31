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

    restart {
      attempts = 3
      delay = "60s"
      interval = "1h"
      mode = "fail"
    }

    constraint {
      attribute = "$\u007Bnode.class\u007D"
      value     = "data"
    }

    network {
      port "endpoint" { to = 5672 }
      port "management" { to = 15672 }
	  port "metrics" { to = 15692 }
    }

    task "psc-rabbitmq" {
      driver = "docker"
      config {
        image = "${image}:${tag}"
        ports = ["endpoint","management","metrics"]
        hostname = "psc-rabbitmq"
        mount {
          type = "volume"
          target = "/var/lib/rabbitmq"
          source = "${nomad_namespace}-rabbitmq"
          readonly = false
          volume_options {
            no_copy = false
            driver_config {
              name = "pxd"
              options {
                io_priority = "high"
                size = 5
                repl = 2
              }
            }
          }
        }
        mount {
          type = "bind"
          target = "/etc/rabbitmq/conf.d/20-management.conf"
          source = "local/20-management.conf"
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
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS = "-rabbitmq_management path_prefix \"/rabbitmq\""
RABBITMQ_DEFAULT_USER="{{ with secret "psc-ecosystem/${nomad_namespace}/rabbitmq" }}{{ .Data.data.user }}{{ end }}"
RABBITMQ_DEFAULT_PASS="{{ with secret "psc-ecosystem/${nomad_namespace}/rabbitmq" }}{{ .Data.data.password }}{{ end }}"
PUBLIC_HOSTNAME="{{ with secret "psc-ecosystem/${nomad_namespace}/admin" }}{{ .Data.data.admin_public_hostname }}{{ end }}"
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
      #template {
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
        tags = ["urlprefix-$\u007BPUBLIC_HOSTNAME\u007D/rabbitmq/"]
        check {
          name         = "alive"
          type         = "http"
          path         = "/rabbitmq/"
          interval     = "30s"
          timeout      = "2s"
          failures_before_critical = 5
          port         = "management"
        }
      }
    }
  }
}
