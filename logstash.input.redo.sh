#!/bin/bash

# leon.strand@medeanalytics.com


directory=~/docker-elk/logstash/config
template=./input-file-logstash.conf

# set date
date="$1"
if [ -n "$date" ]; then
  date=$(echo $date | sed 's/-//g')
else
  echo $0: error: no date provided
  echo $0: usage: $0 YYYY-MM-DD
  echo $0: purpose: prompt logstash to input all events from a date again
  echo $0: example: $0 2016-09-01
  exit 1
fi

# find first logstash configuration file
logstash_file=$(basename $(find $directory -type f | sort | head -1))
echo first logstash file: $logstash_file

# create logstash configuration file name that will precede the first
logstash_file_sequence=$(echo $logstash_file | cut -d- -f1)
logstash_file_sequence=$(expr $logstash_file_sequence - 1)
logstash_file_sequence=$(printf "%02d\n" $logstash_file_sequence)
logstash_file=$(echo $logstash_file | sed 's/^[0-9]\+\(-.*\)$/'$logstash_file_sequence'\1/')
echo new logstash file: $logstash_file

# stream updated template to new logstash configuration file
#sed 's/XXXXXXXX/'$date'/' $template
sed 's/XXXXXXXX/'$date'/' $template | tee $directory/$logstash_file
