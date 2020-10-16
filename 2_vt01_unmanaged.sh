#!/bin/bash

source ./env.sh

set -xeo pipefail
export CELL=gcp_use4a
export KEYSPACE=profiles
export TABLET_UID=100

# Bring up an unmanaged tablet referencing the cms Cloud SQL.
# Configure it as master and apply a representative vschema.
./scripts/cms-tablet-up.sh
vtctlclient TabletExternallyReparented gcp_use4a-100
vtctlclient ApplyVSchema -vschema_file `pwd`/vschema_profiles_initial.json ${KEYSPACE}

# Show a bunch of information that confirms it worked.
sleep 15
vtctlclient ListAllTablets
vtctlclient GetKeyspaces
vtctlclient GetKeyspace profiles
mysql -e 'show databases'
mysql -Dprofiles -e 'select count(*) from profile_field_data_latest'
