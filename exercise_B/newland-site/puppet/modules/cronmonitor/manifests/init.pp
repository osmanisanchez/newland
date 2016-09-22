class cronmonitor {
    $fromaddress = hiera('from_address', '80')
    $password = hiera('password', '8080')
    $toaddress = hiera('to_address', '80')
    $proxyport = hiera('port', '80')
    $phpport = hiera('upstream_port', '8080')
    $testregexp = hiera('test_page_regexp', '80')
    
    $script_path = '/usr/local/bin'

    cron { 'cron-monitor':
        command => "$script_path/monitor-site.py > /var/log/sitemonitor.log 2>&1",
        minute => '*/1',
        ensure => "present",
        require => [
            File['monitor-site.py'],
            File['monitor-settings.py'],
            File['monitor-defs.py'],
        ],
    } 

	file { 'monitor-site.py':
		path => "$script_path/monitor-site.py",
        mode => '0754',
		ensure => file,
		source => 'puppet:///modules/cronmonitor/monitor-site.py',
	}

	file { 'monitor-settings.py':
		path => "$script_path/settings.py",
        mode => '0644',
		ensure => file,
        content => template('cronmonitor/settings.py.erb'),
	}

	file { 'monitor-defs.py':
		path => "$script_path/defs.py",
        mode => '0644',
		ensure => file,
		source => 'puppet:///modules/cronmonitor/defs.py',
	}

}

