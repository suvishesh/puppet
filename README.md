# puppet


repo : https://yum.puppetlabs.com/ 
on both master and server install the repo 

yum install -y https://yum.puppetlabs.com/puppet7-release-el-7.noarch.rpm

-----------------------------------------------------------------------------------------------------------------------------------------

# master	:	

yum install -y puppetserver

open /etc/sysconfig/puppetserver

 Modify this if you'd like to change the memory allocation, enable JMX, etc
 JAVA_ARGS="-Xms2g -Xmx2g" 
to
 JAVA_ARGS="-Xms512m -Xmx512m".

 
vi /etc/hosts
<ip> puppet,master.suvishesh.com
<ip> agent.suvishesh.com


vi /etc/puppetlabs/puppet/puppet.conf

[main]
dns_alt_names = master.suvishesh.com
certname = suvipuppetcert
server = master.suvishesh.com

# Generate a root and intermediate signing CA for Puppet Server

sudo /opt/puppetlabs/bin/puppetserver ca setup


enable and start 
 systemctl enable puppetserver
 systemctl start puppetserve

-----------------------------------------------------

# agent	: 	

yum install -y puppet-agent

vi /etc/hosts
<ip> puppet,master.suvishesh.com
<ip> agent.suvishesh.com


vi /etc/puppetlabs/puppet/puppet.conf
[agent]
server = master.suvishesh.com


sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

o/p : 
[root@agent_one puppet]# sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
Notice: /Service[puppet]/ensure: ensure changed 'stopped' to 'running'
service { 'puppet':
  ensure   => 'running',
  enable   => 'true',
  provider => 'systemd',
}

----------------------------------------------------------

#signing certificate

# 1. on agent run this command to request master to sign the certifacte 

/opt/puppetlabs/bin/puppet agent -t 

o/p:
[root@agent_one ~]# /opt/puppetlabs/bin/puppet agent -t
Info: csr_attributes file loading from /etc/puppetlabs/puppet/csr_attributes.yaml
Info: Creating a new SSL certificate request for agent_one.us-east-2.compute.internal
Info: Certificate Request fingerprint (SHA256): 79:3B:4C:A9:E9:37:87:83:C3:DD:06:65:8B:84:0B:1D:DD:FB:90:DD:46:26:72:54:D3:7A:00:9D:79:F5:80:59
Info: Certificate for agent_one.us-east-2.compute.internal has not been signed yet
Couldn't fetch certificate from CA server; you might still need to sign this agent's certificate (agent_one.us-east-2.compute.internal).
Exiting now because the waitforcert setting is set to 0.

# 2. on master execute to list certificates

sudo /opt/puppetlabs/bin/puppetserver ca list 

o/p:
[root@master ~]# sudo /opt/puppetlabs/bin/puppetserver ca list
Requested Certificates:
    agent_one.us-east-2.compute.internal       (SHA256)  79:3B:4C:A9:E9:37:87:83:C3:DD:06:65:8B:84:0B:1D:DD:FB:90:DD:46:26:72:54:D3:7A:00:9D:79:F5:80:59

# 3. sign the certifacte with name 

sudo /opt/puppetlabs/bin/puppetserver ca sign --certname agent_one.us-east-2.compute.internal 

to sign all certificate requests 
sudo /opt/puppetlabs/bin/puppetserver ca sign --all

o/p:
[root@master ~]# sudo /opt/puppetlabs/bin/puppetserver ca sign --certname agent_one.us-east-2.compute.internal
Successfully signed certificate request for agent_one.us-east-2.compute.internal

#In some cases, you may need to revoke the certificate of a particular node to read them back. Replace the <AGENT_NAME> with your client hostname.

sudo /opt/puppetlabs/bin/puppetserver ca revoke --certname <AGENT_NAME>

#List all of the signed and unsigned requests. You should run on the master server.

sudo /opt/puppetlabs/bin/puppetserver ca list --all

# 4. Verify Puppet Agent
Once the Puppet master is signed your client certificate, run the following command on the client machine to test it.

sudo /opt/puppetlabs/bin/puppet agent --test

o/p:
[root@agent_one ~]# sudo /opt/puppetlabs/bin/puppet agent --test
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Caching catalog for agent_one.us-east-2.compute.internal
Info: Applying configuration version '1614095113'
Notice: Applied catalog in 0.01 seconds


# docs : 
https://medium.com/@vikumkbv/how-to-install-puppet-master-and-puppet-agent-in-linux-system-e4afa6eb0ef
https://www.edureka.co/blog/install-puppet/#install_puppet_master_and_puppet_agent 
https://www.howtoforge.com/tutorial/how-to-setup-puppet-master-and-agent-on-centos-7/c
