---
title: Power of Puppet
layout: default
---

# The Power of Puppet

### Prerequisites

- Welcome Quest

## Quest Objectives

- Use a module from the Forge, and a pre-written module to set up a website serving the quest guide.
- Use the Puppet Enterprise (PE) Console to manage the Learning VM's configuration

## Getting Started

In this quest you will see how Puppet and the Puppet Enterprise (PE) Console provides a simple way to achieve an otherwise compelex task.  You will set up a functional local website that will serve the full content of this Quest Guide. Instead of writing code or using standard terminal commands to accomplish this objective, you will use the PE console to deploy freely available modules from the Puppet Forge. 

As you go through this quest, remember that Puppet is a powerful tool, and there is a lot to learn. We will explain concepts as needed to complete and understand each task, but sometimes we'll need to hold off on a fuller explanation of some detail until a later section. So don't worry if you don't feel like you're getting everything right away; we'll get there when the time is right!

When you're ready to get started, type the following command:

    quest --start power 

## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the Puppet community, including many written and maintained by Puppet Labs employees and partners. A module is a bundle of Puppet code packaged along with the other files and data you need to complete a task using Puppet. The Forge is a key part of using Puppet effectively. Easy access to existing modules allows you to jump-start your infrastructure setup and avoid re-inventing the wheel where the hard work has already been done. (We go into greater detail about the Forge in the Puppet Module Tool Quest.)

{% aside Puppet Enterprise Supported Modules %}
Remember how we mentioned in the Welcome Quest that Puppet Enterprise comes with several benefits, in addition to Puppet itself? [Puppet Enterprise supported modules](http://forge.puppetlabs.com/puppetlabs?utf-8=%E2%9C%93&supported=yes) are modules that are rigorously tested  for compatibility with Puppet Enterprise and it's stack of bundled tools. They are supported and maintained by Puppet Labs to ensure continued stability as the underlying components are updated. 
{% endaside %}

{% task 1 %}

To get started setting up the Quest Guide website, you'll need to download and install the `puppetlabs-apache` module from the Forge. If you like, check out the module's [page on the Forge](http://forge.puppetlabs.com/puppetlabs/apache) to see details and documentation. (If you're offline or behind a firewall, check the aside below for instructions on using the cached version of the module.) The `apache` module gives you all the tools you need to automate installing, configuring, and starting an Apache webserver. In your terminal, enter the following command to install the module:

	puppet module install puppetlabs-apache

This command tells Puppet to download the Puppet Labs `apache` module from the Forge and place it in the directory specified as Puppet's _modulepath_. The modulepath is a directory on your system where Puppet saves modules you install and accesses modules you already have installed. For Puppet Enterprise, this defaults to `/etc/puppetlabs/puppet/modules/`.

{% aside Offline? No problem. %}
We've cached the required modules on the Learning VM. If you don't have internet access, run the following terminal commands instead of using the `puppet module` tool:

	cd /etc/puppetlabs/puppet/modules  

	tar zxvf /usr/src/forge/puppetlabs-apache-0.8.1.tar.gz -C .  
	
	mv puppetlabs-apache-* apache  
{% endaside %}

Great job! You've just installed your first module from the Forge. To set up the LVM Guide website, you'll also need to use a custom `lvmguide` module we've written for this quest. For the sake of simplicity, we've already included `lvmguide` in the VM's module path, so there's no need to fetch it from the Forge. This small `lvmguide` module draws on some resources from the Puppet Labs `apache` module and uses some code and content of its own to finish the configuration of the Quest Guide website. 

### The lvmguide and apache modules

Before using these modules, you should know a little more about how they work. The `lvmguide` *module* includes Puppet code that defines an `lvmguide` *class*. (Though there are superficial similarities, you'll be better off forgetting aything you know about how classes work in Object Oriented programming when dealing with Puppet's classes.) In Puppet, a *class* is simply a named block of Puppet code organized in a way that defines a set of associated system resources. For instance, a class might install a package, customize an associated configuration file for that package, and start a service provided by that package. Because these are related and interdependent processes, it makes sense to organize them into a single configurable unit: a class. 

While a module can include many classes, there must always be a main class that shares the name of the module and serves as the primary access point for the module's functionality.

So the `lvmguide` module contains an `lvmguide` class, which tells Puppet how to configure the Learning VM to act as a webserver serving the Quest Guide as a static html website.

It does this by using the `apache` module you just installed to:

- install the Apache httpd server provided by the `httpd` package
- create a new VirtualHost that will act as the Quest Guide website
- configure httpd to serve the Quest Guide website
- start and manage the httpd service

Finally, the `lvmguide` class tells Puppet to place the files for the Quest Guide website in the `/var/www/html/lvmguide` directory where the httpd service can make them accessible to your browser when you visit the website.

### Putting the modules to use

In order to configure the Learning VM to serve you the Quest Guide website, we need to assign the `lvmguide` class to it, a process called as *classification*. In short, classification is how you tell Puppet which classes to apply to which systems in your infrastructure. There are a few different ways to classify nodes, but in this quest, we will be using the PE Console's node classifier.

## The Puppet Enterprise Console

The PE Console a web-based Graphical User Interface (GUI) that gives you easy visibility and control of your infrastructure without requiring you to dig into the Puppet code itself. You can use it to:

- Manage node requests to join the Puppet deployment
- Assign Puppet classes to nodes and groups
- View reports and activity graphs
- Trigger Puppet runs on demand
- Browse and compare resources on your nodes
- View inventory data
- Invoke orchestration actions on your nodes
- Manage console users and their access privileges

For this quest, you will use the PE Console to classify the Learning VM with the `lvmguide` class.

To access the PE Console you'll need the Learning VM's IP address. Remember, you can use the `facter` tool packaged with PE to access this.

	facter ipaddress


{% tip %}
You can see a list of all the system facts accessible through facter by running the `facter -p` command.
{% endtip %}

Make a note of IP address for the VM.  Open a web browser on your host machine and go to `https://<ip-address>`(type in the IP address for the VM instead of `<ip-address>`), and press Return (Enter) to load the PE Console. (Be sure to include the `s` in `https`) If your browser gives you a security notice, you can safely accept the certificate. The notification appears because the certificate is self-signed.

Use the login information below to access to the PE Console:

**Username:** puppet@example.com  
**Password:** learningpuppet

{% figure '../assets/PE_Login.png' %}

You're in! Now that you have access to the PE Console, we'll go over the steps you'll take to classify the "learn.localdomain" node (i.e. the Learning VM) with the `lvmguide` class.

## Using the PE Console for Classification

In order to classify the `learn.localdomain` node with the `lvmguide` class, add the class to the list of classes available to the PE Console.

### Adding a Class to the PE Console

Click the "Add Classes" button. Find the **Classes** panel and click the **Add classes** button. (You may need to scroll to the bottom of the page to find the panel.)

{% figure '../assets/PE_Add_Classes.png' %}

Type *lvmguide* in the "Filter the list below" input box, and select the checkbox associated with *lvmguide* class that appears in your results once you filter.

{% figure '../assets/PE_lvmguide_Selected.png' %}

Click the "Add selected classes" button to add the *lvmguide* class to the list of classes that can be assigned to node in the PE Console.  

{% figure '../assets/PE_Add_Selected_Classes.png' %}

You should see the class appear in the list of classes on the left, and also see a verification message at the top of the PE Console.

### Classifying a node 

Now that the `lvmguide` class is available in the PE Console, let's classify the node `learn.localdomain`.

Click on the "Nodes" menu item in the navigation menu. (You may need to scroll to the top of the page to see the navigation menu.)

{% figure '../assets/PE_Nodes_Menu.png' %}

Click on the *learn.localdomain* node hyperlink. (This should be the only one listed since the Learning VM is the only node you're managing with Puppet Enterprise.)

{% figure '../assets/PE_Learn_Node.png' %}

Once you're on the node page for *learn.localdomain*, click the "Edit" button located in the top-right corner of the screen. 

{% figure '../assets/PE_Edit_Button.png' %}

In the Classes section, type *lvmguide* in the "add a class" input box  

{% figure '../assets/PE_Add_lvmguide_Class.png' %}

Click the "Update" button at the bottom.

{% figure '../assets/PE_Update_Button.png' %}

Excellent! If everything went according to plan, you've successfully classified the `learn.localdomain` node with the `lvmguide` class.

## Run Puppet

Now that you have classified the `learn.localdomain` node with the `lvmguide` class, Puppet knows how the system should be configured, but will not make any changes until a Puppet run occurs. The Puppet `agent` daemon does this by default by running in the background on any nodes you manage with Puppet. Every 30 minutes, the Puppet agent daemon requests a *catalog* from the Puppet Master. The Puppet Master parses all the classes applied to that node and builds a catalog that describes how the node is supposed to be configured. It returns this catalog to the node's Puppet agent, which then applies any changes necessary to bring the node into the line with the state described by the catalog.

{% task 3 %}

Instead of waiting for the Puppet agent to make its scheduled run, use the `puppet agent` tool to trigger one yourself. In your terminal, type the following command:

	puppet agent --test

**Please note this may take about a minute to run.** This is about the time it takes for the software packages to be downloaded and installed as needed. After a brief delay, you will see text scroll by in your terminal indicating that Puppet has made the changes to the system necessary to get the Quest Guide website set up.

Check out the Quest Guide! In your browsers address bar, type the following URL: `http://<ip-address>`. (Note that `https://<ip-address>` will load the PE Console, while `http://<ip-address>` will load the Quest Guide as a website. See the difference? It's the `s`.)

From this point on you can either follow along with the website or with the PDF, whichever works best for you.

### IP Troubleshooting

The website for the quest guide will remain accessible for as long as the VM's IP address remains the same. If you were to move your computer or laptop to a different network, or if you suspended your laptop and resumed work on the Learning VM after a while, the website may not be accessible. You still have the PDF to follow along with. 

In case any of the above issues happen, and you end up with a stale IP address, run the following commands on the Learning VM to get a new IP address. (Remember, if you're unable to establish an SSH session, you can log in directly through the interface of your virtualization software.)

Refresh your DHCP lease:

    service network restart

Find your IP address:

    facter ipaddress

## Exploring the lvmguide Class

To understand what the `lvmguide` class does, take a look under the hood. In your terminal, use the `cd` command to navigate to the module directory. (Remember, `cd` for 'change directory.')

	cd /etc/puppetlabs/puppet/modules

Next, using the `vim` or `nano` text editor, open the `init.pp` manifest. (While we've configured `vim` to use some nice formatting an syntax highlighting features, `nano` may be more straight-forward if you're not used to working through a terminal. Whenever we ask you to open a file on the Learning VM, feel free to use whichever  editor you feel most comfortable with.)

	nano lvmguide/manifests/init.pp

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

(To exit out of the file, use the command `control-x` in nano, or `:q!` in vim.)

If you're not used to reading code, this might seem like a lot of detail. We'll give you a quick overview so the concepts will be more familiar when encounter them later on, but don't worry about getting it all right away.

{% highlight puppet %}
class lvmguide (
  $document_root = '/var/www/html/lvmguide',
  $port = '80',
) {
{% endhighlight %}

The class `lvmguide` takes two parameters: `$document_root` and `$port`. These have default values defined as `/var/www/html/lvmguide` and `80`, which is why you were able to apply the class without specifying any parameters explicitly.

{% highlight puppet %}
  class { 'apache': 
    default_vhost => false,
  }
{% endhighlight %}

The `lvmguide` class declares another class: `apache`. Puppet knows about the `apache` class because it is defined by the `apache` module you installed into the modulepath earlier. The `default_vhost` parameter for the `apache` class is set to `false`. This is all the equivalent of saying "Set up Apache, and don't use the default VirtualHost because I want to specify my own."

{% highlight puppet %}
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }
{% endhighlight %}

This block of code declares the `apache::vhost` class for the Quest Guide with the title `learning.puppetlabs.vm`, and with `$port` and `$docroot` set to those class parameters we saw earlier. This is the same as saying "Please set up a VirtualHost website serving the 'learning.puppetlabs.vm' website, and set the port and document root based on the parameters from above." The `apache::vhost` syntax tells Puppet to find a class called `vhost` in the `apache` module.

{% highlight puppet %}
  file { '/var/www/html/lvmguide':
    ensure  => directory,
    owner   => $::apache::params::user,
    group   => $::apache::params::group,
    source  => 'puppet:///modules/lvmguide/html',
    recurse => true,
    require => Class['apache'],
  }
{% endhighlight %}

Finally, the class ensures that the directory `/var/www/html/lvmguide` exists and that its contents are managed recursively. The `source =>` line tell Puppet to copy the content for this directory from an `html` directory in the `lvmguide` module.

It may seem like there's a lot going on here, but once you have a basic understanding of the syntax, a quick read-through will be enough to get the gist of well-written Puppet code. In fact, we often talk about Puppet's Domain Specific Language (DSL) as **self-documenting code**.

### Repeatable, Portable, Testable

It's cool to install and configure an Apache httpd web server with a few lines of code and some clicks in the console, but keep in mind that the best part can't be shown with the Learning VM: once the `lvmguide` module is installed, you can apply the `lvmguide` class to as many nodes as you like, even if they have different specifications or run different operating systems.

And once a class is deployed to your infrastructure, Puppet gives you the ability to manage the configuration from a central point. With Puppet, you can propagate changes across your whole infrastructure at once, or (if you don't like surprises!) carefully promote updates to development nodes through testing and into production.
 
## Modules, Classes - Oh My!

As you follow along with the next few quests, it may help to keep in mind the overall structure of Puppet code. At the highest level, Puppet uses modules as a means of organizing code and bringing together all the definitions, files, templates -- all the things that are needed to manage a certain technology or directed towards a particular purpose. For example, we used the apache module in this current quest - which provides everything needed to configure or manage an apache httpd server. Modules are designed to be resused, so the same module can be used to configure systems with different operating systems and features.

Modules contain definitions for Classes, which provide for reuse as well. Classes provide for containers of resources - so you can reuse common associations between several resources such as files, users, packages and services - without having to redefine them completely each time. The apache class, which belongs in the apache module includes definitions for how the httpd service should be configured, how the configuration file should look like, and what package needs to be installed to provide the httpd server etc. Combined with the ability to specify dependencies between resources (for example, you can specify that whenever the configuration file's contents change, the httpd server is to be restated), classes allow Puppet to be flexible and powerful by reusing well-defined collections of resources.

Before you can embark on creating your own classes and modules, however, you will need to understand the syntax that Puppet uses to describe resources and the relationships between them. This is done using __Manifests__, and in the next few quests, we will learn how to write manifests in Puppet's language.

## Review

Great job on completing the quest! To summarize, we learned how to leverage exising modules on the Forge and use the PE Console to set up our quest guide website locally. We also learned how to classify a node with a class. We will continue to reference the block of Puppet code for the `lvmguide` module throughout the remaining quests in order to understand what we did.
