---
title: NTP
layout: default
---

# NTP

### Prerequisites

- 

## Quest Objectives

- 

## Getting Started

In this quest you will

    quest --start ntp

## What's NTP

> Time is the substance from which I am made. Time is a river which carries me along, but I am the river; it is a tiger that devours me, but I am the tiger; it is a fire that consumes me, but I am the fire.
-- Jorge Luis Borges

If you want the nodes in your infrastructure to play nicely together, you'll need a system in place to keep their clocks accurately synchronized. Security services, shared filesystems, certificate signing, logging systems, and many other fundamental services and applications need accurate and coordinated time to function reliably. Given variable network latency, it takes some clever algorithms and protocols to get this coordination right. 

The Network Time Protocol (NTP) provides a standard way to keep time millisecond-accurate within your network while staying synchronized to Coordinated Universal Time (UTC) by way of publicly accessible time servers. (The subtleties of NTP are outside the scope of this lesson. If you're interested, you can [read all about it](http://www.eecis.udel.edu/~ntp/ntpfaq/NTP-a-faq.htm))

NTP is one of the most fundamental services you will want to include in your infrastructure. Puppet Labs maintains a supported module that makes the configuration and management of NTP simple.

## Package/File/Service

So you've decided to use Puppet to manage NTP on your infrastructure. We'll show you how to install and deploy the NTP module in a moment, but first, take a look at the current state of your system. This way, you'll be able to keep track of what Puppet changes and understand why the NTP module does what it does.

To get the NTP service running, there are three key resources that Puppet will manage. The puppet resource resource tool can show you the current state of each of these resources.

First, check the state of the NTP *package*:

	puppet resource package ntp
	
check the NTP configuration *file*:
	
	puppet resource file /etc/ntp.conf

finally, see if the Network Time Protocol Daemon (NTPD) *service* is running:

	puppet resource service ntpd
	
You'll see that the NTP package is installed on the Learning VM, that the configuration file exists, and that the ntpd service is 'stopped'.

As you continue to work with Puppet, you'll find that this *package/file/service* pattern is very useful. These three resource types correspond to the common sequence of installing a package, customizing that package's functionality with configuration file, and starting the service provided by that package.

Also, note that the *package/file/service* pattern describes the typical relationships of dependency among these three resources: a well-written class will define these relationships, telling Puppet to restart the service if the configuration file has been modified, and re-create the configuration file when the package is installed or updated. We'll get into the specifics of how these dependencies are defined in a later quest. But now, on to the installation!

## Installation

Before you classify the Learning VM with the NTP class, you'll need to install the NTP module from the forge. While the module itself is called `ntp`, modules in the forge are prefixed by the name of their creator. So to get the Puppet Labs NTP module from the forge, you'll specify `puppetlabs-ntp`, but when you look at the module saved to the modulepath on your Puppet Master, it will be named `ntp`. Keep this in mind, as trying to install multiple modules of the same name can lead to conflicts!

{% task 1 %}

Use the puppet module tool to install the Puppet Labs `ntp` module. 

	puppet module install puppetlabs-ntp
	
This command tells the puppet module tool to fetch the module from the Puppet Forge and place it in Puppet's modulepath: `/etc/puppetlabs/puppet/modules`.

## Classification with the site.pp Manifest

Now that the NTP module is installed, all the included classes are available to use in node classification.

In the Power of Puppet quest, you learned how to classify a node with the PE Console. In this quest, we introduce another method of node classification: the `site.pp` manifest. 

`site.pp` is the first manifest the Puppet agent checks when it connects to the master. It defines global settings and resource defaults that will apply to all nodes in your infrastructure. It is also where you will put your *node definitions* (sometimes called `node statements`). A node definition is a block of Puppet code that specifies a set one or more nodes and declares the classes that Puppet will enforce on that set.

Because it's more ammenable to monitoring with the Learning VM quest tool, we'll be primarily using this site.pp method of classification in this Quest Guide. Once you've learned the basic mechanics of node definitions and class declarations, however, this knowledge will be portable to whatever methods of classification you decide to use later.

{% task 2 %}

Open the site.pp manifest in your text editor.

	vim /etc/puppetlabs/puppet/manifests/site.pp
	
Skip to the bottom of the file. (You can use the vim shortcut `G`)

You'll see a `default` node definition. This is a special node definition that Puppet will apply to any node that's not specifically included in any other node definition.

Use the `include` syntax to add the `ntp` class to your default node definition:

{% highlight puppet %}

node default {
  include ntp
}

{% endhighlight %}

{% task 3 %}

Test the `site.pp` manifest with the `puppet parser validate` command, and run `puppet agent -t` to trigger a Puppet run.

Once the Puppet run is complete, use the puppet resource tool to inspect the `ntpd` service again. If the class has been successfully applied, you will see that the service is running.

### Synching up

To avoid disrupting processes that rely on consistent timing, the ntpd service works by adding or removing a few microseconds to each tick of the system clock so as to slowly bring it into syncronization with the NTP server. 

If you like, run the `ntpstat` command to check on the synchronization status. Don't worry about waiting to get synchronized. Because the Learning VM is virtual, its clock will probably be set based on the time it was created or last suspended. It's likely to be massively out of date with the time server, and it may take half an hour or more to get synchronized!

## Class Defaults and Class Parameters

Because the `ntp` class includes default settings for its parameters, you were able to declare it with the simple `include` syntax. If you're wondering what time servers the module uses by default, there are a couple of ways to check this. Now that we've classified the Learning VM with the `ntp` class, Puppet is managing the NTP's configuration file. To see what servers the  specified, enter the command:
	
	cat /etc/ntp.conf | grep server
	
You'll see a list of the default servers:

	server 0.centos.pool.ntp.org
	server 1.centos.pool.ntp.org
	server 2.centos.pool.ntp.org

These ntp.org servers aren't actually time servers themselves; rather, they're access points that will pass you on to one of a pool of public timeservers. Most servers assigned through the ntp.org pool are provided by volunters running NTP as an extra service on a mail or web server. While these work well enough, you'll get more accurate time and use less network resources by directly specifying local timeservers run by your ISP, a university, or a government institution.

Furthermore, though we're running through this exercise with the Learning VM as the only node, you'd generally want to configure a single node in your network as an internal timeserver. This node would synchronize with an public timeserver and act as intermediary timeserver to the rest of your network.

To manually specify which timeservers your NTPD service will poll, you'll need to override the default ntp.org pool servers set by the NTP module.

This is where Puppet's *class parameters* come in. *Class parameters* provide a method to set variables in a class as it's declared. The syntax for parameterized classes looks similar to the syntax for resource declarations. Have a look at the following example:

{% highlight puppet %}

class { 'ntp':
  servers => ['nist-time-server.eoni.com','nist1-lv.ustiming.org','ntp-nist.ldsbc.edu']
}

{% endhighlight %}

{% task 3 %}

In your `site.pp`, replace the `include ntp` line with a parameterized class declaration based on the example above. Use the servers from the example, or, if you know of a nearer timeserver, include that. Note that you should always specify at least *three* timeservers for ntp to function reliably. You might, for instance, include two from the ntp.org pool and one known nearby timeserver. NTP will poll all specified servers and use an algorithm to select the most reliable.

{% task 4 %}

Once you've made your changes to the `site.pp` manifest and used the puppet parser tool to validate your syntax, use the puppet agent tool to trigger a puppet run.

You will see in the output that Puppet has changed the `/etc/ntp.conf` file and triggered a refresh of the `ntpd` service.

### And One More Thing: Arrays

In our haste to override the server defaults, we glossed over an important detail above. You likely noticed that the `servers` parameter in our class declaration took a list of servers as a value, not just one. This list of values, separated by commas (`,`) and wrapped in brackets (`[]`), is called an *array*.