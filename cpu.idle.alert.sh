#!/bin/bash

# leon.strand@medeanalytics.com


process='jvm'
string=$process' cpu usage'
cpu_usage_threshold=7
check_passed_threshold=15
alerts=10
mail_sender='leon.strand@medeanalytics.com'
mail_recipient='leonstrand@gmail.com'
mail_subject="$string under threshold $cpu_usage_threshold"

check() {
  check_passed=0
  stage_4_announced=0
  while :; do 
    if [ $stage_4_announced -eq 0 ]; then
      echo
      echo
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $string
      stage_4_announced=1
    fi
    cpu_usage_threshold_exceeded=0
    cpu_usages=$(top -bn1 | grep $process | grep -v grep | awk '{print $9}')
    if [ -z "$cpu_usages" ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $string not detected
      sleep 1
      continue
    fi
    for cpu_usage in $cpu_usages; do
      if (( $(echo "$cpu_usage >= $cpu_usage_threshold" | bc -l) )); then 
        cpu_usage_threshold_exceeded=1
        echo -n $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $string: 
        printf '%5.1f %5.1f %5.1f %5.1f %5.1f' $cpu_usages
        echo : alert threshold all \< $cpu_usage_threshold
        check_passed=0
        break
      fi
    done
    if [ $cpu_usage_threshold_exceeded -eq 0 ]; then
      check_passed=$(expr $check_passed + 1)
      echo -n $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $string: 
      printf '%5.1f %5.1f %5.1f %5.1f %5.1f' $cpu_usages
      echo -n : alert threshold all \< $cpu_usage_threshold met 
      printf '%3d ' $check_passed 
      echo of $check_passed_threshold consecutive times
    fi
    if [ $check_passed -eq $check_passed_threshold ]; then
      echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): $string check passed
      break
    fi
    sleep 1
  done
}
alert() {
  echo
  echo
  echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): alerting
  echo
  time top -bn1 -p $(pgrep -d, -f jvm) | tee >(mailx -v -s "$mail_subject" -r $mail_sender $mail_recipient)
}

echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): begin
check
alert
echo $0: $(date '+%Y-%m-%d %H:%M:%S.%N'): end
