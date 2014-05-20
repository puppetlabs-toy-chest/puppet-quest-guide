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
 - Understand the purpose of Puppet modules
 - Learn the basic structure and layout of modules
 - Write and test a simple module
 
## Getting Started

So far we've seen some simple examples of Puppet code, but what makes Puppet such an adaptable tool? When it comes to getting things done, it's all about the **module**. A Puppet module is a self-contained bundle of code and data, organized around a particular purpose. The code would encompass manifests, the data would include all the source files, templates etc that you need to accomplish the purpose of the module. Everything we have learned until this point and more can come together as part of a module. When you're ready, type the following command:

	quest --start modules

## What's a Module?

If *resources* and *classes* are the atoms and molecules of Puppet, we might consider *modules* our amoebas: the first self-contained organisms of the Puppet world. Until now, we've been writing one-off manifests to demonstrate individual Puppet topics, but in actual practice, every manifest should be contained within a module. 

Thus far, in order to gain insight into Puppet's language features and syntax, we have been writing one-off manifests, perhaps using a source file for the contents of some configuration file (as we did for the SSH daemon configuration) etc. We have to remember, however that Puppet is designed to help you manage _lots_ of systems (not just one system) from a central point - the master. 

Although it is possible to list all the resources (users, files, package, services, cron tasks etc) that you need to manage on a system in one huge manifest, and then apply that manifest on the system, this is not scalable. Neither is it composable, or flexible enough to be reused. Classes were our first stop on the path to learning how to create 'blocks' - building blocks that we can use to describe the configuration of the systems we seek to manage.

There is still a missing part of the puzzle. When you ask Puppet to, say, `include ssh` on a particular node, or, as we did in the Power of Puppet quest, _classify_ a node (learn.localdomain) with a class (lvmguide), how does Puppet know _where_ to find the definition for the class, in order to ensure that the specified configuration is realized?

The answer is, we agree to put the class definitions in a standard location on the file system, by placing the manifest containing the class definition in a specific directory in a module.

Simply put, a Module is a directory with a specific structure - a means for us to package everything needed to achieve a certain goal. Once we agree to stick to the standard way of doing this, a significant benefit is the ability to _share_ our work, such that others who seek to achieve the same goal can re-use our work. The [Forge](https://forge.puppetlabs.com) is the central location where you can find modules that have been developed by others.

In our initial Quest, we were able to use an Apache module from the Forge. This let us easily install and configure an Apache webserver to host the website version of this Quest Guide. The vast majority of the necessary code had already been written, tested, documented, and published to the Puppet Forge.

Modules provide a structure to make these collections of pre-written Puppet code, well, *modular*. In order to enable Puppet to access the classes and types defined in a module's manifests, modules give us a standard pattern for the organization of and naming of Puppet manifests and other resources.

## Module Path

All modules are located in a directory specified by the *modulepath* variable in Puppet's configuration file. On the Learning VM, Puppet's configuration file can be found at `/etc/puppetlabs/puppet/puppet.conf`.

{% task 1 %}

Find the modulepath on the Learning VM.

If you're ever wondering where your modulepath is, you can find it by running the `puppet agent` command with the `--configprint` flag and specifying `modulepath`:

    puppet agent --configprint modulepath

What the returned value tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system. Classes and types defined by modules in these directories will be available to Puppet.

## Module Structure

The skeleton of a module is a pre-defined structure of directories that Puppet already knows how to traverse to find the module's manifests, templates, configuration files, plugins, and anything else necessary for the module to function. Of these, we have encountered manifests and files that serve as the source for configuration files. We will learn about the rest in due course.

Remember, `/etc/puppetlabs/puppet/modules` is in our modulepath. Use the `ls` command to see what's in that directory:

	ls /etc/puppetlabs/puppet/modules
	
There's the `apache` module we installed before. There is also the `lvmguide` module that was used to set up the quest guide website, that was already in place when we started. Use the `tree` command to take a look at the basic directory structure of the module. (To get a nice picture, we can use a few flags with the tree command to limit our output to directories, and limit the depth to two directories.)

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

Once you get down past this basic directory structure, however, the `apache` module begins to look quite complex. To keep things simple, we can create our own first module to work with.

{% task 2 %}

First, be sure to change your working directory to the modulepath. We need our module to be in this directory if we want Puppet to be able to find it.

	  cd /etc/puppetlabs/puppet/modules
	
You have created some users in the *Resources* and *Manifests* quests, so this resource type should be fairly familiar. Let's make a `users` module that will help us manage users on the Learning VM.

The top directory of any module will always be the name of that module. Use the `mkdir` command to create your module directory:

	  mkdir users

{% task 3 %}
Now we need two more directories, one for our manifests, which must be called `manifests`, and one for our tests, which must be called (you guessed it!) `tests`. As you will see shortly, tests allow you to easily apply and test classes defined in your module without having to deal with higher level configuration tasks like node classification.

Go ahead and use the `mkdir` command to create `users/manifests` and `users/tests` directories within your new module.

    mkdir users/{manifests,tests}

If you use the `tree users` command to take a look at your new module, you should now see a structure like this:

	users
	├── manifests
	└── tests

	2 directories, 0 files

{% task 4 %}

Create a manifest defining class users:

The manifests directory can contain any number of the `.pp` manifest files that form the bread-and-butter of your module. If there is a class with the same name as the module, the definition for that class should be in a file name `init.pp`. In our case, we need a class called `users` in our module with the same name. The defintion for class users should be in a file called `init.pp` in the `manifests` directory. This is necessitated by the mechanism by which Puppet locates class definitions when you name a class. If for example, you had a file called `settings.pp` in the manifests directory, you will have to refer to it as class `users::settings` for Puppet to be able to find the class defintion contained in it. By placing the definition for class `users` in `init.pp`, we can refer to that class defintion by the name of the module - `users`. 

Go ahead and create the `init.pp` manifest in the `users/manifests` directory. (We're assuming you're still working from the `/etc/puppetlabs/puppet/modules`. The full path would be `/etc/puppetlabs/puppet/modules/users/manifests.init.pp`)

    nano users/manifests/init.pp

Now in that file, add the following code:

{% highlight puppet %}
class users {
  user { 'alice':
  	ensure 	=> present,
  }
}
{% endhighlight %}

We have defined a class with just the one resource in it. A resource of type `user` with title `alice`.

Use the `puppet parser` tool to validate your manifest:

    puppet parser validate users/manifests/init.pp

For now, we're not going to apply anything. This manifest *defines* the `users` class, but so far, we haven't *declared* it. That is, we've described what the `users` class is, but we haven't told Puppet to actually do anything with it.

## Declaring Classes from Modules

Remember when we talked about *declaring* classes in the Classes Quest? We said we would discuss more on the correct way to use classes in the Modules Quest. Once a class is *defined* in a module, there are actually several ways to *declare* it. As you've already seen, you can declare classes by putting `include [class name]` in your main manifest, just as we did in the Classes Quest.

The `include` function declares a class, if it hasn’t already been declared somewhere else. If a class has already been declared, `include` will notice that and do nothing.

This lets you safely declare a class in several places. If some class depends on something in another class, it can declare that class without worrying whether it’s also being declared elsewhere. 

{% task 5 %}

Write a test for our new class:

In order to test our `users` class, we will create a new manifest in the `tests` directory that declares it. Create a manifest called `init.pp`  in the `users/tests` directory.

    nano users/tests/init.pp

All we're going to do here is *declare* our `users` class with the `include` directive.

{% highlight puppet %}
include users
{% endhighlight %}

Try applying the new manifest with the `--noop` flag first. If everything looks good, apply the `users/tests/init.pp` manifest without the `--noop` flag to take your `users` class for a test drive, and see how it works out when applied.

Use the `puppet resource` tool to see if `user alice` has been successfully created.

So What happened here? Even though the `users` class was in a different manifest, we were able to *declare* our test manifest. Because our module is in Puppet's *modulepath*, Puppet was able to find the correct class and apply it.

#### You just created your first Puppet module!! 

## Classification

When you use a *Node Classifier*, such as the Puppet Enterprise Console, you can *classify* nodes - which is to say that you can state which classes apply to which nodes, using the node classifier. This is exactly what we did when we used the PE Console to classify our Learning VM node with the `lvmguide` class in the Power of Puppet quest. In order to be able to classify a node thus, you *must* ensure all of the following:  

1. There is a module (a directory) with the same name as the class in the modulepath on the Puppet master
2. The module has a file called `init.pp` in the `manifests` directory contained within it
3. This `init.pp` file contains the definition of the class

With modules, you can create composable configurations for systems. For example, let's say that you have a module called 'ssh' which provides class ssh, another called 'apache' and a third called 'mysql'. Using these three modules, and the classes provided by them, you can now classify a node to be configured with any combination of the three classes. You can have a server that has mysql and ssh managed on it (a database server), another with apache and ssh managed on it (a webserver), and a server with only ssh configured on it. The possibilities are endless. With well-written, community-vetted, even Puppet Supported Modules from the Forge, you can be off composing and managing configuration for your systems in no time. You can also write your _own_ modules that use classes from these Forge modules, as we did with the `lvmguide` class, and resuse them too.

## Review

1. We identified what the features of a Puppet Module are, and understood how it is useful
2. We wrote our first module!
3. We learned how modules (and the classes within them) can be used to create composable configurations by using a node classifier such as the PE Console.
 
