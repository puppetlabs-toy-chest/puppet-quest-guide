---
title: The Learning Virtual Machine (VM)
layout: default
---

## The Learning Virtual Machine (VM)

If you want to learn more about Puppet or are a new user of Puppet or just looking to have fun exploring Puppet, then you've come to the right place. This is our free downloadable Learning VM for you to play around with and explore. The Learning VM is a companion to our Puppet Quests a few sections below, which are a series of tutorials about the Puppet language and using its various tools. Although, please keep in mind that this Learning VM focuses on using Puppet Enterprise at its core, but most of the quests can also apply to Puppet open source.


## Learning Puppet

So what is Puppet? Great question! Puppet is a versatile tool for managing your servers. You simply describe your machine configurations in an easy-to-read declarative language (such as Ruby), and Puppet will ensure that your systems conform to and stay in that desired state.

Associated with this Learning VM are a series of quest adventures that will teach you about about managing your systems with Puppet. These quests start out very basic to accommodate all users no matter your experience level. Essentially, we provide everyone a level starting point to build from. From there, its up to you how much you want to learn and what exactly you want to learn. We hope that this will be the beginning of an interesting journey towards automating your systems management efforts.

## The Quest Structure

The individual quest design is very simple in its structure and consists of three parts.

1. An introduction to the quest as it relates to Puppet
2. A themed storyline of the quest and how Puppet fits in.
3. Going on your quest adventure! (Applying what your knowledge in the Learning VM!)

In the below example quest (you don't need to do anything), in order to understand how Puppet is useful and can be leveraged to simplify configuration management, we will automate a task with Puppet. This is an example quest:

__*Quest*__: 

>Let's assume that you work as an engineer in a web-development firm. You are tasked with configuring Virtual Machines for use by web developers. You are given a list of requirements, such as:  

>* the usernames of the web developers 
* a list of one of more user groups
* a list of files and directories that should be present on the machine  
* a list of software packages that should be installed on the machine 
* a website served by the Apache2 webserver
* a database that should be present on the machine

Each of the above steps are tasks within this quest that you will need to complete.

In the above example you _could_ manually configure the Learning VM by completing a list of tasks each time you need a VM. However, I have a feeling you'll soon realize that this manual process boils down to repeating the same set of tasks over and over again. In addition, you're not even using Puppet, so there really is no point for you to continue.

In relation to this example, we will teach you how to use Puppet to _describe_ your requirements to configure the VM appropriately and automate the process of configuring all the other VM's correctly and quickly.

### Ready to start your [Quest #1](docs.puppetlabs.com/learning) adventure? 



========
<div class="page-break"></div>

## Classes and Modules

We have seen how there are _resources_ and how we seek to configure systems by means of specifying the values for the attributes of the resources we want to manage. The task of configuring a machine will involve defining the attributes of several different resources, possibly of different types. Classes provide for a layer of abstraction, wherein you can group together resources.

A __Class__ in Puppet is a collection of resources, which, once defined, can be declared as a single unit.  

### Defining Classes

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

### Declaring classes

As we learnt earlier, a class is a collection or group of resources. In the previous section, we saw an example of a class definition. The question that needs answering now, is, how can we use the class definition? How can we tell Puppet to _use_ the defintion as part of configuring a system?

You can direct Puppet to apply a class definition on a system by using the __*include*__ keyword. By creating a puppet manifest - we already know that Puppet manifests are files with the extension ".pp" that have code in Puppet DSL - that has the include directive in it, we can use the class.

    include users
    
A manifest with just the single line above will apply the definition of class users to the system.

But when you say, `include users` how does Puppet know where to find the class defintion? We will answer that question in the next section.

### Modules
A Puppet __*module*__ is a collection of class definitions, file, template etc, organized around a particular purpose. In order to enable Puppet to find the class definitions, manifests that allow one to test the class defintions, files that may be required, etc that it may need to configure a machine for a particular purpose, we adhere to a consistent directory structure in which we place class definitions, any files that are needed etc.
All the modules are placed in a special directory specified by the __*modulepath*__.
The modulepath is setting that can be defined in Puppet configuration file. Puppet's configuration file exists in the directory `/etc/puppetlabs/puppet/puppet.conf` on the Learning VM.
You can also find the modulepath by means of the following command:
    puppet agent --configprint modulepath
Try running that command on the Learning Puppet VM now, and confirm that it returns the following value:
`/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules`
What the above tells us is that Puppet will look in the directories `/etc/puppetlabs/puppet/modules` and then in `/opt/puppet/share/puppet/modules` to find the modules in use on the system.

#### Module directory structure	
Modules are directories with a pre-defined structure, with class definitions, files etc in specific sub-directories. 
Inside a module, manifests with class definitions are always placed in a directory called __*manifests*__. A class with the same name as the module is defined in a file called __*init.pp*__.
> Let's create our first module!
> In the Learning VM, change to the `/etc/puppetlabs/puppet/modules/` directory, by running the following command:  
>        cd /etc/puppetlabs/puppet/modules/> Let's create our module directory structure by executing the following command:
>        mkdir -pv users/{manifests,tests}
> This creates a directory called users, with two directories called manifests and tests within it.
> Now let's create the definition of class users:
> Using a text editor (nano, vim, or emacs - depending on your preference), create a file called `init.pp` in the manifests directory:
>        vim manifests/init.pp
> For the content of the file, type in the definition of class users described earlier, also provided below:

>        class users {
>    
>    		user { 'elmo':
>    		  ensure => present,
>    		  gid    => 'staff',
>    		  home   => '/mnt/home/elmo',	
>          }
>    
>           user { 'gonzo':
>		      ensure => present,
>    		  gid    => 'staff',
>  		      home   => '/mnt/home/elmo',	
>          }
>        
>           group { 'staff':
>             ensure => present,
>             gid    => '1001',
>           }
>    
>           file { '/mnt/home/':
>             ensure => directory,
>             mode   => '0755',
>           }
>      
>        }  
> Save the file after adding the above content.
> Now let's create a test, to enable us to apply the class definition:
> Using the text editor of your choice, create a file called `init.pp` in the tests directory now:
>        vim tests/init.pp
> For the content of the file, use the following:
>        include users
Great! Now we have a module called `users`!
Let's try and manage the resources defined in class users. It's as simple as using `puppet apply` to apply our test:
>  Run the following command:
>  puppet apply tests/init.pp

> You should see something similar to the following as the output:

>        Notice: /Stage[main]/Users/File[/mnt/home/]/ensure: created
>        Notice: /Group[staff]/ensure: created
>        Notice: /User[elmo]/ensure: created
>        Notice: /User[gonzo]/ensure: created
>        Notice: Finished catalog run in 0.40 secondsThat's it, we just created our first Puppet module - a module that creates users to meet our requirements.
The two important things to note here are:
1.  Puppet's DSL, by virtue of its __declarative__ nature, makes it possible for us to define the attributes of the resouces, without the need to concern ourselves with _how_ the definition is enforced. Puppet uses the Resource Abstraction Layer to abstract away the complexity surrounding the specific commands to be executed, and the operating system-specific tools used to realize our definition! You did not need to know or specify the command to create a new unix user group to create the group `staff`, for example.
2. By creating a class called users, it is now possible for us to automate the process of creating the users we need on any system with Puppet installed on it, by simply including that class on that system. Class definitions are reusable!
======== 
<div class="page-break"></div>

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the puppet community for Puppet Open Source and Puppet Enterprise IT automation software. Modules available on the forge simplify the process of managing your systems. These modules will provide you with classes and new resource types to manage the various aspects of your infrastructure. So your task is reduced from that of describing the classes using Puppet's DSL to one of _using_ an existing description with the right options.
 
### The puppet module tool

Puppet also provide a module tool to help you download, install, list and manage modules from the forge.

For example:

> Run the command:
> puppet module list

This should list the modules currently installed on the system in the following format:

    /etc/puppetlabs/puppet/modules (no modules installed)
    /opt/puppet/share/puppet/modules
    ├── cprice404-inifile (v0.10.3)
    ├── puppetlabs-apt (v1.1.0)
    ├── puppetlabs-auth_conf (v0.1.6)
    ├── puppetlabs-firewall (v0.3.0)
    ├── puppetlabs-java_ks (v1.1.0)
    ├── puppetlabs-pe_accounts (v2.0.1)
    ├── puppetlabs-pe_common (v0.1.0)
    ├── puppetlabs-pe_mcollective (v0.1.13)
    ├── puppetlabs-pe_postgresql (v0.0.4)
    ├── puppetlabs-pe_puppetdb (v0.0.9)
    ├── puppetlabs-postgresql (v2.3.0)
    ├── puppetlabs-puppet_enterprise (v3.0.1)
    ├── puppetlabs-puppetdb (v1.5.1)
    ├── puppetlabs-request_manager (v0.0.9)
    ├── puppetlabs-stdlib (v3.2.0)
    └── ripienaar-concat (v0.2.0)

You can also search for, and install modules


With regards to things that we need to manage on our current VM, we can accelerate the process of defining the configuration for our machines using modules from the forge.

For example, to configure the test machine for our web-developers, we will need to install, configure, and manage the Apache2 webserver to serve web pages. So let us search for a module to manage the Apache2 webserver.

> Run the command:
> puppet module search apache

This should return something similar to the following:

    Notice: Searching https://forge.puppetlabs.com ...
    NAME                   DESCRIPTION         AUTHOR          KEYWORDS 
    5UbZ3r0-httpd          This module han...  @5UbZ3r0        apache   
    7terminals-ant         The Apache Ant ...  @7terminals     apache   
    7terminals-maven       Puppet module t...  @7terminals     apache  
    puppetlabs-apache      Puppet module f...  @puppetlabs     apache
    vStone-apache          Manage apache a...  @vStone         apache,  
    zeleznypa-xhgui        The XHGui modul...  @zeleznypa      apache 

You can also search at the [Forge website](http://forge.puppetlabs.com). If you do so, you will a list on the results page:
[Results for a search for the apache module.](https://forge.puppetlabs.com/modules?q=apache)
 
Now, we can install the module we need. Let's install puppetlabs-apache.

> Run the command:
> puppet module install puppetlabs-apache.

This should return the following:

    Notice: Preparing to install into /etc/puppetlabs/puppet/modules ...
    Notice: Downloading from https://forge.puppetlabs.com ...
    Notice: Installing -- do not interrupt ...
    /etc/puppetlabs/puppet/modules
    └─┬ puppetlabs-apache (v0.9.0)
      └── puppetlabs-concat (v1.0.0)
      
### Using Modules from the Forge

Now that the apache module is installed in our `modulepath`, let's look at how we might use it!

One way to get started using the module is to inspect the code written in Puppet DSL that is in the module's manifests directory at:
`/etc/puppetlabs/puppet/modules/apache/manifests`

However, there is an easier way to do this for well-written modules that include documentation. Let's begin by visiting the [page for the apache module on the puppet forge](https://forge.puppetlabs.com/puppetlabs/apache).

The documentation on the page provides us insight into how to use the class definitions provided in the module to accomplish several tasks. For example, if we wanted to install apache with the default options, the module documentation suggests we can do it as follows:

    class { 'apache':  }
    
It's as simple as that! So if we wanted our machine to have apache installed on it, all we need to do is ensure that the above _class declaration_ is in some manifest that applies to our node. We can also use the Puppet Enterprise Console to apply the class to our node.

What if we wanted to configure the default website served by Apache? The documentation tells us that we can use the following code to achieve that:

    apache::vhost { 'first.example.com':
          port    => '80',
          docroot => '/var/www/first',
    }

This leverage a _Defined Resource Type_ called `apache::vhost` that helps us create virtual hosts in Apache.

As you can see in the above, you can specify the port Apache listens on by changing the value for the parameter `port` in the above sample, to be the port you need Apache to listen on. 
## Quest - Automated Test Machine ConfigurationThe Quest in the motivating example requires us to configuring a machine foe web developers. Let's see what we need to do, with more details, this time.


### Problem DescriptionLet's assume that you work as an engineer in a web development agency. You are tasked with configuring Virtual Machines for use by web developers to test their websites. You are given a detailed list of requirements.
> Requirements:

> When configured, the system will provide web developers with a base system with the pre-requisite packages installed, with the user accounts and directories created.

> The system needs to have:

>* A user called `webtest` whose primary group (gid) is webdev
* Another user called `apache` whose primary group (gid) is apache
* A group called `webdev`
* The following directories:
	* /var/www - owned by user apache and group webdev
	* /var/www/html - owned by user apache and group webdev
	* /home/webtest - owned by user webtest
* The following packages should be installed:
	* httpd
	* mysql
	* php
	* php-cli
	* php-mysql
* MySQL server should be installed with root password 'foo'
* The mysql and httpd services should be running
* A mysql database called `webdb` should exist

__*Note*__: You can see the number of tasks you have completed as you progress through the quest in the bottom left of the Learning Puppet VM terminals. The quest is complete when all the tasks for the quest are complete.
To check on which tasks are still incomplete, try the command:
      progress
This will list the Incomplete tasks.	

### Define, Iterate!

Since we want to automate the process of configuring a base system for the web developers, we will want to create a module, with a single class in it.  Let us call this module `testmachine`. This module will have a class called `testmachine` defined in it. We will also need a test manifest to enable us to test the class as we work on our definition of the class. Once we create the test file, we can use the `puppet apply` command to test our definition.

We want to develop the class definition through an iterative process. Starting with a simple definition that defines one, or a few resources, we want to test things as we go. So initially, you may choose to ensure that the  user and the group are created. Then you apply the test to make sure that your definition works as expected. Next, you may try to ensure that the required directories exist - so you add the resources to the class definition, and apply the test.

As you work through the quest, you can refer to puppet's documentation for the various types of resources using:  
          
      puppet describe <type> 

and if you need help with the syntax, refer to previous code samples, or get help from the puppet resource command, for example:

	  puppet resource package 
	  

### Steps towards success

There will be an indicator to the lower right of the terminal window that shows your progress as you complete the tasks needed to configure the machine.

If you want to check on progress, with more details, run the command:

    progress
    
This will list the Incomplete tasks that you have yet to complete.

The steps involved in completing the quest are as follows:

1. Create a module, called `testmachine`, in the correct directory, with the correct directory structure.
	* for this, remember what we learnt about the module directory structure
	* also remember that you will need a directory for your class definition, and another for your test manifest.
2. Define the class called `testmachine`	* remember that the class definition needs to be in a file called `init.pp` in the correct directory
    * also recall the syntax for class definitions - refer to the class definition in the previous section if needed
    * you may want to start with an empty class definition like the following:
    >        class testmachine {
    >
    >        }
    * and add resource declarations to the definition, one (or a few) at a time
3. Create a test for the class testmachine
	* The test file should help you test the class definition as you work on it.
4. Now, in an iterative manner, build the definition for the class testmachine, until you have completely described all the resources you need to manage on the machine.
5. When it's time to configure apache and mysql, install and use the modules provided by puppetlabs at the Forge
    * After the modules puppetlabs-apache and puppetlabs-mysql are installed, read the documentation for the modules and accomplish the following:
        1. Make sure that the mysql server is installed, with the root user's password being set to 'foo'.
        2. Ensure the httpd service is running, by installing the apache server using the puppetlabs-apache module. 
    * Remember to read the documentation for the module if something isn't clear!
    

The `puppet help` &nbsp; command, and by the other puppet commands we have discussed before may help you as you proceed with the quest. Don't be afraid to experiment! 

========
<div class="page-break"></div>

## The Road Ahead

We hope that completing the quest was a lot of fun. Now that we have a class that can be used to configure a machine as a base system for web developers to test their work on, we can configure a new VM almost instantly, just by applying the class. Your work in defining the class once will pay off many times over in the time you save configuring the new VMs.

Although we learned only about using Puppet to configure a single VM - the one Puppet is installed on, it is possible to create a puppet master server that can be used to configure a lot of machines, each with the puppet agent daemon installed on them. This master-agent setup is the key to leveraging the ease with which you can manage entire networks of machines from a single, central server. The concepts are the same as we covered in this lesson - think of how, instead of just managing your Learning Puppet VM, you would be able to manage any machine with puppet installed on it, that can connect to your machine!

In subsequent lessons, we will learn more about how the Puppet Agent and the Puppet Master interact with each other, how you can dynamically generate content for files etc. For each lesson, we will have a Motivating Example, and a quest to complete!
    
