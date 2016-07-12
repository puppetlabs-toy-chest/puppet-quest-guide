# Hello Puppet

## Quest objectives

- Familiarize yourself with this guide and the `quest` tool.
- Install the Puppet agent on a newly provisioned node.
- Use `puppet resource` to inspect and modify the user accounts
  on your new node.
- Use `facter` to find and display system information.
- Understand the idea of Puppet's resource abstraction layer (RAL).

## Get started

> Any sufficiently advanced technology is indistinguishable from magic.

> - Arthur C. Clarke

Welcome to the Quest Guide for the Puppet Learning VM. This guide will be
your companion as you make your way through the Learning VM's series of
interactive lessons.

Before getting into Puppet itself, this lesson starts off with an introduction
to the `quest` tool that you will use throughout the following lessons to track
your progress.

Next, we'll cover the installation of the Puppet agent and some of the core
ideas involved in managing infrastructure with Puppet.  You'll learn how to
install the Puppet agent on a newly provisioned system and use `puppet
resource` and `facter` to explore the state of that system. Through these
tools, you will learn about *resources* and *facts*, the fundamental units of
information Puppet uses to manage a system.

As you get started with this guide, remember that Puppet is a powerful and
complex tool. This guide will generally explain concepts as you encounter
them. For the sake teaching to best practices, however, you will sometimes
need to make use of a more advanced feature before it has been covered in
depth.

Ready to get started? Run the following command on your Learning VM:

    quest begin hello_puppet

## An introduction to the quest tool

Each time you start a new quest, the `quest` tool uses Puppet to set up
everything you'll need to complete that quest. In this case, we're going to
be teaching you about the Puppet agent and showing you how to install it on a
new system, so the quest tool has prepared that system for you. (In the
background, the quest tool uses a tool called Docker to quickly create and
destroy lightweight containerized nodes as needed before each quest.) We'll
move on to that installation in a moment, but first let's review a couple more
features of the quest tool.

First, go ahead and use the `--help` flag with the `quest` command to list the
available subcommands.

<div class = "lvm-task-number"><p>Task 1:</p></div>

    quest --help

As you entered that command, you might have noticed that the status line in the
bottom right of your terminal changed. This status line helps you keep track of
your progress through the *tasks* in each quest.

<div class = "lvm-task-number"><p>Task 2:</p></div>

To see a more detailed list of these tasks, use the `status` subcommand. Give
it a try now. 

    quest status

You'll see that `Task 2: View the list of available quests` is still
incomplete. To complete this task, run the `list` subcommand:

    quest list

Now check the status again to see it marked as complete:

    quest status

(If you're curious about how these tasks work, take a look at the set of tests
in the `/usr/src/puppet-quest-guide/tests/` directory on the Learning VM. The
source code for the quest tool itself is
[here](https://github.com/puppetlabs/quest).)

## What is Puppet?

Puppet is an configuration management tool designed to manage the state of
resources across your infrastructure. Puppet's declarative language provides a
flexible way to specify the desired state for each node in your puppetized
network. The Agent-Master architecture automates and centralizes the process of
applying your Puppet code. The Puppet master server ensures that the correct
configuration is securely and consistently applied to each Puppet agent node in
your infrastructure.

## The Puppet Agent

In this quest, we'll be focusing on the Puppet agent.

The Puppet agent is the piece of Puppet software that runs on each of the
systems you want Puppet to manage. It keeps everything on that system in line
with the desired state defined for it by the central Puppet master server.

To be precise, the term "Puppet agent" refers to the `puppet-agent` daemon that
communicates between the Puppet master and the tools used to enforce changes
locally. When we install the Puppet agent, however, we're also installing a
suite of packages that support it. This includes tools like `facter` and
`puppet resource` that you will use in this quest to explore the state of an
agent node.

You may see "Puppet agent," "agent," or "agent node" used to refer to any
system where the Puppet agent is running. To avoid confusion, this guide will
use "Puppet agent" to refer to the `puppet-agent` daemon itself, and "agent
node" to refer to a system where the Puppet agent is installed.

## Installation

The Puppet master hosts an install script you can easily run from any system
that can connect to it. We've pre-installed the Puppet master on the Learning
VM, so this install script is ready to be loaded and run by your (soon-to-be)
agent node.

<div class = "lvm-task-number"><p>Task 3:</p></div>

The quest tool has already set up a new node with the FQDN
`hello.learning.puppetlabs.vm` where you can try out the agent installation.
Use `ssh` to connect to this node.

    ssh root@hello.learning.puppetlabs.vm

Paste in the following command to grab the the agent installer from the
master and run it:

    curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

(You can find full documentation of the agent installation process, including
specific instructions for Windows and other operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html))

## Resources

As noted above, the Puppet agent is installed with a set of supporting tools
you can use to explore your system from a Puppet's-eye-view.

One of Puppet's core concepts is the *resource abstraction layer*. For Puppet,
each aspect of the system you want to manage (users, files, services, and
packages, are some of the most common examples) is represented in Puppet code
as a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Take a look. Be sure you're ssh'd to your agent node, then enter:

    puppet resource user root

What you see is the Puppet code representation of a resource with the type
`user` that corresponds to the `root` user on the agent node:

``` puppet
user { 'root':
  ensure           => present,
  comment          => 'root',
  gid              => '0',
  home             => '/root',
  password         => '$1$jrm5tnjw$h8JJ9mCZLmJvIxvDLjw1M/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '0',
}
```

We'll get into the specifics of the syntax when you start writing your own
resource declarations in a later quest. For now, let's explore how Puppet's
resource abstraction layer allows it to translate back and forth between
Puppet's code representation of a resource and the native tools and data of the
system where it's running.

<div class = "lvm-task-number"><p>Task 5:</p></div>

To see how this works, we'll first use native CentOS commands to create a new
user:

    useradd galatea

and to check that that the new user exists:

    cat /etc/passwd | grep galatea

<div class = "lvm-task-number"><p>Task 6:</p></div>

Let's say you've decided you want to keep track of the full name of this user
account's owner. Go ahead and add a comment with this information.

    usermod galatea -c "Galatea of Cyprus"

That's simple enough, but let's see how you can do the same operations through
Puppet and the resource abstration layer.

You can use the Puppet resource tool with specific parameters to modify the
state of a resources, including creating or destroying it with the `ensure`
parameter. We'll start by removing the user `galatea` so you can try recreating
the account with Puppet. The `ensure` attribute represents whether or not a
resource exists on a system. You can remove a user account by setting the
ensure attribute to `absent`.

<div class = "lvm-task-number"><p>Task 7:</p></div>

Go ahead and remove the `galatea` user:

    puppet resource user galatea ensure=absent

If you like, check `/etc/passwd` again to see that the user is really gone.

<div class = "lvm-task-number"><p>Task 8:</p></div>

To recreate the user, enter the same command with the `ensure` parameter
changed from `absent` to `present`.

    puppet resource user galatea ensure=present

Puppet will create that user for you. There's nothing too mysterious happening
here. In fact, Puppet is using just the same `useradd` command behind the
scenes that you used to create the user yourself.

<div class = "lvm-task-number"><p>Task 9:</p></div>

Next, let's see about setting the comment. You could do it with the same
`parameter=value` shorthand you used to create the user, but we'll try it
another way. If you pass the `--edit` or `-e` flag to the `puppet resource`
command, it will drop the current state of a specified in a text editor. Any
changes you make to this Puppet code representation of the resource are applied
when you save and exit.

    puppet resource -e user galatea

Edit the resource to add the comment line as below. (If you're new to the Vim
text editor, you can use the `i` command to get into `insert` mode, and `ESC`
to return to command mode followed by `:wq` to save quit.) 

```puppet
user { 'galatea':
  ensure           => 'present',
  comment          => 'Galatea of Cyprus',
  gid              => '1004',
  home             => '/home/galatea',
  password         => '!!',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '1004',
}
```

Again, Puppet knew to use the `usermod` command in the background to enforce
the changes you specified when you edited the `galatea` user resource. If you
were on a different system, it would use tools appriate for that system. For
example, if you were working on a Windows system, Puppet would have used the
Active Directory Services Interface (ADSI) to set the user's description field.

This ability to use the same consistent language to handle resources with
different tools and across different operating systems is the *abstraction*
we're talking about in *resource abstraction layer*.

## Facter

When you installed the Puppet agent, you also installed a tool called `facter`.
As its name suggests, `facter` collects data about a system and makes them
availale to Puppet (and you) as a set of facts.

<div class = "lvm-task-number"><p>Task 10:</p></div>

On your agent node, use `facter` to inspect the `os` fact:

    facter os

The data output will include everything `facter` knows about the OS and its
architecture.

    {
      architecture => "x86_64",
      family => "RedHat",
      hardware => "x86_64",
      name => "CentOS",
      release => {
        full => "7.1.1503",
        major => "7",
        minor => "1"
      },
      selinux => {
        enabled => false
      }
    }

<div class = "lvm-task-number"><p>Task 11:</p></div>

You can also dig in to this data to pull out specific facts. Try getting just
the family of the OS:

    facter os.family

As you'll see in the section below, the Puppet master uses these facts to
decide what kind of configuration you want to apply to each node in your
infrastructure.

## Running the Puppet agent

The `puppet resource` and `facter` commands we explored above show you how
Puppet's resource abstraction layer works on your agent node. This tools are
useful for exploring the state of an unfamiliar system, but by themselves,
don't offer a considerable advantage over native commands or scripting. The
real power of Puppet's RAL is as an interface for centralization and
automation.

Think of it this way: if you're planning to do the work yourself, a universal
screwdriver doesn't seem like much more than a novel addition to your
already-full toolbox. If you're building a robot to do your work for you,
however, you'll be much better off giving it a single tool with a universal
interface than bolting on a new arm for every size philips and fearson in your
workshop.

Let's walk through a Puppet agent run so you can understand how this system
works.

When you installed the Puppet agent, it set up a configuration file that tells
the agent node how to find and connect to the Puppet master. Until the Puppet
master knows to trust the Agent, however, you won't be able to complete a
Puppet agent run. To authenticate your agent node to the Puppet master, you
will have to sign its certificate. This allows SSL communication between the
Puppet master and agent nodes.

<div class = "lvm-task-number"><p>Task 12:</p></div>

Just to see what happens, try to trigger a puppet agent run without your agent
node's certificate signed. The agent will attempt to contact the Puppet master,
but its request will be rejected.

    puppet agent -t

You'll see a notification like the following:

    Exiting; no certificate found and waitforcert is disabled

No problem, you just have to sign the certificate. (If you prefer a GUI, you
can do this easily through the PE console. For now, we'll show you how to do it
from the command line.)

<div class = "lvm-task-number"><p>Task 13:</p></div>

First, exit your SSH session to return to the your Puppet master node.

    exit

Use the `puppet cert` tool to list the unsigned certificates on your network.

    puppet cert list

Sign the cert for `hello.learning.puppetlabs.vm`.

    puppet cert sign hello.learning.puppetlabs.vm

<div class = "lvm-task-number"><p>Task 14:</p></div>

With that taken care of, reconnect to your agent node:

    ssh root@hello.learning.puppetlabs.vm

Trigger another agent run. With your certificate signed, you'll see some
action.

    puppet agent -t

While you haven't told Puppet to manage any resources on the system, you'll see
a lot of text scroll by. Because this is the node's first Puppet run, it has to
synchronize the set of local tools with the ones on the master. This process is
called pluginsync.

This pluginsync process adds a lot of clutter. Without it, you'd see something
like the following. (Feel free to trigger another puppet run to get a cleaner
output yourself. As we'll discuss later, Puppet is generally *idempotent* which
means that running it multiple times won't change the outcome.)

```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for hello.learning.puppetlabs.vm
Info: Applying configuration version '1464919481'
```

Though this output only shows a few of the things the Puppet agent is doing, it
gives you a few clues about the conversation between the agent and master. For
now, we'll focus on two key steps in this conversation.

First, the agent node sends a collection of facts to the Puppet master. These
are the same facts you see when you run the `facter` tool yourself. The Puppet
master takes these facts and uses them with your Puppet code to compile a
catalog. While Puppet code can contain conditionals, variables, and other
features that make it an expressive language, the catalog is the final parsed
list of resources and parameters that the Puppet agent will apply to the node.

![image](../assets/SimpleDataFlow.png)

When you triggered a Puppet run, the Puppet master didn't find any Puppet code
to apply to your agent node, so it didn't make any changes. Let's elaborate a
little bit on the user resource you were looking at above by adding a home
directory. Generally organize all your Puppet code into classes and modules,
but just this once, we're going to make an exception and write some code
directly into a special file called the `site.pp` manifest.

<div class = "lvm-task-number"><p>Task 15:</p></div>

End your SSH session to return to the Puppet master.

    exit

Now open the `site.pp` manifest for the production environment.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

First, we'll create block of code called a node delcaration.

```puppet
node hello.learning.puppetlabs.vm {
}
```

After the Puppet agent sends the facts from a node to the Puppet master, one of
the first step in compiling a catalog is to find a node block that matches the
agent node's fqdn fact. (We'll get into some more elaborate ways you can do
this step—such as using different facts and matching them against regular
expressions—in a later quest.)

Next, add resource declarations for the `galatea` user and her home directory.
(Note that while you'll learn the syntax more quickly if you type your code
manually, if you do want to paste content into vim, you can hit `ESC` to enter
command mode and type `:set paste` to disable the automatic formatting.)

```puppet
node hello.learning.puppetlabs.vm {
  user { 'galatea':
    ensure  => 'present',
    comment => 'Galatea of Cyprus',
  }
  file { '/home/galatea':
    ensure => 'present',
    owner  => 'galatea',
  }
}
```

Remember, use `ESC` then `:wq` to save and exit.

<div class = "lvm-task-number"><p>Task 16:</p></div>

It's always a good idea to check your code before you run it. 

    puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp

<div class = "lvm-task-number"><p>Task 17:</p></div>

Now SSH to your agent node:

    ssh root@hello.learning.puppetlabs.vm

And trigger another puppet run

    puppet agent -t

## Review

Nice work, you've finished the first quest on your way to Puppet mastery. At
this point you should have a general understanding of what Puppet is and some
of its core concepts and tools.

We reviewed the `quest begin` `quest --help` and `quest status` commands that
you'll be using throughout this guide to keep your progress on the VM
coordinated with the quests and tasks you read here.

We also covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

With that new node set up, you learned about the *resource abstraction layer*,
a key Puppet concept. You used `facter` to view system facts, and used the
`puppet resource` tool to investigate and modify the state of the `ntp` package
and `ntpd` serivce.

After signing your node's certificate, you defined some for that node in a node
declaration block in your master's `site.pp` manifest and triggered a Puppet
agent run to apply those resources.
