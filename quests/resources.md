---
title: Resources
layout: default
---

# Puppet Resources

In this quest you will be introduced to the fundamental applications of Puppet resources and using them to inspect the state of your Virtual Machine.

## Resources

The power of a magic word is never as simple as it seems. Any wizard worth his beard has a at least a few arcane tomes lying around the tower. The pages of these books (if you can decode the cryptic runes) tell of the bonds between the syllables of a spell and the elements under its influence. As an aspirant in the mystical arts of Puppet, you must learn of these things in order to type the words of power with confidence and wisdom.

We'll begin with **resources**, the basic units that Puppet uses to describe an environment.

## Anatomy of a Resource

Know thyself, user, for you too are a resource. Use the following command to see how you look to Puppet:

	puppet resource user root
		
The output will look like this:
		
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

This block of code that describes a resource is called a **resource declaration**. It's a little abstract, but a nice portrait, don't you think? 

### Resource Type
Look at the first line of the resource declaration. The word you see before the curly brace is the **resource type**, in this case, `user`. Just as any individual cat or dog is a member of a species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource must be a member of a **resource type**.

Though Puppet allows you to describe and manipulate a great variety of resource types, the following are some of the most common: 

* `user` A user
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job

### Resource Title
After the resource type comes a curly brace and a single-quoted `title` of the resource: in your case, 'root'. (Be proud to have such a noble title!) Because the title of a resource is used to identify it, it must be unique. No two resources of the same type can share the same title.

### Attribute Value Pairs
After the colon, comes a list of **attributes** and their corresponding **values**. Each line consists of an attribute name, a `=>` (hash rocket), a value, and a final comma. For example, `home => '/root',` means that your home is set to the directory `/root`.

### Puppet DSL

In general terms, a resource declaration will match the following pattern:

	type {'title':
    	attribute => value,
    }
		
The syntax you see here is an example of Puppet's Domain-Specific Language (DSL), which is built on the Ruby programming language. Because the Puppet DSL is a **declarative** language rather than a **procedural** one, the descriptions themselves have the power to change the state of the environment. Use the DSL to paint a picture of what you want to see, and Puppet's providers will make it so.

## Tasks

The first step in mastering Puppet is to discipline your mind's eye to perceive the world around you as a collection of **resources**. This means that you will not be using resource declarations to shape your environment just yet. Instead you will exercise your power by hand and use Puppet only to inspect the consequences of your actions.


1. The path to greatness is a lonely one. Fortunately, your superuser status gives you the ability to create an assistant for yourself:

        useradd -r ralph

2. Potent stuff. Now take a look at your creation:

        puppet resource user ralph
            
	Note that Ralph's password attribute is set to `'!!'`. This isn't a proper password at all! In fact, it's a special value indicating Ralph has no password whatsoever. If he has a soul, it's locked out of his body.
	
3. Rectify the situation. Set Ralph's password to *puppetlabs*.

		passwd ralph
		
	If you take another look at `resource user ralph`, the value for his password attribute should now be set to a SHA1 hash of his password: `'$1$hNahKZqJ$9ul/RR2U.9ITZlKcMbOqJ.'`

5. Now have a look at Ralph's `home` attribute. When you created him, it was set to `'/home/ralph'` by default. His home is a `directory`, which is a special kind of the resource type `file`. The `title` of any file is the same as the path to that file. To see Ralph's home directory, enter the command:

		puppet resource file /home/ralph
		
6. What? `ensure => 'absent',`? Values of the `ensure` attribute indicate the basic state of a resource. A value of absent means it doesn't exist at all. When you created Ralph, you automatically assigned him an address, but neglected to put anything there. Do this now:

		mkdir /home/ralph
		
7. Now have another look:

		puppet resource file /home/ralph
		
8. Just one more thing. You made a home for Ralph, but he doesn't own it. The group and owner attributes are still set to your own id: '0'. Fix that, and inspect the result one more time.

		chown -R ralph:ralph /home/ralph
		
 	 	puppet resource file /home/ralph

