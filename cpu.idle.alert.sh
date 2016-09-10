#!/bin/bash

# leon.strand@medeanalytics.com


cpu_usage_threshold=7
check_passed_threshold=15
alerts=10
containers_up_threshold=4

check() {
  check_passed=0
  container_notified=0
  netcat_notified=0
  curl_notified=0
  stage_1_announced=0
  stage_2_announced=0
  stage_3_announced=0
  stage_4_announced=0
  while :; do 
    # stage 1 of 4: containers
    if [ $stage_1_announced -eq 0 ]; then
      echo
      echo
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): stage 1 of 4: containers
      stage_1_announced=1
    fi
    containers_up=$(docker ps -q -f 'name=dockerelk_*' | wc -l)
    if [ "$containers_up" -lt $containers_up_threshold ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $containers_up of $containers_up_threshold containers up
      echo docker ps -af name=dockerelk_\\*
      docker ps -af name=dockerelk_\*
      sleep 1
      continue
    fi
    if [ $container_notified -ne 1 ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): all containers up
      echo docker ps -af name=dockerelk_\\*
      docker ps -af name=dockerelk_\*
      container_notified=1
    fi
    # stage 2 of 4: elasticsearch cluster
    if [ $stage_2_announced -eq 0 ]; then
      echo
      echo
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): stage 2 of 4: elasticsearch cluster
      stage_2_announced=1
    fi
    if nc -w1 localhost 9200; then
      if [ $netcat_notified -ne 1 ]; then
        echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): connection to localhost:9200 succeeded
        echo nc -vw1 localhost 9200
        nc -vw1 localhost 9200
        netcat_notified=1
      fi
    else
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): connection to localhost:9200 failed
      echo nc -w1 localhost 9200
      sleep 1
      continue
    fi
    # stage 3 of 4: elasticsearch indices
    if [ $stage_3_announced -eq 0 ]; then
      echo
      echo
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): stage 3 of 4: elasticsearch indices
      stage_3_announced=1
    fi
    if curl --connect-timeout 1 localhost:9200/_cat/indices?v 1>/dev/null 2>&1; then
      if [ $curl_notified -ne 1 ]; then
        echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): elasticsearch indices curl succeeded
        echo curl --connect-timeout 1 localhost:9200/_cat/indices?v
        curl --connect-timeout 1 localhost:9200/_cat/indices?v
        curl_notified=1
      fi
    else
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): elasticsearch indices curl failed
      echo curl --connect-timeout 1 localhost:9200/_cat/indices?v
      sleep 1
      continue
    fi
    # stage 4 of 4: cpu usage
    if [ $stage_4_announced -eq 0 ]; then
      echo
      echo
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): stage 4 of 4: cpu usage
      stage_4_announced=1
    fi
    cpu_usage_threshold_exceeded=0
    cpu_usages=$(top -bn1 | egrep 'docker-compose|jvm' | grep -v grep | awk '{print $9}')
    if [ -z "$cpu_usages" ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose or jvm processes not detected
      sleep 1
      continue
    fi
    #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage: $cpu_usages
    for cpu_usage in $cpu_usages; do
      if (( $(echo "$cpu_usage >= $cpu_usage_threshold" | bc -l) )); then 
        cpu_usage_threshold_exceeded=1
        echo -n $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage: 
        printf '%5.1f %5.1f %5.1f %5.1f %5.1f' $cpu_usages
        echo : alert threshold all \< $cpu_usage_threshold
        #echo -n $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage: $cpu_usages: cpu usage over threshold $cpu_usage_threshold
        #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose or jvm cpu usage threshold $cpu_usage_threshold exceeded
        #if [ $check_passed -ne 0 ]; then
          #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): setting passed check count back to 0
          #echo : setting passed check count back to 0
          #echo : condition not met
        #else
          #echo
        #fi
        check_passed=0
        break
      fi
    done
    if [ $cpu_usage_threshold_exceeded -eq 0 ]; then
      check_passed=$(expr $check_passed + 1)
      echo -n $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage: 
      printf '%5.1f %5.1f %5.1f %5.1f %5.1f' $cpu_usages
      echo -n : alert threshold all \< $cpu_usage_threshold met 
      printf '%3d ' $check_passed 
      echo of $check_passed_threshold consecutive times
      #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage: $cpu_usages: cpu usage under threshold $cpu_usage_threshold: condition reached $check_passed of $check_passed_threshold times in a row needed to alert
      #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): docker-compose and jvm cpu usage below cpu usage threshold $cpu_usage_threshold
      #echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): condition reached $check_passed of $check_passed_threshold times in a row needed to alert
    fi
    if [ $check_passed -eq $check_passed_threshold ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): cpu usage check passed
      break
    fi
    sleep 1
  done
}
alert() {
  echo
  echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): alerting
  for i in $(seq $alerts); do
    echo -ne '\a'
    sleep 1
  done
}

echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): begin
check
alert
echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): end
