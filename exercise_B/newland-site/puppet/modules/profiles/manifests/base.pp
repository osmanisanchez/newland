class profiles::base {
	stage { 'prerequisite': before => Stage['main'] }
	
	class { '::hosts':
		stage => 'prerequisite',
		
	}
}