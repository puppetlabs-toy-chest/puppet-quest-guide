---
title: Setup
layout: default
---

# Learning VM Setup

## About the Learning Virtual Machine

The Learning Virtual Machine (VM) is a sandbox environment equipped with everything you'll ned to get started learning Puppet and Puppet Enterprise (PE). Because we believe exploration and playfulness are key to successful learning, we've done our best to make getting started with Puppet a fun and frictionless process. The VM is powered by CentOS Linux and for your convenience, we've pre-installed Puppet Enterprise (PE) along with everything you'll need to put it into action. Before you get started, however, we'll walk you through a few steps to get the VM configured and running.

The Learning VM comes in two flavors. You downloaded this guide with either a VMware version that is suitable for VMware Player or VMware Workstation on Linux and Windows based machines, and VMware Fusion for Mac, or an Open Virtualization Format (OVF) file that is suitable for Oracle's Virtualbox as well as several other virtualization players that support this format. The steps below assume that you are using either VMware Fusion or Virtualbox, but the outlines of the setup process should be easily applicable to other virtualization software. If you run into issues getting the Learning VM set up, feel free to contact us at learningvm@puppetlabs.com, and we'll do our best to help out.

## Getting started with the Learning VM

If you haven't already downloaded VMware Player, VMware Workstation, or Oracle Virtualbox, please see the linked below:

* [VMWare Player](http://www.vmware.com/go/downloadplayer)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

We also suggest using a Secure Shell (SSH) to interact with the Learning VM. This will let you use a command-line interface that will let you copy and paste, avoid mouse-capture, and generally be a little more comfortable than interacting with the virtualization software directly. If you're using Mac OS, you can run SSH by way of the default Terminal application or a third party application like [iTerm](http://iterm2.com/). If you are on a Windows OS, we suggest downloading and using [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html), a free SSH client for Windows.

Once you have an up-to-date virtualization application and the means to SSH to the Learning VM (don't worry about the details of SSH just yet, we'll go over the specifics below) you're ready to configure the Learning VM itself.

If you're using VMware software, follow the instructions in the VMware Setup section below.

If you're using Virtualbox, skip ahead to the Virtualbox section and follow the instructions there.

### VMware Setup

If you're reading this guide, you've already extracted the .zip file that contains the Learning VM. It's a good idea to keep the archived file on hand in case you want to create a new instance of the Learning VM from scratch.

Launch VMware fusion. If it opens with a setup dialogue, close out of this. This dialogue is for creating a new virtual machine, and will mislead you if you're trying to open the Learning VM file.

From the VMWare __File__ menu, select __Open__ and navigate to the .vmx file included in your Learning VM download. You may also drag and drop the .vmx file into the VMWare virtual machine library.

Don't launch the VM just yet. There are a few configuration steps that you should complete before launching the Learning VM for the first time. If you skipped ahead and already launched the learning VM, shut it down by logging in with the credentials `root` and `puppet` and entering the command `shutdown -P now`. If you run into errors, remember that you can simply delete the VM and create another by unpacking the .zip archive and following the instructions above.

With the Learning VM selected in the VMWare library, open the __Settings__ panel and click the __Network Adapter__ icon.

Select __Autodetect__ under the __Bridged Networking__ heading as shown in the example.

{% figure '../assets/vmware_network_bridged.png' %}

Next, you'll need to increase the memory allocation to the VM to ensure that it has the resources neccessary to run smoothly. Go back to the __Settings__ panel and click the __Processors & Memory__ icon. We suggest allocating four gigabytes of memory, as shown in Figure 2. Use the slider to set your memory allocation. Note that the Learning VM will likely still function with less memory allocated, but you may encounter performance issues.

{% figure '../assets/vmware_memory.png' %}

Now that your settings are configured, click the __Power On__ button to boot up the VM.

	NOTE: Virtualization software uses mouse and keyboard capture to 'own' these devices and communicate input to the guest operating system. The keystroke to release the mouse and keyboard will be displayed at the top right of the VM window.

Once the VM is powered up, skip ahead to the Next Steps section below.

### VirtualBox Setup

Be sure you have an up-to-date installation of VirtualBox. The Learning VM works best with VirtualBox 4.x. If you don't have VirtualBox 4.x, please get you [free download](https://www.virtualbox.org/wiki/Downloads) of the latest version.

Choose “Import Appliance” from the File menu and select the .ovf file included with your download.
	
__Do not__ use the “New Virtual Machine Wizard” and select the included .vmdk file as the disk; machines created this way will kernel panic during boot. 

Don't launch the VM just yet. There are a few configuration steps that you should complete before launching the Learning VM for the first time. If you skipped ahead and already launched the learning VM, shut it down by logging in with the credentials `root` and `puppet` and entering the command `shutdown -P now`. If you run into errors, remember that you can simply delete the VM and create another by unpacking the .zip archive and following the instructions above. 

In the VirtualBox Manager panel, select __Network__ to access networking options. Choose __Bridged Adapter__ from the drop-down menu.

{% figure './assets/vbox_network_bridged.png' %}

For everything to work smoothly, we suggest allocating four gigabytes of memory to the VM, as shown in Figure 4 below. In the VirtualBox Manager panel, click __System__ to access the system options and use the slider to set your memory allocation. Note that the Learning VM will likely still function with less memory allocated, but you may encounter performance issues.

{% figure './assets/vbox_memory.png' %}

Now that everything is configured, click the __Start__ button in the upper left to boot up the VM.

Note: Refer to [VirtualBox documentation](http://www.virtualbox.org/manual) for additional information as required.

Once the VM is powered up, continue to the Next Steps section below.

## Next Steps

Once the VM is booted, hit enter to get to the login prompt, and log in using the following credentials:  

* username: **root**
* password: **puppet**

Once you're logged in, you'll need to find the Learning VM's IP address. Puppet Enterprise is already installed, so we can use the included Facter tool to find it.
		
		facter ipaddress

Make a note of the IP address displayed. You'll need it to start an SSH session on Learning VM and in order to connect to the PE Console.

One more thing before we are done. To ensure you have the best experience, and the quest progress tracking works as expected, log out from the VM.

Enter the command:

    exit

NWe will now connect to the VM over SSH.

To SSH to the VM, on a Linux system or a Mac, you can open a Terminal application and run the following command:

    ssh root@<ip-address>

where `<ip-address>` will be replaced by the IP address for your Learning VM that you noted down when setting up your VM.

If you are using a Windows computer, please use an SSH client. We recommend [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).

Here are the credentials to log in to the Learning VM via SSH:

 * username: **root**  
 * password: **puppet**

Now that the Learning VM is set up, please continue following the rest of the Quest Guide. 

In addition to the VM, the following resources may be handy in your journey to learn Puppet:

* [Puppet users group](http://groups.google.com/group/puppet-users)
* [Puppet Ask - Q&A site](http://ask.puppetlabs.com)
* #puppet IRC channel on irc.freenode.net
* You can also email us at <learningvm@puppetlabs.com>

We hope you have fun learning Puppet!
