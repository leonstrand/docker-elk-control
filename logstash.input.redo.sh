#!/bin/bash

# leon.strand@medeanalytics.com


directory=~/docker-elk/logstash/config
template=./input-file-logstash.conf
container='dockerelk_logstash_1'

set_date() {
  echo
  echo
  echo $0: stage 1 of 6: setting date
  date="$1"
  if [ -n "$date" ]; then
    date=$(echo $date | sed 's/-//g')
    date=$(echo $date | sed 's/\.//g')
  else
    echo $0: error: no date provided
    echo $0: usage: $0 YYYY-MM-DD
    echo $0: purpose: prompt logstash to input all events from a date again
    echo $0: example: $0 2016-09-01
    exit 1
  fi
}

find_first_logstash_configuration_file() {
  echo
  echo
  echo $0: stage 2 of 6: finding first logstash configuration file
  logstash_file=$(basename $(find $directory -type f | sort | head -1))
  echo first logstash file: $logstash_file
}

create_preceding_logstash_configuration_file_name() {
  echo
  echo
  echo $0: stage 3 of 6: creating preceding logstash configuration file name
  logstash_file_sequence=$(echo $logstash_file | cut -d- -f1)
  logstash_file_sequence=$(expr $logstash_file_sequence - 1)
  logstash_file_sequence=$(printf "%02d\n" $logstash_file_sequence)
  logstash_file=$(echo $logstash_file | sed 's/^[0-9]\+\(-.*\)$/'$logstash_file_sequence'\1/')
  logstash_file=$(echo $logstash_file | sed 's/^\(.*\)\(-logstash.conf\)$/\1-'$date'\2/')
  echo new logstash file: $logstash_file
}

stream_updated_template_to_preceding_logstash_configuration_file() {
  echo
  echo
  echo $0: stage 4 of 6: streaming updated template to preceding logstash configuration file
  #sed 's/XXXXXXXX/'$date'/' $template
  sed 's/XXXXXXXX/'$date'/' $template | tee $directory/$logstash_file
}

delete_elasticsearch_index() {
  echo
  echo
  echo $0: stage 5 of 6: deleting elasticsearch index
  # build elasticsearch index name
  date=$(echo $date | sed 's/^\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)$/\1.\2.\3/')
  echo $0: date: $date
  elasticsearch_index='logstash-'$date
  echo $0: elasticsearch_index: $elasticsearch_index
  time ~/docker-elk-control/elasticsearch.index.delete.sh foo
}

erase_logstash_sincedb() {
  echo
  echo
  echo $0: stage 6 of 6: erasing logstash sincedb
  time docker cp ~/docker-elk-control/logstash.sincedb.erase.sh $container:/
  time docker exec $container /logstash.sincedb.erase.sh
  time docker exec $container rm -v /logstash.sincedb.erase.sh
}


set_date "$@"
#find_first_logstash_configuration_file
#create_preceding_logstash_configuration_file_name
#stream_updated_template_to_preceding_logstash_configuration_file
delete_elasticsearch_index
erase_logstash_sincedb
