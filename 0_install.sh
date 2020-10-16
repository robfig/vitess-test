#!/bin/bash

# Install Percona Server 5.7
sudo yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release setup ps57
sudo yum -y install Percona-Server-server-57
sudo yum -y install etcd

# Download Vitess 7.0.2 & move into /usr/local/vitess.
curl -OL https://github.com/vitessio/vitess/releases/download/v7.0.2/vitess-7.0.2-aea21dc.tar.gz
tar -xzf vitess-7.0.2-aea21dc.tar.gz
cd vitess-7.0.2-aea21dc
sudo mkdir -p /usr/local/vitess
sudo mv * /usr/local/vitess/

# Add that to PATH.
echo 'export PATH=/usr/local/vitess/bin:${PATH}' >> ~/.bash_profile
echo "Please run:"
echo "  export PATH=/usr/local/vitess/bin:${PATH}"
cd ..
