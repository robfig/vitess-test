#!/bin/bash

source ./env.sh

set -xeo pipefail
export CELL=gcp_use4a

./scripts/etcd-up.sh
./scripts/vtctld-up.sh
./scripts/vtgate-up.sh
