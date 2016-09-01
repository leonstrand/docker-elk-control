#!/bin/bash

# leon.strand@medeanalytics.com


if [ -n "$ELASTICSEARCH_INDICES_PATH" ]; then
  echo $0: elasticsearch indices path: $ELASTICSEARCH_INDICES_PATH
  command="cd ~/docker-elk && time docker-compose up"
  echo $command
  eval $command
else
  echo $0: error: can not start elk
  echo $0: error: elasticsearch indices path unknown
  echo $0: set like so:
  echo export ELASTICSEARCH_INDICES_PATH=/elk
fi
