#!/bin/bash

puppetmaster() {

echo "================================== setting local env =================================="
PUPPET_SYSCONFIG_PATH='/etc/sysconfig/puppetserver'
INTERNAL_IP=$(hostname -I)
AGENT_IP='172.31.28.124'
echo "================================== installing puppetmsater =================================="
yum install -y https://yum.puppetlabs.com/puppet7-release-el-7.noarch.rpm
yum install -y puppetserver
sleep 5s
echo "================================== changing the config to work on 512m =================================="
sed -i 's/Xms.g/Xms512m/g;s/Xmx.g/Xmx512m/g' $PUPPET_SYSCONFIG_PATH
echo "================================== check and add host entry =================================="
sed -i '/master\|agent/d' /etc/hosts
cat << EOF >> /etc/hosts
$INTERNAL_IP master.puppet.com
$AGENT_IP agent.puppet.com 

EOF
echo "================================== edit puppet config =================================="
sed -i '/main\|dns\|certname\|master/d' /etc/puppetlabs/puppet/puppet.conf
cat << EOF >> /etc/puppetlabs/puppet/puppet.conf
[main]
dns_alt_names = master.puppet.com
certname = suvipuppetcert
server = master.puppet.com

EOF
echo "================================== ca setup on master =================================="
sudo /opt/puppetlabs/bin/puppetserver ca setup || true
echo "================================== start puppetserver =================================="
echo "sleeping 10s before starting puppetserver"
sleep 10s
systemctl enable puppetserver
systemctl start puppetserver 

}

puppetmaster