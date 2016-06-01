# Hello Puppet

## Quest objectives

- Familiarize yourself with this guide and the `quest` tool.
- Install the Puppet agent on a newly provisioned node.
- Use `puppet resource` and `facter` to inspect and modify the user accounts
  on your new node.

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
systems you want to manage and keeps it in line with how the central Puppet
master thinks it should be configured.

If you want to stay specific, the term "Puppet agent" refers particularly to
the `puppet-agent` daemon that communicates between the Puppet master and the
tools used to enforce changes locally. When we install the Puppet agent,
however, we're also installing a suite of tools that go along with it—including
tools like `facter` and `puppet resource` that you'll see in this quest. (In
fact, you can do quite a lot with these tools without ever touching the Puppet
agent or connecting to a Puppet master.)

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

First, use `ssh` to connect to the node where you're going to install the
Puppet agent. (Remember, this node has already been set up for you by the quest
tool.)

    ssh root@hello.learning.puppetlabs.vm

Then paste in the following command to run the agent installer:

    curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

(You can find full documentation of the agent installation process, including
specific instructions for Windows and other operating systems on the [docs
page](https://docs.puppet.com/pe/latest/install_agents.html))

## Resources and Facts

Now that you have the Puppet agent installed, let's take some time to
investigate this node from what you could call a Puppet's-eye-view.

At the core of Puppet is something called the *resource abstraction layer*.
for Puppet, each bit of the system you want to manage (a user, file, service,
or package, to give some common examples) can be represented in Puppet code as
a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Take a quick look. Still connected to your agent node, enter:

    puppet resource user root

We'll get into the specifics of the syntax when you start writing your own
resource declarations in a later quest. For now, what's important is that
Puppet can translate back and forth between this Puppet code representation of
a resource and the native tools and data of the system where it's running.

<div class = "lvm-task-number"><p>Task 4:</p></div>

First, let's create a new user with the native CentOS command. If you're
familiar with a differnet operating system and don't know what this command is
on CentOS, I'll give you a moment to google it now.

Just kidding:

    useradd galatea

Now let's validate that that user exists:

    cat /etc/passwd | grep galatea

<div class = "lvm-task-number"><p>Task 5:</p></div>

Now, let's see how you can do the same operations through the abstraction layer
that Puppet provides. First, let's delete the user to give us a clean slate.
You can use the Puppet resource tool with specific parameters to modify the
state of a resources, including creating or destroying it.

    puppet resource user galatea ensure=absent

If you like, check `/etc/passwd` again to see that the user is really gone.


This ability to use the same consistent language to handle resources with
different tools and across different operating systems is the *abstraction*
we're talking about in *resource abstraction layer*.

A program called `facter` is another key tool that makes this resource
abstraction possible. As its name suggests, `facter` collects data about a
system and makes them availale to Puppet (and you) as a set of structured
facts.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Let's take a look at `facter`.

If you're not connected to your agent node, use SSH to reconnect.

    ssh root@hello.learning.puppetlabs.vm

Now use `facter` to see the OS data available on this node:

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

You can also dig in to this data to pull out specific facts. Try getting the


    facter os.name

'facter' helps
Puppet know which native tools it should use on the system and can be used with
conditionals in Puppet code to select correct software and configuration
options.

(You can also explicitly specify which package manager Puppet should use. For
example, on a Windows system you can choose to use Chocolatey instead of the
native Windows tools to install from an MSI or EXE.)

<div class = "lvm-task-number"><p>Task 4:</p></div>

Configuring the Network Time Protocol (NTP) service is a common first step in
managing your infrastructure. Let's check if the NTP package is installed.
Because you're on an Ubuntu system, you can use `dpkg`:

    dpkg -s ntp

Now that you have the Puppet agent installed, you can also use the `puppet
resource` tool to do the same check wihout considering the operating system of
the node you happen to be connected to:

    puppet resource package ntp

<div class = "lvm-task-number"><p>Task 5:</p></div>

To set up NTP on your infrastructure, you'll likely want to configure a server
that the `other nodes in your infrastructure will coordinate with. With the
simple two-node network we're using for this quest, we might nominate the
Puppet master node to run this service as well.

Let's exit our SSH session and check the status of the NTP package on
our Puppet master:

    exit

Again, use `facter` to find the `os.name` fact:

    facter os.name

You'll see that you're now on a CentOS system. This means that you need to use
`rpm` instead of `dpkg`:

    rpm -qa | grep ntp

But you can also just use `puppet resource` again:

    puppet resource package ntp

## Modifying resources

While using `facter` and `puppet resource` to get information about a system is
convenient, the real power of Puppet's resource abstraction layer is that it
can also make changes. Not only can it translate the state of your system into
a Puppet resource, but it can also use a resource as a model for making changes
on your system.

You already saw that the NTP package was installed on your Puppet master, so
let's take a look at the NTP daemon service.

    puppet resource service ntpd

You'll see that the service is stopped and not enabled.

    service { 'ntpd':
      ensure => 'stopped',
      enable => 'false',
    }

Let's change that. Instead of using the full Puppet code syntax you see in the
output of the `puppet resource` command, we can use a shorthand to directly
set the key-value pairs of the resource and apply those changes to the system.

    puppet resource service ntpd ensure='running' enable='true'

Puppet will notify you of the changes it has made and show the new state of the
`ntpd` resource.

    Notice: /Service[ntpd]/ensure: ensure changed 'stopped' to 'running'
    service: { 'ntpd':
      ensure => 'running',
      enable => 'true',
    }

Note that you didn't have to worry about implementation details here. Puppet
knew to use Systemd commands to start the service because we're on CentOS 7. If
we had been on Centos 6, it would have used SysVinit.

There are some configuration details we would normally want to adjust in
`/etc/ntp.conf`. When we get to the next quest, we'll address how you can
easily manage this kind of configuration with Puppet. For now, though, we'll
settle for directing our agent node to use the master as its NTP server.

SSH to your agent node:

    ssh root@hello.learning.puppetlabs.vm

Take a look at the configuration file.

    vim /etc/ntp.conf

You'll see that there are several default servers already specified.

    server 0.ubuntu.pool.ntp.org
    server 1.ubuntu.pool.ntp.org
    server 2.ubuntu.pool.ntp.org
    server 3.ubuntu.pool.ntp.org

NTP is more reliable if it can poll multiple servers, so we'll leave in those
first three defaults, but we can replace the third with 
`learning.puppetlabs.vm` and tell NTP to prefer this server. There are several
ways to manage configuration files with Puppet that we'll address in a later
quest, but for now, go ahead and edit the configuration by hand. (If you're not
used to Vim, note that you'll need to type `i` to enter insert mode.) Replace
the `server 3.ubuntu.pool.ntp.org` line with:

    server learning.puppetlabs.vm prefer

Once you've made your change, save and exit Vim. (To do this, you first exit
insert mode with `ESC`, then type `:wq` and hit enter. That's `:` to get a
command prompt within Vim, then `w` to write the file and `q` to quit.)

With your configuration set, use the `puppet resource` tool to start the `ntp`
service. Note that while the resource abstraction layer will figure out how to
manage resources on different systems, you still have to be aware of variations
in the names of things like services and packages. In this case, the service is
called `ntp` on Ubuntu, and `ntpd` on CentOS. (You'll see in later quests how
Puppet modules can still help you handle this kind of variation.)

    puppet resource service ntp ensure='running'

Now check to see the updated list of peers NTP is connected to:

    ntpq -p

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
