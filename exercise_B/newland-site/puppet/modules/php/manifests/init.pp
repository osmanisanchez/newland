class php {
    $port = hiera('port', '80')
    $index = hiera('index', 'index.php')

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

    package { 'php5-fpm':
        ensure => present,
        require => Exec['apt-get update'],
    }

    package { 'php5-redis':
        ensure => present,
        notify => Service['php5-fpm'],
        require => Exec['apt-get update'],
    }

    service { 'php5-fpm':
        ensure => running,
        require => Package['php5-fpm'],
    }
    
    service { 'nginx':
        ensure => running,
        require => Package['nginx'],
    }

    file { 'vagrant-nginx':
        path => '/etc/nginx/sites-available/webserver',
        owner => 'root',
        group => 'root',
        mode => '0644',
        ensure => file,
        notify => Service['nginx'],
        require => Package['nginx'],
        content => template('php/webserver.erb'),
    }

    file { 'default-nginx-disable':
        path => '/etc/nginx/sites-enabled/default',
        ensure => absent,
        require => Package['nginx'],
    }

    file { 'vagrant-nginx-enable':
        path => '/etc/nginx/sites-enabled/webserver',
        target => '/etc/nginx/sites-available/webserver',
        ensure => link,
        notify => Service['nginx'],
        require => [
            File['vagrant-nginx'],
            File['default-nginx-disable'],
        ],
    }

    file { 'index-php':
        path => "/var/www/index.php",
        group => 'www-data',
        mode => '0644',
        ensure => file,
        require => Package['nginx'],
        source => 'puppet:///modules/php/index.php',
    }

    file { 'settings-php':
        path => "/var/www/settings.php",
        group => 'www-data',
        mode => '0644',
        ensure => file,
        require => Package['nginx'],
        source => 'puppet:///modules/php/settings.php',
    }
    
    
}
