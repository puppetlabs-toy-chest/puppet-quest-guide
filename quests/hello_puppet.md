{% include '/version.md' %}

# Hello Puppet

## Quest objectives

- Install the Puppet agent on a newly provisioned node.
- Understand the Puppet's resource abstraction layer (RAL).

## Get started

> Any sufficiently advanced technology is indistinguishable from magic.

> - Arthur C. Clarke

In this quest, you'll begin your introduction to Puppet by installing the
Puppet agent and learning some of the core ideas involved in managing
infrastructure with Puppet. Once the Puppet agent is installed on a newly
provisioned system, you will use the `puppet resource` and `facter` tools to
explore the state of that system. Through these tools, you will learn about
*resources* and the fundamental units of information Puppet uses to manage a
system.

Ready to get started? Run the following command on your Learning VM:

    quest begin hello_puppet

## What is Puppet?

Before getting into the details of how Puppet works and how to correctly use
it, let's take a moment to review what Puppet is and why it's worth learning.

Put in the most general terms, Puppet is a configuration management tool that
allows you to define changes and automate the maintenance of the systems in
your infrastructure. What defines a tool, however, is how it helps you. Let's
take a moment to review some of the ways Puppet can make your life easier.

**Puppet is portable.** Its declarative language gives you a single syntax for
describing desired state across Windows and Unix-like systems, network devices,
and containers. This means you don't have to switch language and toolset every
time you start work on a new system.

**Puppet is centralized.** With Puppet's master-agent architecture, there's no
need to connect to systems individually to make changes. Once the Puppet agent
service is running on a system, it will periodically establish a secure
connection to the Puppet master, fetch any Puppet code you've applied to it
and make any changes necessary to bring the system in line with the desired
state you described.

[**The Puppet Forge**](forge.puppet.com) is a repository of modules maintained
by Puppet and the Puppet community that give you everything you need to manage
common applicatons and services. The Forge has a wide range of modules to help
you manage everything from NTP and SQL Server to Minecraft. 

**Puppet connects you to the cutting edge.** It provides a stable platform for
bringing new technologies into production. Puppet's integrations with Docker,
Kubernetes, Mesos and others let you engage with next generation software in a
way that's simple, reliable, and consistent.

## The Puppet agent

In just a moment, we'll walk you through the installation of your Puppet agent.
First, however, let's take a moment to go over what the Puppet agent is and its
role in your Puppet infrastructure.

The Puppet agent runs on each of the systems you want Puppet to manage. It
communicates with the central Puppet master server and handles any changes
needed to keep its system in line with the desired state. While the Puppet
agent is generally used as part of a Master/Agent architecture, it can also be
used to apply Puppet code locally. This independent use of the agent is often
used to quickly test code on a development system. We take advantage of it
here to demonstrate some of the core concepts of Puppet before moving on to a
more complete master/agent architecture and workflow.

When you install the Puppet agent you also get a suite of packages that support
it. This includes tools like `facter` and `puppet resource`, which you can use
from the command-line to view the state of the system in the same way Puppet
does behnid the scenes.

## Agent installation

The Puppet master hosts an install script you can easily run from any system
that can connect to it. There's already a Puppet master running on the Learning
VM, so this install script is ready to be loaded and run by your (soon-to-be)
agent node.

<div class = "lvm-task-number"><p>Task 3:</p></div>

To get you started, the quest tool has provided you with a system you can use
to try out the agent installation.

Use `ssh` to connect to `hello.puppet.vm`. Your credentials are:

**username: learning**
**password: puppet**

    ssh learning@hello.puppet.vm

Now that you're connected to this system, copy in the command listed below to
load the agent installer from the master and run it.

(If the script hangs due to an inability to access the required repositories,
it may be due to changing networks or network settings since the agent node was
created. The easiest way to address this is by rebooting the VM and running
`quest begin hello_puppet` to restart this quest and re-create the agent node.)

    sudo curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

Note that if your Agent node is running on a different operating system than
the Master, you will have to take some steps to ensure that the correct
installation script available. You can find full documentation of the agent
installation process, including specific instructions for Windows and other
operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html)

## Resources

As we noted above, the Puppet agent comes with a set of supporting tools you
can use to explore your system from a Puppet's-eye-view. Now that the agent is
installed, we'll take a moment to explore these tools and see what they can
teach you about how Puppet works.

One of Puppet's core concepts is something called the *resource abstraction
layer*. For Puppet, each aspect of the system you want to manage (users, files,
services, and packages are some of the most common examples) is represented in
Puppet code as a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Take a look. (Be sure you're still connected your agent node.) Run the
following command to ask Puppet to describe a file resource:

    puppet resource file /home/learning/www/index.html

What you see is the Puppet code representation of a resource. In this case,
the resource's type is `file`, and its path is
`/home/learning/www/index.html":

``` puppet
file { '/home/learning/www/index.html':
  ensure => 'absent',
}
```

Let's break down this resource syntax into its different components so we
can see the anatomy of a resource a little more clearly.

``` puppet
type { 'title':
   parameter => 'value',
}
```

The **type** tells Puppet what kind of thing the resource describes.  It can be
a **core type** like a user, file, service, or package, or a **custom type**
that you have implemented yourself or installed from a module. Custom types let
you use describe resources that might be specific to a service or application
(for example, an Apache vhost or MySQL database) that Puppet doesn't know about
out of the box. Internally, a resource's type is what points Puppet to the set
of tools it will use to manage the resource on your system.

The body of a resource is a list of **parameter value pairs** that follow the
pattern `parameter => value`. The parameters and possible values vary from type
to type. These specify the state of the resource on the system. Documentation
for resource parameters is provided in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

The **resource title** is a unique name that Puppet uses to identify the
resource internally. You probably noticed that the title, in the case of our
file resource, is actually the file's path. All resources have a special
parameter that will default to the value of the resource's title.  In the case
of the file resource, this special parameter is the `path`. We could actually
use a different title for the resource as long as we then set the path
explicitly:

file { 'my_html_file':
  ensure => 'absent',
  path   => 'home/learning/www/index.html',
} 

Because a file's path parameter must be specify a unique path on the
filesystem, letting it do double-duty as a title will save you time and make
your Puppet code easier to read. All resource types have a similar special
parameter that lets the title do double-duty. This special parameter is called
a **namevar**. You can find more information about the **namevar** for
different resource types in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

This can be a little confusing, so let's reiterate: technically, the *title* is
just a unique identifier that let's Puppet keep track of the resource. For
convenience, however, the title will automatically be used as the default for a
parameter called the namevar. The namevar is the *path* in the case of a file
resource, for example, or the *package* you want to install with a *package*
resource.

Now that you're more familiar with the resource syntax, let's take another look
at that file resource.

``` puppet
file { '/home/learning/www/index.html':
  ensure => 'absent',
}
```

Notice that it has a single parameter value pair: `ensure => 'absent'`. The
`ensure` parameter tells us the basic state of a resource. For the *file* type,
this parameter will tell us if the file exists on the system and whether it's a
normal file, a directory, or link.

<div class = "lvm-task-number"><p>Task 5:</p></div>

So Puppet is telling us that this file doesn't exist. Let's see what happens
when you use the `touch` command to create a new empty file at that path.

    touch /home/learning/www/index.html

Now use the `puppet resource` tool to see how this change is represented in
Puppet's resource syntax.

    puppet resource file /home/learning/www/index.html

Now that the file exists on the system, Puppet has more to say about it. The
resource Puppet shows will include the first two parameter value pairs shown
below as well as some information about the file's owner and when it was
created and last modified.

``` puppet
file { '/home/learning/www/index.html':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

When the `puppet resource` tool interprets a file in this resource declaration
syntax, it converts the content to an MD5 hash. This hashing lets Puppet
quickly compare the actual content of a file on your system against the
expected content to see if any change is necessary.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Let's use the `puppet resource` tool to add some content to our file.

Running `puppet resource` with a `parameter=value` argument will tell Puppet to
modify the resource on the system to match the value you set. (Note that while
this is a great way to test out changes in a development environment, it's not
a good way to manage production infrastructure.  Don't worry, though, we'll get
to that soon enough.) We can use this to set the content of your file resource.

    puppet resource file /home/learning/www/index.html content='Hello Puppet!'

Puppet will display some output as it checks the hash of the existing content
against the new content you provided and modifies the content to match the new
value.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Take another look at the file to see the modified content:

    cat /home/learning/www/index.html

### Types and Providers

This translation back and forth between the state of the system and Puppet's
resource syntax is the heart of Puppet's **Resource Abstraction Layer**. To get
a better understanding of how this works, let's take a look at another resource
type, the `package`. Since we were playing with an `index.html` file earlier,
let's stay with that theme and have a look at the package resource for the
Nginx server.

    puppet resource package nginx 

Again, because this package doesn't exist on the system, Puppet shows you the
`ensure => absent` parameter value pair.

```puppet
package { 'nginx':
  ensure => 'absent',
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

Puppet selects a default provider based on a node's operating system and
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

This time, Puppet will show you the specific version of the package installed.

```puppet
package { 'httpd':
  ensure => '2.4.6-45.el7.centos',
}
```

## Review

We covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

Now that you've learned some of the core concepts behind Puppet, you're ready
to use these ideas in a more realistic workflow. As we noted above, the `puppet
resource` command is a great way to explore a system or test Puppet code, but
it's not the tool you'll be using to automate your configuration management.

In the next quest, we'll show you how the Puppet agent communicates with your
Puppet master to fetch a **catalog**, a compiled list of resources, and apply
that catalog to your system.

You'll learn how to save your Puppet code to a file called a **manifest** and
organize it into a **module** within your Puppet master's **codedir**. This
structure lets Puppet keep track of where to find all the resources it needs
to manage your infrastructure.
