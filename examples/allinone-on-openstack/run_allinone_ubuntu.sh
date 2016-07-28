#!/bin/bash
set -x
set -e

#Fix fqdm issues
sed -i '/127.0.0.1 localhost$/ s/$/ allinone/' /etc/hosts
echo domain local >> /etc/resolv.conf
sudo hostname allinone

# Update machine and install vim (just in case)


apt-get remove puppet -y
sudo apt-get update -y
apt-get install git -y
apt-get install build-essential -y
apt-get install g++ -y
sudo apt-get autoremove puppet
sudo apt-get install ruby-dev vim -y
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
sudo dpkg -i puppetlabs-release-pc1-trusty.deb
rm -rf puppetlabs-release-pc1-trusty.deb
sudo apt-get update
apt-get install puppetserver -y
sudo echo "export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin'" > ~/.bashrc
source ~/.bashrc
rm -rf /usr/bin/gem

ln -s /opt/puppetlabs/puppet/bin/gem /usr/bin/gem

sudo apt-get install zlib1g zlib1g-dev g++ -y
/opt/puppetlabs/puppet/bin/gem  install r10k --no-rdoc --no-ri --verbose
/opt/puppetlabs/puppet/bin/gem  install bundler --no-rdoc --no-ri --verbose
/opt/puppetlabs/puppet/bin/gem  install faraday --no-rdoc --no-ri --verbose
/opt/puppetlabs/puppet/bin/gem  install json --no-rdoc --no-ri --verbose
/opt/puppetlabs/puppet/bin/r10k puppetfile install --moduledir /opt/puppetlabs/puppet/modules/ --puppetfile /openstack/Puppetfile --verbose
ln -s /openstack/ /opt/puppetlabs/puppet/modules/midonet_openstack

# Hack the module 'openstack'
IP=$(ip -4 a | grep inet | grep -e '192.168.1\.' | sed 's/^[[:space:]]*//' | cut -d' ' -f2 | cut -d'/' -f1)
sed -i "s/bridged_ip/${IP}/" /vagrant/params.pp

# get the network of the bridged interface and replace some variables
NETWORK=$(ip r | grep -v default | grep -e '^192.168.1\.' | cut -d' ' -f1)
sed -i "s%bridged_network%${NETWORK}%" /vagrant/params.pp

ALLOWED_HOST_NETWORK=$(ip r | grep -v default | grep -e '^192.168.1\.' | cut -d' ' -f1 | cut -d'/' -f1 | cut -d'.' -f1,2,3).%
sed -i "s,allowed_host_network,${ALLOWED_HOST_NETWORK}," /vagrant/params.pp

## Copy the hacked params.pp

cp /vagrant/params.pp /opt/puppetlabs/puppet/modules/midonet_openstack/manifests/params.pp


# Run the puppet manifest. Comment this line if you want to perform
# some changes in the manifest
puppet apply -e "include ::midonet_openstack::role::allinone_vanilla"
# Fuck the iptables
iptables -F
#Add the FIP to Horizon Vhost
new_vhost=$(mktemp)
head -n -1 /etc/apache2/sites-enabled/15-horizon_vhost.conf > $new_vhost
echo "ServerAlias $1" >> $new_vhost
echo '</VirtualHost>' >> $new_vhost
mv $new_vhost /etc/apache2/sites-enabled/15-horizon_vhost.conf
# Restart the Apache service.
service apache2 restart
