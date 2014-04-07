---
title: Classes
layout: default
---

# Classes

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest

## Quest Objectives

So we've mentioned the term classes in previous quests. Remember that little blurb regarding enforcing a collection of resource declarations across an entire system with a single file? That collection of resources is called a **class**. In this quest we cover the use of classes within a Puppet manifest to group resource declarations into reusable blocks of Puppet code. When you're ready to get started, type the following command:

    quest --start classes

{% aside This is just an example %}
This quest only exists to show you the functionality and benefit of classes. Please do not ever do this example in real life, since you may want to include classes across multiple nodes. In the Modules Quest we will show you the proper way define classes and declare classes separately.
{% endaside %}

## Defining Classes

**Defining** a class makes it available by name, but does not automatically evaluate the code inside it. Before you can use a class, you must define it by including the keyword `class` in your manifest (at the top) accompanied by a `title` for that class.

* Users should have their own home directories in the directory `/mnt/home/<user>`
* We need to ensure that a group with the name of `sidekick` is present
* We also need to add the names of the users who will be members of the group `sidekick`

{% highlight puppet %}
class former sidekicks {
  user { 'byte':
    ensure => present,
	gid    => 'sidekick',
	home   => '/mnt/home/byte',	
   }
    
  user { 'kilobyte':
    ensure => present,
    gid    => 'sidekick',
    home   => '/mnt/home/kilobyte',	
  }
        
  group { 'sidekick':
    ensure => present,
    gid    => '1001',
  }

  file { '/mnt/home/':
    ensure => directory,
    mode   => '0755',
  }
}  
{% endhighlight %}

In the above example we **defined** a class called `former sidekicks`, which consists of classifying your former sidekicks as a collection of three different resource types: `user`, `group`, and `file`. The above description is both elegant, self-documenting, and 100% constructed in Puppet's DSL.

Now that we have a class called `former sidekicks`, we can include the above class in the configuration of a machine to manage your former sidekicks. However, this is just an example. A more real life use case would be applying the ntp module across your systems.

{% task 1 %}
First, just as we enforced manifests in the Manifest Quest, let's enforce the module ntp.

	puppet apply /root/examples/modules1-ntp1.pp

That's funny. Nothing happened. This is because the class in the `modules1-ntp1.pp` manifest is only being defined and not declared. Declared? What's that? We will discuss that in the section below.

{% task 2 %}
We are going to have to modify the `modules1-ntp1.pp` manifest a little to make sure Puppet applies the defined resources. Type the following command to edit the ntp manifest:

	nano /root/examples/modules1-ntp1.pp

{% aside Text Editors %}
Remember, for the sake of simplicity and consistency, we use the text editor nano in our instructions, but feel free to use vim or another text editor of your choice.
{% endaside %}

## Declaring Classes

In the previous section, we saw an example of a class definition and learned that a class is a collection of resources. The question that still needs answering is, how can we use the class definition? How can we tell Puppet to use the definition as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the `include` directive. We already know that Puppet manifests are files with the extension `.pp` and contain code in Puppet's DSL. In addition to Puppet's DSL, the `include` directive is already built into the Puppet infrastructure so you can use class(es) in any manifest.

But when you say `include former sidekicks`, how does Puppet know where to find the class definition? We will answer that question as you progress through this quest and future quests.

Again, a more real life use case would applying the ntp module across your system.

{% task 3 %}
In the `modules1-ntp1.pp` manifest go ahead and add the `include ntp` directive at the very end. Make sure it is outside of the curly braces. This will hopefully tell Puppet to apply the defined `ntp` resource. 

{% task 4 %}
Go ahead and now enforce the manifest `/root/examples/modules1-ntp1.pp`.

	HINT: Use the puppet apply tool. Refer to the Manifests Quest.

Great! This time Puppet actually applied our defined ntp resource. Always remember to define first, then declare.

Again, please do not ever do this above example in real life, since you may want to include classes across multiple nodes. This is just an example to show you the functionality and benefit of classes. In the Modules Quest we will show you the proper way define classes and declare classes separately.

