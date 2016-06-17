# midonet_openstack

NOW UNDER HEAVY DEVELOPMENT!

# midonet-midonet_openstack

MidoNet Reference and Testing Deployment Module for OpenStack.

Version 5.0 / 2014.2 / Juno

####Table of Contents

1. [Overview - What is the puppetlabs-openstack module?](#overview)
2. [A Note on Versioning](#versioning)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with OpenStack](#setup)
    * [Setup Requirements](#setup-requirements)
    * [Beginning with OpenStack](#beginning-with-openstack)
4. [Usage - Configuration and customization options](#usage)
    * [Hiera configuration](#hiera-configuration)
    * [Controller Node](#controller-node)
    * [Storage, Network, and Compute Nodes](#other-nodes)
5. [Reference - An under-the-hood peek at what the module is doing](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [License](#license)

##Overview

The puppetlabs-openstack module is used to deploy a multi-node, all-in-one, or swift-only installation of
OpenStack Juno. This module superseeds [puppetlabs-openstack](http://github.com/puppetlabs/puppetlabs-openstack)
by defining roles and profiles that configure OpenStack with MidoNet as Neutron driver

##Versioning

This module has been given version 4 to track the puppet-openstack modules. The versioning for the
puppet-openstack modules are as follows:

```
Puppet Module :: OpenStack Version :: OpenStack Codename
2.0.0         -> 2013.1.0          -> Grizzly
3.0.0         -> 2013.2.0          -> Havana
4.0.0         -> 2014.1.0          -> Icehouse
5.0.0         -> 2014.2.0          -> Juno
```

##Module Description

Using the stable/juno branch of the puppet-openstack modules, midonet-midonet_openstack allows
for the rapid deployment of an installation of OpenStack Juno. For the multi-node, up to four
types of nodes are created for the deployment:

* A controller node that hosts databases, message queues and caches, and most api services.
* A network node that defines Metadata and DHCP services.
* A compute node to run guest operating systems with the MidoNet agent
* A coordination node for the nsdb (network state database) for clusterized services.

You can still use the storage and tempest nodes defined in [puppetlabs-openstack](https://github.com/puppetlabs/puppetlabs-openstack/blob/master/README.md#module-description)

##Setup

###Setup Requirements

This module assumes nodes running on a RedHat 7 variant (RHEL, CentOS, or Scientific Linux)
or Ubuntu 14.04 (Trusty) with either Puppet Enterprise or Puppet.

Each node needs a minimum of two network interfaces, and up to four.
The network interfaces are divided into two groups.

- Public interfaces:
  * API network.
  * External network.
- Internal interfaces:
  * Management network.
  * Data network.

This module have been tested with Puppet 3.5 and Puppet Enterprise. This module depends upon Hiera. Object
store support (Swift) depends upon exported resources and PuppetDB.

###Beginning with OpenStack

To begin, you will need to do some basic setup on the compute node. SElinux needs to be disabled
on the compute nodes to give OpenStack full control over the KVM hypervisor and other necessary
services. This is the only node that SELinux needs to be disabled on.

Additionally, you need to know the network address ranges for all four of the public/private networks,
and the specific ip addresses of the controller node and the storage node. Keep in mind that your
public networks can overlap with one another, as can the private networks.

The examples directory contains Vagrantfiles with CentOS 7 boxes to test out all-in-one, multi-node,
or swift-only deployments.

##Usage

###Hiera Configuration
The first step to using the puppetlabs-openstack module is to configure hiera with settings specific
to your installation. In this module, the example directory contains sample common.yaml (for multi-node)
and allinone.yaml (for all-in-one) files with all of the settings required by this module, as well as an
example user and networks to test your deployment with. These configuration options include network settings,
locations of specific nodes, and passwords for Keystone and databases. If any of these settings are
undefined or not properly set, your deployment may fail.

###Controller Node
For your controller node, you need to assign your node the controller role. For example:

```
node 'control.localdomain' {
  include ::openstack::role::controller
}
```

It's important to apply this configuration to the controller node before any of the other
nodes are applied. The other nodes depend upon the service and database setup in the controller
node.

###Other Nodes

For the remainder nodes, there are roles to assign for each. For example:
```
node 'storage.localdomain' {
  include ::openstack::role::storage
}

node 'network.localdomain' {
  include ::openstack::role::network
}

node /compute[0-9]+.localdomain/ {
  include ::openstack::role::compute
}
```

For this deployment, it's assumed that there is only one storage node and one network
node. There may be multiple compute nodes.

After applying the configuration to the controller node, apply the remaining
configurations to the worker nodes.

You will need to reboot all of the nodes after installation to ensure that the kernel
module that provides network namespaces, required by Open VSwitch, is loaded.

##Reference

The midonet-midonet_openstack module is built on the 'Roles and Profiles' pattern. Every node
in a deployment is assigned a single role. Every role is composed of some number of
profiles, which ideally should be independent of one another, allowing for composition
of new roles. The puppetlabs-openstack module does not strictly adhere to this pattern,
but should serve as a useful example of how to build profiles from modules for customized
and maintainable OpenStack deployments.

##Limitations

* High availability and SSL-enabled endpoints are not provided by this module.

##License

Copyright (c) 2015 Midokura SARL, All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

**strongly based on**

Puppet Labs OpenStack - A Puppet Module for a Multi-Node OpenStack Juno Installation.

Copyright (C) 2013, 2014 Puppet Labs, Inc. and Authors

Original Author - Christian Hoge

Puppet Labs can be contacted at: info@puppetlabs.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
