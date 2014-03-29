---
title: Modules
layout: default
---

# Modules

### Prerequisites

- Resources Quest
- Mainfest Quest
- Classes Quest
- Varibales Quest
- Conditions Quest
- Ordering Quest

## Quest Objectives

So what exactly makes Puppet such an amazing tool? It's all about the **module**. A Puppet module is a collection of resources, definitions, files, templates, etc, organized around a particular purpose. Essentially everything we have learned up until this point.

In order to enable Puppet to find these class definitions, manifests allow one to test the class defintions that it may need to configure a machine for a particular purpose. We adhere to a consistent directory structure in which we place class definitions and any other files that are needed etc.

The tasks we will accompish in this quest will explore and help you get started learning about modules. When you're ready, type the following command:

	quest --start modules

## Module Path

All modules are placed in a special directory specified by the **modulepath**. The modulepath is a setting that can be defined in Puppet configuration file. Puppet's configuration file exists in the directory `/etc/puppetlabs/puppet/puppet.conf`.

You can also find the modulepath with the following command:

    puppet agent --configprint modulepath

What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system.

## Module Structure

A module is a directory with a pre-defined structure, with class definitions, files, etc. in specific sub-directories. The module’s name must be the same name as the directory it is housed in. Inside a module there must be a manifests directory, which can contain any number of `.pp` files, but must contain the `init.pp` file. The `init.pp` file must contain a single class definition and must be the same as the module’s name.

## Declaring Classes from Modules

Remember when we talked about declating classes in the Classes Quest? Once a class is stored in a module, there are actually several ways to declare it. You've already seen this, but you can declare classes by putting `include [class name]` in your main manifest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class has already been declared, `include` will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared in `site.pp`.

{% task 1 %}
Find your `modulepath` and then ensure your are working in that directory.
	
	HINT: What you need to type is stated in the Module Path section

{% task 2 %}
Create your manifests directory by typing the following command:

	mkdir -p users/manifests

{% task 3 %}
Now, we're going to want to edit the manifest. Type the following command:

	HINT: Remember how to do this? Look back at the Manifests Quest if you forgot.

{% task 4 %}
Do you remember the `user` resource and the anatomy of how a resource is constructed? Using that knowledge can you make sure that `user => kilo` is present in the user class.

{% task 5 %}
Next, check to make sure the syntax you entered is correct using `puppet parser`.

{% task 6 %}
Lets now make a test directory in the same modulepath. Type the following command:

	mkdir users/tests

{% task 7 %}
Like we did before, we are going to want to edit the manifest in the test directory: Type the following command:

	nano users/tests/init.pp

{% task 8 %}
We are going to take advantage of the `include` function now. Type the following information into the manifest:

		include users

{% task 9 %}
Next, check to make sure the syntax you entered is correct using `puppet parser`.

{% task 10 %}
Oh shoot! We forgot to add the staff `group` to user como. Can you quickly run back into the manifest and make sure the staff `group` is present. Don't forgot to add `/bin/bash` as the shell and `gid => 'staff',` for user como as well.

{% task 11 %}
Sorry about that, check again to make sure the syntax you entered is correct using `puppet parser`.

{% task 12 %}
We're not ready to execute this manifest just yet. We want to test run it first. Do you remember in the Manifests Quest when we discussed how to do that? Go ahead and apply the manifest in the test directory in `--noop` mode.

{% task 13 %}
Great! Everything is running how it should be. Now finish this off by enforcing your class on the local system.

#### You just created your first Puppet module!! 

## 

### There are two important things to note here:

