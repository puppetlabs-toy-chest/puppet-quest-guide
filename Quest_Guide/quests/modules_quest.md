---
title: Modules
layout: default
---

# Modules

### Prerequisites

- Welcome
- Power of Puppet
- Resources
- Manifests and Classes

## Quest Objectives
 - Understand the purpose of Puppet modules
 - Learn the module directory structure
 - Write and test a simple module
 
## Getting Started

If you want to get things done effeciently in Puppet, the **module** will be your best friend. You got a little taste of module structure in the Manifests and Classes quest. In this quest, we'll get into the details. 

In short, a Puppet module is a self-contained bundle of all the Puppet code and other data needed to manage some aspect of your configuration. In this quest, we'll go over the purpose and structure of Puppet modules, before showing you how to create your own.

When you're ready, type the following command:

	quest --start modules

## Why Meddle with Modules?
There's no hard-and-fast technical reason why you can't throw all your resource declarations for a node into one massive class. But this wouldn't be very Puppetish. Puppet's not just about bringing your nodes in line with a desired configuration state; it's about doing this in a way that's transparent, repeatable, and as painless as possible.

Modules are a big part of how Puppet eases the challenges of configuration management. Returns on the work that goes into crafting one well-written module can be multiplied across an unlimited number of nodes. Modules allow you to organize your Puppet code into units that are testable, reusable, and portable, in short, *modular*.

The standard module filestructure gives Puppet a consistent way to locate whatever classes, files, templates, plugins, and binaries are required to manage a given function on a node.

Modules and the module directory structure also provide an important way to manage scope within Puppet. Keeping everything nicely tucked away in its own module means you have to worry much less about name collisions and confusion.

Finally, because modules are standardized and self-contained, they're easy to share. Puppet Labs hosts a free service called the [Forge](https://forge.puppetlabs.com) where you can find a wide array of modules developed and maintained by others.

## The modulepath
All modules accessible by your Puppet Master are located in the directories specified by the *modulepath* variable in Puppet's configuration file. On the Learning VM, this configuration file is `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}
You can find the modulepath on any system with Puppet installed by running the `puppet agent` command with the `--configprint` flag and the `modulepath` argument:

    puppet agent --configprint modulepath

This will tell you that Puppet looks in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find available modules.

## Module Structure
Now that you have an idea of why modules are useful and where they're kept, it's time to delve a little deeper into the structure of a module. 

A module consists of a pre-defined structure of directories that help Puppet reliably locate the module's contents.

Use the `ls` command to see what's in the modulepath:

	ls /etc/puppetlabs/puppet/modules
	
You'll probably recognize some familiar module names from previous quests.

Take a look at the directory structure of the modules here. To get clear picture, use a couple flags with the `tree` command to limit the output to directories, and limit the depth to two directories.

	tree -L 2 -d /etc/puppetlabs/puppet/modules/
	
You'll see a list of directories, like so:

	/etc/puppetlabs/puppet/modules/
	└── apache
    	├── files
    	├── lib
    	├── manifests
    	├── spec
    	├── templates
    	└── tests
    	...
    	
Each of the standardized subdirectory names you see tells Puppet users and Puppet itself where to find each of the various components that come together to make a complete module.

Now that you have an idea of what a module is and what it looks like, you're ready to make your own. 

You've already had a chance to play with the *user* and *package* resources in previous quests, so this time we'll focus on the *file* resource type. Because the settings for services and applications are often set in a configuration file, the *file* resource type can be very handy for managing these settings. 

The module you'll make in this quest will manage some settings for Vim, the text editor you've been using to write your Puppet code.

Change your working directory to the modulepath if you're not already there.

	  cd /etc/puppetlabs/puppet/modules

The top directory will be the name you want for the module. In this case, let's call it "vimrc." Use the `mkdir` command to create your module directory:

	  mkdir vimrc

Now you need three more directories, one for manifests, one for tests, and one for files.

    mkdir vimrc/{manifests,tests,files}

If you use the `tree users` command to take a look at your new module, you should now see a structure like this:

	vimrc
	├── files
	├── manifests
	└── tests

	3 directories, 0 files

{% task 4 %}

We've already set up the Learning VM with some custom settings for Vim. Instead of starting from scratch, copy that existing file into the `files` directory of your new module.

	cp ~/.vimrc vimrc/files/vimrc
	
Once you've copied the file, open so you can make an addition.

	vim vimrc/files/vimrc

We'll keep things simple. By default, line numbering is disabled. Add the following line to then end of the file to tell Vim to turn on line numbering.

	set number
	
Save and exit.

Now that your source file is ready, you need to write a manifest to tell puppet what to do with it.

Remember, the manifest that includes the main class for a module is always called `init.pp`. Create the `init.pp` manifest in your module's manifests directory.

	vim vimrc/manifests/init.pp

The Puppet code you put in here will be pretty simple. You need to define a class `vimrc`, and within it, make a file resource declaration to tell Puppet to take the `vimrc/files/vimrc` file from your module and use Puppet's built in fileserver to push it out to the specified location.

In this case, the `.vimrc` file that defines your Vim settings lives in the `/root` directory. This is the file you want Puppet to manage, so its full path (i.e. `/root/.vimrc`) will be the *title* of the file resource you're declaring.

This resource declaration will then need two attribute value pairs. 

First, as with the other resource types you've encountered, `ensure => 'present',` tells Puppet to ensure that the entity described by the resource exists on the system. 

Second, the `source` attribute tells Puppet what the managed file should actually contain. The Puppet Master uses a built-in file server to make the source file available to client nodes, and the value for the source attribute should be the URI of the source file.

All Puppet file server URIs are structured as follows:

	puppet://{server hostname (optional)}/{mount point}/{remainder of path}
	
However, there's some URI abstraction magic built in to Puppet that makes these URIs more concise, but can also make them a bit hard to understand.

First, note that the optional server hostname is nearly always omitted, and will default to the hostname of the Puppet master. This means that you'll generally see file URIs that begin with a triple forward slash, like so: `puppet:///`.

Second, nearly all file serving in Puppet is done through modules, and Puppet provides a couple of shortcuts to make accessing files in modules easier. Instead of specifying the full path to a file, you can just include `modules/module_name/file_name`. Puppet will automatically fill in the modulepath and the `files` subdirectory. 

So while the path to the vimrc source file is `/etc/puppetlabs/puppet/modules/vimrc/files/vimrc`, Puppet's URI abstraction shortens it to `/modules/vimrc/vimrc`. Combined with the implicit hostname, then, the attribute value pair for the source URI is:

	source => 'puppet:///modules/vimrc/vimrc',

And putting this all together, your init.pp manifest should contain the following:

{% highlight puppet %}
class vimrc {
  file { '/root/.vimrc':
    ensure => 'present',
    source => 'puppet:///modules/vimrc/vimrc',
  }
}
{% endhighlight %}

Save the manifest, and use the `puppet parser` tool to validate your syntax:

    puppet parser validate vimrc/manifests/init.pp

Remember, this manifest *defines* the `vimrc` class, but you'll need to *declare* it for it to have an effect. That is, we've described what the `users` class is, but we haven't told Puppet to actually do anything with it.

{% task 5 %}

To test the `vimrc` class, create a manifest called `init.pp`  in the `vimrc/tests` directory.

    vim vimrc/tests/init.pp

All we're going to do here is *declare* our `vimrc` class with the `include` directive.

{% highlight puppet %}
include vimrc
{% endhighlight %}

Apply the new manifest with the `--noop` flag. If everything looks good, drop the `--noop` and apply it for real.

Go ahead and open a file with Vim and see if your new settings have been applied.

## Review

1. We identified what the features of a Puppet Module are, and understood how it is useful
2. We wrote our first module!
 
