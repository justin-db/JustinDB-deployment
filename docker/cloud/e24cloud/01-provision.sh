#!/bin/bash
set -ex

# etcd machine
docker-machine create \
  --e24cloud_apikey $E24CLOUD_APIKEY \
  --e24cloud_apisecret $E24CLOUD_APISECRET \
  --e24cloud_region eu-poland-1poznan \
  --e24cloud_sshkeyname $E24CLOUD_SSHKEYNAME \
  --e24cloud_sshkeypath $E24CLOUD_SSHKEYPATH \
  --e24cloud_cpus 1 \
  --e24cloud_ram 512 \
  -d e24cloud e24cloud-etcd

# Justindb machines
for ID in {0..2}; do
  docker-machine create \
    --e24cloud_apikey $E24CLOUD_APIKEY \
    --e24cloud_apisecret $E24CLOUD_APISECRET \
    --e24cloud_region eu-poland-1poznan \
    --e24cloud_sshkeyname $E24CLOUD_SSHKEYNAME \
    --e24cloud_sshkeypath $E24CLOUD_SSHKEYPATH \
    --e24cloud_cpus 2 \
    --e24cloud_ram 2048 \
    -d e24cloud e24cloud-justindb-$ID
done
