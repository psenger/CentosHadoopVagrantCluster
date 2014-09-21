#/bin/bash
if [ ! -f /vagrant/sync/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64.rpm ];
then
	echo "pulling java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64.rpm"
	wget http://www.cngrgroup.com/VirtualBoxImage/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64.rpm -O /vagrant/sync/java-1.7.0-openjdk-1.7.0.51-2.4.5.5.el7.x86_64.rpm 
fi

if [ ! -f /vagrant/sync/java-1.7.0-openjdk-devel-1.7.0.51-2.4.5.5.el7.x86_64.rpm ];
then
	echo "pulling java-1.7.0-openjdk-devel-1.7.0.51-2.4.5.5.el7.x86_64.rpm"
	wget http://www.cngrgroup.com/VirtualBoxImage/java-1.7.0-openjdk-devel-1.7.0.51-2.4.5.5.el7.x86_64.rpm -O /vagrant/sync/java-1.7.0-openjdk-devel-1.7.0.51-2.4.5.5.el7.x86_64.rpm
fi

if [ ! -f /vagrant/sync/hadoop-2.5.0.tar.gz ];
then
	echo "pulling hadoop-2.5.0.tar.gz"
	wget http://www.cngrgroup.com/VirtualBoxImage/hadoop-2.5.0.tar.gz -O /vagrant/sync/hadoop-2.5.0.tar.gz
fi

