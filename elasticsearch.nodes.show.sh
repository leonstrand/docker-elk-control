#!/bin/bash

# leon.strand@medeanalytics.com


show() {
  __url="$1"
  echo
  echo $0: curl -sS $__url
  curl -sS $__url
}

show 'localhost:9200/_cluster/state/nodes?pretty'
