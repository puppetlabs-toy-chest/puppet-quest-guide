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

As you get started with this guide, remember that Puppet is a complex tool.
While this guide will generally explain concepts as you encounter them, more
advanced feature before it has been covered in depth.

Ready to get started? Run the following command on your Learning VM:

    quest begin hello_puppet

## Why Puppet?

Puppet is a configuration management tool that allows you to define changes and
automate maintenance of the systems in your infrastructure.

### Portable

Puppet's declarative language gives you a single powerful syntax for describing
desired state across Windows and Unix-like systems.

### Centralized

With Puppet's master-agent architecture, there's no need to connect to systems
individually to make changes. Once the Puppet agent service is running on a
system, it will periodically establish a secure connection to the Puppet master
to fetch any Puppet code you've applied to it and make any changes necessary to
bring the system in line with the desired state you described.

### Modular

The Puppet Forge is a repository of community maintained modules that give you
everything you need to manage common applicatons and services.

### Cutting Edge

With Puppet provides a stable platform for bringing new technologies into
production. Puppet's integrations with technologies like Docker, Kubernetes,
and Mesos let you engage with next generation software in a way that's simple,
reliable, and consistent.

## The Puppet Agent

In this quest, we'll focus on the Puppet agent.

The Puppet agent runs on each of the systems you want Puppet to manage. It
handles communication with the central Puppet master server and manages any
changes needed to keep its system in line with the desired state.

When you install the Puppet agent you also get a suite of packages that support
it. This includes tools like `facter` and `puppet resource` that you can also
use independently to view the state of the system in the same way Puppet does
behnid the scenes.

## Installation

The Puppet master hosts an install script you can easily run from any system
that can connect to it. There's already a Puppet master running on the Learning
VM, so this install script is ready to be loaded and run by your (soon-to-be)
agent node.

<div class = "lvm-task-number"><p>Task 3:</p></div>

To get you started quickly, we've done a little magic to provide you with a
system you can use to try out the agent installation. Use `ssh` to connect to
`hello.puppet.vm`. Your credentials are:

**username: learning**
**password: puppet**

    ssh learning@hello.puppet.vm

Copy in the command listed below to grab the the agent installer from the
master and run it.

(If the script hangs due to an inability to access the required repositories,
it may be due to changing networks or network settings since the agent node was
created. The easiest way to address this is by rebooting the VM and running
`quest begin hello_puppet` to restart this quest and re-create the agent node.)

    curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

You can find full documentation of the agent installation process, including
specific instructions for Windows and other operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html)

## Resources

The Puppet agent comes with a set of supporting tools you can use to explore
your system from a Puppet's-eye-view.

One of Puppet's core concepts is the *resource abstraction layer*. For Puppet,
each aspect of the system you want to manage (users, files, services, and
packages, are some of the most common examples) is represented in Puppet code
as a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Take a look. Be sure you're connected your agent node, then enter:

    puppet resource file /home/learning/www/hello_puppet.html

What you see is the Puppet code representation of a resource with the type
`user` that corresponds to the `root` user on the agent node:

``` puppet
file { '/home/learning/www/index.html':
  ensure => 'absent',
}
```

Let's break down this resource syntax.

``` puppet
resource_type { 'resource_title':
   parameter => 'value',
}
```

The **resource type** tells Puppet what kind of thing the resource describes,
whether it's one of the **core types** like a user, file, service, or package,
or a custom type from a module, like an apache vhost or mysql database.
Internally, this type tells Puppet which set of tools to use to manage the
resource.

The **resource title** is a unique name that Puppet uses to identify the
resource internally. You probably noticed that the title, in this case, is
actually the path of the file we want to manage. Most resources have a special
parameter called a **namevar** that will use the value of the resource title if
it isn't explicitly set. We could actually write the resource as below and it
would refer to the same file:

file { 'my_html_file':
  ensure => 'absent',
  path   => 'home/learning/www/index.html',
} 

Because a file's path parameter is required and specifies a unique place in the
filesystem, this namevar default lets you save time of picking a unique title
and writing out the path parameter explicitly. All resource types have a
namevar, which you can find in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

The body of a resource is a list of **parameter value pairs** that follow the
pattern `parameter => value`. The parameters and possible values vary from type
to type. These specify the state of the resource on the system. Documentation
for resource parameters is provided in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

You may have noticed that the `home/learning/www/index.html` resource had a
single parameter value pair: `ensure => 'absent'`. The `ensure` parameter
specifies the basic state of a resource. Most resources can have an `ensure`
value of `absent` or `present` to specify whether or not the resource exists on
the system.

Because the `file` resource can be used to manage directories and symlinks as
well as ordinary files, the ensure attribute can take the `file`, `directory`,
and `link` values as well as the basic `present` and `absent`. (The `present`
value will create an ordinary file if nothing exists at the specified path,
but will not replace an existing directory or symlink. A more specific value
will replace what's already there if it does not match that value.)

<div class = "lvm-task-number"><p>Task 5:</p></div>

To see how this works, we'll first use native CentOS commands to create the
file:

    touch /home/learning/www/index.html

To check that that the file exists, you can use the `ls` command:

    ls /home/learning/www/index.html

Now use the `puppet resource` tool to see how this change is represented in
Puppet's resource syntax.

    puppet resource file /home/learning/www/index.html

Now that the file exists on the system, Puppet has more information to provide.

``` puppet
file { '/home/learning/www/index.html':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

The Puppet resource tool 

<div class = "lvm-task-number"><p>Task 6:</p></div>

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
