---
title: Puppet Module Tool
layout: default
---

# The Forge and the Puppet Module Tool

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Manifest Quest
- Variables Quest
- Conditions Quest
- Ordering Quest
- Classes Quest
- Modules Quest

## Quest Objectives

- Confidently use the `puppet module` tool in association with Forge modules

## Getting Started

In the previous Modules Quest we primarily learned about the structure of a module and how to create a module. Next we want to answer questions like: 

- How do I install a module?
- How do I use a module?
- What about upgrading an existing module?
- How can I do all this and more from the command line?

{% aside %}

To complete this quest, the Learning VM will need to be connected to the Internet.

{% endaside %}
 
When you're ready to take your Puppet knowledge to the next level, type the following command:

	quest --start forge

The `puppet module` tool is one of the most important tools in expanding your use of Puppet. The `puppet module` tool allows you to create, install, search, (and so much more) for modules on the Forge. We'll also discuss the Puppet Forge in greater detail below.

The `puppet module` tool has subcommands that make finding, installing, and managing modules from the Forge much easier from the command line. It can also generate empty modules, and prepare locally developed modules for release on the Forge. 

### Actions

- `list` - List installed modules.
- `search` - Search the Puppet Forge for a module.
- `install` - Install a module from the Puppet Forge or a release archive.
- `upgrade` - Upgrade a puppet module.
- `uninstall` - Uninstall a puppet module.
- `build` - Build a module release package.
- `changes` - Show modified files of an installed module.
- `generate` - Generate boilerplate for a new module.


{% task 1 %}

List all the installed modules

Let's see what modules are already installed on the Learning VM and where they're located. To do this, we want Puppet to show it to us in a tree format. Go ahead and type the following command: 

	puppet module list --tree

{% task 2 %}

Search the forge for a module

Wow! you have a lot installed. That's great. Let's install one more - the `puppetlabs-mysql` module. You should search the Forge modules that help you configure mysql. To do so from the command line, type the following command:

	puppet module search mysql 

The results list all the modules that have `mysql` in their name or description. Modules on the Forge are always named as _authorname-modulename_. You will notice that one of the modules listed in the serach results is `puppetlabs-mysql`. The `puppetlabs-mysql` module is a module authored and curated primarily by the puppetlabs organization.

{% task 3 %}

Install a module 

Let's install the `puppetlabs-mysql` module. In fact, let us specify a specific version of the module. Run the following command:

	puppet module install puppetlabs-mysql --version 2.2.2

You will see that the module is downloaded and installed. You will also see that in addition to the `puppetlabs-mysql` module, all the modules it depends on were also downloaded and installed.

By default, modules are installed in the `modulepath`.

{% task 4 %}

Upgrade an installed module

Okay, now let's go ahead and upgrade the mysql module to the latest version:

	puppet module upgrade puppetlabs-mysql

Great, if you needed to uninstall a module, you can do so by running the following command:

	puppet module uninstall puppetlabs-mysql

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the puppet community for Puppet. These modules will provide you with classes, new resource types, and other helpful tools such as functions, to manage the various aspects of your infrastructure. This reduces your task from describing the classes using Puppet's DSL to using existing descriptions with the appropriate values for the parameters.

If you would like to further inspect the `puppetlabs-mysql` module Puppet code, you need to `cd` to the path then open the `init.pp` manifest.  

    cd /etc/puppetlabs/puppet/modules/mysql/manifests   
    nano init.pp

However, there is a much easier way to inspect this module by visiting the [page for the puppetlabs-mysql module on the Forge](http://forge.puppetlabs.com/puppetlabs/mysql).

The documentation on the page provides insight into how to use the provided class definitions in the module to accomplish tasks. If we wanted to install `mysql` with the default options, the module documentation suggests we can do it as follows:

	include '::mysql::server'

It's as simple as that! So if we wanted our machine to have the `mysql` server installed on it, all we need to do is ensure that the above **class declaration** is in some manifest that applies it to our node.

## Puppet Enterprise Supported Modules

[Puppet Enterprise Supported Modules](https://forge.puppetlabs.com/supported) make it easy to ensure common services can be set up, configured and managed easily with Puppet Enterprise. These are modules that are tested with Puppet Enterprise, and officially supported under the umbrella of Puppet Enterprise support. They will be maintained, with bug and security patches as needed, and are vetted to work on multiple platforms. The list of modules is growing, and includes modules to manage, among others, NTP, Firewall, the Windows registry, APT, MySQL, Apache, and many others. Here's a [List of all supported modules at the Forge](https://forge.puppetlabs.com/modules?supported=yes).

## Review

We familiarized ourselves with the Puppet Module tool, which allows us to download and manage modules from the Puppet Forge. Once a module is installed, we have access to all the definitions and tools provided by the installed module. This allows us to accelerate the process of managing system configrations with Puppet, by providing us the ability to re-use the work of the Puppet community. Once you become familiar with Puppet, you might even contribute to the Forge yourself, sharing your work with the community!


