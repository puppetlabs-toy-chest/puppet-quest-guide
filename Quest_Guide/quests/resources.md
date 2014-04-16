---
title: Resources
layout: default
---

# Resources

### Prerequisites

- Welcome Quest
- Power of Puppet Quest

## Quest Objectives

- Understand how resources on the system are modeled in Puppet's Domain Specific Language (DSL)
- Learn about the Resource Abstraction Layer (RAL)
- Use Puppet to inspect resources on your system


## Getting Started

In this quest, you will be introduced to Resources and how system configurations are represented using Resource definitions. You will learn how to inspect resources on the Learning VM using Puppet. Please note though, that we are not going to use Puppet to manage any resources. Instead, we are going to use basic Unix commands in this quest, and then look at how the resultant resource changes are represented in Puppet's Domain Specific Language (DSL). As an aspiring practitioner of Puppet, it is important for you to have a thorough understanding of the Puppet syntax as well as the `puppet resource` and `puppet describe` tools. When you're ready to get started, type the following command:

    quest --start resources

## Resources

Resources are the fundamental units for modeling system configurations. Each resource describes some aspect of a system, like a service that must be running or a package that must be installed. The block of Puppet code that describes a resource is called a **resource declaration**. Resource declarations are written in Puppet's own Domain Specific Language.

### Puppet's Domain Specific Language

Puppet uses its own configuration language, one that was designed to be accessible to sysadmins and does not require much formal programming experience. The code you see below is an example of what we're referring to. Since it is a **declarative** language, the definitions of resources can be considered as *models* of the state of resources.

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside The Trailing Comma %}
Though a comma isn't strictly necessary at the end of the final attribute value pair, it is best practice to include it for the sake of consistency.
{% endaside %}

The first step in mastering Puppet is to learn about the world around you. You will also realize everything in this Learning VM is a collection of **resources**. You will not be using resource declarations to shape your environment just yet. Instead, you will exercise your power by hand and use Puppet only to inspect your actions using the `puppet resource` and `puppet describe` tools.

## Anatomy of a Resource

Resources can be large or small, simple or complex. In the world of Puppet, you and everything around you (on the Learning VM) are resources. But let's say you wanted to learn more about a particular resource. How would one do that? Well, you have two options: `puppet describe` and `puppet resource`.

{% task 1 %}
Let's say you want to learn more about the `user` resource type as it applies to all users in the Learning VM. You would need to type the following command:

	puppet describe user

The `puppet describe` command can list info about the currently installed resource types on a given machine.

{% task 2 %}
Great! But how would one look at a specific resource? Well, to check and see how you look in the world of Puppet, type the following command :

	puppet resource user root
		
To Puppet, you look like this. The block of code below describes you is called a **resource declaration**. It's a little abstract, but a nice portrait, don't you think?

{% highlight puppet %}
user { 'root':
  ensure           => 'present',
  comment          => 'root',
  gid              => '0',
  home             => '/root',
  password         => '$1$jrm5tnjw$h8JJ9mCZLmJvIxvDLjw1M/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '0',
}
{% endhighlight %}

The `puppet resource` can interactively inspect and modify resources on a single system as well as can be useful for one-off jobs. However, Puppet was born for greater things which we'll discuss further in the Manifest Quest.

### Resource Type

Let's take a look at your first line in the above resource declaration. Do you see the word `user`? It's right _before_ the curly brace. This is called the **resource type**. Just as any individual cat or dog is a member of its species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource must be a member of a resource type. Think of this type as a framework that defines the range of characteristics an individual resource can have.

Puppet allows you to describe and manipulate a variety of resource types. Below are some core resource types you will encounter most often: 

* `user` A user
* `group` A user group
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job
* `exec` An external command
* `host` A host entry

{% aside ...Wait, There's More! %}

If you are curious to learn about all of the different built-in resources types available for you to manage, see the [Type Reference Document](http://docs.puppetlabs.com/references/latest/type.html) 

{% endaside %}

### Resource Title

Again, let's take a look at your first line in the above resource declaration. Do you see the single quoted word `'root'`? It's right _after_ the curly brace. This is called the **title**. The title of a resource is used to identify it and **must** be unique. No two resources of the same type can share the same title. Also, don't forget to always add a colon (:) after the title. That's important to remember and often overlooked!

{% task 3 %}
The path to greatness is a lonely one. Fortunately, your superuser status gives you the ability to create a sidekick for yourself. First let's do this in a non-Puppet way. Type the following command:

	useradd byte

{% task 4 %}
Now take a look at Byte using the `puppet resource` tool. Type the following command:

	puppet resource user byte
            
Potent stuff. Note that Byte's password attribute is set to `'!!'`. This isn't a proper password at all! In fact, it's a special value indicating Byte has no password whatsoever.

### Attribute Value Pairs

One more time. Let's look at the resource declaration for user `root` listed above. After the colon (:) comes a list of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (which we call a hash rocket), a value, and a final comma. For example, the attribute value pair `home => '/root',` indicates that your home is set to the directory `/root`.
	
{% task 5 %}
Let's rectify Byte's password situation by setting it to *puppetlabs*. Type the following command:

	passwd byte

Now set the password to *puppetlabs* and pressing Enter (Return) twice. You will not see anything displayed as you type the password.
		
Now if you take another look at Byte using `puppet resource`, the value for Byte's password attribute should now be set to a SHA1 hash of his password, something a little like this: `'$1$hNahKZqJ$9ul/RR2U.9ITZlKcMbOqJ.'`

{% task 6 %}
Now have a look at Byte's home directory, which was set to `'/home/byte'` by default. Directories are a special kind of file, and so Puppet would know of them as File resources. Byte's home is a directory is really just a special kind of file resource type. The `title` of any file is, by default, the same as the path to that file. Let's find out more about the `tools` directory where our sidekick can store his tools. Enter the command:

	puppet resource file /home/byte/tools
		
{% task 7 %}
What? `ensure => 'absent',`? Values of the `ensure` attribute indicate the basic state of a resource. A value of absent means something doesn't exist at all. We need to make a directory for Byte to store his tool in:

	mkdir /home/byte/tools
		
Now have another look at Byte's home directory:

	puppet resource file /home/byte/tools

{% aside Quest Progress %}
Awesome! Have you noticed when you successfully finish a task, the 'completed tasks' in the lower right corner of your terminal increases? To check on your progress type the following command:

	quest --progress

This shows your progress by displaying the tasks you've completed and tasks that still need completing.
{% endaside %}

{% task 8 %}
We want Byte to be the owner of his own tools. To do this, type the following commands:
 
	chown -R byte:byte /home/byte/tools

Inspect the state of the directory one more time, to make sure everything is in order: 

	puppet resource file /home/byte/tools

## The Resource Abstraction Layer

By now, we have seen some examples of how Puppet 'sees' resources on the system. A common pattern you might observe is that these are descriptions of *how* the resource in question should or does look like. In subsequent quests, we will see how, instead of just inspecting existing resource, we can *declare* how specific resource *should look like*, providing us the ability to model the state of these resources. 

Puppet provides us this ability to describe resources of different types of resources. Each type is a high-level model of the resource. Our job in defining how a system should be configured is reduced to one of creating a *high-level model* of the *desired state* of the system. We don't need to worry about how that is achieved.

Puppet takes the descriptions expressed by resource declarations and uses **providers** that are specific to the Operating System to realize them. These Providers abstract away the complexity of managing diverse implementations of resource types on different systems. As a whole, this system of resource types and the providers that implement them is called the **Resource Abstraction Layer**, or **RAL**.

You can describe the ideal state of a user resource. Puppet will choose a suitable provider to realize your definition - in the case of users, Puppet can use providers to manage user records in `/etc/passwd` files or `NetInfo`, or `LDAP`. Similarly, when you wish to install a package, you can stand back and watch Puppet figure out whether to use `yum` or `apt` for package management. This lets you ignore the implentation details with managing the resources, such as the names of the commands (is it `adduser` or `useradd`?) the arguments for the commands, file formats etc and lets you focus on the more important job of modeling the desired state for your systems.

By harnessing the power of the RAL, you can be confident of the potency of your Puppet skills wherever your journey takes you.


## Review

Let's rehash what we learned in this quest. First, we learned two very important Puppet topics: the Resource Abstraction Layer and the anatomy of a resource. To dive deeper into these two important topics, we showed you how to use the `puppet describe` and `puppet resource` tools, which also leads us to a better understanding Puppet's Language. These tools will be tremendously useful to you in the succeeding quests. Unfortunately we didn't get to write any Puppet code in this quest, but that's okay. We're going to start doing that in the Manifest Quest (the next quest)!

