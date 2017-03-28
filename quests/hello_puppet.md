{% include '/version.md' %}

# Hello Puppet

## Quest objectives

- Get started with the basics: what is Puppet and what does it do?
- Install the Puppet agent on a new system.
- Understand Puppet's resources and the resource abstraction layer (RAL).

## Get started

> Any sufficiently advanced technology is indistinguishable from magic.

> - Arthur C. Clarke

This quest will begin your hands-on introduction to Puppet. We'll start by
installing the Puppet agent and learning some of the core ideas involved in
managing infrastructure with Puppet. Once the Puppet agent is installed on a
new system, you will use the `puppet resource` tool to explore the state of
that system. Through this tools, you will learn about *resources*, the
basic units Puppet uses to describe and manage a system.

Ready to get started? Run the following command on your Learning VM:

    quest begin hello_puppet

## What is Puppet?

Before getting into the details of how Puppet works and how to use it, let's
take a moment to review what Puppet is and why it's worth learning. When we
talk about Puppet, we're often using the name as a short-hand for a collection
of tools and services that work in concert to help you define how you want the
systems in your infrastructure configured then automate the process of bringing
those systems into your desired state and keeping them there. As you continue
with this guide, we'll take a deeper into dive Puppet's individual components,
but for now we'll review some of the key points that distinguish Puppet's
approach from the other tools you might use to manage your systems.

Puppet lets you to define a desired state for all the systems in your
infrastructure. Once this state is defined, Puppet automates the process of
getting your systems into that state and keeping them there.

This state for your systems is written in Puppet code, a domain specific
language lets you define how each server or device in your infrastructure
should be configured. This **infrastructure as code** approach means that users
concerned with version control, compliance, CI/CD, and testing can easily fold
infrastructure into their development and release workflow.

Puppet code is a **declarative** language, which means that you Puppet only
need to describe the desired state for his or her systems, not the steps
needed to get there. Once you've specified in Puppet code which aspects of a
system you want Puppet to manage, a Puppet agent service running in the
background makes any changes needed to bring the system into compliance with
the desired state.

Puppet's declarative approach requires that you think about the systems in your
infrastructure differently than you would if you were using scripts, golden
images, or runbooks. Puppet has several advantages that help you spend time
focused on **what** your infrastructure can do for you rather than **how**
you're going to get there.

**Puppet is portable.** Its declarative language gives you a single syntax for
describing desired state across Windows and Unix-like operating systems,
network devices, and containers. You don't have to switch language and toolset
every time you start work on a new system. Learning Puppet gives you a skillset
that can be carried over across projects and roles.

**Puppet is centralized.** With Puppet's master/agent architecture, there's no
need to connect to systems individually to make changes. Once the Puppet agent
service is running on a system, it will periodically establish a secure
connection to the Puppet master, fetch any Puppet code you've applied to it and
make any changes necessary to bring the system in line with the desired state
you described. The fact that centralized control is built in from Puppet's
foundations makes monitoring and compliance that much easier. Puppet also
offers orchestration features that allow you to coordinate changes across 

**Puppet is community driven.** Joining the [Puppet
community](https://puppet.com/community) means you can benefit from the
knowledge and code contributed by thousands of other users around the world.
Ask questions on [Slack](https://slack.puppet.com/),
[IRC](http://webchat.freenode.net/?channels=puppet), or our
(Ask)[http://ask.puppet.com/] Q&A site. Attend [Puppet User Groups (PUGs)] to
connect with other Puppet users in your area. Get a jump start on your Puppet
infrastructure with [the Puppet Forge](forge.puppet.com), a repository of
modules maintained by Puppet and the Puppet community that give you everything
you need to manage common applications and services. The Forge has a wide range
of modules to help you manage everything from NTP and SQL Server to Minecraft.
The base of well tested and reviewed code means that you can get started
puppetizing key aspects of your infrastructure right out of the gate.

**Puppet connects you to the cutting edge.** Puppet provides a stable platform
for bringing new technologies into production. Integrations with Docker,
Kubernetes, Mesos, AWS, vSphere and others let you engage with next generation
tools in a way that's simple, reliable, and consistent.

## The Puppet agent

As we noted above, what we call Puppet is actually a variety of tools and
services that work together to help you manage and coordinate the systems in
your infrastructure. Though this ecosystem gives you a great degree of power
and control, the complexity can leave a new user wondering where to start. So
this was the first question we had to answer as we were putting together this
guide: "where do we begin?"

By introducing the Puppet agent and some of the command line tools included in
the agent installation, we hope to strike the right balance between the big
picture view of Puppet and the the bottom-up fundamentals. You'll begin to
understand the agent's role in the broader Puppet architecture, as well as the
details of how interacts with the system where it's installed.

The Puppet agent runs on each of the systems you want Puppet to manage. The
agent serves as the bridge between the system where it's installed and the
Puppet master server. The agent communicates in two directions: out to this
master server to see how its system should be configured, then with native
system tools to check the actual state of the system and make any changes
necessary to bring it in line with the desired state.

For now, we'll set aside the agent's interactions with the Puppet master server
and focus on the tools Puppet uses to check and modify a system's state. When
you install the Puppet agent you get a set of command-line tools that allow you
to interact directly with a system in the same way the Puppet agent does. This
includes software like `facter` and the `puppet resource` command.  Using these
tools will help you understand how the Puppet agent sees and modifies the state
of the system where it's running.

## Agent installation

Though we're focusing on the local  of the Puppet agent in this quest, we'll
still be working the context of the master/agent architecture set up on the
Learning VM. The Learning VM itself has the Puppet Enterprise stack
pre-installed, including the Puppet master service. For each quest, the quest
tool will provide one or more agent systems that you will explore and configure
with Puppet over the course of the quest.

For this quest, we've prepared a fresh system where you can install the Puppet
agent and explore some of the tools it provides. The Puppet master hosts an
agent install script that makes it easy to install the Puppet agent on any
system that can access the master.

<div class = "lvm-task-number"><p>Task 3:</p></div>

To get started, use `ssh` to connect to `hello.puppet.vm`. Your credentials
are:

**username: learning**  
**password: puppet**

    ssh learning@hello.puppet.vm

Now that you're connected to this system, copy in the command listed below to
load the agent installer from the master and run it.

If the script hangs due to an inability to access the required repositories,
it may be due to changing networks or network settings since the agent was
created. The easiest way to address this is by rebooting the VM and running
`quest begin hello_puppet` to restart this quest and re-create the Agent
system.

    sudo curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

You will see some text stream across the screen as the installation runs.

Note that if your Agent is running on a different operating system than
the Master, you will have to take some steps to ensure that the correct
installation script available. In this case, our master and agent are both
running CentOS 7, so we don't have to worry about this difference. You can find
full documentation of the agent installation process, including specific
instructions for Windows and other operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html)

## Resources

As we noted above, the Puppet agent comes with a set of supporting tools you
can use to explore your system from a Puppet's-eye-view. Now that the agent is
installed, we can explore these tools and see what they can teach you about how
Puppet works.

One of Puppet's core concepts is something called the *resource abstraction
layer*. For Puppet, each aspect of the system you want to manage (such as a
user, file, service, or package) is represented in Puppet code as a unit called
a *resource*. The `puppet resource` tool allows you to view and modify these
resources directly.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Be sure you're still connected your Agent system, and run the following command
to ask Puppet to describe a file resource:

    puppet resource file /tmp/test

What you see is the Puppet code representation of a resource. In this case,
the resource's type is `file`, and its path is
`/tmp/test":

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

Let's break down this resource syntax into its different components so we
can see the anatomy of a resource a little more clearly.

```puppet
type { 'title':
   parameter => 'value',
}
```

The **type** is the kind of thing the resource describes. It can be a **core
type** like a user, file, service, or package, or a **custom type** that you
have implemented yourself or installed from a module. Custom types let you
describe resources that might be specific to a service or application (for
example, an Apache vhost or MySQL database) that Puppet doesn't know about out
of the box. Internally, a resource's type points Puppet to the set of tools it
will use to manage the resource on your system.

The body of a resource is a list of **parameter value pairs** that follow the
pattern `parameter => value`. The parameters and possible values vary from type
to type. These specify the state of the resource on the system. Documentation
for resource parameters is provided in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

The **resource title** is a unique name that Puppet uses to identify the
resource internally. In the case of our file resource you looked at above, the
resource's title was the path of the file on the system: `/tmp/test`. Each
resource type has a unique identifying feature that can be used as the resource
title. A `user` resource will use the account name as a title, for example, and
a `package` resource will use the name of the package you want to manage.

There's an caveat to resource titles, however, that can trip up new users. You
can set a `file` resource's title to something other than the file's path as
long as you also set a `path` parameter for that resource.  For example:

```puppet
file { 'my_file':
   ensure => 'present',
   path   => '/tmp/test'
}
```

A `file` resource's path will default to the title if the `path` parameter is
not explicilty set. The same pattern applies for other resources, such as a
user's account name or package name as we mentioned above. This parameter that
defaults to the title is called a **namevar**. You can find more information
about the **namevar** for different resource types in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

Now that you're more familiar with the resource syntax, let's take another look
at that file resource.

``` puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

Notice that it has a single parameter value pair: `ensure => 'absent'`. The
`ensure` parameter tells us the basic state of a resource. For the *file* type,
this parameter will tell us if the file exists on the system and if it does,
whether it's a normal file, a directory, or link.

<div class = "lvm-task-number"><p>Task 5:</p></div>

Puppet is telling us that this file doesn't exist. Let's see what happens when
you use the `touch` command to create a new empty file at that path.

    touch /tmp/test

Now use the `puppet resource` tool to see how this change is represented in
Puppet's resource syntax.

    puppet resource file /tmp/test

Now that the file exists on the system, Puppet has more to say about it. The
resource Puppet shows includes the first two parameter value pairs shown below
as well as some information about the file's owner and when it was created and
last modified.

``` puppet
file { '/tmp/test':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

The value of the `content` parameter may not be what you expected. When the
`puppet resource` tool interprets a file in this resource declaration syntax,
it converts the content to an MD5 hash. This hashing lets Puppet quickly
compare the actual content of a file on your system against the expected
content to see if any change is necessary. This kind of shortcut means that
the way Puppet shows an existing resource on the system and the way that
resource would be fully defined in Puppet code's resource syntax can be a
little different.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Let's use the `puppet resource` tool to add some content to our file.

Running `puppet resource` with a `parameter=value` argument will tell Puppet to
modify the resource on the system to match the value you set. (Note that while
this is a great way to test out changes in a development environment, it's not
a good way to manage production infrastructure.  Don't worry, though, we'll get
to that soon enough.) We can use this to set the content of your file resource.

    puppet resource file /tmp/test content='Hello Puppet!'

Puppet will display some output as it checks the hash of the existing content
against the new content you provided. When it sees that the hashes don't match,
it sets the file's content to the value of your new `content` parameter.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Take another look at the file to see the modified content:

    cat /tmp/test

### Types and Providers

This translation back and forth between the state of the system and Puppet's
resource syntax is the heart of Puppet's **resource abstraction layer**. To get
a better understanding of how this works, let's take a look at another resource
type, the `package`. As an example, we'll look at the package for the Apache
webserver `httpd` package.

    puppet resource package httpd

Because this package doesn't exist on the system, Puppet shows you the
`ensure => purged` parameter value pair. This `purged` value is similar to the
`absent` value you saw earlier for the `file` resource, but in the case of the
package resource, indicates that both the package itself and any configuration
files installed by the package manager are both absent.

```puppet
package { 'httpd':
  ensure => 'purged',
}
```

As we mentioned above, each resource **type** has a set of **providers**. A
**provider** is the translation layer that sits between Puppet's resource
representation and the native system tools it uses to discover and modify the
underlying system state. Each resource type generally has a variety of
different providers.

These providers can seem invisible when everything is working correctly, but
it's important to understand how they interact with the underlying tools.

As it turns out, the quickest way to see the inner workings of a provider
is to break it. Let's tell Puppet to install a non-existant package named
`bogus-package` and take a look at the error message.

    puppet resource package bogus-package ensure=present

You'll see an error message telling you that yum wasn't able to find the
specified package, including the command that Puppet's yum provider tried to
run when it saw that the package wasn't already installed.

```
Error: Execution of '/bin/yum -d 0 -e 0 -y install bogus-package' returned 1:
Error Nothing to do
```

Puppet selects a default provider based on the agent's operating system and
whether the commands associated with that provider are available. You
can override this default by setting a resource's `provider` parameter.

Let's try installing the same fake package again, this time with the pip
provider.

     puppet resource package bogus-package ensure=present provider=pip

You'll see a similar error with a failed pip command instead of the yum
command.

```
Error: Execution of '/bin/pip install -q bogus-package' returned 1: Could not
find a version that satisfies the requirement bogus-package (from versions: )
No matching distribution found for bogus-package
```

Now that you know what's happening in the background, let's try installing
a real package with the default provider.

    puppet resource package httpd ensure=present

This time, Puppet will be able to install the package, and the value of the
`ensure` parameter will show you the specific version of the package installed.

```puppet
package { 'httpd':
  ensure => '2.4.6-45.el7.centos',
}
```

Note that though you didn't specify a version of the package to install, Puppet
defaults to installing the latest available version.

## Review

In this quest we went over what Puppet is and some of the advantages of
managing your infrastructure with Puppet's declarative domain-specific
language and master/agent architecture.

We covered the the installation of the Puppet agent on a new system using an
install script hosted on the Puppet master. Once the agent and suite of
supporting tools were installed, we went over the fundamentals of Puppet's
**resource abstraction layer** (RAL), including **resources**, resource
**types**, and the **providers** that translate between your Puppet code and
the native system tools.

Now that you've learned some of the core concepts behind Puppet, you're ready
to use these ideas in a more realistic workflow. As we noted above, the `puppet
resource` command is a great way to explore a system or test Puppet code, but
it's not the tool you'll be using to automate your configuration management.

In the next quest, you'll learn how to save your Puppet code to a file called a
**manifest** and organize it into a **module** within your Puppet master's
**codedir**. This structure lets Puppet keep track of where to find all the
resources it needs to manage your infrastructure.

We'll show you how the Puppet agent communicates with your Puppet master to
fetch a compiled list of resources called a **catalog** based on Puppet code
kept on the master.

