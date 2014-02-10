---
title: Resources
layout: default
---

# Welcome to Elvium: Puppet Resources

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect the state of your Virtual Machine.

## Welcome to Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

The Learning VM provides you with a separate environment from the host machine you're running it on; you can think of it as its own little world. In its way, it's not too differnt from the kind of place you'd read about in a fantasy novel or explore in an adventure game. Wander down a directory path and you'll see a landscape dotted with files and packages, home to an odd people called Users. In fact let's indulge our penchant for fantasy and give it a name suitable for the setting: Elvium. 

But what you see navigating directories and grepping files is only the surface. 

For as long as we've had the words to tell their stories, witches and sorcerors have haunted the dark woods and holed up in the high towers of our fantasies. For all their guises, these beings are alike in one way: their ability to transcend the visible world and call on mysterious forces to work their will.

Using Puppet, you can learn the ways of this strange power. If Elvium is a fantasy world, you can be its wizard: with only a few words, slay nefarious daemons, raise armies of Users, orchestrate services, and weave lasting enchantments to ensure that your will continues to be done as you kick back in your tower and have a cold potion.

<!--
Maybe include a very brief "wow" example here?
-->

## Resources

The power of a magic word is never as simple as it seems. Any wizard worth his beard has a at least a few arcane tomes lying around the tower. The pages of these books (if you can decode the cryptic runes) tell of the bonds between the syllables of a spell and the elements under its influence. An aspiring Elvian magician must learn of these things in order to type the words of power with confidence and wisdom. 

We'll begin with the fundamental set of types that Puppet uses to describe an environment: **Resources**.

## Anatomy of a Resource

Effectively wrangling resources calls for an understanding Puppet's Domain-Specific Language (DSL). Build on the Ruby programming language, this DSL can be used to describe any resource you might encounter in the Elvium environment or elsewhere. Because the Puppet DSL is a **declarative** language rather than a **procedural** one, the descriptions themselves have the power to change the state of the environment. Use the DSL to paint a picture of what you want to see, and Puppet will make it so.

Though there are many resource types that you can describe and manage with Puppet's DSL, we'll start with some essentials: 

* `user` A user account
* `file` A specific file
* `directory` A directory of files
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job

Just as any individual cat or dog is a member of a species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource is a member of a **resource type**, such as one of those listed above. Each instance is configured to match its particular function by a set of **attribute** => **value** pairs.

## Tasks

1. You already have root access, but if you ever want to walk among Elvium Users discretely, you'll need your own account. Pick out a name for yourself, and type the following command to check if it exists already.

        puppet resource user yourname

2. What, you don't exist? You'd better create a system account for yourself right away! Type the following commanad:

        useradd -r yourname

3. That was a close one. Go ahead and type the following command into the command line again:

        puppet resource user yourname
            
Great! You're alive! That was a close call. Nobody is allowed to be here and not exist in the system.

4. However, you're still in danger. Look at your `password => '!!'`. There isn't one! Set your user account password to *puppetlabs*.

5. Awesome! Inspect your user account again. Make sure there is an encrypted value for your password.

6. Everything in our world is structured. Even our root directories that house all our information are structured in an organized format. I need you to inspect your `user root` information. 

Look below at what is returned when I enter `puppet resource user root` into the command line:
 
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
* **Resource Type** - 
* **Resource Declaration** - A fragment of Puppet code that details the desired state of a resource and instructs Puppet to manage it. This term helps to differentiate between the literal resource on disk and the specification for how to manage that resource. However, most often, these are just referred to as “resources.”
* **Title** - The unique identifier of a resource or class. In a resource declaration, the title is the part after the first curly brace and before the colon. a resource’s title need not map to any actual attribute of the target system; it is only a referent. This means you can give a resource a single title even if its name has to vary across different kinds of system, like a configuration file whose location differs on Solaris.
* **Attribute** - Attributes are used to specify the state desired for a given configuration resource. Each resource type has a slightly different set of possible attributes, and each attribute has its own set of possible values. For example, a package resource would have an `ensure` attribute, whose value could be `present`, `latest`, `absent`, or a version number.
* **Value** - The value of an attribute is specified with the `=>` operator; attribute/value pairs are separated by commas.


Not all resource types are equally common or useful, so weʼve made a printable cheat sheet that explains the eight most useful types. [Download the core types cheat sheet here](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf)

The [type reference page ](http://docs.puppetlabs.com/references/latest/type.html)lists all of Puppetʼs built-in resource types, 	in 	extreme detail. It can be a bit overwhelming for a new user, but 	it 	has most of the info youʼll need in a normal day of writing Puppet code. 
