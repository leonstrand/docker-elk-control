#!/bin/bash

# leon.strand@medeanalytics.com


# set self ip address to first ip address that isn't the loopback interface or any docker interface
self=$(for interface in $(ip link | grep -v link | awk '{print $2}' | egrep -v 'lo|docker' | tr -d :); do if ifconfig $interface | grep -q inet\ ; then break; fi; done; ifconfig $interface | grep inet\  | awk '{print $2}')
echo $0: self: $self

containers='
elasticsearch
elasticsearchloadbalancer
'
images='
logstash
elasticsearch
kibana
'

# set cluster hosts
# try environment variable ELASTICSEARCH_CLUSTER_HOSTS first, command line second, and cluster file last
file=~/docker-elk-control/elasticsearch.cluster_hosts.txt;
if [ -n "$ELASTICSEARCH_CLUSTER_HOSTS" ]; then
  echo $0: setting elasticsearch cluster hosts using environment variable ELASTICSEARCH_CLUSTER_HOSTS
  hosts="$ELASTICSEARCH_CLUSTER_HOSTS"
else
  if [ -n "$1" ]; then
    echo $0: setting elasticsearch cluster hosts using command line arguments
    hosts="$@"
  else
    echo $0: no hosts provided on command line, checking $file
    if [ -s $file ]; then
      echo $0: setting elasticsearch cluster hosts using elasticsearch cluster hosts file $file
    else
      echo $0: could not determine elasticsearch cluster hosts to set discovery.zen.ping.unicast.hosts
      echo $0: must provide at least one host to enable elasticsearch cluster
      echo $0: will only cluster locally without
      echo $0: disregard this warning if this host is the first one up in the elasticsearch cluster
      hosts=''
    fi
  fi
fi

for container in $containers; do
  echo $0: container: $container
  file=~/docker-elk/$container/config/elasticsearch.yml
  echo $0: file: $file
  #network.publish_host: 192.168.1.57
  sed -i 's/^\(network.publish_host: \).*$/\1'$self'/' $file

  discovery_zen_ping_unicast_hosts='["'
  if [ $container == 'elasticsearch' ]; then
    discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'elasticsearchloadbalancer'
  else
    for host in $hosts; do
        discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'", "'$host'", "'$host':9301'
    done
  fi
  discovery_zen_ping_unicast_hosts=$discovery_zen_ping_unicast_hosts'"]'
  # elasticsearchloadbalancer: discovery.zen.ping.unicast.hosts: ["192.168.1.57", "192.168.1.118", "192.168.1.118:9301"]
  sed -i 's/^\(discovery.zen.ping.unicast.hosts: \).*$/\1'"$discovery_zen_ping_unicast_hosts"'/' $file

  echo $0: egrep \'network.publish_host\|discovery.zen.ping.unicast.hosts\' $file
  egrep 'network.publish_host|discovery.zen.ping.unicast.hosts' $file
done

for image in $images; do
  echo $0: time docker pull $image
  time docker pull $image
done
