---
title: Puppet Module Tool
layout: default
---

# Puppet Module Tool

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Classes Quest
- Varibales Quest
- Conditions Quest
- Ordering Quest
- Modules Quest

## Quest Objectives

In the previous Modules Quest we primarily learned about the structure of a module and how to create a module. Next we want to answer the questions: 

- How do I use a module?
- How do I install a module?
- What about upgrading an existing module?
- How can I do this all from the command line?
- And so on...

The `puppet module` tool is one of the most important tools in expanding your use of Puppet. The `puppet module` tool allows you to create, install, search, (and so much more) for modules on the Puppet Forge. We'll discuss the Puppet Forge more in detail below, but the Puppet Forge is a repository of user-contributed Puppet code of expandable components to using Puppet.

The `puppet module` tool also has subcommands that make finding, installing, and managing modules from the Puppet Forge much easier from the command line. It can also generate empty modules, and prepare locally developed modules for release on the Forge. When you're ready to take your Puppet knowledge to the next level, type the following command:

	quest --start puppet module tool

## Actions

- `list` - List installed modules.
- `search` - Search the Puppet Forge for a module.
- `install` - Install a module from the Puppet Forge or a release archive.
- `upgrade` - Upgrade a puppet module.
- `uninstall` - Uninstall a puppet module.
- `build` - Build a module release package.
- `changes` - Show modified files of an installed module.
- `generate` - Generate boilerplate for a new module.


{% task 1 %}
Let's see what modules are already installed on the Learning VM and where they're located. To do this, we want Puppet to show it to us in a tree format. Go ahead and type the following command: 

	puppet module list -tree

{% task 2 %}
Wow! you have a lot installed. That's great. But it seems like your missing the [module name] module. You should search the Puppet Forge for the module. Type the following command:

	puppet module search puppetlabs-apache

{% task 3 %}
There's something on the Forge that exists! Let use it. Let's install module one version earlier than present. Run the following command:

NOTE: normally I would have you install the latest version, but now I can show you how to update an existing module in the next step

	puppet module install puppetlabs-apache --version 0.10.0

{% task 4 %}
Okay, now go ahead and upgrade earlier module version to present version

	puppet module upgrade puppetlabs-apache

{% task 5 %}
Please do not do this, but you can also uninstall a module by running the below command. We're not going to do this because we still need this module

	puppet module uninstall puppetlabs-apache

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the puppet community for Puppet Open Source and Puppet Enterprise. Modules available on the forge simplify the process of managing your systems. These modules will provide you with classes and new resource types to manage the various aspects of your infrastructure. This reduces your time from describing the classes using Puppet's DSL to usning an existing description with the configuring the right options for you.

{% task 6 %}
Now lets inspect the module the code written in Puppet DSL in the module's manifests directory. The directory path is: 

	/etc/puppetlabs/puppet/modules/apache/manifests

{% task 7 %}
However, there is a much easier way to inspect this module by visiting the [page for the apache module on the puppet forge](https://forge.puppetlabs.com/puppetlabs/apache).

{% task 8 %}
The documentation on the page provides insight into how to use the provided class definitions in the module to accomplish tasks. If we wanted to install [something] with the default options, the module documentation suggests we can do it as follows:

	class { 'apache':  }

{% task 9 %}
It's as simple as that! So if we wanted our machine to have apache installed on it, all we need to do is ensure that the above **class declaration** is in some manifest that applies to our node.

{% task 10 %}
What if we wanted to configure the default website served by Apache?

	apache::vhost { 'first.example.com':
	  port    => '80',
	  docroot => '/var/www/first',
	}

NOTE: This leverage a **Defined Resource Type** called `apache::vhost` that helps us create virtual hosts in Apache. You can specify the port Apache listens to by changing the value for the parameter `port`.

