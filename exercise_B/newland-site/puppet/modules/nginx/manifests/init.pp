class nginx {
    $port = hiera('port', '80')
    $upstream_port = hiera('upstream_port', '8080')

    group { 'puppet':
        ensure => present,
    }

    exec { 'apt-get update': 
        command => '/usr/bin/apt-get update',
    }

    package { 'apache2.2-common':
      ensure => absent,
    }

    package { 'nginx': 
        ensure => present,
        require => Exec['apt-get update'],
    }

    service { 'nginx':
        ensure => running,
        require => Package['nginx'],
    }

    file { 'vagrant-nginx':
        path => '/etc/nginx/sites-available/proxy',
        owner => 'root',
        group => 'root',
        mode => '0644',
        ensure => file,
        notify => Service['nginx'],
        require => Package['nginx'],
        content => template('nginx/proxy.erb'),
    }

    file { 'default-nginx-disable':
        path => '/etc/nginx/sites-enabled/default',
        ensure => absent,
        require => Package['nginx'],
    }

    file { 'vagrant-nginx-enable':
        path => '/etc/nginx/sites-enabled/proxy',
        target => '/etc/nginx/sites-available/proxy',
        ensure => link,
        notify => Service['nginx'],
        require => [
            File['vagrant-nginx'],
            File['default-nginx-disable'],
        ],
    }
}

