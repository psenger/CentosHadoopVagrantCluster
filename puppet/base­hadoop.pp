
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
	content => "export HADOOP_HOME=/usr/local/hadoop\nexport PATH=\$PATH:\$HADOOP_HOME/bin\nexport HADOOP_PREFIX=\$HADOOP_HOME\nexport HADOOP_YARN_HOME=\$HADOOP_HOME\n",
}

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
  managehome 	     => true,
  gid              => '1001',
  home             => '/home/hadoop',
  password         => '$6$nD4vMHXv$xlQYJuXUwZ.U0mD/6XmcuC6JmfQAj7hN759SuSMue2I6fePPXbzQChJDhRA3XAyO3YNS9SL50ul0ru/G.PWGE.',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '1001',
  purge_ssh_keys   => true,
  require 		     => [ Group['hadoop'] ],
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

# Create the data directory
file { '/home/hadoop/data':
	ensure  => 'directory',
  	group   => 'hadoop',
	owner   => 'hadoop',
	mode    => '777',
	require => [ File['/etc/hadoop'] ],
 }

# Configuration Files
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
  target   => '/vagrant/sync/etc/hadoop/core-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/hdfs-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/etc/hadoop/hdfs-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/mapred-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/etc/hadoop/mapred-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/yarn-site.xml':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/etc/hadoop/yarn-site.xml',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/slaves':
  ensure   => 'link',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  target   => '/vagrant/sync/etc/hadoop/slaves',
  require  => [ FILE['/etc/hadoop'] ],
}

file { '/var/log/hadoop':
  ensure   => 'directory',
  group    => 'hadoop',
  mode     => '777',
  owner    => 'hadoop',
  require => [  User['hadoop'] ],
}

file { '/usr/local/hadoop/logs':
  ensure   => 'link',
  group    => 'hadoop',
  mode     => '777',
  owner    => 'hadoop',
  target   => '/var/log/hadoop/',
  require  => [ File['/var/log/hadoop'], Exec['unpack_hadoop'], User['hadoop'] ],
}

## Shell Scripts ##
file { '/etc/profile.d/hadoop-2.5.0-env.sh':
	source  => '/usr/local/hadoop/etc/hadoop/hadoop-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/usr/local/hadoop'] ],
}

file { '/etc/profile.d/httpfs-2.5.0-env.sh':
	source  => '/usr/local/hadoop/etc/hadoop/httpfs-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/usr/local/hadoop'] ],
}

file { '/etc/profile.d/mapred-2.5.0-env.sh':
	source  => '/usr/local/hadoop/etc/hadoop/mapred-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/usr/local/hadoop'] ],
}

file { '/etc/profile.d/yarn-2.5.0-env.sh':
	source  => '/usr/local/hadoop/etc/hadoop/yarn-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/usr/local/hadoop'] ],
}

## Add hosts to the /etc/host file ##
augeas { 'etc_hosts':
  context => '/etc/hosts',
  changes => [
    "set /files/etc/hosts/1/ipaddr 127.0.0.1",
    "set /files/etc/hosts/1/canonical localhost",
    "set /files/etc/hosts/1/alias localhost.localdomain",
    "set /files/etc/hosts/2/ipaddr ::1",
    "set /files/etc/hosts/2/canonical localhost",
    "set /files/etc/hosts/2/alias ipv6-loopback",
    "set /files/etc/hosts/3/ipaddr 192.168.33.10",
    "set /files/etc/hosts/3/canonical jobtracker",
    "set /files/etc/hosts/4/ipaddr 192.168.33.11",
    "set /files/etc/hosts/4/canonical namenode",
    "set /files/etc/hosts/5/ipaddr 192.168.33.12",
    "set /files/etc/hosts/5/canonical secondarynamenode",
    "set /files/etc/hosts/6/ipaddr 192.168.33.13",
    "set /files/etc/hosts/6/canonical datanode1",
    "set /files/etc/hosts/7/ipaddr 192.168.33.14",
    "set /files/etc/hosts/7/canonical datanode2",
    "set /files/etc/hosts/8/ipaddr 192.168.33.15",
    "set /files/etc/hosts/8/canonical datanode3",
    "set /files/etc/hosts/9/ipaddr 192.168.33.16",
    "set /files/etc/hosts/9/canonical datanode4",
  ],
}

## Add hosts to the /.ssh/knwown_hosts file ##
file{ '/home/hadoop/.ssh' :
 ensure  => directory,
 group   => 'hadoop',
 owner   => 'hadoop',
 mode    => 0600,
 require => [ User['hadoop'] ],
}
file{ '/home/hadoop/.ssh/id_rsa' :
 ensure  => file,
 group   => 'hadoop',
 owner   => 'hadoop',
 mode    => 0600,
 source  => '/vagrant/sync/home/hadoop/.ssh/id_rsa',
 require => [ File[ '/home/hadoop/.ssh' ], User['hadoop'] ],
}
file{ '/home/hadoop/.ssh/id_rsa.pub' :
 ensure  => file,
 group   => 'hadoop',
 owner   => 'hadoop',
 mode    => 0600,
 source  => '/vagrant/sync/home/hadoop/.ssh/id_rsa.pub',
 require => [ File[ '/home/hadoop/.ssh' ], User['hadoop'] ],
}
file{ '/home/hadoop/.ssh/known_hosts' :
 ensure  => file,
 group   => 'hadoop',
 owner   => 'hadoop',
 mode    => 0600,
 source  => '/vagrant/sync/home/hadoop/.ssh/known_hosts',
 require => [ File[ '/home/hadoop/.ssh' ], User['hadoop'] ],
}
ssh_authorized_key { 'hadoop@namenode':
  user    => 'hadoop',
  type    => 'ssh-rsa',
  key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCjGy09h7c+HZ1HF3x4w6UuWHDheoP16CVZ7wbHQit9rQ3yLI3IgnFi+qEPLZ+vKBfTC/EtQi/gHW//3HGwjzvCvgUGnXotYT6D+UTJsbQ7I1oRmuQOV6B/S1yyTA4OQgrvEWZDc8A36feSH+O+qVKA7ADRM6/XDPJypJnM9ICzVtzdN3vAQojG8VPg2/+Afp9WbOsuB4xOJxQ9kViEIPnsLn0hsGzCkBbVUC7LXZYVqtteVqUCL9XsLpe0q2jhyYQQQpRW0l4EDnwrQ+79VUnU/ANzNBpJBL5j+L2lVaXQYw82qpqSf4rEG4fyzxeiXfBYwocgHxcMHCwJHkVLqTWl',
  require => [ File[ '/home/hadoop/.ssh' ], User['hadoop'] ],
}