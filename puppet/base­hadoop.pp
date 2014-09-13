
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

package { ['java-1.7.0-openjdk','java-1.7.0-openjdk-devel']:
	ensure => present,
}
file { '/etc/profile.d/java-1.7.sh':
	content => 'export JAVA_HOME=/usr/lib/jvm/java\nexport JRE_HOME=/usr/lib/jvm/jre\nexport PATH=$PATH:$JAVA_HOME/bin\n',
}
# exec { 'install_java_8' :
# 	command => 'rpm --install /vagrant/sync/jdk-8u20-linux-x64.rpm',
# 	creates => '/usr/java/jdk1.8.0_20',
# }  
# file { '/etc/profile.d/java-1.8.0_20.sh':
# 	content => "export JAVA_HOME=/usr/java/latest
# export JRE_HOME=/usr/java/latest
# export PATH=$JAVA_HOME/bin:$PATH
# ",
# }

exec { 'unpack_hadoop' :
 	command => 'tar -xf /vagrant/sync/hadoop-2.5.0.tar.gz',
	cwd     => '/usr/local/',
	creates => '/usr/local/hadoop-2.5.0',
	user    => root, 
}

file { '/usr/local/hadoop':
	ensure  => link,
	replace => true,
	target  => '/usr/local/hadoop-2.5.0',
}

group { 'hadoop':
  ensure => 'present',
  gid    => '1001',
}

user { 'hadoop':
  ensure           => 'present',
  managehome 	   => true,
  gid              => '1001',
  home             => '/home/hadoop',
  password         => '$6$nD4vMHXv$xlQYJuXUwZ.U0mD/6XmcuC6JmfQAj7hN759SuSMue2I6fePPXbzQChJDhRA3XAyO3YNS9SL50ul0ru/G.PWGE.',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '1001',
  require 		   => [ Group['hadoop'] ],
}

file {'/home/hadoop':
	ensure  => 'directory',
	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '755',
	require => [ Group['hadoop'], User['hadoop'] ],
}

file { '/etc/hadoop': 
	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '755',
	replace => true,
	recurse => true,
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop',
	require => [ Exec['unpack_hadoop'], User['hadoop'] ],
}

file { '/etc/profile.d/hadoop-env.sh': 
	source  => '/etc/hadoop/hadoop-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/httpfs-env.sh': 
	source  => '/etc/hadoop/httpfs-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/mapred-env.sh': 
	source  => '/etc/hadoop/mapred-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/yarn-env.sh': 
	source  => '/etc/hadoop/yarn-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}


host { 'localhost':
  ensure       => 'present',
  host_aliases => ['localhost.localdomain', 'localhost' ],
  ip           => '127.0.0.1',
  target       => '/etc/hosts',
}
host { 'datanode1':
  ensure => 'present',
  ip     => '192.168.33.13',
  target => '/etc/hosts',
}
host { 'datanode2':
  ensure => 'present',
  ip     => '192.168.33.14',
  target => '/etc/hosts',
}
host { 'datanode3':
  ensure => 'present',
  ip     => '192.168.33.15',
  target => '/etc/hosts',
}
host { 'jobtracker':
  ensure => 'present',
  ip     => '192.168.33.12',
  target => '/etc/hosts',
}
host { 'namenode':
  ensure => 'present',
  ip     => '192.168.33.11',
  target => '/etc/hosts',
}

