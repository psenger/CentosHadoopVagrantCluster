
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

package { 'java-1.7.0-openjdk-devel':
 	ensure => present,
	source => '/vagrant/sync/java-1.7.0-openjdk-devel-1.7.0.51-2.4.5.5.el7.x86_64.rpm'
}

package { 'java-1.7.0-openjdk':
 	ensure => present,
	source => '/vagrant/sync/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64.rpm'
}

file { '/etc/profile.d/java-1.7.sh':
	content => "export JAVA_HOME=/usr/lib/jvm/java\nexport JRE_HOME=/usr/lib/jvm/jre\nexport PATH=\$PATH:\$JAVA_HOME/bin\n",
}

file { '/etc/profile.d/hadoop-2.5.0.sh':
	content => "export HADOOP_HOME=/usr/local/hadoop\nexport PATH=\$PATH:\$HADOOP_HOME/bin\n",
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

# unpack haoop
exec { 'unpack_hadoop' :
 	command => 'tar -xf /vagrant/sync/hadoop-2.5.0.tar.gz',
	cwd     => '/usr/local/',
	creates => '/usr/local/hadoop-2.5.0',
	user    => root,
}

# link the generic hadoop in /usr/local to the specific version
file { '/usr/local/hadoop':
	ensure  => link,
	replace => true,
	target  => '/usr/local/hadoop-2.5.0',
}

# crete the group hadoop
group { 'hadoop':
  ensure => 'present',
  gid    => '1001',
}

# crete the user hadoop
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

# create the home directory for hadoop
file {'/home/hadoop':
	ensure  => 'directory',
	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '755',
	require => [ Group['hadoop'], User['hadoop'] ],
}

# create the yarn group
group { 'yarn':
  ensure => 'present',
  gid    => '1002',
}

# create the yarn user
user { 'yarn':
  ensure           => 'present',
  gid              => '1002',
  home             => '/home/yarn',
  password         => '$6$72hqTKl1$/t91T11p414nYVIW4sKupBIVkCrUBnIVBJxOAZTjqPhexkj.GhzTNG68AuwOkFyWCIt3U6K65dDp8bIeIJWz8/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '1002',
  require 		   => [ Group['yarn'] ],
}

# create the home directory for yarn
file { '/home/yarn':
  ensure   => 'directory',
  group    => 'yarn',
  owner    => 'yarn',
  mode     => '700',
  require  => [ Group['yarn'], User['yarn'] ],
}

# Create the configuration directory and only if the hadoop user and hadoop program are installed.
file { '/etc/hadoop':
	ensure  => 'directory',
	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '755',
	require => [ Exec['unpack_hadoop'], User['hadoop'] ],
}
# create the data directory
file { '/home/hadoop/data':
	ensure  => 'directory',
  	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '777',
	require => [ File['/etc/hadoop'] ],
 }

file { '/etc/hadoop/configuration.xsl':
  ensure   => 'file',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  source   => '/usr/local/hadoop/etc/hadoop/configuration.xsl',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/core-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/core-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/hdfs-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/hdfs-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/mapred-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/mapred-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/yarn-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/yarn-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/var/log/hadoop':
  ensure   => 'directory',
  group    => 'hadoop',
  mode     => '755',
  owner    => 'hadoop',
  require => [  User['hadoop'] ],
}

file { '/usr/local/hadoop/logs':
  ensure   => 'link',
  group    => 'hadoop',
  mode     => '777',
  owner    => 'hadoop',
  target   => '/var/log/hadoop/log',
  require  => [ File['/var/log/hadoop'], Exec['unpack_hadoop'], User['hadoop'] ],
}

file { '/etc/profile.d/hadoop-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/hadoop-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ Exec['unpack_hadoop'] ],
}

file { '/etc/profile.d/httpfs-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/httpfs-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ Exec['unpack_hadoop'] ],
}

file { '/etc/profile.d/mapred-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/mapred-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ Exec['unpack_hadoop'] ],
}

file { '/etc/profile.d/yarn-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/yarn-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ Exec['unpack_hadoop'] ],
}

# add hosts to the /etc/host file
host { 'datanode1':
  ensure  => 'present',
  ip      => '192.168.33.13',
  target  => '/etc/hosts',
}
host { 'datanode2':
  ensure  => 'present',
  ip      => '192.168.33.14',
  target  => '/etc/hosts',
}
host { 'datanode3':
  ensure  => 'present',
  ip      => '192.168.33.15',
  target  => '/etc/hosts',
}
host { 'datanode4':
  ensure  => 'present',
  ip      => '192.168.33.16',
  target  => '/etc/hosts',
}
host { 'jobtrackernode':
  ensure  => 'present',
  ip      => '192.168.33.12',
  target  => '/etc/hosts',
}
host { 'namenode':
  ensure  => 'present',
  ip      => '192.168.33.11',
  target  => '/etc/hosts',
}


