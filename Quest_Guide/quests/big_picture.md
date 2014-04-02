---
title: Power of Puppet
layout: default
---

# Power of Puppet

## Quest Objectives

In this initial quest you will be introduced the power of Puppet using the Puppet Enterprise (PE) Console and the Puppet Forge. Our main learning objective is to set up a website to serve you the entire quest guide, should you not perfer to use the accompanying PDF. Don't worry though, both the website and PDF have the same content and will help guide you on your journey to learn Puppet. When you're ready to get started, type the following command:

    quest --start begin
    
{% aside Using Puppet without writing code %}

We're not writing code in this quest. In fact, we're going to use Puppet without writing a single line of code. Using the Puppet Enterprise Console we'll see what Puppet can do with regards to automating tasks (and the actual little amount of code it takes).

{% endaside %}


## The Puppet Forge

The [Puppet Forge](http://forge.puppetlabs.com) is a public repository of modules written by members of the puppet community to simplify the process of managing your systems. These modules will provide you with classes and new resource types to manage the various aspects of your infrastructure. Using these modules reduces your time using Puppet's Domain Specific Language (DSL) to describe classes in configuring the right options for you. Don't fret if you don't know exactly what we're talking about here. We will go into greater detail during the Puppet Modules and QuestPuppet Module Tool Quest.

{% aside Puppet Enterprise Supported Modules %}

[Puppet Enterprise supported modules](http://forge.puppetlabs.com/puppetlabs?utf-8=%E2%9C%93&supported=yes) are rigorously tested with Puppet Enterprise and supported (maintained) by Puppet Labs.

{% endaside %}

{% task 1 %}
To get started with our website, we're going to need to download and install the [apache module](http://forge.puppetlabs.com/puppetlabs/apache) from the Puppet Forge. In your terminal type the following command:

	puppet module install puppetlabs-apache

{% aside If you're doing this offline, do these steps instead of the one above %}

	cd /etc/puppetlabs/puppet/modules  
	tar zxvf /usr/src/forge/puppetlabs-apache-0.8.1.tar.gz -C .  
	mv puppetlabs-apache-* apache  

{% endaside %}

Great job! You've just installed your first modules from the Puppet Forge. Pretty easy don't you think? We went ahead and also pre-installed lvmguide module on your behalf as well.

### lvmguide and apache modules

The lvmguide module is a simple module with a simple class which stages the files for the quest guide website and uses the apache module you just installed to

- install the apache2 httpd server
- start and manage the httpd service
- create a new virtualhost that will act as the website with the quest guide in it

To use these classes nested in each of these modules we need to be able enforce classes to particular machines. In order to configure the Learning VM to serve you the quest guide web pages, we need to assign the appropriate class(es), a process known as Classification (don't worry about the terminology at this point. We'll talk more about this in the Classes Quest). To do this we will use the Puppet Enterprise Console.

## The Puppet Enterprise Console

The Puppet Enterprise Console is Puppet Enterprise’s web Graphical User Interface (GUI) to using Puppet and automating your system without the need to write code. You can use it to:

- Manage node requests to join the puppet deployment
- Assign Puppet classes to nodes and groups
- View reports and activity graphs
- Trigger Puppet runs on demand
- Browse and compare resources on your nodes
- View inventory data
- Invoke orchestration actions on your nodes
- Manage console users and their access privileges

{% task 2 %}
We need to find your ip address. Luckly Puppet come prepackaged with a tool called Facter which will help you find this out easily. In your terminal type the following command:

	facter ipaddress

Please write down your ip address as you will need it to access the Puppet Enterprise Console. Next, in your browsers address bar, type the following URL: **https://your-ip-address**.

{% aside Security Restriction %}

Go ahead and also accept the security exception since we are running locally with a self-signed certificate. There is no security risk of any kind.

{% endaside %}

Awesome! You are at the door step of entering the Puppet Enterprise Console. Enter the below login information to offically gain access to the Puppet Enterprise Console:

**Username:** puppet@example.com  
**Password:** learningpuppet
![image](./assets/PE_Login.png)

We're in! Remember, we're trying to get the apache module and lvmguide module communicating with each other.

### Steps

**STEP #1:** Click the "Add Classes" button (You may need to scroll to the bottom of the page)    
![image](./assets/PE_Add_Classes.png)

**STEP #2:** Type *lvmguide* in the "filter the list below" input box  
![image](./assets/PE_lvmguide.png)

**STEP #3:** Select the *lvmguide* class that appears once you filter  
![image](./assets/PE_lvmguide_Selected.png)

**STEP #4:** Click the"Add selected classes" button to add the *lvmguide* class. (You may need to scroll to the bottom of the page)  

{% aside Editing Class parameters %}

You should see the class appear in both class windows and a verification message at the top of your screen

{% endaside %}
![image](./assets/PE_Add_Selected_Classes.png)
  
**STEP #5:** Click on the "Nodes" menu item in the navigation bar  
![image](./assets/PE_Nodes_Menu.png)

**STEP #6:** Click on the *learn.localdomain* node hyperlink (should be the only one listed)  
![image](./assets/PE_Learn_Node.png)

**STEP #7:** Click the "Edit" button  
![image](./assets/PE_Edit_Button.png)

**STEP #8:** In the Classes section, type *lvmguide* in the "add a class" input box  

{% aside Editing Class parameters %}

If you click on *Edit Parameters* for the lvmguide class you can see the defaults. **There is nothing for you to do here.** This is just an fyi when you're implementing Puppet and want to know where and how edit class parameters.

{% endaside %}
![image](./assets/PE_Add_lvmguide_Class.png)

**STEP #9:** Click the "Update" button  
![image](./assets/PE_Update_Button.png)

## Let's Run Puppet

We just successfully classified the “learn.localdomain” node with the lvmguide class. Now we need to tell the puppet agent to fetch and enforce the definition for the “learn.localdomain” node.

{% task 3 %}
In order to fetch and apply the catalog we need to manually trigger a puppet run. In your terminal type the following command:

	puppet agent --test

You will see the test scroll in your terminal indicating that apache was installed and the website was set up. **Please note this may take about a minute to run.**

{% tip %}

Running `puppet agent -t` works also.

{% endtip %}

{% task 4 %}
Let's checkout the quest guide! In your browsers address bar, type the following URL: **http://your-ip-address**.

## Exploring The lvmguide Class

Let’s take a high level look at what the lvmguide class does for us. In your terminal you're going to want to cd into the modules directory:

	cd /etc/puppetlabs/puppet/modules

Next, using vim, nano, or a text editor of your choice, open up the init.pp manaifest. Type the following command in you terminal:

	vi manifests/init.pp

{% aside %}

We will learn more detailed information about each of these concepts in future quests. However, this is a leading example of how a few lines of puppet manifest code can automate a relatively complex task.

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

In the above code sample, we see that Class lvmguide defined as follows:

1. It declared class apache with the default_vhost parameter set to false.
2. It declared an apache::vhost for the quest guide
3. It set the document root to `/var/www/html/lvmguide` (which is the default value for the $document_root parameter)
4. It ensures that the directory `/var/www/html/lvmguide` exists and that its contents are managed recursively. 

{% tip %}

The file in the directory are sourced from the lvmguide module.

{% endtip %}

The real power here is that you now have this class in a module that can be assigned to any number of the nodes you wish manage. There is no repetition or any other node-specific code that needs to be written!