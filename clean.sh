#!/bin/bash

# leon.strand@medeanalytics.com


clean() {
  __container=$1
  echo $0: docker stop $__container
  docker stop $__container
  echo $0: docker rm -v $__container
  docker rm -v $__container
}

sincedb() {
  echo
  echo
  echo $0: rm -fv ~/docker-elk/logstash/sincedb/.sincedb_*
  rm -fv ~/docker-elk/logstash/sincedb/.sincedb_*
}

volumes() {
  dangling_volumes=$(docker volume ls -qf dangling=true)
  if [ -n "$dangling_volumes" ]; then
    echo
    echo
    echo $0: time docker volume ls -qf dangling=true \| xargs -r docker volume rm
    time docker volume ls -qf dangling=true | xargs -r docker volume rm
  fi
  if [ -e /elk/elasticsearch ]; then
    echo $0: sudo rm -rv /elk/elasticsearch
    sudo rm -rv /elk/elasticsearch
  fi
}

containers() {
  containers="$(docker ps -a -f 'name=dockerelk_' --format '{{.Names}}')"
  if [ -n "$containers" ]; then
    echo
    echo
    echo $0: stopping and removing dockerelk_* containers
    for container in $containers; do
      clean $container &
    done
    wait
  fi
  echo
  echo
  echo $0: docker ps -a
  docker ps -a
}

images() {
  orphan_images=$(docker images -a | grep none)
  if [ -n "$orphan_images" ]; then
    echo
    echo
    echo $0: time docker images -a \| grep none \| awk '{print $3}' \| xargs -r docker rmi
    time docker images -a | grep none | awk '{print $3}' | xargs -r docker rmi
  fi
  docker_images=$(docker images --format '{{.Repository}}' dockerelk_*)
  if [ -n "$docker_images" ]; then
    echo
    echo
    echo $0: removing dockerelk_* images
    echo $0: docker rmi $docker_images
    docker rmi $docker_images
  fi
  #echo $0: docker rmi logstash elasticsearch kibana
  #docker rmi logstash elasticsearch kibana
  echo
  echo
  echo $0: docker images -a
  docker images -a
}


#sincedb
volumes
containers
images
echo
