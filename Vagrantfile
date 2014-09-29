# -*- mode: ruby -*-
# vi: set ft=ruby :
boxes = [
  { :name => :jobtracker,        :ip => '192.168.33.10', :ssh_port => 2202, :cpus => 1, :mem => 1024, :mac => "720002691321" },
  { :name => :namenode,          :ip => '192.168.33.11', :ssh_port => 2203, :cpus => 1, :mem => 1024, :mac => "720002691332" },
  { :name => :secondarynamenode, :ip => '192.168.33.12', :ssh_port => 2204, :cpus => 1, :mem => 1024, :mac => "720002691343" },
  { :name => :datanode1,         :ip => '192.168.33.13', :ssh_port => 2205, :cpus => 1, :mem => 1024, :mac => "720002691354" },
  { :name => :datanode2,         :ip => '192.168.33.14', :ssh_port => 2206, :cpus => 1, :mem => 1024, :mac => "720002691365" },
  { :name => :datanode3,         :ip => '192.168.33.15', :ssh_port => 2207, :cpus => 1, :mem => 1024, :mac => "720002691376" },
  { :name => :datanode4,         :ip => '192.168.33.16', :ssh_port => 2208, :cpus => 1, :mem => 1024, :mac => "720002691386" },
]
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provision "shell", inline: "/vagrant/sync/pull.sh"
    boxes.each do |opts|
        config.vm.define opts[:name] do |config|
          config.vm.box = "CentOS-7.0-1406-x86_64"
          # config.vm.box_url = "http://www.cngrgroup.com/VirtualBoxImage/CentOS-7.0-1406-x86_64.box"
          config.vm.box_url = "/Users/psenger/VirtualMachineImages/CentOS-7.0-1406-x86_64.box"
          config.vm.network "private_network", ip: opts[:ip], guest: 22, host: opts[:ssh_port], netmask: "255.255.255.0" #, auto_config: false
          config.vm.hostname = "%s" % opts[:name].to_s
          config.vm.provision "puppet" do |puppet|
                # puppet.options = "--verbose --debug"
                puppet.manifests_path = "puppet"
                puppet.manifest_file = "base­hadoop.pp"
          end
          config.vm.provider "virtualbox" do |vb|
                # Use VBoxManage to customize the VM
                vb.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
                vb.customize ["modifyvm", :id, "--memory", opts[:mem] ] if opts[:mem]
          end
       end
    end
end