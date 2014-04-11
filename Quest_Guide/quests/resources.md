---
title: Resources
layout: default
---

# Resources

### Prerequisites

- Welcome Quest
- Power of Puppet Quest

## Quest Objectives

- Acquire a clear understanding of Puppet syntax
- Acquire a clear understanding of the Resource Abstraction Layer (RAL)
- Confidently use Puppet tools to inspect resources on your system
- Acquire a clear understanding on how a resource looks in Puppet

## Getting Started

In this quest you will be introduced to the fundamental applications of inspecting the state of Puppet resources on this Learning VM. Please note though, we are not going to use Puppet to create resources. We're going to use basic Unix commands in this quest. We are only going to use Puppet to inspect resources we create. As an aspiring practitioner of Puppet, it is important for you to have a thorough understanding of the Puppet syntax as well as the `puppet resource` and `puppet describe` tools. When you're ready to get started, type the following command:

    quest --start resources

## Domain Specific Language (DSL)

The syntax you see below is an example of Puppet's Domain-Specific Language (DSL), which is built on the Ruby programming language. Because the Puppet DSL is a **declarative** language, the descriptions themselves have the power to change the state of the environment. One thing to note here, and pay close attention to, is the readability of the code structure. At a glance, Puppet's DSL allows you to decipher tasks with relative ease.

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside The Comma %}
Though a comma isn't strictly necessary at the end of the final attribute value pair, it is best practice to include it for the sake of consistency.
{% endaside %}

The first step in mastering Puppet is to learn about the world around you. You will also realize everything in this Learning VM is a collection of **resources**. You will not be using resource declarations to shape your environment just yet. Instead you will exercise your power by hand and use Puppet only to inspect your actions using the `puppet resource` and `puppet describe` tools.

## The Resource Abstraction Layer

A great part of the utility of resources is in their power to abstract away the particularities of a system while still providing a full description of your environment. 

Puppet takes the descriptions expressed by resource declarations and uses providers to implement the system-specific processes to realize them. These Providers abstract away the complexity of managing diverse implementations of resource types on different systems. As a whole, this system of resource types and the providers that implement them is called the **Resource Abstraction Layer**, or **RAL**.

If you want to create a user, Puppet's RAL will abstract away the `useradd` and `adduser`, giving you a single way to do things across systems. Similarly, when you wish to install a package, you can stand back and let Puppet's providers decide whether to use `yum` or `apt-get` for package management.

By harnessing the power of the RAL, you can be confident of the potency of your Puppet skills wherever your journey takes you.

## Anatomy of a Resource

Resources can be large or small, simple or complex. In the world of Puppet, you and everything around you are resources. But let's say you wanted to learn more about a particular resource. How would one do that? Well, you have two options: `puppet describe` and `puppet resource`.

{% task 1 %}
Let's say you want to learn more about the `user` resource type as it applies to all users in the Learning VM. You would need to type the following command:

	puppet describe user

The `puppet describe` command can list info about the currently installed resource types on a given machine.

{% task 2 %}
Great! But how would one look at a specific resource? Well, to check and see how you look in the world of Puppet type the following command :

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

One more time. Let's look at your above resource declaration, this time examine the body. After the colon (:) comes a list of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (hash rocket), a value, and a final comma. For example, the attribute value pair `home => '/root',` indicates that your home is set to the directory `/root`.
	
{% task 5 %}
Let's rectify Byte's password situation by setting it to *puppetlabs*. Type the following command:

	passwd byte
		
If you take another look at Byte using `puppet resource`, the value for Byte's password attribute should now be set to a SHA1 hash of his password, something a little like this: `'$1$hNahKZqJ$9ul/RR2U.9ITZlKcMbOqJ.'`

{% task 6 %}
Now have a look at Byte's home directory, which was set to `'/home/byte'` by default. Byte's home is a directory is really just a special kind of file resource type. The `title` of any file has to be the same as the path to that file. Enter the command:

	puppet resource file /home/byte/tools
		
{% task 7 %}
What? `ensure => 'absent',`? Values of the `ensure` attribute indicate the basic state of a resource. A value of absent means something doesn't exist at all. When you created Byte, you automatically assigned an address, but neglected to put anything there. We need to make a directory for Byte to exist:

	mkdir /home/byte/tools
		
Now have another look at Byte's home directory:

	puppet resource file /home/byte/tools

{% aside Quest Progress %}
Awesome! Have you noticed when you successfully finish a task, the 'completed tasks' in the lower right corner of your terminal increases? To check on your progress type the following command:

	quest --progress brief

This shows your progress by displaying the tasks you've completed and tasks that still need completing.
{% endaside %}

{% task 8 %}
We do not want Byte's tools to be available to anyone else. We need to make Byte's permissions exclusive. To do this, type the following command:
 
	chmod 700 /home/byte/tools

Inspect the result one more time to make sure Byte has been constructred properly.

	puppet resource file /home/byte/tools

## Review

Let's rehash what we learned in this quest. First, we learned two very important Puppet topics: the Resource Abstraction Layer (RAL) and the anatomy of a resource. To dive deeper into these two important topics, we showed you how to use the `puppet describe` and `puppet resource` tools, which also leads us to a textual understanding Puppet's Domain-Specific Language (DSL). If you only remember one thing from this quest, make sure it's a clear understanding between these two tools. We'll be routinley referring back to them in future quests. Unfortunately we didn't get to write any Puppet code in this quest, but that's okay. We're going to in the Manifest Quest (the next quest)!
