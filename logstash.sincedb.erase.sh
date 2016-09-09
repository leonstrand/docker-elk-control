#!/bin/bash

# leon.strand@medeanalytics.com


directory_sincedb=/var/lib/logstash
directory_tmp=/tmp
logs=/pai-logs
date='20160902'

for i in $directory_sincedb/.sincedb_*; do
  if [ -s $i ]; then
    echo
    echo $i
    grep -vf <(find $logs -type f -name \*$date\* -printf '%i\n') $i >$directory_tmp/$(basename $i)
    wc -l $i
    wc -l $directory_tmp/$(basename $i)
  fi
done
