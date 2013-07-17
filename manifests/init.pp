# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Create a new Trac instance.  Example usage:
#
#    Trac {
#        alt => "Reductive Labs",
#        cgidir => "/export/docroots/reductivelabs.com/cgi-bin",
#        cc => "luke@abuse.com",
#        url => "https://reductivelabs.com",
#        repobase => "/export/svn/repos"
#    }
#
#    trac {
#        enhost:
#            description => "Enhost - LDAP System Information Uploader";
#        puppet:
#            description => "Puppet - Portable System Automation",
#            cc => "puppet-dev@madstop.com";
#   }

define trac(
    $basedir = "/export/svn/trac",
    $repository = false,
    $templates = "/usr/share/trac/templates",
    $cgipath = false,
    $navadd = false,
    $cc,
    $description,
    $db = "sqlite:db/trac.db",
    $owner = "root",
    $group = "apache",
    $url,
    $repobase,
    $cgidir,
    $replyto = "trac@$domain",
    $from = "trac@$domain",
    $alt = $domain,
    $smtpserver = "mail.$domain",
    $repostype = "svn",
    $apache = false,
    $adminuser,
) {

        $repo = $repository ? {
        false => "$repobase/$name",
        default => $repository
    }
    $link = "$url/trac/$name"
    $tracdir = "$basedir/$name"
    $config = "$tracdir/conf/trac.ini"

    # Create the app
    
    exec { "tracinit-$name":
        command => "trac-admin $tracdir initenv $name $db $repostype $repo",
        path => "/usr/bin:/bin:/usr/sbin",
        logoutput => false,
        creates => $config
    }

    # Chown it to httpd user/group.
    
    file { $tracdir:
        owner => $owner,
        group => $group,
        recurse => true,
        mode => 755,
        require => Exec["tracinit-$name"]
    }

    file { "$tracdir/db":
        owner => $owner,
        group => $group,
        recurse => true,
    }

    # Create the config files.

    file { $config:
        owner => $owner,
        group => $group,
        mode => 755,
        content => template("trac/tracconfig.erb"),
        require => Exec["tracinit-$name"]
    }

    if $::osfamily == 'redhat' {
            file { "trac-$name":
            path => "/etc/httpd/trac/$name.conf",
            owner => $owner,
            group => $group,
            mode => 644,
            content => template("trac/tracsite.erb"),
            notify => Service[httpd] # notify apache that it should restart
            }
    } elsif $::osfamily == 'debian' {
            file { "trac-$name":
            path => "/etc/apache2/trac/$name.conf",
            owner => $owner,
            group => $group,
            mode => 644,
            content => template("trac/tracsite.erb"),
            notify => Service[httpd] # notify apache that it should restart
            }
    }

    # Add the admin user.

    exec { "tracinit-$name-$adminuser":
        command => "trac-admin /srv/trac/$name permission add $adminuser TRAC_ADMIN",
        path => "/usr/bin:/bin:/usr/sbin",
        unless => "trac-admin /srv/trac/$name permission list | grep TRAC_ADMIN | grep $adminuser",
    }

      
}
