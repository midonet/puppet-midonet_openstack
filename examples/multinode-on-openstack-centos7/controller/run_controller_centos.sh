#!/bin/bash
set -x
set -e

# Variables
TMP_DIR="/tmp"
OPENSTACK_AIO_DIR="/openstack"
PUPPET_MAJ_VERSION=4
PUPPET_RELEASE_FILE=puppetlabs-release-pc1
PUPPET_BASE_PATH=/etc/puppetlabs/code
PUPPET_PKG=puppet-agent
PUPPET_MODULEDIR="${PUPPET_BASE_PATH}/modules"

hostnamectl set-hostname $(hostname -s)

sed -i "s|^127.0.0.1.*|127.0.0.1  $(hostname -s).local $(hostname -s) localhost|" /etc/hosts

# Prerequisites
sudo yum -y remove facter puppet rdo-release epel-release
sudo yum -y install libxml2-devel libxslt-devel ruby-devel rubygems wget vim biosdevname tcpdump
sudo yum -y groupinstall "Development Tools"

# Puppet
cd ${TMP_DIR}
wget http://yum.puppetlabs.com/${PUPPET_RELEASE_FILE}-el-7.noarch.rpm
if [ $(rpm -qa|grep -c ${PUPPET_RELEASE_FILE}) -le 0 ]; then
  rpm -ivh ${PUPPET_RELEASE_FILE}-el-7.noarch.rpm
fi
yum install -y ${PUPPET_PKG}

# Gems
gem install bundler --no-rdoc --no-ri --verbose
cd ${OPENSTACK_AIO_DIR}

# Hack the module 'openstack'
IP=$(ip -4 a | grep inet | grep -e '192.168.1\.' | sed 's/^[[:space:]]*//' | cut -d' ' -f2 | cut -d'/' -f1)
sed -i "s/bridged_ip/${IP}/" examples/multinode-on-openstack-centos7/params.pp

# get the network of the bridged interface and replace some variables
NETWORK=$(ip r | grep -v default | grep -e '^192.168.1\.' | cut -d' ' -f1)
sed -i "s%bridged_network%${NETWORK}%" examples/multinode-on-openstack-centos7/params.pp

ALLOWED_HOST_NETWORK=$(ip r | grep -v default | grep -e '^192.168.1\.' | cut -d' ' -f1 | cut -d'/' -f1 | cut -d'.' -f1,2,3).%
sed -i "s,allowed_host_network,${ALLOWED_HOST_NETWORK}," examples/multinode-on-openstack-centos7/params.pp

#Override the params.pp
cp examples/multinode-on-openstack-centos7/params.pp manifests/params.pp

sudo echo "export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin'" > ~/.bashrc
source ~/.bashrc

bundle install --path ~/.gem
export PATH="${PATH}:~/.gem/ruby/bin"
echo 'export PATH="${PATH}:~/.gem/ruby/bin"' > ~/.bashrc

# Puppet modules
r10k puppetfile install --puppetfile ${OPENSTACK_AIO_DIR}/Puppetfile \
  --moduledir ${PUPPET_MODULEDIR}

# Make sure puppet-midonet has the latest changes
rm -rf /etc/puppetlabs/code/modules/midonet
cp -R /ali-g /etc/puppetlabs/code/modules/midonet

# Copy this repository to $moduledir
mkdir -p ${PUPPET_MODULEDIR}/midonet_openstack
cp -R ${OPENSTACK_AIO_DIR}/* ${PUPPET_MODULEDIR}/midonet_openstack/

# Run the puppet manifest. Comment this line if you want to perform
# some changes in the manifest

# Fuck the iptables
iptables -F

/opt/puppetlabs/puppet/bin/gem install faraday multipart-post
puppet apply -e "include ::midonet_openstack::role::controller_static"  2>&1 | tee /tmp/puppet-$(date +"%Y-%m-%d_%H-%M-%S").out
#sed -i 's/\(novncproxy_base_url=http:\/\/\)[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\(:6080\/vnc_auto.html\)$/\1'"${1}"'\2/' /etc/nova/nova.conf
#service openstack-nova-compute restart
#ip link set dev eth1 up

# Fuck the iptables
iptables -F
# Add the FIP to Horizon Vhost
# We do a sed because centos7 was screwing with the echo solution.
sed -i "\|</VirtualHost>|i ServerAlias $2" /etc/httpd/conf.d/15-horizon_vhost.conf
# Restart the Apache service.
service httpd stop
service httpd start
