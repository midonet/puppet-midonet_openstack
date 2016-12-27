class { 'midonet_openstack::role::allinone_mem':
        cluster_ip            => generate('/bin/sh', '-c', '/usr/bin/curl -s ifconfig.io | tr -d "\n"'),
        analytics_ip          => generate('/bin/sh', '-c', '/usr/bin/curl -s ifconfig.io | tr -d "\n"'),
}
