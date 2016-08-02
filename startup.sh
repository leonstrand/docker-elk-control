#!/bin/bash

# leon.strand@medeanalytics.com


user='lstrand'
echo $0: user: $user #debug
# first ip address that isn't the loopback interface or any docker interfaces
self=$(ip address show $(ip address show | grep '^[1-9]' | egrep -v 'lo|docker' | head -1 | cut -d' ' -f2 | tr -d :) | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
echo $0: self: $self #debug
containers='
elasticsearch
elasticsearchloadbalancer
'
images='
logstash
elasticsearch
kibana
'

for container in $containers; do
  #echo #debug
  echo $0: container: $container #debug
  file=/home/$user/docker-elk/$container/config/elasticsearch.yml
  echo $0: file: $file #debug
  #network.publish_host: 192.168.1.57
  sed -i 's/^\(network.publish_host: \).*$/\1'$self'/' $file

  #echo #debug
  discovery_zen_ping_unicast_hosts='["'
  if [ $container == 'elasticsearch' ]; then
    discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'elasticsearchloadbalancer'
  else
    discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts$self
  fi
  if [ -n "$1" ]; then
    for host in $@; do
      #echo $0: host: $host #debug
      discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'", "'$host'", "'$host':9301'
    done
  else #debug
    echo $0: warning: no host provided for discovery.zen.ping.unicast.hosts #debug
    echo $0: must provide at least one host to enable elasticsearch cluster #debug
    echo $0: will only cluster locally without #debug
  fi
  discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'"]'
  #echo $0: discovery_zen_ping_unicast_hosts: $discovery_zen_ping_unicast_hosts #debug
  # elasticsearch: discovery.zen.ping.unicast.hosts: ["192.168.1.57:9301", "192.168.1.118", "192.168.1.118:9301"]
  # elasticsearchloadbalancer: discovery.zen.ping.unicast.hosts: ["192.168.1.57", "192.168.1.118", "192.168.1.118:9301"]
  sed -i 's/^\(discovery.zen.ping.unicast.hosts: \).*$/\1'"$discovery_zen_ping_unicast_hosts"'/' $file

  #echo #debug
  echo $0: egrep \'network.publish_host\|discovery.zen.ping.unicast.hosts\' $file
  egrep 'network.publish_host|discovery.zen.ping.unicast.hosts' $file
done

for image in $images; do
  echo $0: time docker pull $image
  time docker pull $image
done
