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

In this quest you will learn about the contents and structure of Puppet modules. You will learn how to create and test a simple module. When you're ready, type the following command:

	quest --start modules

## What's a Module?

If *resources* and *classes* are the atoms and molecules of Puppet, we might consider *modules* our amoebas: the first self-contained organisms of the Puppet world. Until now, we've been writing one-off manifests to demonstrate individual Puppet topics, but in actual practice, every manifest should be contained within a module. The only exception, which we will address in more detail below, is the main `site.pp` module, which contains site-wide and node-specific code.

A huge convenience of using Puppet is that thousands of modules are already freely available via the Puppet Forge (and Forge content is constantly being added and improved).

In our initial Quest, we were able to use an Apache module from the Forge. This let us easily install and configure an Apache webserver to host the website version of this Quest Guide. The vast majority of the necessary code had already been written, tested, documented, and published to the Puppet Forge.

Modules provide a structure to make these collections of pre-written Puppet code, well, *modular*. In order to enable Puppet to access the classes and types defined in a module's manifests, modules give us a standard pattern for the organization of and naming of Puppet manifests and other resources.

## Module Path

All modules are located in a directory specified by the *modulepath* variable in Puppet's configuration file. On the Learning VM, Puppet's configuration file can be found at `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}
If you're ever wondering where your modulepath is, you can find it by running the `puppet agent` command with the `--configprint` flag and specifying `modulepath`:

    puppet agent --configprint modulepath

What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system. Classes and types defined by modules in these directories will be available to Puppet.

## Module Structure

The skeleton of a module is a pre-defined structure of directories that Puppet already knows how to traverse to find the module's manifests, templates, configuration files, plugins, and anything else necessary for the module to function.

Remember, our *modulepath* is `/etc/puppetlabs/puppet/modules`. Use the `ls` command to see what's in that directory:

	ls /etc/puppetlabs/puppet/modules
	
There's the `apache` module we installed before. Use the `tree` command to take a look at the basic directory structure of the module. (To get a nice picture, we can use a few flags with the tree command to limit our output to directories, and limit the depth to two directories.)

	tree -L 2 -d /etc/puppetlabs/puppet/modules/
	
You should see a list of directories, like so:

	/etc/puppetlabs/puppet/modules/
	└── apache
    	├── files
    	├── lib
    	├── manifests
    	├── spec
    	├── templates
    	└── tests

{% task 2 %}
Once you get down past this basic directory structure, however, the `apache` module begins to look quite complex. To keep things simple, we can create our own bare-bones module to work with.

First, be sure to change your working directory to the modulepath. We need our module to be in this directory if we want Puppet to be able to find it.

	cd /etc/puppetlabs/puppet/modules
	
You have created some users in the *Resources* and *Manifests* quests, so this resource type should be fairly familiar. Let's make a `users` module that will help us manage users on the Learning VM.

The top directory of any module will always be the name of that module. Use the `mkdir` command to create your module directory:

	mkdir users

{% task 3 %}
Now we need two more directories, one for our manifests, which must be called `manifests`, and one for our tests, which must be called (you guessed it!) `tests`. As you will see shortly, tests allow you to easily apply and test classes defined in your module without having to deal with higher level configuration tasks like node classification.

Go ahead and use the `mkdir` command to create `users/manifests` and `users/tests` directories within your new module.

If you use the `tree users` command to take a look at your new module, you should now see a structure like this:

	users
	├── manifests
	└── tests

	2 directories, 0 files

{% task 4 %}
The manifests directory can contain any number of the `.pp` manifest files that form the bread-and-butter of your module. Whatever other manifests it contains, however, it must always contain an `init.pp` manifest. The `init.pp` manifest defines the module's main class, which must have same name as the module itself, in this case, `users`.

Go ahead and create the `init.pp` manifest in the `users/manifests` directory. (We're assuming you're still working from the `/etc/puppetlabs/puppet/modules`. The full path would be `/etc/puppetlabs/puppet/modules/users/manifests.init.pp`)

Write a simple `users` class with a `user` resource declaration:

{% highlight puppet %}
class users {
  user { 'alice':
  	ensure 	=> present;
  }
}
{% endhighlight %}

Use the `puppet parser` tool to validate your manifest.

For now, we're not going to apply anything. This manifest *defines* the `users` class, but so far, we haven't *declared* it. That is, we've described what the `users` class is, but we haven't told Puppet to actually do anything with it.

## Declaring Classes from Modules

Remember when we talked about *declaring* classes in the Classes Quest? We said we would discuss more on the correct way to use classes in the Modules Quest. Once a class is *defined* in a module, there are actually several ways to *declare* it. As you've already seen, you can declare classes by putting `include [class name]` in your main manifest, just as we did in the Classes Quest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class has already been declared, `include` will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in `site.pp`.

{% task 9 %}
In order to test our `users` class, we will create a new manifest in the `tests` directory that declares it. Create a manifest called `init.pp`  in the `users/tests` directory.

All we're going to do here is *declare* our `users` class with the `include` directive.

{% highlight puppet %}
include users
{% endhighlight %}

Run a `--noop`. If everything looks good, apply the `users/tests/init.pp` manifest to test your `users` class.

Use the `puppet resource` tool to see if `user alice` has been successfully created.

So What happened here? Even though the `users` class was in a different manifest, we were able to *declare* our test manifest. Because our module is in Puppet's *modulepath*, Puppet was able to find the correct class any apply it.

#### You just created your first Puppet module!! 

## Review
1.  Puppet's DSL, by virtue of its __declarative__ nature, makes it possible for us to define the attributes of the resources, without the need to concern ourselves with _how_ the definition is enforced. Puppet uses the Resource Abstraction Layer to abstract away the complexity surrounding the specific commands to be executed, and the operating system-specific tools used to realize our definition! You did not need to know or specify the command to create a new unix user group to create the group `staff`, for example.
2. By creating a class called users, it is now possible for us to automate the process of creating the users we need on any system with Puppet installed on it, by simply including that class on that system. Class definitions are reusable!
