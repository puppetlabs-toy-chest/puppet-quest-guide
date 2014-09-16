---
title: Resources
layout: default
---

# Resources

### Prerequisites

- Welcome Quest
- Power of Puppet Quest

## Quest Objectives

- Understand how resources on the system are modeled in Puppet's Domain Specific Language (DSL).
- Use Puppet to inspect resources on your system.
- Use the Puppet Apply tool to make changes to resources on your system.
- Learn about the Resource Abstraction Layer (RAL).

## Getting Started

In this quest, you will be introduced to Resources and how system configurations are represented using Resource definitions. You will learn how to inspect and modify resources on the Learning VM using Puppet command-line tools. A thorough understanding of how the Puppet resource syntax reflects the state of a system will be an important foundation as you continue to learn the more complex aspects of Puppet and it's DSL.

When you're ready to get started, type the following command:

    quest --start resources

## Resources

Resources are the fundamental units for modeling system configurations. Each resource describes some aspect of a system and its state, like a service that should be running or a package you want installed. The block of code that describes a resource is called a **resource declaration**. These resource declarations are written in Puppet code, a Domain Specific Language (DSL) built on Ruby.

### Puppet's Domain Specific Language

When Luke Kanies was initially designing Puppet, he experimented with several languages before settling on Ruby as the best match for his vision of a transparent and readable way to model system states. 

Puppet's DSL is a *declarative* language rather than an *imperative* one. This means that instead of defining a process or set of commands, Puppet code describes (or declares) only the desired end state, and relies of built-in *providers* to deal with implementation.

Ruby's *hash* syntax provides a clean way to format this kind of declarative model, and is the basis for the *resource declarations* you'll be learning about in this quest.

A nice feature of Puppet's declarative model is that it goes both ways; that is, you can inspect the current state of any existing resource in the same syntax you would use to declare a desired state.

Using the *puppet resource* tool, take a look at your root user account.

	puppet resource user root 
	
Note the syntax of the command: *puppet resource \<type\> \<name\>*. You'll see something like the following.

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

It's a little abstract, but a nice portrait, don't you think?

### Resource Type

Let's take a look at your first line in the above resource declaration.

{% highlight puppet %}
	user { 'root':
{% endhighlight %}

The word `user`, right _before_ the curly brace, is the **resource type**.

Puppet includes a variety of built-in resource types, which allow you to manage various aspects of a system. Below are some of the core resource types you'll likely encounter most often: 

* `user` A user
* `group` A user group
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job
* `exec` An external command
* `host` A host entry

If you are curious to learn about all of the different built-in resources types available for you to manage, see the [Type Reference Document](http://docs.puppetlabs.com/references/latest/type.html) 

### Resource Title

Take another look at the first line of the resource declaration. 

{% highlight puppet %}
	user { 'root':
{% endhighlight %}

The single quoted word 'root' just before the colon is the resource **title**. Puppet uses a resource's title as a unique identifer for that resource. This means that no two resources of the same type can share a title.

### Attribute Value Pairs

Now that we've covered the *type* and *title*, take a look at the body of the resource declaration.

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

After the colon in that first line comes a hash of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (pronounced 'hash rocket'), a value, and a final comma. For instance, the attribute value pair `home => '/root',` indicates that your home is set to the directory `/root`.

So to bring this all together, a resource declaration will match the following pattern:

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside The Trailing Comma %}
Though the comma at the end of the final attribute value pair isn't strictly necessary, it is best practice to include it for the sake of consistency. Leave it out, and you'll inevitably forget to insert it when you add another attribute value pair on the following line.
{% endaside %}

So in the world of Puppet, you and everything around you can be respresented as a resource, and resources follow a nice declarative syntax. But what if you want to change something? 

You can, and easily. But before making any changes, take a moment to learn a bit more about the user type. You'll want a way of knowing *what* you're changing before you start changing attributes. Use the *puppet describe* tool to get a description of the *user* type, including a list of its parameters.

	puppet describe user | less
	
No need to read all the way through, but take a minute to skim the *describe* page for the *user* type. Notice the documentation for some of the attributes you saw for the *root* user.
	
You can use the Puppet resource declaration syntax with the *puppet apply* tool to make quick changes to resources on the system. (Note, though, that while *puppet apply* is great for tests and exploration, it's limited to this kind of one-off change. We'll get to the more robust ways to manage resources in later quests.)

You can use the *puppet apply* tool with the *-e* (*--execute*) flag to execute a bit of Puppet code. In this example, you'll create a new user called *galatea*. Puppet uses some defaults for unspecified user attributes, so all you'll need to do to create a new user is set the 'ensure' attribute to 'present'. This 'present' value tells Puppet to check if the resource exists on the system, and to create the specified resource if it does not.

	puppet apply -e "user { 'galatea': ensure => 'present', }"

Use the `puppet resource` tool to take a look at user *galatea*. Type the following command:

	puppet resource user galatea

Notice that while the *root* user had a *comment* attribute, Puppet hasn't created one for your new user. As you may have noticed looking over the *puppet describe* entry for the user type, this *comment* is generally the full name of the account's owner.

While puppet apply with the `-e` flag can be handy for quick one-liners, you can pass an `--execute` (incidentally, also shortened to `-e`) flag to the `puppet resource` tool to edit and apply changes to a resource.

	puppet resource -e user galatea
	
You'll see the same output for this resource as before, but this time it will be opened in a text editor (vim, by default). To add a *comment* attribute, insert a new line to the resource's list of attribute value pairs:

	comment => 'Galatea of Cyprus',
	
Save and exit (`:wq` in vim), and the resource declaration will be applied with the added comment. If you like, use the `puppet resource` tool again to inspect the result.

{% aside Quest Progress %}
Have you noticed that when you successfully finish a task, the 'completed tasks' in the lower right corner of your terminal increases? Remember, you can also check your progress by entering the following command:

	quest --progress

{% endaside %}

## The Resource Abstraction Layer

As we mentioned at the beginning of this quest, Puppet takes the descriptions expressed by resource declarations and uses *providers* specific to the operating system to realize them. These providers abstract away the complexity of managing diverse implementations of resource types on different systems. As a whole, we call this system of resource types and providers the **Resource Abstraction Layer**, or **RAL**.

In the case of users, Puppet can use providers to manage users with LDAP, Windows ADSI, AIX, and several other providers depending on a node's system. Similarly, when you wish to install a package, you can stand back and watch Puppet figure out whether to use 'yum', 'apt', 'rpm', or one of several other providers for package management. This lets you ignore the implementation-related details of managing the resources, such as the names of the commands (is it `adduser` or `useradd`?), arguments for the commands, and file formats, and lets you focus on the end result.

By harnessing the power of the RAL, you can be confident of the potency of your Puppet skills wherever your journey takes you.

## Review

So let's rehash what you learned in this quest. First, we covered two very important Puppet topics: the Resource Abstraction Layer and the anatomy of a resource. To dive deeper into these two important topics, we showed you how to use the `puppet describe` and `puppet resource` tools, which also leads to a better understanding of Puppet's Language. These tools will be tremendously useful to you in the following quests.

