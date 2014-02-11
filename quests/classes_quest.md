
# Classes Quest

In this quest we examine previously discussed resources and how to group them together in a **class** that can then be applied across your machines. We have seen how _resources_ are used to configure systems by a means of specifying values for corresponding attributes of the resources we want to manage. The task of configuring a machine will involve defining the attributes of several different resources, possibly of different types. Classes provide for a layer of abstraction, wherein you can group together resources.

## Resources Review

Remember when we talked about resources? Here's a refresher: Just as any individual cat or dog is a member of a species (*Felis catus* and *Canus lupis familiaris* to be precise) any instance of a resource is a member of a **resource type**. Though Puppet allows you to describe and manipulate many different resource types, the following are some of the most common: 

* `user` A user account
* `file` A specific file
* `directory` A directory of files
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job

## Defining Classes

When the Wizard Judge on Elvium convicts a system componenet that is causing harm or useless to the system, he categorizes them from the rest of the population. To do this in Elvium additional requirements are required for classifying. We can create a definition for a class of misfits called `broken users`. This class will store two broken components in Elvium. To do this:

* Users in Elvium should have their home directories in the directory `/mnt/home`
* We need to ensure that a group with the name of `operational` is present
* We also need to add the names of the users who will be members of the group `operational`
* makerbot's home directory should be `/mnt/home/makerbot`. 

      class broken users {
      
		user { 'makerbot':
		  ensure => absent,
		  gid    => 'operational',
		  home   => '/mnt/home/makerbot',	
        }
    
        user { 'frion':
		  ensure => absent,
		  gid    => 'operational',
		  home   => '/mnt/home/frion',	
        }
        
        group { 'operational':
          ensure => present,
          gid    => '1001',
        }
    
        file { '/mnt/home/':
          ensure => directory,
          mode   => '0755',
        }
    
      }  

In the above example of classifying broken users on Elvium, we **defined** a class called `broken users`, which consists of a collection of three different resources - a `user` resource, a `group` resource, and a `file` resource. The above description is both elegant, and self-documenting and 100% constructed in Puppet's DSL.

Now that we have a class called `broken users`, we can include the above class in the configuration of a machine to manage broken users in Elvium.

## Declaring Classes

In the previous section, we saw an example of a class definition and learned that a class is a collection of resoure. The question that still needs answering is, how can we use the class definition? How can we tell Puppet to _use_ the defintion as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the __*include*__ function. We already know that Puppet manifests are files with the extension ".pp" and contain code in Puppet's DSL, but new information on top of that is that it has the __*include*__ directive already built in so we can use the class(es) created in the manifest.

    include users
    
A manifest with just the single line above will apply the definition of class users to the system. But when you say, `include users` how does Puppet know where to find the class defintion? We will answer that question as you journey.

## Tasks

- Create a manifest with the following classes that does [some task]:
- Think of something can be buildable into the Module Quest (next quest)
- How can `include [resource]` be included. I will like this to be expandable in the Module Quest where multiple `include [resource]` functions will be in one manifest.

---

Module Quest

- discuss modulepath
- module structure
- declaring classes from modules `include [resource]`

---

Puppet Module Quest

- discuss the puppet module tool
- install = --version --force --environment --modulepath --ignore-dependencies
- list = --tree --version --ignore-dependencies
- search = 
- uninstall = --force
- upgrade = 
- build = 
- changes = 
- generate = 

## Supplemental Information

### Definitions
- **Class** - is a collection of resources, which, once defined, can be declared as a single unit.
- **Defining** - Defining a class makes it available by name, but doesn’t automatically evaluate the code inside it.
- **Declaring** - a class evaluates the code in the class, and applies all of its resources.
