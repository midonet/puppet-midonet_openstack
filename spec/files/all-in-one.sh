#!/bin/bash
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Deploy Puppet OpenStack modules, deploy OpenStack and test the setup.
# Software requirements:
# * Ubuntu 14.04 LTS or Ubuntu 16.04 LTS or CentOS7 fresh install
# * 'git' installed
#
# Hardware requirements:
# * At least 4GB of memory, but 8GB is recommended
# * At least 10GB of storage
#
# Usage:
# $ git clone git://git.openstack.org/openstack/puppet-openstack-integration
# $ cd puppet-openstack-integration
# $ ./all-in-one.sh
#
# or
#
# $ curl -sL http://git.openstack.org/cgit/openstack/puppet-openstack-integration/plain/all-in-one.sh | bash
#

export SCRIPT_DIR=$(cd `dirname $0` && pwd -P)
source $SCRIPT_DIR/functions

print_header 'Preparing environment'

if is_fedora; then
    print_header 'Setup (RedHat based)'
    sudo yum -y install libxml2-devel libxslt-devel ruby-devel rubygems wget
    sudo yum -y groupinstall "Development Tools"
elif uses_debs; then
    print_header 'Setup (Debian based)'
    sudo apt-get update
    sudo apt-get install -y libxml2-dev libxslt-dev zlib1g-dev ruby wget
fi
