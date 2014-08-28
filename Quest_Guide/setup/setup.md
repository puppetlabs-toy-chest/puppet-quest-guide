---
title: Setup
layout: default
---

# Learning VM Setup

## About the Learning Virtual Machine

The Learning Virtual Machine (VM) is a sandbox environment equipped with everything you'll need to get started learning Puppet and Puppet Enterprise (PE). Because we believe exploration and playfulness are key to successful learning, we've done our best to make getting started with Puppet a fun and frictionless process. The VM is powered by CentOS Linux and for your convenience, we've pre-installed Puppet Enterprise (PE) along with everything you'll need to put it into action. Before you get started, however, we'll walk you through a few steps to get the VM configured and running.

The Learning VM comes in two flavors. You downloaded this guide with either a VMware (.vmx) file or an Open Virtualization Format (.ovf) file. The .vmx version works with VMware Player or VMware Workstation on Linux and Windows based machines, and VMware Fusion for Mac. The .ovf file is suitable for Oracle's Virtualbox as well as several other virtualization players that support this format.

We've included instructions below for VMware Fusion, VMware Player, and Virtualbox. If you run into issues getting the Learning VM set up, feel free to contact us at learningvm@puppetlabs.com, and we'll do our best to help out.

## Getting started with the Learning VM

If you haven't already downloaded VMware Player, VMware Fusion, or Oracle Virtualbox, please see the links below:

* [VMWare Player](http://www.vmware.com/go/downloadplayer)
* [VMWare Fusion](http://www.vmware.com/go/downloadfusion)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

You'll also need an SSH client to interact with the Learning VM over a Secure Shell (SSH) connection. This will be more comfortable than interacting with the virtualization software directly. If you're using Mac OS, you will be able to run SSH by way of the default Terminal application or a third party application like [iTerm](http://iterm2.com/). If you are on a Windows OS, we recommend [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html), a free SSH client for Windows.

Once you have an up-to-date virtualization application and the means to SSH to the Learning VM you're ready to configure the Learning VM itself.

If you're reading this guide, you've already extracted the .zip file that contains the Learning VM. Keep that .zip file around in case you want to create a fresh instance of the Learning VM without having the re-do the download.

## VM Setup

Start by launching your virtualization software. (Don't be tempted by any dialogues or wizards that pop up the first time you open the software. These will walk you through creating a *new* virtual machine, and will mislead you if you're trying to open the *existing* Learning VM file.) 

Depending on what virtualization software you're using, there are some slight variations in how you'll open Learning VM file.

 * In __VMware Player__ there will be an _Open a Virtual Machine_ option on the Welcome screen.  You can also select *File > Open...* from the *Player* menu in the top left.
 
 * For __VMWare Fusion__,  select _File > Open..._ from the menu bar.
 
 * For __VirtualBox__, select _File > Import Appliance..._ from the menu bar.
 
 * If you're using different virtualization software, just be sure to *open* or *import*, rather than *create new*.

Don't launch the VM just yet. There are a few configuration steps that you should complete before launching the Learning VM for the first time. (If you skipped ahead and already launched the VM, shut it down by logging in with the credentials `root` and `puppet` and entering the command `shutdown -P now`. And if you run into errors, remember that you can simply delete the VM and create another by unpacking the .zip archive and following the instructions above.)

With the Learning VM selected in the library or manager window, open the __Settings__ panel. There are a few things to adjust here.

First, in under **Network** or **Network Adapter**, confirm that the **Network Adapter** is enabled, and configure it to use **Bridged** networking.

Next, you'll need to increase the memory allocation and processors to the VM to ensure that it has the resources neccessary to run smoothly. These options are under **System** in VirtualBox and **Processors & Memory** in VMware Fusion. Allocate 4 GB of memory (4096 MB) and two processor cores. You can run the Learning VM with less memory and fewer processor cores, but you may encounter performance issues.

Now that your settings are configured, select __Start__ or __Power On__ to boot up the VM.

{% aside Input Capture %}
Virtualization software uses mouse and keyboard capture to 'own' these devices and communicate input to the guest operating system. The keystroke to release the mouse and keyboard will be displayed at the top right of the VM window.
{% endaside %}

## Next Steps

Once the VM is booted, you may have to hit `enter` to see to the login prompt. Log in using the following credentials:  

* username: **root**
* password: **puppet**

All you'll want to do for now is get the Learning VM's IP address. Use the Facter tool bundled with Puppet Enterprise tool to find it.
		
	facter ipaddress

Make a note of the IP address displayed. You'll need it to open an SSH connection to the Learning VM and in order to access to the PE Console later.

For the Learning VM's quest tool to work smoothly, you'll need to log out before starting your SSH session. (The file that tracks your command line history will only be created after you log out for the first time.) Enter the command:

    exit

Now that you have the IP address, open an SSH connection to the Learning VM. 

On a Linux system or a Mac, you can open a Terminal application and run the following command, replacing `<ip-address>` with the IP address of your Learning VM:

    ssh root@<ip-address>

If you are on a Windows system, use an SSH client. We recommend [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html). Enter the IP address into the *Hostname* textbox and click *Open* to start your session.

Use the same credentials:

 * username: **root**  
 * password: **puppet**

Now that the Learning VM is configured and you're connected, you're all set to take on your first quest! We hope you have fun learning Puppet!

In addition to the VM, the following resources may be handy in your journey to learn Puppet:

* [Puppet users group](http://groups.google.com/group/puppet-users)
* [Puppet Ask - Q&A site](http://ask.puppetlabs.com)
* \#puppet IRC channel on irc.freenode.net
* You can also email us at <learningvm@puppetlabs.com>