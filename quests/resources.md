---
title: Resources
layout: default
---

# Welcome to Elvium: Puppet Resources

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect the state of your Virtual Machine.

## Welcome to Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to Elvium, user. Have a look around. Walk down a directory path and admire our landscape. Wander the verdant forests of files and hear the clamor of bustling services. But take note: what you see now is only the surface. The real channels of power in Elvium lie deeper, in the very bones of the kingdom, and you must learn of these things. You see, you are not an ordinary user, for you have been born into the Elvium with a user id of '0', the fabled mark of **Root**.

In recognition of this auspicious sign, the venerable council of Sudoers has seen fit to present you with this Quest Guide.

If you choose to follow the path set forth herein, you will learn to channel your abilities by using the art of Puppet. With only a few words, slay nefarious daemons, raise armies of users, orchestrate magnificent services, and, most importantly, weave your power into abiding enchantments to ensure that your will continues to be done in Elvium as you journey out to bring other kingdoms into your dominion.

<!--
Maybe include a very brief "wow" example here?
-->

## Resources

The power of a magic word is never as simple as it seems. Any wizard worth his beard has a at least a few arcane tomes lying around the tower. The pages of these books (if you can decode the cryptic runes) tell of the bonds between the syllables of a spell and the elements under its influence. As an aspirant in the mystical arts of Puppet, you must learn of these things in order to type the words of power with confidence and wisdom.

We'll begin with **resources**, the fundamental set of types that Puppet uses to describe an environment.

## Anatomy of a Resource

Just as any individual cat or dog is a member of a species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource is a member of a **resource type**. Though Puppet allows you to describe and manipulate many different resource types, the following are some of the most common: 

* `user` A user account
* `file` A specific file
* `directory` A directory of files
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job

Each individual instance of a resource type is configured to match its particular function by a set of **attribute** => **value** pairs.



The syntax you see here is an example of Puppet's Domain-Specific Language (DSL). Build on the Ruby programming language, this DSL can be used to describe any resource you might encounter in the Elvium environment or elsewhere. Because the Puppet DSL is a **declarative** language rather than a **procedural** one, the descriptions themselves have the power to change the state of the environment. Use the DSL to paint a picture of what you want to see, and Puppet's providers will make it so.

## Tasks

1. Check out your user information.

        puppet resource user root
        
>1a. In the above, what is the _type_ of the resource?  
1b. What is the _title_ of the resource?  
1c. What is the _value_ of the _attribute_ 'home'?

<!-- Carthik
- once the user has entered `puppet resource user root` in the command the display question 6a.
- once the user has entered the correct response in the command line, display question 6b.
- once the user has entered the correct response in the command line, display question 6c.
-->

2. You might get lonely. To help you out, let's make an assistant:

        useradd -r ralph

3. That was a close one. Go ahead and type the following command into the command line again:

        puppet resource user ralph
            
	Great! You're alive! That was a close call. Nobody is allowed to be here and not exist in the system.

4. However, you're still in danger. Look at your `password => '!!'`. There isn't one! Set your user account password to *puppetlabs*.

		passwd ralph

5. Awesome! Inspect your user account again. Make sure there is an encrypted value for your password.



## Supplemental Information 

* **Resource** - A unit of configuration, whose state can be managed by Puppet. Every resource has a type (such as file, service, or user), a title, and one or more attributes with specified values (for example, an ensure attribute with a value of present). Resources can be large or small, simple or complex, and they do not always directly map to simple details on the client – they might sometimes involve spreading information across multiple files, or even involve modifying devices. For example, a service resource only models a single service, but may involve executing an init script, running an external command to check its status, and modifying the system’s run level configuration.
* **Resource Type** - 
* **Resource Declaration** - A fragment of Puppet code that details the desired state of a resource and instructs Puppet to manage it. This term helps to differentiate between the literal resource on disk and the specification for how to manage that resource. However, most often, these are just referred to as “resources.”
* **Title** - The unique identifier of a resource or class. In a resource declaration, the title is the part after the first curly brace and before the colon. a resource’s title need not map to any actual attribute of the target system; it is only a referent. This means you can give a resource a single title even if its name has to vary across different kinds of system, like a configuration file whose location differs on Solaris.
* **Attribute** - Attributes are used to specify the state desired for a given configuration resource. Each resource type has a slightly different set of possible attributes, and each attribute has its own set of possible values. For example, a package resource would have an `ensure` attribute, whose value could be `present`, `latest`, `absent`, or a version number.
* **Value** - The value of an attribute is specified with the `=>` operator; attribute/value pairs are separated by commas.


Not all resource types are equally common or useful, so weʼve made a printable cheat sheet that explains the eight most useful types. [Download the core types cheat sheet here](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)

The [type reference page ](http://docs.puppetlabs.com/references/latest/type.html)lists all of Puppetʼs built-in resource types, 	in 	extreme detail. It can be a bit overwhelming for a new user, but 	it 	has most of the info youʼll need in a normal day of writing Puppet code. 
