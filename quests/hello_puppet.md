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
your companion as you make your way through a series of interactive quests,
using the accompanying VM as a sandbox environment to exercise your Puppet
skills.

We'll begin by introducing you to the `quest` tool. This tool isn't a part of
Puppet itself, but it's going to be an important part of your experience with
the Learning VM. We'll give you a brief overview of how to use the tool and
read the feedback it provides.

Once you're familiar with the quest tool, we'll move on to some of the
most basic and important features of Puppet itself. You'll learn how to install
the Puppet agent on a newly provisioned node and use `puppet resource` and
`facter` to explore the state of that new system. Through these tools, you will
learn about *resources* and *facts*, the fundamental units of information
Puppet uses to manage a system.

Just one more note before we dive in: as you get started with this guide,
remember that Puppet is a powerful and complex tool. We do our best in this
guide to explain concepts as you encounter then, but will occasionally
introduce a topic that needs to wait for a later quest for a full explanation.
(We'll show you how to avoid dependency cycles in your Puppet code, but it's
not always possible to keep them out of learning materials!)

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
incomplete (Unless you got ahead of yourself!). Go ahead and run the `list`
subcommand:

    quest list

Now check the status again to see it marked as complete:

    quest status

If you're curious about how these tasks work, you're welcome to take a look at
the set of tests they run locally at `/usr/src/puppet-quest-guide/tests/`. Or
[in our repository](https://github.com/puppetlabs/puppet-quest-guide). The
source code for the quest tool itself is [here](https://github.com/puppetlabs/quest).

## The Puppet agent

The Puppet agent is the piece of Puppet software that runs on each of the
systems you want to manage. It keeps everything on that system in line with the
desired state defined for it by the central Puppet master server.

If you want to stay specific, the term "Puppet agent" refers particularly to
the `puppet-agent` daemon that communicates between the Puppet master and the
tools used to enforce changes locally. When we install the Puppet agent,
however, we're also installing a suite of tools that go along with it. This
includes tools like `facter` and `puppet resource` that you'll see in this
quest. (In fact, you can do quite a lot with these tools without ever touching
the Puppet agent or connecting to a Puppet master.)

You may also see "Puppet agent," "agent," or "agent node" used to refer to any
system where the Puppet agent is running. To avoid confusion, we'll do our best
to always use "Puppet agent" to refer to the application that communicates with
the Puppet master and "agent node" to refer to a system where the Puppet agent
is installed.

The Puppet master hosts an install script you can easily run from your agent
node that can connect to it. We've pre-installed the Puppet master on the
Learning VM (we can call the Learning VM itself our "master node"), so this
install script is ready to be loaded and run by our (soon-to-be) agent node.

<div class = "lvm-task-number"><p>Task 3:</p></div>

The quest tool has already set up a new node with the FQDN
`hello.learning.puppetlabs.vm` where you can try out the agent installation. Go
ahead and use `ssh` to connect to this node.

    ssh root@hello.learning.puppetlabs.vm

Then paste in the following command to grab the the agent installer from the
master and run it:

    curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

(You can find full documentation of the agent installation process, including
specific instructions for Windows and other operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html))

## Resources

Now that you have the Puppet agent installed, let's take some time to
investigate this node Puppet's-eye-view.

At the core of Puppet is something called the *resource abstraction layer*.
for Puppet, each bit of the system you want to manage (a user, file, service,
or package, to give some common examples) can be represented in Puppet code as
a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Take a quick look. Still connected to your agent node, enter:

    puppet resource user root

We'll get into the specifics of the syntax when you start writing your own
resource declarations in a later quest. For now, what's important is to see
that Puppet can translate back and forth between this Puppet code
representation of a resource and the native tools and data of the system where
it's running.

<div class = "lvm-task-number"><p>Task 4:</p></div>

To see how this works, we'll first create a new user and validate that that
user exists with the native CentOS commands. If you're familiar with a
different operating system and don't know what these commands on CentOS, I'll
give you a moment to google it now.

Just kidding:

    useradd galatea

And to check that that the new user exists:

    cat /etc/passwd | grep galatea

Now let's say you want to keep track of your new user's full name by adding a
comment to the user account.

    usermod galatea -c "Galatea of Cyprus"

<div class = "lvm-task-number"><p>Task 5:</p></div>

That's simple enough, but let's see how you can do the same operations through
the abstraction layer that Puppet provides. First, let's delete the user to
give us a clean slate. You can use the Puppet resource tool with specific
parameters to modify the state of a resources, including creating or destroying
it with the `ensure` parameter.

    puppet resource user galatea ensure=absent

If you like, check `/etc/passwd` again to see that the user is really gone.

Now to recreate the user, enter the same command with the `ensure` parameter
changed from `absent` to `present`.

    puppet resource user galatea ensure=present

Puppet will go ahead and create that user for you. Note that there's nothing
mysterious going on here. Behind the scenes, Puppet is using just the same
`useradd` command you did to create this user.

Similarly, we can change the comment. You could do it with the same
`parameter=value` shorthand we used to create the user, but let's try it
another way. You can pass the `--edit` or `-e` flag to the `puppet resource`
command to drop the current state of a specified into a text editor. Any
changes you make to this Puppet code representation of the resource will then
be applied when you save and exit.

    puppet resource -e user galatea

Go ahead and edit the resource to add the comment line as below. (If you're new
to the Vim text editor, you can use the `i` command to get into `insert` mode,
and `ESC` to return to command mode followed by `:wq` to save quit.) 

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
had been on a Windows system, for example Puppet would have used the Active
Directory Services Interface (ADSI) to set the user's description field.

This ability to use the same consistent language to handle resources with
different tools and across different operating systems is the *abstraction*
we're talking about in *resource abstraction layer*.

## Facter

A program called `facter` is another key tool that makes this resource
abstraction possible. As its name suggests, `facter` collects data about a
system and makes them availale to Puppet (and you) as a set of structured
facts.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Let's take a look at `facter`.

Still connected to your agent node, use `facter` to explore the `os` fact.

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

<div class = "lvm-task-number"><p>Task 5:</p></div>

You can also dig in to this data to pull out specific facts. Try getting just
the family of the OS:

    facter os.family

Behind the scenes, this the same tool Puppet was using to figure out how to
handle the changes to the user resource.

As you'll see in the Puppet agent section below, these facts also help the
central Puppet master decide what kind of configuration you want to apply to
each agent node in your infrastructure. So facts from `facter` not only help
Puppet figure out how to manage your resources, they also help Puppet determine
which resources on a system it should be managing and what values those
resources' parameters should have.

## Running the Puppet agent

The `puppet resource` and `facter` commands we explored above show you how
Puppet's resource abstraction works on your agent node, but how does this fit
into the kind of master-agent architecture that lets you centralize control of
your infrastructure? The best way to understand this system is to try it out.

The agent installer already set up a configuration file that tells your agent
node how to find and connect to the Puppet master, but the Puppet master
doesn't yet know that you want to add this node to your infrastructure until
you sign a certificate for that node. This certificate signing process is
essential for keeping your Puppetized infrastructure secure and keeps you from
accidentally adding nodes to your infrastructure (where they might pick up
inintended configuration changes).

<div class = "lvm-task-number"><p>Task 6:</p></div>

Just to see what happens, try to trigger a puppet agent run without your agent
node's certificate signed.

    puppet agent -t

You'll see a notification like the following:

    Exiting; no certificate found and waitforcert is disabled

No problem, we just have to sign the certificate. First, exit your SSH session
to return to the your Puppet master node.

    exit

Use the `puppet cert` tool to list the unsigned certificates on your network.

    puppet cert list

Now go ahead and sign the cert for `hello.learning.puppetlabs.vm`.

    puppet cert sign hello.learning.puppetlabs.vm

With that taken care of, reconnect to your agent node and we'll go over the
anatomy of a Puppet agent run.

    ssh root@hello.learning.puppetlabs.vm

Trigger another agent run. With your certificate signed, you'll see a bit more
happen.

    puppet agent -t

Though we haven't yet told Puppet to manage any resources on the system, you'll
see a lot of text scroll by. Because this is the node's first Puppet run, it
has to grab the source code for all tools and extensions on the master. This
ensures that an agent node has everything it needs to correctly enforce the
desired state defined for it by the master.

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

Though the Puppet agent isn't telling you everything it's doing here, this
output gives you a few clues about the conversation between the agent and
master. For now, we'll focus on two key steps in this conversation. First, the
agent node sends a collection of facts to the Puppet master. These are the same
facts you see when you run the `facter` tool yourself. The Puppet master takes
these facts and uses them with your Puppet code to compile a catalog. While
Puppet code can contain conditionals, variables, and other features that make
it an expressive language, the catalog is the final parsed list of resources
and parameters that the Puppet agent will apply to the node.

![image](../assets/SimpleDataFlow.png)

When you triggered a Puppet run, the Puppet master didn't find any Puppet code
to apply to your agent node, so it didn't make any changes. Let's elaborate a
little bit on the user resource you were looking at above by adding a home
directory. Generally organize all your Puppet code into classes and modules,
but just this once, we're going to make an exception and write some code
directly into a special file called the `site.pp` manifest.

First, end your SSH session to return to the Puppet master.

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

It's always a good idea to check your code before you run it. 

    puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp

Now SSH to your agent node:

    ssh root@hello.learning.puppetlabs.vm

And trigger another puppet run

    puppet agent -t

## Review

Nice work, you've completed your first quest on your way to Puppet mastery!

We reviewed the `quest begin` `quest --help` and `quest status` commands that
you'll be using throughout this guide to keep your progress on the VM
coordinated with the quests and tasks you read here.

We also covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

With that new node set up, you learned about the *resource abstraction layer*,
a key Puppet concept. You used `facter` to view system facts, and used the
`puppet resource` tool to investigate and modify the state of the `ntp` package
and `ntpd` serivce.

In the next quest, you will build on this foundation by using the PE console
to fully automate NTP on your infrastructure.
