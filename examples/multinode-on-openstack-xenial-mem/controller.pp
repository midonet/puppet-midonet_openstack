class { 'midonet_openstack::role::controller_static':
        zk_id                 => 1,
        is_mem                => true,
        mem_username          => 'qa',
        mem_password          => 'gogoqat3am',
        mem_apache_servername => 'marioneta.midonet.org',
        horizon_extra_aliases => ['horizonte.midonet.org'],
        cluster_ip            => generate('/bin/sh', '-c', '/usr/bin/curl -s ifconfig.io | tr -d "\n"'),
        analytics_ip          => generate('/bin/sh', '-c', '/usr/bin/curl -s ifconfig.io | tr -d "\n"'),
}
