#!/bin/bash

# leon.strand@medeanalytics.com


directory=/elk

start() {
  if grep -q 'network.publish_host: docker host ip address or hostname' ~/docker-elk/elasticsearch/config/elasticsearch.yml; then
    echo $0: error: can not start elk
    echo $0: error: elasticsearch configuration lacks required network information
    echo $0: set like so:
    echo ~/docker-elk-control/startup.sh
    echo $0: then rerun $0
  else
    command="cd ~/docker-elk && time docker-compose up"
    echo $command
    eval $command
  fi
}

if [ -n "$ELASTICSEARCH_INDICES_PATH" ]; then
  echo $0: info: elasticsearch indices path environment variable ELASTICSEARCH_INDICES_PATH defined
  echo $0: info: elasticsearch indices path: $ELASTICSEARCH_INDICES_PATH
  start
else
  if [ -d /elk ]; then
    echo $0: warning: elasticsearch indices path environment variable ELASTICSEARCH_INDICES_PATH undefined but directory $directory exists
    echo $0: warning: setting elasticsearch indices path environment variable ELASTICSEARCH_INDICES_PATH to $directory
    export ELASTICSEARCH_INDICES_PATH=/elk
    start
  else
    echo $0: error: can not start elk
    echo $0: error: elasticsearch indices path undefined and directory $directory does not exist
    echo $0: set like so:
    echo export ELASTICSEARCH_INDICES_PATH=/elk
  fi
fi
