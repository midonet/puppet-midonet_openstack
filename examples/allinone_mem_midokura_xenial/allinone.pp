class { 'midonet_openstack::role::allinone_mem':
        mem_username          => '',
        mem_password          => '',
        mem_apache_servername => '',
        horizon_extra_aliases => ['horizonte.midonet.org'],
        cluster_ip            => generate('/bin/sh', '-c', '/usr/bin/curl -s ifcfg.me | tr -d "\n"'),
        is_insights           => undef,
        analytics_ip          => '',
        is_ssl                => false,
        insights_ssl          => false,
}
