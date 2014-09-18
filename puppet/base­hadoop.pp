
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
	# replace => true,
	# recurse => true,
	# source  => '/usr/local/hadoop-2.5.0/etc/hadoop',
	require => [ Exec['unpack_hadoop'], User['hadoop'] ],
}
# create the data directory
file { '/home/hadoop/data':
	ensure => 'directory',
  	group  => 'hadoop',
	owner  => 'hadoop',
	mode   => '777',
	require => [ File['/etc/hadoop'] ],
 }

file { '/etc/hadoop/core-site.xml':
  ensure   => 'file',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  content  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
	<configuration>
	    <property>
	        <name>fs.defaultFS</name>
	        <value>hdfs://namenode:9000</value>
	    </property>
	</configuration>",
	require => [ FILE['/etc/hadoop'] ],
}

file { '/etc/hadoop/hdfs-site.xml':
  ensure   => 'file',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  content  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
	<configuration>

		<!-- Path on the local filesystem where
			 the NameNode stores the namespace
			 and transactions logs persistently. -->
		<property>
			<name>dfs.namenode.name.dir</name>
			<value>/home/hadoop/data</value>
		</property>

		<!-- List of permitted DataNodes. -->
		<property>
			<name>dfs.namenode.hosts</name>
			<value>datanode1,datanode2,datanode3,datanode4</value>
		</property

		<!-- List of excluded DataNodes. -->
		<property>
			<name>dfs.namenode.hosts.exclude</name>
			<value></value>
		</property>

		<!-- HDFS blocksize of 256MB for large file-systems. -->
		<property>
			<name>dfs.blocksize</name>
			<value>268435456</value>
		</property>

		<!-- More NameNode server threads to handle RPCs from large number of DataNodes. -->
	    <property>
	        <name>dfs.namenode.handler.count</name>
	        <value>100</value>
	    </property>

	</configuration>",
	require => [ FILE['/etc/hadoop'] ],
}
file { '/etc/hadoop/mapred-site.xml':
  ensure   => 'file',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  content  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<configuration>

		<!-- Configurations for MapReduce Applications -->
    <!-- Configurations for MapReduce Applications: -->

    <!-- Execution framework set to Hadoop YARN.  -->
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>


    <!-- Larger resource limit for maps. -->
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>1536</value>
    </property>


    <!-- Larger heap-size for child jvms of maps. -->
    <property>
        <name>mapreduce.map.java.opts</name>
        <value>-Xmx1024M</value>
    </property>


    <!-- Larger resource limit for reduces. -->
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>3072</value>
    </property>


    <!-- Larger heap-size for child jvms of reduces. -->
    <property>
        <name>mapreduce.reduce.java.opts</name>
        <value>-Xmx2560M</value>
    </property>


    <!-- Higher memory-limit while sorting data for efficiency. -->
    <property>
        <name>mapreduce.task.io.sort.mb</name>
        <value>512</value>
    </property>

    <!-- More streams merged at once while sorting files. -->
    <property>
        <name>mapreduce.task.io.sort.factor</name>
        <value>100</value>
    </property>


    <!-- Higher number of parallel copies run by reduces to fetch outputs from very large number of maps. -->
    <property>
        <name>mapreduce.reduce.shuffle.parallelcopies</name>
        <value>50</value>
    </property>


    <!-- Configurations for MapReduce JobHistory Server: -->

    <!--
    MapReduce JobHistory Server host:port
    Default port is 10020.
    -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value></value>
    </property>


    <!--
    MapReduce JobHistory Server Web UI host:port
    Default port is 19888.
    -->
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value></value>
    </property>

    <!--
    /mr-history/tmp
    Directory where history files are written by MapReduce jobs.
    -->
    <property>
        <name>mapreduce.jobhistory.intermediate-done-dir</name>
        <value></value>
    </property>


    <!--
    /mr-history/done
    Directory where history files are managed by the MR JobHistory Server.
    -->
    <property>
        <name>mapreduce.jobhistory.done-dir</name>
        <value></value>
    </property>


	</configuration>"
}
file { '/etc/hadoop/yarn-site.xml':
  ensure   => 'file',
  group    => 'hadoop',
  owner    => 'hadoop',
  mode     => '755',
  content  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<configuration>
		<!-- ###################################################
		     Configurations for ResourceManager and NodeManager:
			 ################################################### -->

		<!-- Enable ACLs? Defaults to false. -->
		<property>
			<name>yarn.acl.enable</name>
			<value>false</value>
		</property>

		<!-- ACL to set admins on the cluster. ACLs are of for comma-separated-usersspacecomma-separated-groups. Defaults to special value of * which means anyone. Special value of just space means no one has access. -->
		<property>
			<name>yarn.admin.acl</name>
			<value>*</value>
		</property>

		<!-- Configuration to enable or disable log aggregation -->
		<property>
			<name>yarn.log-aggregation-enable</name>
			<value>false</value>
		</property>

		<!-- ###################################################
		     Configurations for ResourceManager:
			 ################################################### -->

	   	<!-- ResourceManager host:port for clients to submit jobs.
		 	 host:port If set, overrides the hostname set in yarn.resourcemanager.hostname. -->
	    <property>
	        <name>yarn.resourcemanager.address</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager host:port for ApplicationMasters to talk to Scheduler to obtain resources.
	         host:port If set, overrides the hostname set in yarn.resourcemanager.hostname. -->
	    <property>
	        <name>yarn.resourcemanager.scheduler.address</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager host:port for NodeManagers.
	         host:port If set, overrides the hostname set in yarn.resourcemanager.hostname. -->
	    <property>
	        <name>yarn.resourcemanager.resource-tracker.address</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager host:port for administrative commands.
	         host:port If set, overrides the hostname set in yarn.resourcemanager.hostname. -->
	    <property>
	        <name>yarn.resourcemanager.admin.address</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager web-ui host:port.
	         host:port If set, overrides the hostname set in yarn.resourcemanager.hostname. -->
	    <property>
	        <name>yarn.resourcemanager.webapp.address</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager host.
	         host Single hostname that can be set in place of setting all yarn.resourcemanager*address resources. Results
	         in default ports for ResourceManager components. -->
	    <property>
	        <name>yarn.resourcemanager.hostname</name>
	        <value></value>
	    </property>

	    <!-- ResourceManager Scheduler class.
	         CapacityScheduler (recommended), FairScheduler (also recommended), or FifoScheduler -->
	    <property>
	        <name>yarn.resourcemanager.scheduler.class</name>
	        <value></value>
	    </property>

	    <!-- Minimum limit of memory to allocate to each container request at the Resource Manager. In MBs -->
	    <property>
	        <name>yarn.scheduler.minimum-allocation-mb</name>
	        <value></value>
	    </property>

	    <!-- Maximum limit of memory to allocate to each container request at the Resource Manager. In MBs -->
	    <property>
	        <name>yarn.scheduler.maximum-allocation-mb</name>
	        <value></value>
	    </property>

	    <!-- List of permitted/excluded NodeManagers. -->
	    <property>
	        <name>yarn.resourcemanager.nodes.include-path</name>
	        <value></value>
	    </property>

	    <!-- List of permitted/excluded NodeManagers. -->
	    <property>
	        <name>yarn.resourcemanager.nodes.exclude-path</name>
	        <value></value>
	    </property>

		<!-- ###################################################
		     Configurations for NodeManager:
			 ################################################### -->
	   <!--
	    Resource i.e. available physical memory, in MB, for given NodeManager
	    Defines total available resources on the NodeManager to be made available to running containers
	    -->
	    <property>
	        <name>yarn.nodemanager.resource.memory-mb</name>
	        <value></value>
	    </property>

	    <!--
	    Maximum ratio by which virtual memory usage of tasks may exceed physical memory
	    The virtual memory usage of each task may exceed its physical memory limit by this ratio. The total amount of virtual memory used by tasks on the NodeManager may exceed its physical memory usage by this ratio.
	    -->
	    <property>
	        <name>yarn.nodemanager.vmem-pmem-ratio</name>
	        <value></value>
	    </property>

	    <!--
	    Comma-separated list of paths on the local filesystem where intermediate data is written.
	    Multiple paths help spread disk i/o.
	    -->
	    <property>
	        <name>yarn.nodemanager.local-dirs</name>
	        <value></value>
	    </property>

	    <!--
	    Comma-separated list of paths on the local filesystem where logs are written.
	    Multiple paths help spread disk i/o.
	    -->
	    <property>
	        <name>yarn.nodemanager.log-dirs</name>
	        <value></value>
	    </property>

	    <!--
	    10800
	    Default time (in seconds) to retain log files on the NodeManager Only applicable if log-aggregation is disabled.
	    -->
	    <property>
	        <name>yarn.nodemanager.log.retain-seconds</name>
	        <value></value>
	    </property>

	    <!--
	    /logs
	    HDFS directory where the application logs are moved on application completion. Need to set appropriate permissions. Only applicable if log-aggregation is enabled.
	    -->
	    <property>
	        <name>yarn.nodemanager.remote-app-log-dir</name>
	        <value></value>
	    </property>

	    <!--
	    logs
	    Suffix appended to the remote log dir. Logs will be aggregated to yarn.nodemanager.remote-app-log-dir/user/thisParam Only applicable if log-aggregation is enabled.
	    -->
	    <property>
	        <name>yarn.nodemanager.remote-app-log-dir-suffix</name>
	        <value></value>
	    </property>

	    <!--
	    mapreduce_shuffle
	    Shuffle service that needs to be set for Map Reduce applications.
	    -->
	    <property>
	        <name>yarn.nodemanager.aux-services</name>
	        <value></value>
	    </property>

		<!-- ###################################################
		     Configurations for History Server:
			 ################################################### -->

		<!-- -1	How long to keep aggregation logs before deleting them. -1 disables. Be careful, set this too small and you will spam the name node. -->
		<property>
			<name>yarn.log-aggregation.retain-seconds</name>
			<value></value>
		</property>

		<!-- -1	Time between checks for aggregated log retention. If set to 0 or a negative value then the value is computed as one-tenth of the aggregated log retention time. Be careful, set this too small and you will spam the name node. -->
		<property>
			<name>yarn.log-aggregation.retain-check-interval-seconds</name>
			<value></value>
		</property>

	</configuration>",
	require => [ FILE['/etc/hadoop'] ],
}

file { '/etc/profile.d/hadoop-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/hadoop-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/httpfs-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/httpfs-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/mapred-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/mapred-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
}

file { '/etc/profile.d/yarn-2.5.0-env.sh':
	source  => '/usr/local/hadoop-2.5.0/etc/hadoop/yarn-env.sh',
	mode    => 755,
	owner   => root,
	group   => root,
	require => [ File['/etc/hadoop'] ],
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
host { 'jobtracker':
  ensure  => 'present',
  ip      => '192.168.33.12',
  target  => '/etc/hosts',
}
host { 'namenode':
  ensure  => 'present',
  ip      => '192.168.33.11',
  target  => '/etc/hosts',
}

