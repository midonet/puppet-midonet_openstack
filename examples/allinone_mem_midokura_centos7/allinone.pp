class { 'midonet_openstack::role::allinone_mem':
        mem_username          => 'qa',
        mem_password          => 'gogoqat3am',
        cluster_ip            => generate('/bin/sh', '-c', '/usr/bin/curl -s ifcfg.me | tr -d "\n"'),
        analytics_ip          => generate('/bin/sh', '-c', '/usr/bin/curl -s ifcfg.me | tr -d "\n"'),
}
