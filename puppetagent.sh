#!/bin/bash

puppetagent() {

echo "setting env"
PUPPET_AGENTCONFIG_PATH='/etc/puppetlabs/puppet/puppet.conf'
INTERNAL_IP=$(hostname -I)
MASTER_IP='172.31.26.218'
echo "================================== installing agent =================================="
yum install -y https://yum.puppetlabs.com/puppet7-release-el-7.noarch.rpm
yum install -y puppet-agent
sleep 5s
echo "================================== add host entry and configs =================================="
sed -i '/master\|agent/d' /etc/hosts
cat << EOF >> /etc/hosts
$INTERNAL_IP agent.puppet.com
$MASTER_IP master.puppet.com

EOF
sed -i '/agent\|server/d' $PUPPET_AGENTCONFIG_PATH
cat << EOF >> $PUPPET_AGENTCONFIG_PATH
[agent]
server = master.puppet.com
EOF
echo "================================== start agent =================================="
echo "sleeping 10s before starting puppet"
sleep 10s
/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
sleep 3s
/opt/puppetlabs/bin/puppet agent -t

}

puppetagent
