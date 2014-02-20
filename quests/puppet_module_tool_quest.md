
# Puppet Module Tool Quest

The `puppet module` tool is the most important tool in expanding Puppet. The `puppet module` tool allows you to create, install and searches for modules on the Puppet Forge. We'll discuss the Puppet Forge more in detail below, but the Puppet Forge is a repository of user-contributed Puppet code of expandable components to using Puppet. The `puppet module` tool also has subcommands that make finding, installing, and managing modules from the Puppet Forge much easier from the command line. It can also generate empty modules, and prepare locally developed modules for release on the Forge.

## Actions

- `list` - List installed modules.
- `search` - Search the Puppet Forge for a module.
- `install` - Install a module from the Puppet Forge or a release archive.
- `upgrade` - Upgrade a puppet module.
- `uninstall` - Uninstall a puppet module.
- `build` - Build a module release package.
- `changes` - Show modified files of an installed module.
- `generate` - Generate boilerplate for a new module.

### Tasks

1. Let's see what modules are already installed and where they're located. To do this, we want Puppet to show us in a tree format. Go ahead and type the following command: 

		puppet module list -tree

2. Wow! you have a lot installed. That's great. But it seems like your missing the [module name] module. You should search the Puppet Forge for the module. Type the following command:

		puppet module search puppetlabs-apache

3. There's something on the Forge that exists! Let use it. Let's install module one version earlier than present. Run the following command:

	NOTE: normally I would have you install the latest version, but now I can show you how to update an existing module in the next step

		puppet module install puppetlabs-apache --version 0.10.0

4. Okay, now go ahead and upgrade earlier module version to present version

		puppet module upgrade puppetlabs-apache

5. Please do not do this, but you can also uninstall a module by running the below command. We're not going to do this because we still need this module

		puppet module uninstall puppetlabs-apache

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the puppet community for Puppet Open Source and Puppet Enterprise. Modules available on the forge simplify the process of managing your systems. These modules will provide you with classes and new resource types to manage the various aspects of your infrastructure. This reduces your time from describing the classes using Puppet's DSL to usning an existing description with the configuring the right options for you.

### Tasks

6. Now lets inspect the module the code written in Puppet DSL in the module's manifests directory. The directory path is: 

		/etc/puppetlabs/puppet/modules/apache/manifests

7. However, there is a much easier way to inspect this module by visiting the [page for the apache module on the puppet forge](https://forge.puppetlabs.com/puppetlabs/apache).

8. The documentation on the page provides insight into how to use the provided class definitions in the module to accomplish tasks. If we wanted to install [something] with the default options, the module documentation suggests we can do it as follows:

		class { 'apache':  }

9. It's as simple as that! So if we wanted our machine to have apache installed on it, all we need to do is ensure that the above **class declaration** is in some manifest that applies to our node.

10. What if we wanted to configure the default website served by Apache?

		apache::vhost { 'first.example.com':
          port    => '80',
          docroot => '/var/www/first',
		}

	NOTE: This leverage a **Defined Resource Type** called `apache::vhost` that helps us create virtual hosts in Apache. You can specify the port Apache listens to by changing the value for the parameter `port`.

<!-- How can 9 and 10 be converted into tasks -->
