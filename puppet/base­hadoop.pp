
if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

Exec {
	path => ['/usr/local/bin','/usr/bin','/usr/local/sbin','/usr/sbin']
}
File {
	owner => root,
	group => root,
}

# package { [ 'git.x86_64' ]: ensure=>ensure, }

$hadoop_home = '/usr/local/hadoop'

exec { 'install_java_8' :
	command => 'rpm --install /vagrant/sync/jdk-8u20-linux-x64.rpm',
	creates => '/usr/java/jdk1.8.0_20',
}
  
file { '/etc/profile.d/java-1.8.0_20.sh':
	content => "export JAVA_HOME=/usr/java/latest
export JRE_HOME=/usr/java/latest
export PATH=$JAVA_HOME/bin:$PATH
",
}

exec { 'unpack_hadoop' :
 	command => 'tar -xf /vagrant/sync/hadoop-2.5.0.tar.gz',
	cwd     => '/usr/local/',
	creates => '/usr/local/hadoop-2.5.0',
	user    => root, 
	require => File['/usr/local/hadoop'],
}

file { '/usr/local/hadoop':
	ensure  => link,
	replace => true,
	target  => '/usr/local/hadoop-2.5.0',
}