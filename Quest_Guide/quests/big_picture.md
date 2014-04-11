---
title: Power of Puppet
layout: default
---

# Power of Puppet

### Prerequisites

- Welcome Quest

## Quest Objectives

- Download a module from the Puppet Forge
- Use the Puppet Enterprise (PE) Console to classify a node
- Explore how we created the Quest Guide website locally

## Getting Started

In this quest you will be introduced to the power of Puppet using the Puppet Enterprise (PE) Console and the Puppet Forge. The product of this quest is to set up a functional website locally that will serve you the entire Quest Guide, as an alternative to the PDF version. Don't worry though, both the website and PDF have the same content and will help guide you on your journey to learn Puppet. However, to do this, we're not going to be writing any code in this quest. Instead, we'll be using existing code and the PE Console to see just how far Puppet can take us in automating your infrastructure without yet delving into code. Are you intrigued as to how this looks? When you're ready to get started, type the following command:

    quest --start powerofpuppet

## The Puppet Forge

No matter if you use Puppet open source or Puppet Enterprise, another tool at your disposal is the [Puppet Forge](http://forge.puppetlabs.com). The Forge is a public repository of modules ritten by members of the puppet community, which we can leverage to simplify the process of managing your systems. This is just a general description of the Forge, which will suffice for now. We'll go into greater detail about the Forge in the Puppet Module Tool Quest.

{% aside Puppet Enterprise Supported Modules %}
Remember in the Welcome quest when we stated PE comes with many prepackaged tools? Well, another one of those tools are [Puppet Enterprise supported modules](http://forge.puppetlabs.com/puppetlabs?utf-8=%E2%9C%93&supported=yes). These modules are rigorously tested with Puppet Enterprise environment and are also supported (maintained) by Puppet Labs.
{% endaside %}

{% task 1 %}
For us to get started with setting up our Quest Guide website, we need to download and install the [apache module](http://forge.puppetlabs.com/puppetlabs/apache) from the Forge. In your terminal type the following command:

	puppet module install puppetlabs-apache

This tells Puppet to go into the Forge and specifcally download and install the `puppetlabs-apache` module onto this Learning VM.

{% aside Offline? No problem. %}
We've cached the required modules on the Learning VM. If you don't have internet access, run the following terminal commands instead of using the `puppet module` tool:

	cd /etc/puppetlabs/puppet/modules  

	tar zxvf /usr/src/forge/puppetlabs-apache-0.8.1.tar.gz -C .  
	
	mv puppetlabs-apache-* apache  
{% endaside %}

Great job! You've just installed your first module from the Forge. Pretty easy don't you think? We also went ahead and pre-installed `lvmguide` module on your behalf.

### The lvmguide and apache modules

The `lvmguide` module includes a simple class which stages the files for the Quest Guide website and uses the `apache` module you just installed to:

- install the `apache2` httpd server.
- start and manage the httpd service.
- create a new virtualhost that will act as the Quest Guide website.

To use the classes nested in each of these modules, we need to be able to enforce the classes on particular machines. In order to configure the Learning VM to serve you the Quest Guide website, we need to assign the appropriate class(es), a process known as Classification (don't worry about the terminology at this point. We'll talk more about this in the Modules Quest). To do this we will use the PE Console.

## The Puppet Enterprise Console

The PE Console is Puppet Enterprise’s web-based Graphical User Interface (GUI) that lets you automate your infrastructure with little or no coding necessary. You can use it to:

- Manage node requests to join the Puppet deployment.
- Assign Puppet classes to nodes and groups.
- View reports and activity graphs.
- Trigger Puppet runs on demand.
- Browse and compare resources on your nodes.
- View inventory data.
- Invoke orchestration actions on your nodes.
- Manage console users and their access privileges.

{% task 2 %}
To access the PE Console we need to find your IP address. Luckly, Puppet Enterprise comes prepackaged with Facter, which will help you find this out easily. In your terminal, type the following command:

	facter ipaddress

Please write down your returned IP address as you will need it to access the PE Console. Next, in your browsers address bar, type the following URL: **https://your-ip-address**.

{% aside Security Restriction %}
If your browser gives you a security notice, go ahead and accept the exception. Because we are running locally with a self-signed certificate, there is no security risk.
{% endaside %}

Awesome! You are at the doorstep of the PE Console. Enter the login information below to gain access:

**Username:** puppet@example.com  
**Password:** learningpuppet

{% figure '../assets/PE_Login.png' %}

We're in! Now that we have access to the PE Console, the next step will be to classify the "learn.localdomain" node with the `lvmguide` class.

### Steps

**STEP #1:** Click the "Add Classes" button  
LOCATION: You may need to scroll to the bottom of the page. The button is located in the lower left hand corner of the screen in the Classes panel. 

{% figure '../assets/PE_Add_Classes.png' %}

By clicking this button will allow you to get started classifying the "learn.localdomain" node with the lvmguide class discussed in the next step.

**STEP #2:** Type *lvmguide* in the "filter the list below" input box  

{% figure '../assets/PE_lvmguide.png' %}

To classify "learn.localdomain" node means to determine what the actual node configurations will be. We want to find the lvmguide class so we can assign it to a node, as well as provide any data the lvmguide class requires.

**STEP #3:** Select the checkbox associated with *lvmguide* class that appears in your results once you filter  

{% figure '../assets/PE_lvmguide_Selected.png' %}

This means you want to assign the lvmguide class to this node.

**STEP #4:** Click the"Add selected classes" button to add the *lvmguide* class.  
LOCATION: You may need to scroll to the bottom of the page.

{% aside Verification %}
You should see the class appear in both class windows and a verification message at the top of your screen.
{% endaside %}

{% figure '../assets/PE_Add_Selected_Classes.png' %}

By clicking this button tells Puppet to classify the lvmguide to the node. 

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
