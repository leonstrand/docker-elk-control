#!/bin/bash

# leon.strand@medeanalytics.com


nodes='
192.168.1.57
192.168.1.77
192.168.1.118
192.168.1.251
'

execute() {
  echo $@
  eval $@
}

command='curl -sS localhost:9200/_cat/indices?v'
execute $command

docs_count=$(curl -sS localhost:9200/_cat/indices?v | egrep -v 'health|kibana' | awk '{sum += $6} END {print sum}')
docs_deleted=$(curl -sS localhost:9200/_cat/indices?v | egrep -v 'health|kibana' | awk '{sum += $7} END {print sum}')
printf '%s %19s %12s\n' 'total documents excluding kibana' $docs_count $docs_deleted


echo
command='curl -sS localhost:9200/_cluster/state/version,master_node?pretty'
execute $command

echo
#echo curl -sS localhost:9200/_nodes/_all/http_address?pretty \| grep -v cluster_name \| egrep \'name\|http_address\|data\|master\'
#curl -sS localhost:9200/_nodes/_all/http_address?pretty | grep -v cluster_name | egrep 'name|http_address|data|master'
#curl -sS localhost:9200/_cluster/state/version,nodes?pretty | egrep 'name|transport_address|data|master'
echo $0: elasticsearch cluster nodes
echo -e 'ip address\tport\trole'
master_node=$(curl -sS localhost:9200/_cluster/state/master_node?pretty | grep master_node | awk '{print $NF}' | tr -d \")
elasticsearch_nodes=$(curl -sS localhost:9200/_nodes/_all/http_address?pretty | grep -B1 '"name"' | egrep -v '"name"|--' | awk '{print $1}' | tr -d \")
for elasticsearch_node in $elasticsearch_nodes; do
  #curl -sS localhost:9200/_nodes/$elasticsearch_node/http_address?pretty
  http_address=$(curl -sS localhost:9200/_nodes/$elasticsearch_node/http_address?pretty | grep '"http_address"' | awk '{print $NF}' | tr -d '",')
  ip=$(echo $http_address | cut -d: -f1)
  port=$(echo $http_address | cut -d: -f2)
  role=
  if [ "$master_node" == "$elasticsearch_node" ]; then
    role='master, data'
  else
    if curl -sS localhost:9200/_nodes/$elasticsearch_node/http_address?pretty | grep -A2 '"attributes"' | grep -v attributes | grep -q '"data" : "false"'; then
      if curl -sS localhost:9200/_nodes/$elasticsearch_node/http_address?pretty | grep -A2 '"attributes"' | grep -v attributes | grep -q '"master" : "false"'; then
        role='loadbalancer'
      fi
    else
      role='data'
    fi
  fi
  #echo -e $http_address'\t'$role
  echo -e $ip'\t'$port'\t'$role
done | sort -V

echo
echo $0: logstash nodes with file input
for node in $nodes; do
  echo -en $node'\t'
  #ssh $node ls ~/docker-elk/logstash/config/10*
  ssh $node "if [ -f ~/docker-elk/logstash/config/10* ]; then echo yes; else echo no; fi"
done
