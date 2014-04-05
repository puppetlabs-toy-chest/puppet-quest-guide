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
- Classes Quest
- Varibales Quest
- Conditions Quest
- Ordering Quest

## Quest Objectives

So what exactly makes Puppet such an amazing tool? It's all about the **module**. A Puppet module is a collection of resources, definitions, files, templates, etc, organized around a particular purpose. Essentially everything we have learned until this point.

In order to enable Puppet to find these class definitions, manifests allow one to test the class definitions that it may need to configure a machine for a particular purpose. We adhere to a consistent directory structure in which we place class definitions and any other files that are needed.

The tasks we will accomplish in this quest will explore and help you get started learning about modules. When you're ready, type the following command:

	quest --start modules

## Module Path

All modules are placed in a special directory specified by the **modulepath**. The modulepath is a setting that can be defined in Puppet configuration file. Puppet's configuration file exists in the directory `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}
You can also find the modulepath with the following command.  

    puppet agent --configprint modulepath

What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system.

## Module Structure

A module is a directory with a pre-defined structure with class definitions, files, etc. in specific sub-directories. The module’s name must be the same name as the directory it is housed in. Inside a module there must be a manifests directory, which can contain any number of `.pp` manifest files, but **must** contain the `init.pp` file. The `init.pp` file **must** contain a single class definition and **must** be the same as the module’s name.

{% task 2 %}
Create your manifests directory by typing the following command:

	mkdir -p users/manifests

{% task 3 %}
Now, we're going to want to edit the `init.pp` manifest.

	HINT: Remember how to do this? Look back at the Manifests Quest if you forgot.

{% task 4 %}
Do you remember in the Resources Quests where we talked about the `user` resource and the anatomy of how a resource is constructed? Using that knowledge can you make sure that `user => megabyte` is present in the `class user`?

{% task 5 %}
Next, check to make sure the syntax for the `init.pp` manifest is correct using `puppet parser`.

{% task 6 %}
Once your `init.pp` manifest is error free, enforce the `init.pp` manifest using the `puppet apply` tool.

{% task 7 %}
Check and see if MegaByte has been successfully added to the Learning VM. Do you remember the `puppet resource` tool? If not, Refer back to the Resource Quest.

## Declaring Classes from Modules

Remember when we talked about declaring classes in the Classes Quest? We said we would dicuss more on the correct way to declare classes in the Modules Quest. Once a class is stored in a module, there are actually several ways to declare it. You've already seen this, but you can declare classes by putting `include [class name]` in your main manifest, just as we did in the Classes Quest.

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
Next, check to make sure the syntax you entered is correct using `puppet parser`.

{% task 12 %}
We're not ready to enforce this manifest just yet. We want to test run it first. Do you remember in the Manifests Quest when we talked about simulating a manifest by using the `--noop` argument?

{% task 13 %}
Great! Everything is running how it should be. Now finish this off by enforcing your `init.pp` manifest on the local system.

#### You just created your first Puppet module!! 

## 

### There are two important things to note here:
1.  Puppet's DSL, by virtue of its __declarative__ nature, makes it possible for us to define the attributes of the resources, without the need to concern ourselves with _how_ the definition is enforced. Puppet uses the Resource Abstraction Layer to abstract away the complexity surrounding the specific commands to be executed, and the operating system-specific tools used to realize our definition! You did not need to know or specify the command to create a new unix user group to create the group `staff`, for example.
2. By creating a class called users, it is now possible for us to automate the process of creating the users we need on any system with Puppet installed on it, by simply including that class on that system. Class definitions are reusable!
