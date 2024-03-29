job "logstash" {

  type = "service"
  datacenters = ["${datacenter}"]
  namespace = "${nomad_namespace}"

  group "logstash" {
    count = 1

    network {
      port "logstash" { to = 5044 }
    }

    task "logstash" {
      driver = "docker"

      affinity {
        attribute = "$\u007Bnode.class\u007D"
        value     = "compute"
      }

      config {
        image = "${image}:${tag}"
        volumes = ["local:/usr/share/logstash/pipeline"]
        ports = ["logstash"]
      }
      template {
               data =  <<EOH
HTTP_HOST="0.0.0.0"
{{range service "${nomad_namespace}-elasticsearch" }}XPACK_MONITORING_ELASTICSEARCH_HOSTS=[ "http://{{.Address}}:{{.Port}}" ]{{end}}
EOH
                destination = "secrets/file.env"
                env = true
                }
        template {
          data = <<EOH
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    break_on_match => "true"
    match     => { "message" => "%%%{TIMESTAMP_ISO8601:timestamp}%%%{SPACE}%%%{LOGLEVEL:level}%%%{SPACE}\[%%%{DATA:emitter}\]%%%{SPACE}%%%{NOTSPACE:emitter_infos}%%%{SPACE}%%%{GREEDYDATA:message}" }
    match     => { "message" => "%%%{DATE_EU:date}%%%{SPACE}%%%{TIME:time}%%%{SPACE}%%%{LOGLEVEL:level}%%%{SPACE}%%%{WORD:hostname}%%%{SPACE}\[%%%{DATA:connector}\]%%%{SPACE}(?<class>(?:\.?[a-zA-Z$_][a-zA-Z$_0-9]*\.)*[a-zA-Z$_][a-zA-Z$_0-9]*)%%%{SPACE}:%%%{SPACE}%%%{DATA:metric}%%%{SPACE}---%%%{SPACE}%%%{NUMBER:value:int}" }
    match     => { "message" => "%%%{DATE_EU:date}%%%{SPACE}%%%{TIME:time}%%%{SPACE}%%%{LOGLEVEL:level}%%%{SPACE}%%%{WORD:hostname}%%%{SPACE}\[%%%{DATA:connector}\]%%%{SPACE}(?<class>(?:\.?[a-zA-Z$_][a-zA-Z$_0-9]*\.)*[a-zA-Z$_][a-zA-Z$_0-9]*)%%%{SPACE}:%%%{SPACE}%%%{GREEDYDATA:message}" }
    match     => { "message" => "%%%{GREEDYDATA:mongo_log}" }
    overwrite => [ "message" ]
  }
  date {
    match => ["timestamp", "yyyy-MM-dd HH:mm:ss:SSS"]
  }
}

output {
  if "_grokparsefailure" not in [tags] {
    elasticsearch {
      {{range service "${nomad_namespace}-elasticsearch" }}hosts => [ "http://{{.Address}}:{{.Port}}" ]{{end}}
      index => "%%%{[@metadata][beat]}-%%%{[@metadata][version]}-%%%{+YYYY.MM.dd}"
      manage_template => false
    }
  }
#  stdout {
#    codec => rubydebug
#  }
}

EOH
            destination = "local/logstash.conf"
         }

      resources {
        cpu = 200
        memory = 1024
      }

      service {
        name = "$\u007BNOMAD_NAMESPACE\u007D-logstash"
        port = "logstash"
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
