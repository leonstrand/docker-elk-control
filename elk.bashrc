alias bl='docker exec -it dockerelk_logstash_1 /bin/bash'
alias bk='docker exec -it dockerelk_kibana_1 /bin/bash'
alias be='docker exec -it dockerelk_elasticsearch_1 /bin/bash'
alias ei='curl localhost:9200/_cat/indices?v'
alias wei='watch -d curl localhost:9200/_cat/indices?v'
alias wen='watch -d ~/docker-elk-control/elasticsearch.nodes.show.sh'
alias wis='watch -d ~/docker-elk-control/import.status.show.sh'
alias wein='watch -d ~/docker-elk-control/elasticsearch.index.nodes.status.sh'
alias dec='time ~/docker-elk-control/clean.sh'
alias dcu='command="cd ~/docker-elk && time docker-compose up"; echo $command; eval $command'
alias dea='command="time ~/docker-elk-control/import.complete.alert.sh"; echo $command; eval $command'
function des() {
  file=~/docker-elk-control/elasticsearch.cluster_hosts.txt
  if [ -n "$1" ]; then
    hosts="$@"
  else
    echo $0: no hosts provided on command line, checking $file
    if [ -s $file ]; then
      interface=$(ip address show | grep '^[1-9]' | egrep -v 'lo|docker' | head -1 | cut -d' ' -f2 | tr -d :)
      self=$(ip address show $interface | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
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
