alias bl='docker exec -it dockerelk_logstash_1 /bin/bash'
alias bk='docker exec -it dockerelk_kibana_1 /bin/bash'
alias be='docker exec -it dockerelk_elasticsearch_1 /bin/bash'
alias bel='docker exec -it dockerelk_elasticsearchloadbalancer_1 /bin/bash'
alias ei='curl localhost:9200/_cat/indices?v'
alias wei='watch -d curl localhost:9200/_cat/indices?v'
alias wen='watch -d ~/docker-elk-control/elasticsearch.nodes.show.sh'
alias wis='watch -d ~/docker-elk-control/import.status.show.sh'
alias wein='watch -d ~/docker-elk-control/elasticsearch.index.nodes.status.sh'
alias dec='command="time ~/docker-elk-control/clean.sh"; echo $command; eval $command'
alias dcu='command="time ~/docker-elk-control/docker-compose-up.sh"; echo $command; eval $command'
alias dea='command="time ~/docker-elk-control/import.complete.alert.sh"; echo $command; eval $command'
function des() {
  file=~/docker-elk-control/elasticsearch.cluster_hosts.txt
  if [ -n "$1" ]; then
    hosts="$@"
  else
    echo $0: no hosts provided on command line, checking $file
    if [ -s $file ]; then
      self=$(for interface in $(ip link | grep -v link | awk '{print $2}' | egrep -v 'lo|docker' | tr -d :); do if ifconfig $interface | grep -q inet\ ; then break; fi; done; ifconfig $interface | grep inet\  | awk '{print $2}')
      hosts=$(grep -v $self $file)
    else
      echo $0: $file has no size
      hosts=''
    fi
  fi
  command="time ~/docker-elk-control/startup.sh $hosts"
  echo $command
  eval $command
}
