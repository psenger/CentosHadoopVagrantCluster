CentosImage
===========

This project is my Centos 7 Vagrant configuration for Hadoop.

## Urls

https://github.com/mitchellh/vagrant/tree/master/keys

http://download.virtualbox.org/virtualbox/4.3.14/VirtualBox-4.3.14-95030-Win.exe

## How I built this image

Building an image and preparing an image can be done with these steps


1. Using [Virtual Box Version 4.3.14 ](http://download.virtualbox.org/virtualbox/4.3.14/VirtualBox-4.3.14-95030-Win.exe) and Vagrant 1.6.5 I created a Centos 7 vm. The name that you use to identify the Virtual Box image will be used by Vagrant to identify which image to package up, so take note of the name. I will refer to the name as *NAME*, for this image it is *CentOS-7.0-1406-x86_64*.
2. Before you boot up, in the Virtual Box Settings, go to the network setting and change the First Network Adapter to NAT. This will allow you to download stuff off the internet. Dont worry about the other adapters, our vagrant file will control all of them anyway.
3. Boot the machine and install the OS. 
  - Set the password of root to root
  - create a user called vagrant with a password vagrant, we will add it to sudo later.
  - make sure the vm uses NTP
  - select a base image that is suitable for vm ( there was an option )
  - finish the install as a VM box, very basic.
8. Then log in as root, the following commands are while in the OS.
  - do a yum update.
  - make sure SCP, and SSH are installed.
10. in vagrant's home directory create a .ssh directory
  - chmod 0700 ~/.ssh
  - wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O ~/.ssh/authorized_keys
  - chmod 0600  ~/.ssh/authorized_keys
11. As root, **visudo** and add the following to the end of the file
	
		vagrant ALL=(ALL) NOPASSWD: ALL 

12. As root, **visudo** and add a bang **!** to requiretty for the Defaults stanza, it should look like this when you are done.

		Defaults        !requiretty

13. As root, install the VirtualBox plug ins. I tried to install the pluggins that come with VB as a ISO mountable image but I had problems, so I downloaded it off the net. This will allow you to mount a shared drive, reboot, etc. You can find the version you need matching the version of the vbox to the version of the plug in at [http://download.virtualbox.org/virtualbox/](http://download.virtualbox.org/virtualbox/) In this example we are using 4.3.14 for linux.

  - wget http://download.virtualbox.org/virtualbox/4.3.14/VBoxGuestAdditions_4.3.14.iso
  - sudo mkdir /media/VBoxGuestAdditions
  - sudo mount -o loop,ro VBoxGuestAdditions_4.3.14.iso /media/VBoxGuestAdditions
  - sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
  - sudo umount /media/VBoxGuestAdditions	
  - sudo rmdir /media/VBoxGuestAdditions
  - rm VBoxGuestAdditions_4.3.14.iso

10. shutdown the os
11. in Virtual Box, go the image, and then Settings, Network, make sure that the 1st network adapter is set to **NAT**
11. Nowe we will package the os. Executing the following command will take some time and package it up

		vagrant package --base <NAME> 
	
12. This will create a file called **package.box** this is the file that you would drop on a server somewhere. 
13. Once you init a vagrant managed server for the first time, the package will be registered and can be used over and over again without downloading it.

## Puppet

I installed puppet, but I can't remember how 

## Testing the Image


1. Create a directory called Centos
2. Change into the directory that you just created.
3. Execute one of the following.
	a. If you are doing this the first time
	
		vagrant init "Path-To-Image/package.box"

	b. If you are doing this the the second time
	
		vagrant init "<Name>"

## Remove the image

If the image is bad or you need to rebuild it, you have to remove it from the Vagrant registry by doing this,

	vagrant box remove /Users/psenger/VirtualMachineImages/package.box
	
To list all the vagrant images 

	vagrant box list
