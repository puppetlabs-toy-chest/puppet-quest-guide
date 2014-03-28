---
title: Resources
layout: default
---

# Resources

## Quest Objectives

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect the state of your Virtual Machine. The tasks we will accomplish in this quest will help you learn more about Puppet resources. When you're ready to get started, type the following command:

    quest --start resources

## Puppet Resources

As an aspiring practitioner of Puppet, it is important for you to have a thorough understanding of the relationship between the syntax of Puppet and the environment around you. We'll begin with **Resources**, the basic units that Puppet uses to describe an environment.

## Domain Specific Language (DSL)

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside The Comma %}
Though a comma isn't strictly necessary at the end of the final attribute value pair, it is best practice to include it for the sake of consistency.
{% endaside %}

The syntax you see here is an example of Puppet's Domain-Specific Language (DSL), which is built on the Ruby programming language. Because the Puppet DSL is a **declarative** language the descriptions themselves have the power to change the state of the environment.

The first step in mastering Puppet is to learn about the world around. You will so realize everything is a collection of **resources**. You will not be using resource declarations to shape your environment just yet. Instead you will exercise your power by hand and use Puppet only to inspect your actions.

## Anatomy of a Resource

Resources can be large or small, simple or complex. In the world of Puppet, you too are a resource.

{% task 1 %}
What do you look like? Use the following command to check it out:

	puppet resource user root
		
The output will look like this:

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

The block of code above that describes the `user` resource is called a **resource declaration**. It's a little abstract, but a nice portrait, don't you think? 

### Resource Type

Let's take a look at the first line in the above example resource declaration. Do you see the word `user`? It's right _before_ the curly brace. This is called the **resource type**. Just as any individual cat or dog is a member of its species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource must be a member of a **resource type**. Think of this type as a framework that defines the range of characteristics an individual resource can have.

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

Again, let's take a look at the first line in the above resource declaration. Do you see the single quoted word `'root'`? It's right _after_ the curly brace. This is called the **title**. The title of a resource is used to identify it, it must be unique. No two resources of the same type can share the same title. Also, don't forget to always add a colon (:) after the title.

{% task 2 %}
The path to greatness is a lonely one. Fortunately, your superuser status gives you the ability to create an assistant for yourself. First let's do this in a non-Puppet way. Type the following command:

	useradd ralph

{% task 3 %}
Now take a look at your new assistant. Type the following command:

	puppet resource user ralph
            
Potent stuff. Note that Ralph's password attribute is set to `'!!'`. This isn't a proper password at all! In fact, it's a special value indicating Ralph has no password whatsoever.

### Attribute Value Pairs

One more time. Let's look at the above resource declaration. After the colon, comes a list of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (hash rocket), a value, and a final comma. For example, the attribute value pair `home => '/root',` indicates that your home is set to the directory `/root`.
	
{% task 4 %}
Rectify the Ralph's password situation by setting it to *puppetlabs*.

	passwd ralph
		
If you take another look at `puppet resource user ralph`, the value for his password attribute should now be set to a SHA1 hash of his password, something a little like this: `'$1$hNahKZqJ$9ul/RR2U.9ITZlKcMbOqJ.'`

{% task 5 %}
Now have a look at Ralph's home directory. When you created him, it was set to `'/home/ralph'` by default. His home is a `directory`, which is really just a special kind of the resource type `file`. The `title` of any file is the same as the path to that file. Take a look at Ralph's home directory. Enter the command:

	puppet resource file /home/ralph/assistant
		
{% task 6 %}
What? `ensure => 'absent',`? Values of the `ensure` attribute indicate the basic state of a resource. A value of absent means it doesn't exist at all. When you created Ralph, you automatically assigned him an address, but neglected to put anything there. Do this now:

	mkdir /home/ralph/assistant
		
Now have another look:

	puppet resource file /home/ralph/assistant

Awesome! Have you noticed when you successfully finsihed a task the 'completed tasks' increases? Check on your progress to see how you're doing. Type the following command:

	quest --progress

This shows your progress by displaying tasks that you have completed and tasks that still need completeing.

You're almost there to officially completing your first quest!

{% task 7 %}
Just one more thing. We do not want Ralph to be an assistant to anyone else! Let's make it so:
 
	chmod 700 /home/ralph/assistant

..and inspect the result one more time:

	puppet resource file /home/ralph/assistant

## The Resource Abstraction Layer

A great part of the utility of resources is in their power to abstract away the particularities of a system while still providing a full description of your environment. 

Puppet takes the descriptions expressed by resource declarations and uses providers to implement the system-specific processes to realize them. These Providers abstract away the complexity of managing diverse implementations of resource types on different systems. As a whole, this system of resource types and the providers that implement them is called the **Resource Abstraction Layer**, or **RAL**.

If you want to create a user, for instance, Puppet's RAL will abstract away the `useradd` and `adduser`, giving you a single way to do things across systems. Similarly, when you wish to install a package, you can stand back and let Puppet's providers decide whether to use `yum` or `apt-get` for package management.

By harnessing the power of the RAL, you can be confident of the potency of your Puppet skills wherever your journey takes you.