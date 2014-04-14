---
title: Power of Puppet
layout: default
---

# The Power of Puppet

### Prerequisites

- Welcome Quest

## Quest Objectives

- Use a module from the Forge, and a pre-written module to setup a website serving the quest guide.
- Use the Puppet Enterprise (PE) Console to manage the Learning VM's configuration

## Getting Started

In this quest you will be introduced to the power of Puppet using the Puppet Enterprise (PE) Console and the Puppet Forge. The objective of this quest is to set up a functional website locally that will serve you the entire Quest Guide, as an alternative to the PDF version. Don't worry though, both the website and PDF have the same content and will help guide you on your journey to learn Puppet. 

We are not going to be writing any code in this quest to accomplish the objective. Instead, we will be using a module from the Forge, as well as another that has been written for you on the Learning VM. This will serve as an example of _how_ you can _use_ the code that you will learn to write in the succeeding sections. We hope this gives you a high-level overview of what it is like to use Puppet Enterprise to manage systems, while leveraging code developed by the community that is shared on the Forge. Some of the technical terms in this quest may not be familiar, but we promise we will explain all of it by the end of the guide!

Are you intrigued as to how this looks? When you're ready to get started, type the following command:

    quest --start power 

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the Puppet community. We can leverage the content from the Forge to simplify the process of managing your systems. This is just a general description of the Forge, which will suffice for now. We will go into greater detail about the Forge in the Puppet Module Tool Quest.

But what is a Module, you ask? Simply put, a module is a self-contained bundle of code and data. We will learn about Modules in greater detail in the Module Quest.

{% aside Puppet Enterprise Supported Modules %}
Remember how we indicated in the Welcome Quest that Puppet Enterprise comes with several benefits, in addition to Puppet? [Puppet Enterprise supported modules](http://forge.puppetlabs.com/puppetlabs?utf-8=%E2%9C%93&supported=yes) are modules that are rigorously tested with Puppet Enterprise and are also supported (maintained) by Puppet Labs. 
{% endaside %}

{% task 1 %}

Install the puppetlabs-apache module.

For us to get started with setting up our Quest Guide website, we need to download and install the [apache module](http://forge.puppetlabs.com/puppetlabs/apache) from the Forge. In your terminal type the following command:

	puppet module install puppetlabs-apache

This tells Puppet to download and install the `puppetlabs-apache` module from the Forge onto the Learning VM. Modules are installed in the directory specified as Puppet's _modulepath_. For Puppet Enterprise, this defaults to `/etc/puppetlabs/puppet/modules/`.

{% aside Offline? No problem. %}
We've cached the required modules on the Learning VM. If you don't have internet access, run the following terminal commands instead of using the `puppet module` tool:

	cd /etc/puppetlabs/puppet/modules  

	tar zxvf /usr/src/forge/puppetlabs-apache-0.8.1.tar.gz -C .  
	
	mv puppetlabs-apache-* apache  
{% endaside %}

Great job! You've just installed your first module from the Forge. Pretty easy don't you think? We also went ahead and wrote the `lvmguide` module we will need. You will find this module in the `modulepath` directory as well.

### The lvmguide and apache modules

The `lvmguide` module includes a *Class* of the same name, which configures the Learning VM to act as a webserver serving the Quest Guide as an html website. A Class is a named block of Puppet code. 

It does this by using the `apache` module you just installed to:

- install the Apache httpd server provided by the `httpd` package
- create a new VirtualHost that will act as the Quest Guide website
- configure httpd to serve the Quest Guide website
- start and manage the httpd service

Finally, the `lvmguide` module places the files for the website in the appropriate directory.

### Putting the modules to use

As we mentioned previously a class is a named block of Puppet code. The `lvmguide` class contains the definition that will configure a machine to serve the quest guide. In order to configure the Learning VM to serve you the Quest Guide website, we need to assign the `lvmguide` class to it, a process known as *Classification* (don't worry about the terminology at this point. We'll talk more about this in the Modules Quest). To do this we will use the Puppet Enterprise Console.

## The Puppet Enterprise Console

The PE Console is Puppet Enterprise’s web-based Graphical User Interface (GUI) that lets you automate your infrastructure with little or no coding necessary. You can use it to:

- Manage node requests to join the Puppet deployment
- Assign Puppet classes to nodes and groups
- View reports and activity graphs
- Trigger Puppet runs on demand
- Browse and compare resources on your nodes
- View inventory data
- Invoke orchestration actions on your nodes
- Manage console users and their access privileges

For this quest, we will use the PE Console to classify the VM with the `lvmguide` class.

## The Facter Tool

Puppet Enterprise is often used in concert with other tools to help you administer your systems. Just as the quest tool can provide you feedback on your learning progress, you can use the Facter tool to help you obtain facts about your system. Facter is Puppet’s cross-platform system profiling library. It discovers and reports per-node facts, which are available in your Puppet manifests as variables. 

Facter is used and described in later quests, but the sooner you get familar with Facter, the better.  Go ahead and get to know your system a little better using the `facter` command.

{% tip %}
Facter is one of the many prepackaged tools that **Puppet Enterprise** ships with.
{% endtip %}

{% task 2 %}

Find the ipaddress of the VM using Facter:

To access the PE Console we need to find your IP address. Luckily, Facter makes it easy to find this. In your terminal, type the following command:

	facter ipaddress


{% tip %}
You can see all the facts by running `facter -p`
{% endtip %}

Please write down your returned IP address as you will need it to access the PE Console. Next, in your browser's address bar, type the following URL: **https://your-ip-address**.

{% aside Security Restriction %}
If your browser gives you a security notice, go ahead and accept the exception. The notification appears because we are using a self-signed certificate.
{% endaside %}

Awesome! You are at the doorstep of the PE Console. Enter the login information below to gain access:

**Username:** puppet@example.com  
**Password:** learningpuppet

{% figure '../assets/PE_Login.png' %}

You're in! Now that you have access to the PE Console, the next step will be to classify the "learn.localdomain" node with the `lvmguide` class.

### Steps

In order to classify the `learn.localdomain` node (the Learning VM) with the `lvmguide` class, we need to add the this class to the list of Classes available to the PE Console to classify nodes with. Let's add it.

**STEP #1:** Click the "Add Classes" button  
LOCATION: You may need to scroll to the bottom of the page. The button is located in the lower left hand corner of the screen in the Classes panel. 

{% figure '../assets/PE_Add_Classes.png' %}

**STEP #2:** Type *lvmguide* in the "Filter the list below" input box  

{% figure '../assets/PE_lvmguide.png' %}

**STEP #3:** Select the checkbox associated with *lvmguide* class that appears in your results once you filter  

{% figure '../assets/PE_lvmguide_Selected.png' %}

**STEP #4:** Click the "Add selected classes" button to add the *lvmguide* class to the list of classes that can be assigned to node in the PE Console.  

{% figure '../assets/PE_Add_Selected_Classes.png' %}

{% aside Verification %}
You should see the class appear in the list of classes on the left, and also see a verification message at the top of your PE Console.
{% endaside %}


**STEP #5:** Click on the "Nodes" menu item in the navigation bar  
LOCATION: You may need to scroll to the top of the page to see the navigation bar 

{% figure '../assets/PE_Nodes_Menu.png' %}

**STEP #6:** Click on the *learn.localdomain* node hyperlink (should be the only one listed)  
LOCATION: Look at the center of your screen.  

{% figure '../assets/PE_Learn_Node.png' %}

**STEP #7:** Click the "Edit" button  
LOCATION: Look at the up right corner of the screen. 

{% figure '../assets/PE_Edit_Button.png' %}

**STEP #8:** In the Classes section, type *lvmguide* in the "add a class" input box  

{% aside Editing Class parameters %}
If you click on *Edit Parameters* for the lvmguide class you can see the defaults. *There is nothing for you to do here for the moment,* but it's good to notice it so you will know where to look if you need to edit class parameters in the future.
{% endaside %}

{% figure '../assets/PE_Add_lvmguide_Class.png' %}

**STEP #9:** Click the "Update" button  

{% figure '../assets/PE_Update_Button.png' %}

## Let's Run Puppet

Now that we have classified the “learn.localdomain” node with the `lvmguide` class, we need to tell the puppet agent to fetch and enforce the definition for the “learn.localdomain” node.

{% task 3 %}
To fetch and apply the catalog we will manually trigger a Puppet run. Puppet will check the classification you set in the PE Console and automatically run through all the steps needed to implement the `lvmguide` class. In your terminal type the following command:

	puppet agent --test

You will see the test scroll in your terminal indicating that apache was installed and the website was set up. **Please note this may take about a minute to run.**

{% tip %}
Running `puppet agent -t` works also. The `-t` flag is simply a short version of `--test`.
{% endtip %}

{% task 4 %}
Let's check out the Quest Guide! In your browsers address bar, type the following URL: **http://your-ip-address**.

You're all set up to get started with learning how to use Puppet to automate your infrastructure! Essentiall, what we’ve done here is leverage the Puppet Labs apache module to set up the quest guide.

## Exploring the lvmguide Class

Let’s take a high level look at what the `lvmguide` class does for us. In your terminal you're going to want to `cd` into the modules directory:

	cd /etc/puppetlabs/puppet/modules

Next, using `vim`, `nano`, or a text editor of your choice, open up the `init.pp` manifest. Type the following command in you terminal:

	nano manifests/init.pp

{% aside %}
We will learn more detailed information about each of these concepts in future quests. However, this is a leading example of how a few lines of Puppet code can automate a relatively complex task.
{% endaside %}

{% highlight puppet %}
class lvmguide (
  $document_root = '/var/www/html/lvmguide',
  $port = '80',
) {
  
  class { 'apache': 
    default_vhost => false,
  }
  
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }

  file { '/var/www/html/lvmguide':
    ensure  => directory,
    owner   => $::apache::params::user,
    group   => $::apache::params::group,
    source  => 'puppet:///modules/lvmguide/html',
    recurse => true,
    require => Class['apache'],
  }

}
{% endhighlight %}

In the above code sample, we see that the `class lvmguide`:

1. declared the class apache with the default_vhost parameter set to false.
2. declared an apache::vhost for the quest guide.
3. set the document root to `/var/www/html/lvmguide` (which is the default value for the $document_root parameter).
4. ensured that the directory `/var/www/html/lvmguide` exists and that its contents are managed recursively. 

{% tip %}
The file in the directory is sourced from the lvmguide module.
{% endtip %}

The real power here is that you now have the `class lvmguide` in a module that could be assigned to any number of nodes you wish to manage. There is no repetition or any other node-specific code that needs to be written!

## Review

Great job on completing this quest! To summarize, we learned how to leverage exising modules on the Forge and use the PE Console to set up our quest guide website locally. We also learned the importance of classifying when it comes to automating system tasks. Please note the block of Puppet code for the lvmguide module as we'll be reference it throughout the remaining quests to help bring context to what exactly you just did in greater detail.
