#!/bin/bash

source ./env.sh

set -xeo pipefail
export CELL=gcp_use4a
export KEYSPACE=sharded_by_profile

# Configure the new keyspace to be sharded.
# The keyspace is now sharded with N=1 shards.
vtctlclient ApplyVSchema -vschema_file `pwd`/vschema_profiles_sharded.json ${KEYSPACE}

# Note that we had to drop the foreign keys to profile_operations, since one
# profile_operation row may span many profiles.
#
# Now the schema change is commented out to avoid spurious errors, since it was
# already applied once.
vtctlclient InitShardMaster -force ${KEYSPACE}/-40 ${CELL}-300
vtctlclient InitShardMaster -force ${KEYSPACE}/40-80 ${CELL}-400
vtctlclient InitShardMaster -force ${KEYSPACE}/80-c0 ${CELL}-500
vtctlclient InitShardMaster -force ${KEYSPACE}/c0- ${CELL}-510
# vtctlclient ApplySchema -allow_long_unavailability -sql 'ALTER TABLE profile_field_data DROP FOREIGN KEY profile_field_data_ibfk_1, DROP FOREIGN KEY profile_field_data_ibfk_2' ${KEYSPACE}
# vtctlclient ApplySchema -allow_long_unavailability -sql 'ALTER TABLE profile_field_data_latest DROP FOREIGN KEY _profile_field_data_latest_ibfk_1, DROP FOREIGN KEY _profile_field_data_latest_ibfk_2' ${KEYSPACE}
vtctlclient MoveTables -workflow=import profiles ${KEYSPACE} profile_field_data,profile_field_data_latest

# Run SwitchReads & SwitchWrites to start reading and writing profile_field_data
# using the new tables.
vtctlclient SwitchReads -tablet_type=replica sharded_by_profile.import
vtctlclient SwitchReads -tablet_type=rdonly sharded_by_profile.import
vtctlclient SwitchWrites sharded_by_profile.import

# Now all reads and writes to profiles.profile_field_data[_latest] are actually
# served by this new tablet. Run DropSources to remove the profile data from the
# original DB entirely.
