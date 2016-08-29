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
apt-get install build-essential htop -y
apt-get install g++ -y
apt-get install lsb lsb-core lsb-release -y
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

mkdir -p /etc/puppet/manifests

# Fuck the iptables
iptables -F

# Run the puppet manifest. Comment this line if you want to perform
# some changes in the manifest
puppet apply /etc/puppet/manifests/site.pp
#puppet apply --modulepath=/opt/puppetlabs/puppet/modules -v -e 'include ::midonet_openstack::role::allinone_mem'

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
