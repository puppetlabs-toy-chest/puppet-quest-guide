---
title: Power of Puppet
layout: default
---

# The Power of Puppet

### Prerequisites

- Welcome Quest

## Quest objectives

- Using existing Puppet modules, configure the Learning VM to serve a web
  version of the Quest Guide.
- Learn how the Puppet Enterprise (PE) console's node classifier can manage the
  Learning VM's configuration.

## Getting started

In this quest you will use the Puppet Enterprise (PE) console in conjunction
with existing modules to cut away much of the complexity of a common
configuration task.  You'll configure the Learning VM to serve the content of
this Quest Guide as a locally accessible static HTML website. We'll show you how
you can use Puppet and freely available Puppet modules to fully automate the
process instead of writing code or using standard terminal commands.

As you go through this quest, remember that while Puppet can simplify many
tasks, it's a powerful and complex tool. We will explain concepts as needed to
complete and understand each task in this quest, but sometimes we'll hold off on
a fuller explanation of some detail until a later quest. Don't worry if you
don't feel like you're getting the whole story right away; keep at it and we'll
get there when the time is right!

When you're ready to get started, type the following command:

    quest --start power 

## Forging ahead

A **module** is a bundle of Puppet code packaged along with the other files and
data you need manage some aspect of a system. Need to set up NTP? There's a
module for that. Manage system users? That too. But likely you'll want to do
both of these things and more. Modules let you mix and match reusable bits of
Puppet code to make achieving your desired configuration as painless as
possible. Modules are designed to be, well, *modular*.

But where do these modules come from? The [Puppet
Forge](http://forge.puppetlabs.com) is a public repository of modules
contributed by members of the Puppet community, including many written and
maintained by Puppet Labs employees and partners. The Forge also includes a list
of PE Supported Modules, which Puppet Labs has rigorously tested and is
committed to supporting and maintaining through their lifecycle.

{% task 1 %}
---
- execute: puppet module install puppetlabs-apache
{% endtask %}

To get started setting up the Quest Guide website, you'll need to download and
install Puppet Labs' `apache` module from the Forge. (If you're offline or behind
a firewall, check the aside below for instructions on using the cached version
of the module.) 

The `apache` module gives you everything you need to automate installing,
configuring, and starting an Apache webserver. In your terminal, enter the
following command to install the module:

    puppet module install puppetlabs-apache
	
{% aside Offline? %}
If you don't have internet access, run the following terminal commands to use
cached versions of all the modules used in the quests:

    cd /usr/src/forge/
    for m in `ls`; do puppet module install $m --ignore-dependencies ; done

{% endaside %}

This command tells Puppet to download the Puppet Labs `apache` module from the
Forge and place it in the directory specified as Puppet's _modulepath_. The
modulepath defines the directory on your puppet master where Puppet saves
modules you install and accesses modules you already have installed. For Puppet
Enterprise, this defaults to `/etc/puppetlabs/puppet/environments/production/modules`.

To help set up the Quest Guide website, we've also prepared an `lvmguide`
module. It's already in the VM's module path, so there's no need to fetch it
from the Forge. This small `lvmguide` module draws on some resources from the
`apache` module and uses some code and content of its own to finish the
configuration of the Quest Guide website. 

### The lvmguide and apache modules

Before using these modules, you should know a little more about how they work. 

The `lvmguide` *module* includes Puppet code that defines an `lvmguide` *class*.
In Puppet, a *class* is simply a named block of Puppet code organized in a way
that defines a set of associated system resources. A class might install a
package, customize an associated configuration file for that package, and start
a service provided by that package. These are related and interdependent
processes, so it makes sense to organize them into a single configurable unit: a
class.

While a module can include many classes, it will often have a main class that
shares the name of the module. This class serves as the access point for the
module's functionality and calls on other classes within the module or from
pre-requisite modules as needed.

## Put your modules to use

In order to configure the Learning VM to serve you the Quest Guide website,
you'll need to *classify* it with the `lvmguide` class. Classification tells
Puppet which classes to apply to which machines in your infrastructure. Though
there are a few different ways to classify nodes, we'll be using the PE
console's node classifier for this quest.

{% task 2 %}
---
- execute: facter ipaddress
{% endtask %}

To access the PE console you'll need the Learning VM's IP address. Remember, you
can use the `facter` tool packaged with PE.

    facter ipaddress

{% tip %}
You can see a list of all the system facts accessible through facter by running
the `facter` command.
{% endtip %}

Open a web browser on your host machine and go to `https://<IPADDRESS>`, where
`<IPADDRESS>` is the Learning VM's IP address. (Be sure to include the `s` in
`https`)

Your browser may give you a security notice because the PE console certificate is
self-signed. Go ahead and click through this notice to continue to the console.

When prompted, use the following credentials to log in:

  * username: **admin** 
  
  * password: **learningpuppet**

### Create a node group

Now that you have access to the PE console, we'll walk you through the steps
needed to classify the "learning.puppetlabs.vm" node (i.e. the Learning VM)
with the `lvmguide` class.

First, you'll create a **Learning VM** node group. Node groups allow you to 
segment all the nodes in your infrastructure into separately configurable groups
based on information collected by the `facter` tool.

Click on *Classification* in the console navigation bar. It may take a moment to load.

{% figure '../assets/classification.png' %}

From here, enter "Learning VM" as a new node group name, and click *Add group* to create
your new node group.

{% figure '../assets/node_group.png' %}

Click on the new group to set the rules for this group. You only want the Learning VM
in this group, so create a rule that will match on the name `learning.puppetlabs.vm`.

{% figure '../assets/rule.png' %}

Click *Add rule*, then click the *Commit 1 change* button in the bottom right of the console
interface to commit your change.

{% figure '../assets/commit.png' %}

### Add a class

Now that the `lvmguide` class is available, you can use it to classify the node
`learning.puppetlabs.vm`. Under the *Classes* tab in the interface for the 
Learning VM node group, enter `lvmguide` in the *Class name* text box, then 
click the *Add class* and *Commit 1 change* buttons to confirm your changes.

### Run puppet

Now that you have classified the `learning.puppetlabs.vm` node with the
`lvmguide` class, Puppet knows how the system should be configured, but it won't
make any changes until a Puppet run occurs. 

The puppet agent daemon runs in the background on any nodes you manage with
Puppet. Every 30 minutes, the puppet agent daemon requests a *catalog* from the
puppet master. The puppet master parses all the classes applied to that node and
builds the catalog to describes how the node is supposed to be configured. It
returns this catalog to the node's puppet agent, which then applies any changes
necessary to bring the node into the line with the state described by the
catalog.

{% task 3 %}
- execute: |
    curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H "Content-Type: application/json" -X POST -d '{"name":"Learning VM", "environment":"production", "parent":"00000000-0000-4000-8000-000000000000", "classes":{"lvmguide" : {} },  "rule":["or", ["=", "name", "learning.puppetlabs.vm"]]}' https://localhost:4433/classifier-api/v1/groups
- execute: puppet agent --test
{% endtask %}

Instead of waiting for the puppet agent to make its scheduled run, use the
`puppet agent` tool to trigger one yourself. In the terminal, type the
following command:

  puppet agent --test

This may take a minute to run. This is about the time it
takes for the software packages to be downloaded and installed as needed. After
a brief delay, you will see text scroll by in your terminal indicating that
Puppet has made all the specified changes to the Learning VM.

Check out the Quest Guide website! In your browser's address bar, type the following URL:
`http://<IPADDRESS>`. (Though the IP address is the same, using `https` will
load the PE console, while `http` will load the Quest Guide as a website.)

From this point on you can either follow along with the website or with the PDF,
whichever works best for you.

## IP troubleshooting

The website for the quest guide will remain accessible for as long as the VM's
IP address remains the same. If you move your computer or laptop to a different
network, or if you suspend your laptop and resumed work on the Learning VM
later, the website may not be accessible.

In case any of the above issues happen, and you end up with a stale IP address,
run the following commands on the Learning VM to get a new IP address.
(Remember, if you're ever unable to establish an SSH session, you can log in
directly through the interface of your virtualization software.)

Refresh your DHCP lease:

    service network restart

Find your IP address:

    facter ipaddress

## Explore the lvmguide class

To understand how the `lvmguide` class works, you can take a look under the
hood. In your terminal, use the `cd` command to navigate to the module
directory. (Remember, `cd` for 'change directory.')

    cd /etc/puppetlabs/puppet/environments/production/modules

Next, open the `init.pp` manifest.

    vim lvmguide/manifests/init.pp

{% highlight puppet %}
class lvmguide (
  $document_root = '/var/www/html/lvmguide',
  $port          = '80',
) {

  # Manage apache, the files for the website will be 
  # managed by the quest tool
  class { 'apache':
    default_vhost => false,
  }
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }
}
{% endhighlight %}

(To exit out of the file without saving any changes, make sure you're in
`command` mode in vim by hitting the `esc` key, and enter the command `:q!`.)

Don't worry about understanding each detail of the syntax just yet. For now,
we'll just give you a quick overview so the concepts won't be totally new when
you encounter them again later on. 

#### Class title and parameters:

{% highlight puppet %}
class lvmguide (
  $document_root = '/var/www/html/lvmguide',
  $port = '80',
) {
{% endhighlight %}

The class `lvmguide` takes two parameters, as defined in the parentheses
following the class name. Parameters allow variables within a class to be set as
the class is declared. Because you didn't specify parameter values, the two
variables `$document_root` and `$port` were set to their defaults,
`/var/www/html/lvmguide` and `80`.

#### Include the apache module's apache class:
{% highlight puppet %}
  class { 'apache': 
    default_vhost => false,
  }
{% endhighlight %}

The `lvmguide` class declares another class: `apache`. Puppet knows about the
`apache` class because it is defined by the `apache` module you installed
earlier. The `default_vhost` parameter for the `apache` class is set to `false`.
This is all the equivalent of saying "Set up Apache, and don't use the default
VirtualHost because I want to specify my own."

#### Include the apache module's vhost class:
{% highlight puppet %}
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }
{% endhighlight %}

This block of code declares the `apache::vhost` class for the Quest Guide with
the title `learning.puppetlabs.vm`, and with `$port` and `$docroot` set to those
class parameters we saw earlier. This is the same as saying "Please set up a
VirtualHost website serving the 'learning.puppetlabs.vm' website, and set the
port and document root based on the parameters from above."

#### The files for the website

The files for the quest guide are put in place by the `quest` command line tool,
and thus we don't specify anything about the files in the class. Puppet is
flexible enough to help you manage just what you want to, leaving you free to
use other tools where more appropriate. Thus we put together a solution using
Puppet to manage a portion of it, and our `quest` tool to manage the rest.

It may seem like there's a lot going on here, but by the time you get through
this quest guide, a quick read-through will be enough to get the gist of
well-written Puppet code. One advantage of a declarative language like Puppet is
that the code tends to be much more self-documenting than code written in an
imperative language.

### Repeatable, portable, testable

It's cool to install and configure an Apache httpd web server with a few lines
of code and some clicks in the console, but keep in mind that the best part
can't be shown with the Learning VM. Once the `lvmguide` module is installed,
you can apply the `lvmguide` class to as many nodes as you like, even if they
have different specifications or run different operating systems.

And once a class is deployed to your infrastructure, Puppet gives you the
ability to manage the configuration from a single central point. You can
implement your updates and changes in a test environment, then easily move them
into production.

## Updated content

Before continuing on to the remaining quests, let's ensure that you have the
most up to date version of the quest-related content. Now that we have the
website configured, please run the following command:

    quest update

This will download an updated PDF, files for the quest guide website, as well as
the tests for the quests.

You can find a copy of the updated Quest Guide PDF at:
`http://<IPADDRESS>/Quest_Guide.pdf`, or in the
`/var/www/html/lvmguide/` directory on the VM.

## Review

Great job on completing the quest! You should now have a good idea of how to
download existing modules from the Forge and use the PE console node classifier
to apply them to a node. You also learned how to use the `puppet agent --test`
command to manually trigger a puppet run.

Though we'll go over many of the details of the Puppet DSL in later quests, you
had your first look at a Puppet class, and some of the elements that make it up.
