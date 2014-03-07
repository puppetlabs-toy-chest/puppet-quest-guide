---
title: Resources
layout: default
---

# Resources

## Quest Objectives

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect the state of your Virtual Machine. The tasks we will accomplish in this quest will help you learn more about Puppet resources. If you're ready to get started, type the following command:

    quest --start resources

## Puppet Resources

Real power, whether a spoken spell or a terminal command, is never as simple as it seems. Wizards turn to ancient tomes and grimoirs to tell of the bonds between the syllables of a spell and the elements under its influence. As an aspirant in the mystical arts of Puppet, you must learn of the connections between the syntax of Puppet and the environment around you.

We'll begin with **Resources**, the basic units that Puppet uses to describe an environment.

## Anatomy of a Resource

Know thyself, user, for you too are a resource. Use the following command to see how you look to Puppet:

	puppet resource user root
		
The output will look like this:

{% highlight ruby %}	
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

This block of code that describes a resource is called a **resource declaration**. It's a little abstract, but a nice portrait, don't you think? 

### Resource Type
Look at the first line of the resource declaration. The word you see before the curly brace is the **resource type**, in this case, `user`. Just as any individual cat or dog is a member of its species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource must be a member of a **resource type**. Think of this type as a framework that defines the range of characteristics an individual resource can have.

Though Puppet allows you to describe and manipulate a great variety of resource types, there are some core resource types you will encounter most often: 

* `user` A user
* `group` A user group
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job
* `exec` An external command
* `host` A host entry

### Resource Title
After the resource type comes a curly brace and a single-quoted `title` of the resource: in your case, 'root'. (Be proud to have such a noble title!) Because the title of a resource is used to identify it, it must be unique. No two resources of the same type can share the same title.

### Attribute Value Pairs
After the colon, comes a list of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (hash rocket), a value, and a final comma. For example, the attribute value pair `home => '/root',` indicates that your home is set to the directory `/root`.

### Puppet DSL

In general terms, a resource declaration will match the following pattern:

{% highlight ruby %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}


{% tip %}
Though a comma isn't strictly necessary at the end of the final attribute value pair, it is best practice to include it for the sake of consistency.
{% endtip %}

The syntax you see here is an example of Puppet's Domain-Specific Language (DSL), which is built on the Ruby programming language. Because the Puppet DSL is a **declarative** language rather than a **procedural** one, the descriptions themselves have the power to change the state of the environment. Use the DSL to paint a picture of what you want to see, and Puppet's providers will make it so.

The first step in mastering Puppet is to learn to understand the world around you as a collection of **resources**. You will not be using resource declarations to shape your environment just yet. Instead you will exercise your power by hand and use Puppet only to inspect the consequences of your actions.

{% Task 1 %}
The path to greatness is a lonely one. Fortunately, your superuser status gives you the ability to create an assistant for yourself:

	useradd ralph

Awesome! Did you notice that your 'completed tasks' increased to 1/6? Check on your progress to see how you're doing.

	quest --progress

This shows your progress by displaying tasks that you have completed and tasks that still need completeing.

{% Task 2 %}
Now take a look at your creation:

	puppet resource user ralph
            
Potent stuff. Note that Ralph's password attribute is set to `'!!'`. This isn't a proper password at all! In fact, it's a special value indicating Ralph has no password whatsoever. If he had a soul, it would be locked out of his body.
	
{% Task 3 %}
Rectify the situation. Set Ralph's password to *puppetlabs*.

	passwd ralph
		
If you take another look at `puppet resource user ralph`, the value for his password attribute should now be set to a SHA1 hash of his password, something a little like: `'$1$hNahKZqJ$9ul/RR2U.9ITZlKcMbOqJ.'`

{% Task 4 %}
Now have a look at Ralph's home directory. When you created him, it was set to `'/home/ralph'` by default. His home is a `directory`, which is really just a special kind of the resource type `file`. The `title` of any file is the same as the path to that file. Take a look at Ralph's home directory. Enter the command:

	puppet resource file /home/ralph/spells
		
{% Task 5 %}
What? `ensure => 'absent',`? Values of the `ensure` attribute indicate the basic state of a resource. A value of absent means it doesn't exist at all. When you created Ralph, you automatically assigned him an address, but neglected to put anything there. Do this now:

	mkdir /home/ralph/spells
		
Now have another look:

	puppet resource file /home/ralph/spells

You're on a roll! So far you have completed 5/6 tasks. Let's take a look at what you have completed so far.

	quest --brief

Almost there to officially completing your first quest!

{% Task 6 %}
Just one more thing. Ralph does not want his spells to be seen by anyone else! Let's make it so:
 
	chmod 700 /home/ralph/spells

..and inspect the result one more time:

	puppet resource file /home/ralph/spells
	 	
## The Resource Abstraction Layer

If you completed this quest, you will be familiar with the basics of resources. A great part of the utility of resources, however, is in their power to abstract away the partocularities of a system while still providing a full description of your environment. 

Our sages have long known that Elvium operates according to the rules of **CentOS**, which they call its **Operating System**. We know of distant continents, however, where the fabric of the world has a different weave; that is, there is a different Operating System.

If you find yourself on the shores of Ubuntu and croak out a `useradd`, you will be laughed right off the beach for getting it backwards; as any Ubuntu native could tell you, `adduser` is the right way to say it there. And attempting to install a package with `yum` on a system where `apt-get` is appropriate is a *faux pas* indeed.

If you aspire to extend your influence across these differing systems, it will be wise to learn a method of applying your power consistently, and resources are a key part of this puzzle.

Puppet takes the descriptions expressed by resource declarations and uses providers to implement the system-specific processes to realize them. These Providers abstract away the complexity of managing diverse implementations of resource types on different systems. As a whole, this system of resource types and the providers that implement them is called the **Resource Abstraction Layer**, or **RAL**. If you want to create a user, for instance, Puppet's RAL will abstract away the `useradd` and `adduser`, giving you a single way to do things across systems. Similarly, when you wish to install a package, you can stand back and let Puppet's providers decide whether to use `yum` or `apt-get` for package management.

By harnessing the power of the RAL, you can be confident of the potency of your Puppet skills wherever your journey takes you.