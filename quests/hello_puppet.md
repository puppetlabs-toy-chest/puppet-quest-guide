{% include '/version.md' %}

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

In this quest, we cover the installation of the Puppet agent and some of the
core ideas involved in managing infrastructure with Puppet.  You'll learn how
to install the Puppet agent on a newly provisioned system and use `puppet
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

## Quest setup

Each time you start a new quest, the `quest` tool uses Puppet to set up
everything you'll need to complete that quest. In this case, we're going to
be teaching you about the Puppet agent and showing you how to install it on a
new system, so the quest tool has prepared that system for you. (In the
background, the quest tool uses a tool called Docker to quickly create and
destroy lightweight containerized nodes as needed before each quest.)

Be aware that each time you begin a new quest, any agent nodes you were using
will be destroyed and a new environment will be created for the next quest.
In most cases, the significant work of a quest will be completed on the
Learning VM itself, which hosts your Puppet master and all your Puppet code.
If you return to a partially complete quest

## What is Puppet?

Puppet is a configuration management tool designed to manage the state of
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
Use `ssh` to connect to this node with the password `puppet`.

    ssh root@hello.learning.puppetlabs.vm

Paste in the following command to grab the the agent installer from the
master and run it. (If the script hangs due to an inability to access the
required repositories, it may be due to changing networks or network settings
since the agent node was created. The easiest way to address this is by
rebooting the VM and running `quest begin hello_puppet` to re-create the agent
node.)

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

We'll get into the specifics of this syntax when you start writing your own
resource declarations in a later quest. For now, let's explore how Puppet's
resource abstraction layer allows it to translate back and forth between
Puppet's code representation of a resource and the native tools and data of the
system where it's running.

<div class = "lvm-task-number"><p>Task 5:</p></div>

To see how this works, we'll first use native CentOS commands to create a new
user:

    useradd ollie

To check that that the new user exists, we can look at the /etc/passwd file:

    cat /etc/passwd | grep ollie

<div class = "lvm-task-number"><p>Task 6:</p></div>

Let's say you've decided you want to keep track of the full name of this user
account's owner. Use the `usermod` tool to add a comment with this information.

    usermod ollie -c "Oliver J. Dragon"

Notice that while these operations are quite simple, they involve the use of
several different tools. This isn't a problem if you're working on a system
you're familiar with, but begins to be a significant impediment if you want to
manage an infrastructure of many nodes that might run a variety of operating
systems. Let's see how you can leverage Puppet's resource abstraction layer
to do the same tasks with a single tool.

In addition to letting you view the state of a resource, the Puppet resource
tool allows you to modify, create, and remove resources on the system. The
`ensure` attribute represents whether or not a resource exists on a system. You
can remove a user account by setting the ensure attribute to `absent`, and add
one by setting it to `present`.

<div class = "lvm-task-number"><p>Task 7:</p></div>

We'll create a user with the puppet resource tool, we'll specify the resource
type `user` and the name of the user we want to create followed by the `ensure`
parameter with its value set to `present`. Go ahead and create a new user
account with the name `dolores`

    puppet resource user dolores ensure=present

There's nothing too mysterious happening here as Puppet creates this user
account. In fact, Puppet is using just the same `useradd` command behind the
scenes that you used to create the user yourself.

<div class = "lvm-task-number"><p>Task 9:</p></div>

Next, let's see about setting the comment. You could do have done it by
including another `paramter=value` statement to the end of the initial puppet
resource command, or running the command again with the comment parameter set,
but we'll take the opportunity to demonstrate a different way of doing things.
If you pass the `--edit` or `-e` flag to the `puppet resource` command, it will
drop the current state of the specified resource in a text editor. Any changes
you make to this Puppet code representation of the resource are applied when
you save and exit.

    puppet resource -e user galatea

Edit the resource to add the comment line as shown in the code block below. (If
you're new to the Vim text editor, you can use the `i` command to get into
`insert` mode, and `ESC` to return to command mode followed by `:wq` to save
quit.) 

```puppet
user { 'dolores':
  ensure           => 'present',
  comment          => 'Dolores Dragon',
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
the changes you specified when you edited the `dolores` user resource. If you
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
the OS family:

    facter os.family

As you'll see in the section below, the Puppet master uses these facts to
decide what kind of configuration you want to apply to each node in your
infrastructure.

In a later quest, you'll see how you can use facter along with conditional
logic to write portable and flexible Pupet code.

## Running the Puppet agent

The `puppet resource` and `facter` commands we explored above show you how
Puppet's resource abstraction layer works on your agent node. This tools are
useful for exploring the state of an unfamiliar system, but by themselves,
don't offer a considerable advantage over native commands or scripting. The
real benefit of Puppet's RAL is as an interface for centralization and
automation.

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

No problem, you just have to sign the certificate. For now, we'll show you how
to do it from the command line, but if you prefer a GUI, the PE console
includes tools for certificate management.

<div class = "lvm-task-number"><p>Task 13:</p></div>

First, exit your SSH session to return to the your Puppet master node.

    exit

Use the `puppet cert` tool to list the unsigned certificates on your network.

    puppet cert list

Sign the cert for `hello.learning.puppetlabs.vm`.

    puppet cert sign hello.learning.puppetlabs.vm

<div class = "lvm-task-number"><p>Task 14:</p></div>

With that taken care of, the Puppet agent on your node will be able to contact
the Puppet master to get a compiled catalog of all the resources on the system
it needs to manage. By default, the Puppet agent will do this every thirty
minutes to automatically keep your infrastructure in line. Because it would be
difficult to demonstrate much with these scheduled background runs, however,
we have disabled these periodic agent runs. Instead, you will manually trigger
puppet runs so you can observe their effects.

Go ahead and reconnect to your agent node:

    ssh root@hello.learning.puppetlabs.vm

Trigger another agent run. With your certificate signed, you'll see some
action.

    puppet agent -t

While you haven't told Puppet to manage any resources on the system, you'll see
a lot of text scroll by. This process is called pluginsync. During pluginsync,
your agent checks to ensure that it has all the tools it needs to implement the
RAL and facter, and that the versions of these tools match what's on the
master.

This pluginsync process adds a lot of clutter. Without it, you'd see something
like the following.

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
catalog. While Puppet code can contain language features such as conditionals
and variables, the catalog is the final parsed list of resources and parameters
that the Puppet master sends back to the agent node to be applied.

![image](../assets/SimpleDataFlow.png)

When you triggered a Puppet run, the Puppet master didn't find any Puppet code
to apply to your agent node, so it didn't make any changes. If we want to see
anything interesting happen, we'll have to tell the master what code we want
applied to our node.

<div class = "lvm-task-number"><p>Task 15:</p></div>

End your SSH session to return to the Puppet master:

    exit

Generally, you will organize all your Puppet code into classes and modules, but
just this once, we're going to make an exception and write some code directly
into the `site.pp` manifest. This manifest is one of the ways the Puppet master
determines what Puppet code should be applied to a node. Open the `site.pp`
manifest for the production environment.

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

With this node declaration in place, you can tell Puppet what resources you
want to manage on that node. For now, we'll use a resource type called `notify`
to output a message that we'll see as the Puppet run occurs and in Puppet's
logs. The notify resource type is a little different than most other resource
types in that it doesn't actually make any changes to the system. It can be
very useful, however, for testing and troubleshooting.

```puppet
node hello.learning.puppetlabs.vm {
  notify { 'Hello Puppet!':
    message => 'Hello Puppet!',
  }
}
```

(Note that while you'll learn the syntax more quickly if you type your code
manually, if you do want to paste content into vim, you can hit `ESC` to enter
command mode and type `:set paste` to disable the automatic formatting. Be sure
to press `i` to return to insert mode before pasting your text.)


Remember, use `ESC` then `:wq` to save and exit.

<div class = "lvm-task-number"><p>Task 16:</p></div>

It's always a good idea to check your code before you run it. 

    puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp

<div class = "lvm-task-number"><p>Task 17:</p></div>

Now SSH to your agent node:

    ssh root@hello.learning.puppetlabs.vm

And trigger another puppet run

    puppet agent -t

The output will include something like this:

    Notice: Hello Puppet!
    Notice: /Stage[main]/Main/Node[hello.learning.puppetlabs.vm]/Notify[Hello Puppet!]/message: defined 'message' as 'Hello Puppet!'
    Notice: Applied catalog in 0.45 seconds

Now that you've seen how to manage user accounts with the RAL and use the
`site.pp` manifest on your master to create node definitions, you're ready to
bring the two concepts together. In the next quest, you'll see how to create
a Puppet module to manage user accounts.

## Review

Nice work, you've finished the first quest on your way to Puppet mastery. At
this point you should have a general understanding of what Puppet is and some
of its core concepts and tools.

We covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

With that new node set up, you learned about the *resource abstraction layer*,
a key Puppet concept. You used `facter` to view system facts, and used the
`puppet resource` tool to investigate and modify the state of a `user`
resource.

We introduced the role of certificates in the master/agent relationship, and
the communication that takes place during a puppet agent run. Finally, you
defined a `notify` resource in the master's `site.pp` manifest and triggered
a puppet agent run on the agent node to enforce that configuration.
