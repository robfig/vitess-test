#!/bin/bash

# Copyright 2019 The Vitess Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is an example script that creates a quorum of ZooKeeper servers.

source ./env.sh

cell=${CELL:-'test'}
export ETCDCTL_API=2

# Check that etcd is not already running
curl "http://${ETCD_SERVER}" > /dev/null 2>&1 && fail "etcd is already running. Exiting."

etcd \
  --enable-v2=true \
  --name "$(hostname)" \
  --data-dir "${VTDATAROOT}/etcd/" \
  --listen-client-urls "http://0.0.0.0:2379" \
  --advertise-client-urls "http://$(hostname):2379" \
  --listen-peer-urls "http://0.0.0.0:2380" \
  --initial-advertise-peer-urls "http://$(hostname):2380" \
  --initial-cluster "kmg-mvt01=http://kmg-mvt01:2380,kmg-mvt02=http://kmg-mvt02:2380,kmg-mvt03=http://kmg-mvt03:2380" \
> "${VTDATAROOT}"/tmp/etcd.out 2>&1 &

PID=$!
echo $PID > "${VTDATAROOT}/tmp/etcd.pid"
sleep 5

echo "add /vitess/global"
etcdctl --endpoints "http://${ETCD_SERVER}" mkdir /vitess/global &

echo "add /vitess/$cell"
etcdctl --endpoints "http://${ETCD_SERVER}" mkdir /vitess/$cell &

# And also add the CellInfo description for the cell.
# If the node already exists, it's fine, means we used existing data.
echo "add $cell CellInfo"
set +e
# shellcheck disable=SC2086
vtctl $TOPOLOGY_FLAGS AddCellInfo \
  -root /vitess/$cell \
  -server_address "$(hostname):2379" \
  $cell
set -e

echo "etcd start done..."
