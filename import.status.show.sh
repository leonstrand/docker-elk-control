#!/bin/bash

# leon.strand@medeanalytics.com


show() {
  __url="$1"
  echo
  echo $0: curl -sS $__url
  curl -sS $__url
}

show 'localhost:9200/_cat/indices?v'
echo
echo -n "$0: total documents: "
#curl -sS localhost:9200/_cat/indices | grep -v kibana | awk '{print $6}' | paste -s -d+ - | bc
curl -sS localhost:9200/_cat/indices 2>/dev/null | grep -v kibana | awk '{print $6}' | paste -s -d+ - | bc
echo
echo
file=~/docker-elk/logstash/sincedb/.sincedb_*
echo $0: cat $file
cat $file
