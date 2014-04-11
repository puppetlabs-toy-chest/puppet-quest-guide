---
title: Modules
layout: default
---

# Modules

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Variables Quest
- Conditions Quest
- Ordering Quest
- Classes Quest

## Quest Objectives

<<<<<<< HEAD
- f

## Getting Started

So what exactly makes Puppet such an amazing tool? It's all about the **module**. A Puppet module is a collection of resources, definitions, files, templates, etc, organized around a particular purpose. Essentially everything we have learned until this point.

In order to enable Puppet to find these class definitions, manifests allow one to test the class definitions that it may need to configure a machine for a particular purpose. We adhere to a consistent directory structure in which we place class definitions and any other files that are needed.

=======
>>>>>>> upstream/master
The tasks we will accomplish in this quest will explore and help you get started learning about modules. When you're ready, type the following command:

	quest --start modules

## What's a Module?

If *resources* and *classes* are the atoms and molecules of Puppet, we might consider *modules* our amoebas: the first self-contained organisms of the Puppet world. Until now, we've been writing one-off manifests to demonstrate individual Puppet topics, but in actual practice, every manifest should be contained within a module. The only exception, which we will address in more detail below, is the main `site.pp` module, which contains site-wide and node-specific code.

A huge convenience of using Puppet is that thousands of modules are already freely available via the Puppet Forge (and Forge content is constantly being added and improved).

In our initial Quest, we were able to use an Apache module from the forge to easily install and configure Apache so we could provide a website version of this Quest Guide. It took a few customizations in our class, but the vast majority of the necessary code had already been written, tested, documented, and published to the Puppet Forge.

Modules provide a structure to make these collections of pre-written Puppet code, well, *modular*. In order to enable Puppet to access the classes and types defined in a module's manifests, modules provide a standard pattern for the organization of re-usable collections of Puppet code.

## Module Path

All modules are located in a directory specified by the *modulepath* variable in Puppet's configuration file. On the Learning VM, Puppet's configuration file can be found at `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}
If you're ever wondering where your modulepath is, you can find it by using the handy `--configprint` flag and specifying `modulepath`:

    puppet agent --configprint modulepath

What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system. Classes and types defined by modules in these directories will be available to Puppet.

## Module Structure

A module is a pre-defined structure of directories that contain manifests, templates, configuration files, plugins, and anything else necessary for the module to function.

Remember, our *modulepath* is `/etc/puppetlabs/puppet/modules`. Use the `ls` command to see what's in that directory:

	ls /etc/puppetlabs/puppet/modules
	
There's the `apache` module we installed before. Let's use the `tree` command to take a look at the basic directory structure of the module:

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

{% task 2 %}
Once you get down past this basic directory structure, however, the `apache` module begins to look quite complex. Luckily, we can easilu create our own simple module to explore and fill in. Puppet includes a `puppet module` tool, which allows us to automatically generate a basic module directory structure.

Change directory to the modulepath.

	cd /etc/puppetlabs/puppet/modules
	
Now create a new module.

	puppet module generate learn-modulation

Use the `tree` command to take a look at your new module:

	tree learn-modulation
	
You will see a directory structure like the one below, already populated with some of the basic files needed for a Puppet Module:

	learn-modulation/
	├── manifests
	│   └── init.pp
	├── Modulefile
	├── README
	├── spec
	│   └── spec_helper.rb
	└── tests
	    └── init.pp

So what's going on in here? First, let's address the `manifest` directory. This directory can contain any number of `.pp` manifest files that form the bread-and-butter of your Module. Whatever other manifests it contains, however, it must always contain the `init.pp` manifest which, in turn, must define a class with the same name as your module. Think of this `init.pp` module and the class it contains as the front-door of your module, that is, the point of access from which you can reach the other components when you go to implement the module and call on the classes it contains.

{% task 3 %}
If you take a look at the `/learn-modulation/manifests/init.pp` manifest, you'll see that it has already been set up with an empty `modulation` class.

Let's write a simple resource declaration into this `modulation` class:

{% highlight puppet %}
class modulicious {
  resource { '/root/modulated.txt':
  	ensure 	=> present;
  	content => 'Nice module, bro!'
  }
}
{% endhighlight %}

{% task 7 %}
Check and see if MegaByte has been successfully added to the Learning VM. Do you remember the `puppet resource` tool? If not, Refer back to the Resource Quest.

## Declaring Classes from Modules

Remember when we talked about declaring classes in the Classes Quest? We said we would discuss more on the correct way to declare classes in the Modules Quest. Once a class is stored in a module, there are actually several ways to declare it. You've already seen this, but you can declare classes by putting `include [class name]` in your main manifest, just as we did in the Classes Quest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class has already been declared, `include` will notice that and do nothing.

This let's you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in `site.pp`.

{% task 8 %}
Let's make a test directory in the same modulepath. Type the following command:

	mkdir users/tests

{% task 9 %}
Like we did before, we are going to want to edit the `init.pp` manifest in the test directory. 

{% task 10 %}
This time however, we're going to take advantage of the `include` function. Type the following `include` directive at the very end of the manifest outside of the curly braces.

	include users

Oh shoot! We forgot to add the staff `group` to user MegaByte. Can you quickly dive back into the `init.pp` manifest and make sure the staff `group` is present. Don't forgot to add `/bin/bash` as the shell and `gid => 'staff',` for user MegaByte as well.

{% task 11 %}
Next, check to make sure the syntax you entered is correct using `puppet parser validate`.

{% task 12 %}
We're not ready to enforce this manifest just yet. We want to test run it first. Do you remember in the Manifests Quest when we talked about simulating a manifest by using the `--noop` argument?

{% task 13 %}
Great! Everything is running how it should be. Now finish this off by enforcing your `init.pp` manifest on the local system.

#### You just created your first Puppet module!! 

## Review
1.  Puppet's DSL, by virtue of its __declarative__ nature, makes it possible for us to define the attributes of the resources, without the need to concern ourselves with _how_ the definition is enforced. Puppet uses the Resource Abstraction Layer to abstract away the complexity surrounding the specific commands to be executed, and the operating system-specific tools used to realize our definition! You did not need to know or specify the command to create a new unix user group to create the group `staff`, for example.
2. By creating a class called users, it is now possible for us to automate the process of creating the users we need on any system with Puppet installed on it, by simply including that class on that system. Class definitions are reusable!
