#!/bin/bash

source ./env.sh

cell=${CELL:-'test'}
keyspace=${KEYSPACE:-'test_keyspace'}
shard=${SHARD:-'0'}
uid=$TABLET_UID
mysql_port=$[17000 + $uid]
port=$[15000 + $uid]
grpc_port=$[16000 + $uid]
printf -v alias '%s-%010d' $cell $uid
printf -v tablet_dir 'vt_%010d' $uid
tablet_hostname=''
printf -v tablet_logfile 'vttablet_%010d_querylog.txt' $uid

tablet_type=replica

DB_HOST=localhost
DB_PORT=17306
DB_USER=root
DB_PASS=''

echo "Starting vttablet for $alias for $DB_HOST..."
mkdir -p $VTDATAROOT/$tablet_dir
vttablet \
 $TOPOLOGY_FLAGS \
 -log_dir $VTDATAROOT/tmp \
 -tablet-path $alias \
 -tablet_hostname "$tablet_hostname" \
 -init_keyspace $keyspace \
 -init_shard $shard \
 -init_tablet_type $tablet_type \
 -health_check_interval 5s \
 -port $port \
 -grpc_port $grpc_port \
 -service_map 'grpc-queryservice,grpc-tabletmanager,grpc-updatestream' \
 -pid_file $VTDATAROOT/$tablet_dir/vttablet.pid \
 -vtctld_addr http://localhost:15000/ \
 -db_host "$DB_HOST" \
 -db_port "$DB_PORT" \
 -db_app_user "$DB_USER" \
 -db_app_password "$DB_PASS" \
 -db_dba_user "$DB_USER" \
 -db_dba_password "$DB_PASS" \
 -db_repl_user "$DB_USER" \
 -db_repl_password "$DB_PASS" \
 -db_filtered_user "$DB_USER" \
 -db_filtered_password "$DB_PASS" \
 -db_allprivs_user "$DB_USER" \
 -db_allprivs_password "$DB_PASS" \
 -init_db_name_override profiles \
 > $VTDATAROOT/$tablet_dir/vttablet.out 2>&1 &

# Block waiting for the tablet to be listening
# Not the same as healthy

for i in $(seq 0 300); do
 curl -I "http://$hostname:$port/debug/status" >/dev/null 2>&1 && break
 sleep 0.1
done

# check one last time
curl -I "http://$hostname:$port/debug/status" || fail "tablet could not be started!"
