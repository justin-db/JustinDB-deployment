#!/bin/bash
set -ex

docker run \
  --detach \
  --name etcd \
  --publish 2379:2379 \
  quay.io/coreos/etcd:v2.3.7 \
  --listen-client-urls http://0.0.0.0:2379 \
  --advertise-client-urls http://192.168.99.100:2379

docker run \
    --name justindb-1 -d \
    -p 9000:9000 -p 2551:2551 -p 19999:19999 \
    -v justindb-1-vol:/opt/docker/justindb \
    justindb/justindb:0.1 \
    -Djustin.node-id=0 \
    -Djustin.storage-type=justin.db.storage.RocksDBStorage \
    -Djustin.storage-journal-path=/opt/docker/justindb/rocksdb \
    -Dakka.remote.netty.tcp.hostname=192.168.0.3 \
    -Dakka.remote.netty.tcp.port=2551 \
    -Dakka.remote.netty.tcp.bind-hostname=172.17.0.3 \
    -Dakka.remote.netty.tcp.bind-port=2551 \
    -Dakka.cluster.role.storagenode.min-nr-of-members=3

docker run \
    --name justindb-2 -d \
    -p 9001:9000 -p 2552:2552 -p 20000:19999 \
    -v justindb-2-vol:/opt/docker/justindb \
    justindb/justindb:0.1 \
    -Djustin.node-id=1 \
    -Djustin.storage-type=justin.db.storage.RocksDBStorage \
    -Djustin.storage-journal-path=/opt/docker/justindb/rocksdb \
    -Dakka.remote.netty.tcp.hostname=192.168.0.3 \
    -Dakka.remote.netty.tcp.port=2552 \
    -Dakka.remote.netty.tcp.bind-hostname=172.17.0.4 \
    -Dakka.remote.netty.tcp.bind-port=2552 \
    -Dakka.cluster.role.storagenode.min-nr-of-members=3

docker run \
    --name justindb-3 -d \
    -p 9002:9000 -p 2553:2553 -p 20001:19999 \
    -v justindb-3-vol:/opt/docker/justindb \
    justindb/justindb:0.1 \
    -Djustin.node-id=2 \
    -Djustin.storage-type=justin.db.storage.RocksDBStorage \
    -Djustin.storage-journal-path=/opt/docker/justindb/rocksdb \
    -Dakka.remote.netty.tcp.hostname=192.168.0.3 \
    -Dakka.remote.netty.tcp.port=2553 \
    -Dakka.remote.netty.tcp.bind-hostname=172.17.0.5 \
    -Dakka.remote.netty.tcp.bind-port=2553 \
    -Dakka.cluster.role.storagenode.min-nr-of-members=3

sleep 40

curl 192.168.0.3:9000/health
curl 192.168.0.3:9001/health
curl 192.168.0.3:9002/health

curl 192.168.0.3:19999/members
