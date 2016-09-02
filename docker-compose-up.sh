#!/bin/bash

# leon.strand@medeanalytics.com


if [ -n "$ELASTICSEARCH_INDICES_PATH" ]; then
  echo $0: elasticsearch indices path: $ELASTICSEARCH_INDICES_PATH
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
else
  echo $0: error: can not start elk
  echo $0: error: elasticsearch indices path unknown
  echo $0: set like so:
  echo export ELASTICSEARCH_INDICES_PATH=/elk
fi
