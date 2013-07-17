Updated this trac module to work with RHEL and Debian.

Requires the following modules to work;

https://github.com/example42/puppet-apache.git

https://github.com/duritong/puppet-subversion

Example usage;

	class {'apache':  }
	class {'apache::mod::ssl':  }
	class {'apache::mod::python':  }
	class {'subversion::apache': }

	include subversion

	# Set the global config.
    	Trac {
        	alt => "alt text",
        	cc => "user@domain.com",
        	url => "https://domain.com",
        	repobase => "/srv/svn",
        	basedir => "/srv/trac",
        	templates => "",
        	owner => "www-data",
        	group => "www-data",
    	}


    	file { "/etc/apache2/trac":
    		ensure => "directory",
    	}

    	file { "/srv/www":
    		ensure => "directory",
    	}

	    package { "trac": 
    		ensure => "installed",
    	}

	  	trac {
    		sitename:
    		description => "site description",
    		adminuser => "admin user";
    	}

	    subversion::svnrepo{'sitename': 
		    owner => 'www-data',
		    group => 'www-data',
		}

