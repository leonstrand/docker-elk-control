#!/bin/bash

# leon.strand@medeanalytics.com


host='localhost'
port='9200'

if [ -n "$1" ]; then
  index=$1
  if ! curl -XHEAD -i $host:$port/$index 2>/dev/null | grep -q 200; then
    echo $0: error: index $index does not exist
    exit 1
  fi
else
  echo $0: no index provided, selecting oldest index
  index=$(curl $host:$port/_cat/indices 2>/dev/null | awk '$3 ~ /logstash/ {print $3}' | sort | head -1)
  if [ -z "$index" ]; then
    echo $0: error: no index found
    exit 1
  fi
fi
echo $0: index $index selected
echo curl -XDELETE $host:$port/$index
curl -XDELETE $host:$port/$index
