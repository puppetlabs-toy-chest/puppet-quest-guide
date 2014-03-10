---
title: Classes
layout: default
---

# Classes

### Prerequisites

- Resources Quest
- Mainfest Quest

## Quest Objectives

In this quest we cover the use **classes** to group resource declarations into reusable blocks of Puppet code. If you're ready to get started, type the following command:

    quest --start classes

## Defining Classes

When the Wizard Judge on Elvium convicts a system componenet that is causing harm or useless to the system, he categorizes them from the rest of the population. To do this in Elvium additional requirements are required for classifying. We can create a definition for a class of misfits called `broken_ops`. This class will store two broken components in Elvium. To do this:

* Users in Elvium should have their home directories in the directory `/mnt/home`
* We need to ensure that a group with the name of `operational` is present
* We also need to add the names of the users who will be members of the group `operational`
* makerbot's home directory should be `/mnt/home/maker`. 

		class broken_ops {
		  user { 'maker':
		    ensure => present,
		    gid    => 'operations',
		    home   => '/mnt/home/maker',	
          }
    
          user { 'frion':
		    ensure => present,
		    gid    => 'operations',
		    home   => '/mnt/home/frion',	
          }
        
          group { 'operations':
            ensure => present,
            gid    => '1001',
          }
    
          file { '/mnt/home/':
            ensure => directory,
            mode   => '0755',
          }
        }  

In the above example of classifying broken users on Elvium, we **defined** a class called `broken_ops`, which consists of a collection of three different resources - a `user` resource, a `group` resource, and a `file` resource. The above description is both elegant, and self-documenting and 100% constructed in Puppet's DSL.

Now that we have a class called `broken_ops`, we can include the above class in the configuration of a machine to manage broken users in Elvium.

{% Task 1 %}
Run the following command

	puppet apply /root/examples/modules1-ntp1.pp

That's funny. Nothing happened. This is because the class in the `modules1-ntp1.pp` manifest is only being defined and not declared.

{% Task 2 %}
We are going to have to modify the `modules1-ntp1.pp` manifest a little to make sure Puppet applies the defined resources. Type the following command:

	nano /root/examples/modules1-ntp1.pp


## Declaring Classes

In the previous section, we saw an example of a class definition and learned that a class is a collection of resoure. The question that still needs answering is, how can we use the class definition? How can we tell Puppet to _use_ the defintion as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the __*include*__ function. We already know that Puppet manifests are files with the extension ".pp" and contain code in Puppet's DSL, but new information on top of that is that it has the __*include*__ directive already built in so we can use the class(es) created in the manifest.

	include users
    
A manifest with just the single line above will apply the definition of class users to the system. But when you say, `include users` how does Puppet know where to find the class defintion? We will answer that question as you journey.

{% Task 3 %}
In the `modules1-ntp1.pp` manifest go ahead and add the `include` command at the very end. This will hopefully tell Puppet to apply the defined `ntp` resource.

{% Task 4 %}
Go ahead and now apply the manifest `/root/examples/modules1-ntp1.pp`.

Great! This time Puppet actually applied our defined resources. Always remember to define first, then delcare. However, please do not ever do this above example in real life, since you may want to include classes across nodes. This is just an example to show you the functionality and benefit of classes. In the Modules Quest we will show you the proper way define classes and declare classes separately.

