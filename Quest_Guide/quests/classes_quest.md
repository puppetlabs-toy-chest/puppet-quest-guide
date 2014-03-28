---
title: Classes
layout: default
---

# Classes

### Prerequisites

- Resources Quest
- Mainfest Quest

## Quest Objectives

Remember when we mentioned classes in the Manifests Quest? How about the little blurb regarding enforcing a collection of resource declarations across an entire system with a single file? Those collections of resources are called **classes**. In this quest we cover the use of classes within a Puppet manifest to group resource declarations into reusable blocks of Puppet code. When you're ready to get started, type the following command:

    quest --start classes

## Defining Classes

**Defining** a class makes it available by name, but does not automatically evaluate the code inside it. Before you can use a class, you must define it by including the keyword `class` in your manifest (at the top) accompanied by a `title` for that class.

* Users should have their own home directories in the directory `/mnt/home/<user>`
* We need to ensure that a group with the name of `assistant` is present
* We also need to add the names of the users who will be members of the group `assistant`

{% highlight puppet %}
class former assistants {
  user { 'byte':
    ensure => present,
	gid    => 'assistant',
	home   => '/mnt/home/byte',	
   }
    
  user { 'bite':
    ensure => present,
    gid    => 'assistant',
    home   => '/mnt/home/bite',	
  }
        
  group { 'assistant':
    ensure => present,
    gid    => '1001',
  }

  file { '/mnt/home/':
    ensure => directory,
    mode   => '0755',
  }
}  
{% endhighlight %}

In the above example of classifying your former assistants, we **defined** a class called `former assistants`, which consists of a collection of three different resource types: `user`, `group`, and `file`. The above description is both elegant, and self-documenting and 100% constructed in Puppet's DSL.

Now that we have a class called `former assistants`, we can include the above class in the configuration of a machine to manage your former assistants. However this is just an example. A more real life use case would be applying the ntp module across your systems.

{% task 1 %}
First, let's enforce the module ntp. Type the following command

	puppet apply /root/examples/modules1-ntp1.pp

That's funny. Nothing happened. This is because the class in the `modules1-ntp1.pp` manifest is only being defined and not declared. Declared? What's that about?

{% task 2 %}
We are going to have to modify the `modules1-ntp1.pp` manifest a little to make sure Puppet applies the defined resources. Type the following command to enter the ntp manifest:

	nano /root/examples/modules1-ntp1.pp


## Declaring Classes

In the previous section, we saw an example of a class definition and learned that a class is a collection of resoures. The question that still needs answering is, how can we use the class definition? How can we tell Puppet to use the defintion as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the `include` function. We already know that Puppet manifests are files with the extension `.pp` and contain code in Puppet's DSL. In addition to Puppet's DSL the `include` directive is already built into the Puppet infrastructure so you can use class(es) in any manifest.

A manifest with the included directive of `include former assistants` will be enfored to the system. But when you say, `include former assistants` how does Puppet know where to find the class defintion? We will answer that question as you progress through the quests.

Again, a more real life use case would applying the ntp module across your systems.

{% task 3 %}
In the `modules1-ntp1.pp` manifest go ahead and add the `include` command at the very end. This will hopefully tell Puppet to apply the defined `ntp` resource.

{% task 4 %}
Go ahead and now apply the manifest `/root/examples/modules1-ntp1.pp`.

	HINT: If you need help, refer to the Manifests Quest on how to apply a manifest

Great! This time Puppet actually applied our defined ntp resource. Always remember to define first, then delcare. However, please do not ever do this above example in real life, since you may want to include classes across nodes. This is just an example to show you the functionality and benefit of classes. In the Modules Quest we will show you the proper way define classes and declare classes separately.

