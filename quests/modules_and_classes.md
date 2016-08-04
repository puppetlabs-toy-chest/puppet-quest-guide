{% include '/version.md' %}

# Writing Classes and Manifests

## Quest objectives

- Create a site directory to define configuration specific to your
  infrastructure.
- Create a Puppetfile to define the modules you want to use in your
  environment.

## Get started

In the Hello Puppet quest, you saw how to install the Puppet agent, explore the
Resource Abstraction Layer (RAL), and use the `site.pp` manifest to manage a
`notify` resource on your agent node. As we noted, however, your `notify`
resource told Puppet to raise a message, but didn't actually enforce any
any changes on the system. In part, this was because we didn't want to get you
in the habit of managing systems by declaring resources directly in your
`site.pp` manifest.

In this quest, we'll get you started installing and managing Puppet code
following the same best-practice design patterns our Professional Services
Engineers at Puppet use in the field.

Ready to get started? Run the following command on your Learning VM:

    quest begin roles_and_profiles

## MOTD

A Message of the Day (MOTD) file defines what a user will see on logging in to
a system. This is equivalent to a Logon Message on a Windows system. Managing
this message is a great example for us to use because it's

  1. Very simple
  1. Something you might actually use in production

What's displayed in the MOTD is defined in the `/etc/motd` file on a system.
All you have to do to set the MOTD is manage `/etc/motd` with a Puppet `file`
resource. Using `facter`, the system information tool we introduced in the last
quest, you can easily insert node specific information into the MOTD. 

In this quest, you'll be working with two agent nodes,
`motd-dev.learning.puppetlabs.vm` and `motd-prod.learning.puppetlabs.vm`.

Before managing a system with Puppet, it's generally a good idea to check that
you have a solid understanding of how that system functions. In this case,
let's take a look at the MOTD file manually to verify that it works as
expected. It's a simple concept, but it's worth going through the exercise to
ensure that you have a precise idea of what Puppet will have to do to manage
it.

<div class = "lvm-task-number"><p>Task 1:</p></div>

SSH to the `motd-dev` agent node. (Note that the Puppet agent is pre-installed
on this node.)

    ssh root@motd-dev.learning.puppetlabs.vm

Use the `puppet resource` tool to set the content for the `/etc/motd` file
resource.

    puppet resource file /etc/motd content='test'

Exit and re-connect to the node to verify that your message appears.

That kind of one-off change is simple enough, but SSHing to a machine and
running the `puppet resource` command won't scale very well.

## Classes and Manifests

The first step towards Puppetizing your infrastructure is to define the desired
state of the resources you want to manage in a persistent format.

At its simplest, this can be done by writing your resource declarations in a
text file with the `.pp` extension. This file is called a **manifest**.

Each manifest will generally contain a single class. A **class** is a named
block of Puppet code that declares the set of related resources needed to
manage something on a system. (In the case of the MOTD, we only need one
resource, but you will often find a combination of `package`, `file`, and
`service` resources used to install an applciation, modify its configuration
files, and manage an assocaited service.) Once it's defined, a class can be
declared as a single unit. This allows you to define a component once and
re-use it as needed across multiple nodes in your infrastructure.

For Puppet to find a class, it must be included in a directory structure
defined by your Puppet master's `modulepath` configuration setting. Puppet
loads any classes it finds, making them available to be declared in your
`site.pp` manifest's node blocks or used in the PE console's node classifier.

First, end your SSH session to the `motd-dev` node if you're still connected.
We'll be working from the master's production code environment, so cd to that
directory. (We'll get into some of the details of this directory structure
soon enough—for now, just follow along.)

    cd /etc/puppetlabs/code/environments/production/

Now create a manifest to define a simple MOTD class.

    vim site/profile/manifests/motd.pp

Use

``` puppet
class profile::motd {
  file { '/etc/motd':
    ensure  => file,
    content => 'Hello Puppet!'
  }
}
```

You will see something similar to this:

``` puppet
file { '/etc/motd':
  ensure  => 'file',
  content => '{md5}d8e8fca2dc0f896fd7cb4cb0031ba249',
  ctime   => '2016-07-30 08:08:04 +0000',
  group   => '0',
  mode    => '0644',
  mtime   => '2016-07-30 08:08:04 +0000',
  owner   => '0',
  type    => 'file',
}
```

There are a few differences in how Puppet represents a resource it reads from
the system and how you'll want to define it when you write Puppet code.

You might notice that the `content` parameter is set to an MD5 sum, and not
the actual content of the file. Puppet uses these MD5 sums quicky compare
file contents on the system to those defined in your Puppet code. This means
that when it reads a file from the system into Puppet code, it will represent
its content as an MD5, rather than displaying the full content.

For now, all we'll worry about are the ensure and content attributes. Beca

## Classes, modules

Now that you've validated that the MOTD displays as expected, the next step
is to get some Puppet code into a format that will make it easy to apply to any
nodes in your infrastructure.


Using a Puppet class requires two steps. First, you must define it by writing a
class definition and saving it to a manifest file. Puppet will parse this
manifest and remember your class definition. The class can then be declared to
apply the resource declarations it contains to a node in your infrastructure.

Classes can take **parameters** that allow you to customize the resources they
contain. They can also contain conditional logic that lets them define
different resources or set resource parameters to different values depending on
class parameters, facts, or an external data source such as Hiera.

There are three 

some Puppet code to manage that `/etc/motd` file. You can use the `puppet
resource` command for a quick look at what this code might look like.

<div class = "lvm-task-number"><p>Task 1:</p></div>

On the `test-01` agent node, write the output of `puppet resource` for
`/etc/motd` to `/tmp/motd.pp`

    puppet resource file /etc/motd > /tmp/motd.pp

That `motd.pp` file you wrote to is called a **manifest**. Manifests are text
files containing Puppet code and marked with the `.pp` extension.

Use Vim to open the file and take a look.

    vim /tmp/motd.pp

``` puppet

```

Puppet's community We're going to take this opportunity the introduce concept of the **module**
and the [Puppet Forge](https://forge.puppet.com/) community repository.

In this quest, you'll use the existing
(puppetlabs-motd)[https://forge.puppet.com/puppetlabs/motd] module to help
Puppetize your MOTD file. By using this existing module, you get the benefits
of thorough

For Puppet to be able to find and use a module, it has to be installed into one
of the directories included in Puppet's `modulepath`.

<div class = "lvm-task-number"><p>Task 1:</p></div>

You can use the `puppet config print` command to inspect the value of any of
Puppet's configuration settings. Take a look at the current `modulepath` value.

    puppet config print modulepath

<div class = "lvm-task-number"><p>Task 1:</p></div>

Use the `puppet module` tool to download the `puppetlabs-motd` module into your
master's modulepath. (In a later quest we'll go over setting up a `Puppetfile`
as a single source of truth for the modules in your environment. For now,
however, we're using the `puppet module` tool for the sake of simplicity.)

    puppet module install puppetlabs-motd

Let's take a look at what you get when you download the module.

    tree /etc/puppetlabs/code/environments/production/modules/motd



A module is a reusable, sharable unit of Puppet code. It bundles together
everything you need to manage a system or application on your infrastructure,
and generally gives you a single Puppet code interface to manage all aspects of
this system or application, including the installation of necessary packages,
the setup of configuration files, and the management of associated services.

At their root, modules are little more than a structure of directories and
files that follow a consistent naming concention. This structure gives Puppet a
consistent way to locate whatever classes, files, templates, plugins and
binaries are required to fulfill a module's function.

The Forge is a free public repository where you can find a wide array of
modules maintained by Puppet and our community members. The Forge provides some
quality scoring metrics that can give you a quick idea of how well a module
conforms to good coding standards, as well as listings of [Puppet
Supported](https://forge.puppet.com/supported) and [Puppet
Approved](https://forge.puppet.com/approved) that have been reviewed and
approved by Puppet.




## Managing modules with a Puppetfile

For Puppet to be able to find and use a module, it has to be installed into one
of the directories included in Puppet's `modulepath`.

<div class = "lvm-task-number"><p>Task 1:</p></div>

You can use the `puppet config print` command to inspect the value of any of
Puppet's configuration settings. Take a look at the current `modulepath` value.

    puppet config print modulepath

Because a module is fully contained by its structure on the file system, Puppet
doesn't actually care *how* a module gets into its modulepath. For the sake of
consistency, however, we recommend using a tool called `r10k` to deploy your
modules from a list defined in a `Puppetfile`. This file gives you a single
source of truth for all the modules you're using in a Puppet environment.




To effectively deploy a

For now we'll go over how to use values from `facter` and class parameters to
customize the content of your node's MOTD. We'll cover Hiera and some of the
more advanced Puppet language features in a later quest.

Before you start writing code, though, let's create a directory structure to
help keep everything organized. Generally, your infrastructure will be a
combination of site-specific classes that help you define exactly how you want
your infrastructure to look, and general purpose classes like the ones defined
in the community maintained modules available on the Puppet Forge.

    mkdir -p /etc/puppetlabs/code/site/profile/manifests/


## Review

Nice work, you've finished...

In this quest, you...

Next, you...
