
# Classes Quest

In this quest we examine previously discussed resources and how to group them together in a **class** that can then be applied across your machines. We have seen how _resources_ are used to configure systems by a means of specifying values for corresponding attributes of the resources we want to manage. The task of configuring a machine will involve defining the attributes of several different resources, possibly of different types. Classes provide for a layer of abstraction, wherein you can group together resources.

## Resources Review



## Defining Classes

Let's assume that we need to manage users on a system - this time with some additional requirements.  

* Users on the system should have their home directories in the directory `/mnt/home`
* We need to ensure that a group, with the name of `staff` is present
* We also need two users, `elmo` and `gonzo`, who are members of the group `staff`
* elmo's home directory should be `/mnt/home/elmo`. 


We can create a definition for a class called users that does all of the above, as follows:

    class users {
    
		user { 'elmo':
		  ensure => present,
		  gid    => 'staff',
		  home   => '/mnt/home/elmo',	
        }
    
        user { 'gonzo':
		  ensure => present,
		  gid    => 'staff',
		  home   => '/mnt/home/elmo',	
        }
        
        group { 'staff':
          ensure => present,
          gid    => '1001',
        }
    
        file { '/mnt/home/':
          ensure => directory,
          mode   => '0755',
        }
    
    }  

In the above, we __*define*__ a class called `users`, which is a collection of three different resources - a user resource, a group resource, and a file resource. The above description is both elegant, and self-documenting.

Now that we have a class called users, we can include the above class in the configuration of a machine to manage users on the machine.

## Declaring Classes

As we learnt earlier, a class is a collection or group of resources. In the previous section, we saw an example of a class definition. The question that needs answering now, is, how can we use the class definition? How can we tell Puppet to _use_ the defintion as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the __*include*__ keyword. By creating a puppet manifest - we already know that Puppet manifests are files with the extension ".pp" that have code in Puppet DSL - that has the include directive in it, we can use the class.

    include users
    
A manifest with just the single line above will apply the definition of class users to the system.

But when you say, `include users` how does Puppet know where to find the class defintion? We will answer that question in the next section.

## Tasks



## Supplemental Information

### Definitions
- **Class** - is a collection of resources, which, once defined, can be declared as a single unit.
