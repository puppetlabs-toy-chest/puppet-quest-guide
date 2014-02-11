---
title: Resources
layout: default
---

# Quest #4

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect [name of fantasy world].

## Puppet Resources

In the [adjective][name of fantasy world], where hardware is a thing of this past, objects of [name of fantasy world] exist with certain configurations that serve an overall importance to the greater good of the system. Imagine this world configured as a collection of many independent atomic units. We call those atomic units "resources".

These units vary in size, complexity, and lifespan. So what can a resource be in [name of fantasy world]? 

* `user` A user account
* `file` A specific file
* A directory of files (not sure?)
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job

In [name of fantasy world], we care about each the above resource types. Each serves a greater good to keeping a healthy, thriving organized system.

## Anatomy of a Resource

Exisintg in [name of fantasy world] requires an understanding the unique Domain-Specific Language (DSL) spoken. This language describes and manages resources in [name of fantasy world]. With Puppet, every resource in [name of fantasy world] is an instance of a **resource type**. These resources are uniquly identified by a **title** with **attribute** => **value** pairs.

## Tasks

1. Your Earth name is no good while you're here in [name of fantasy world]. What is your [name of fantasy world] name? Do you exist in [name of fantasy world]? Type the following command to check: 

        puppet resource user yourname

2. You don't exist! You better create a system account for yourself asap! Type the following commanad to add yourself to the [name of fantasy world] system:

        useradd -r yourname

3. That was a close one. Any unidentified resource is terminated every 30 minutes. Go ahead and type the following command into the command line again:

        puppet resource user yourname        
Great! You're alive! That was a close call. Nobody is allowed to be here and not exist in the system.

4. However, you're still in danger. Look at your `password => '!!'`. There isn't one! Set your user account password to *puppetlabs*.

5. Awesome! Inspect your user account again. Make sure there is an encrypted value for your password.

6. Everything in our world is structured. Even our root directories that house all our information are structured in an organized format. I need you to inspect your `user root` information. 

Lo
ok below at what is returned when I enter `puppet resource user root` into the command line:
 
         user {'root':
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

<!-- Carthik
- once the user has entered `puppet resource user root` in the command the display question 6a.
- once the user has entered the correct response in the command line, display question 6b.
- once the user has entered the correct response in the command line, display question 6c.
-->

>6a. In the above, what is the _type_ of the resource?  
6b. What is the _title_ of the resource?  
6c. What is the _value_ of the _attribute_ 'home'?

## Supplemental Information 

* **Resource** - A unit of configuration, whose state can be managed by Puppet. Every resource has a type (such as file, service, or user), a title, and one or more attributes with specified values (for example, an ensure attribute with a value of present). Resources can be large or small, simple or complex, and they do not always directly map to simple details on the client – they might sometimes involve spreading information across multiple files, or even involve modifying devices. For example, a service resource only models a single service, but may involve executing an init script, running an external command to check its status, and modifying the system’s run level configuration.
* **Resource Type** - High-level models of differnt kinds of resources
* **Resource Declaration** - A fragment of Puppet code that details the desired state of a resource and instructs Puppet to manage it. This term helps to differentiate between the literal resource on disk and the specification for how to manage that resource. However, most often, these are just referred to as “resources.”
* **Title** - The unique identifier of a resource or class. In a resource declaration, the title is the part after the first curly brace and before the colon. a resource’s title need not map to any actual attribute of the target system; it is only a referent. This means you can give a resource a single title even if its name has to vary across different kinds of system, like a configuration file whose location differs on Solaris.
* **Attribute** - Attributes are used to specify the state desired for a given configuration resource. Each resource type has a slightly different set of possible attributes, and each attribute has its own set of possible values. For example, a package resource would have an `ensure` attribute, whose value could be `present`, `latest`, `absent`, or a version number.
* **Value** - The value of an attribute is specified with the `=>` operator; attribute/value pairs are separated by commas.


Not all resource types are equally common or useful, so weʼve made a printable cheat sheet that explains the eight most useful types. [Download the core types cheat sheet here](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)

The [type reference page ](http://docs.puppetlabs.com/references/latest/type.html)lists all of Puppetʼs built-in resource types, 	in 	extreme detail. It can be a bit overwhelming for a new user, but 	it 	has most of the info youʼll need in a normal day of writing Puppet code. 
