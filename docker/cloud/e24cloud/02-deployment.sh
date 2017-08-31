#!/bin/bash
set -ex

eval $(docker-machine env e24cloud-etcd)
ETCD_IP=$(docker-machine ip e24cloud-etcd)

docker run \
  --detach \
  --name etcd \
  --publish 2379:2379 \
  quay.io/coreos/etcd:v2.3.7 \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://$ETCD:2379

for ID in {0..2}; do
  eval $(docker-machine env e24cloud-justindb-$ID)
  HOST_IP=$(docker-machine ip e24cloud-justindb-$ID)
  ETCD_IP=$(docker-machine ip e24cloud-etcd)

  docker run \
    --name justindb \
    -p 9000:9000 -p 2551:2551 -d \
    -v justindb-vol:/opt/docker/justindb \
    justindb/justindb:0.1 \
    -Djustin.node-id=$ID \
    -Djustin.storage-type=justin.db.storage.PersistentStorage \
    -Djustin.storage-journal-path=/opt/docker/justindb/journal \
    -Djustin.system=e24cloud-justindb \
    -Djustin.ring.members-count=3 \
    -Dakka.remote.netty.tcp.hostname=$HOST_IP \
    -Dakka.remote.netty.tcp.bind-port=2551 \
    -Dakka.remote.netty.tcp.bind-hostname=172.17.0.2 \
    -Dconstructr.coordination.host=$ETCD_IP
done
