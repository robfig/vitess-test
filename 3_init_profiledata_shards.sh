#!/bin/bash

source ./env.sh

set -xeo pipefail
export CELL=gcp_use4a
export KEYSPACE=sharded_by_profile

################################################################################
# Move profile_field_data to new keyspace.
#
# Only the profile_field_data tables will be sharded; the other tables in the
# existing profiles database will remain unsharded. As a result, the
# profile_field_data tables must be moved to a separate keyspace.
################################################################################

# Create primary & replica tablets for each of 4 shards, divided across 3 hosts.
# The tablets with UID ending in 0 are the primary shards, 1 are the replicas.
case $(hostname) in
    kmg-mvt01)
	TABLET_UID=300 ./scripts/mysqlctl-up.sh
	TABLET_UID=300 SHARD=-40 ./scripts/vttablet-up.sh
	TABLET_UID=301 ./scripts/mysqlctl-up.sh
	TABLET_UID=301 SHARD=40-80 ./scripts/vttablet-up.sh
	TABLET_UID=311 ./scripts/mysqlctl-up.sh
	TABLET_UID=311 SHARD=c0- ./scripts/vttablet-up.sh
    ;;
    kmg-mvt02)
	TABLET_UID=400 ./scripts/mysqlctl-up.sh
	TABLET_UID=400 SHARD=40-80 ./scripts/vttablet-up.sh
	TABLET_UID=401 ./scripts/mysqlctl-up.sh
	TABLET_UID=401 SHARD=80-c0 ./scripts/vttablet-up.sh
    ;;
    kmg-mvt03)
	TABLET_UID=500 ./scripts/mysqlctl-up.sh
	TABLET_UID=500 SHARD=80-c0 ./scripts/vttablet-up.sh
	TABLET_UID=510 ./scripts/mysqlctl-up.sh
	TABLET_UID=510 SHARD=c0- ./scripts/vttablet-up.sh
	TABLET_UID=511 ./scripts/mysqlctl-up.sh
	TABLET_UID=511 SHARD=-40 ./scripts/vttablet-up.sh
    ;;
    *)
        fail "unknown host $(hostname)"
    ;;
esac

# Display a bunch of status information, showing the second keyspace and how it
# appears like a MySQL database with the profile_field_data tables.
sleep 30
vtctlclient GetKeyspaces
vtctlclient ListAllTablets
mysql -e 'show vitess_tablets'
mysql -e 'show databases'
mysql -Dprofiles -e 'select count(*) from profile_field_data_latest'
mysql -Dsharded_by_profile -e 'show tables'
mysql -Dsharded_by_profile -e 'select count(*) from profile_field_data_latest'
