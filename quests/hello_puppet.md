{% include '/version.md' %}

# Hello Puppet

## Quest objectives

- Get started with the basics: What is Puppet and what does it do?
- Install the Puppet agent on a new system.
- Understand Puppet's resources and the resource abstraction layer.

## Get started

This quest kicks off a hands-on introduction to managing infrastructure with
Puppet tools and services. You'll start by installing the agent and learning
some of the core ideas involved in managing infrastructure. Once the agent is
installed on a new system, you will use the `puppet resource` tool to explore
the state of that system. Through this tool, you will learn about *resources*,
the basic units that Puppet uses to describe and manage a system.

Ready to get started? Run the following command on your Learning VM to begin
this quest:

    quest begin hello_puppet

## What is Puppet?

Before getting into the details of the Puppet tools and how to use them, let's
discuss what Puppet is and why it's worth learning. The term Puppet is often
used as a shorthand for a collection of tools and services that work in
concert to help define your infrastructure configuration and then automate
the process of bringing the systems into their desired state and keeping them
there.

Continuing with this guide, you'll dive deeper into individual components
of the software, but for now there are key points that
distinguish its approach from the other tools you might use to manage
your systems.

Using Puppet, you define a desired state for all systems in your
infrastructure. Once this state is defined, it automates the process of
bringing your systems into that state and keeping them there.

This desired state for your systems is written in Puppet code, a domain specific
language (DSL). This **infrastructure as code** approach means that users
concerned with version control, compliance, continuous integration and
deployment, and testing can easily fold infrastructure into their development
and release workflow.

Puppet code is a **declarative** language, which means that you describe only
the desired state for your systems, not the steps needed to get there. Once
you've specified in code those aspects of a system you want Puppet to
manage, an agent service running in the background makes any changes
needed to bring the system into compliance with the desired state.

A declarative approach requires that you think about the systems in your
infrastructure differently than you would if you were using scripts, golden
images, or runbooks. You can focus on **what** your infrastructure can do for
you rather than **how** you're going to get there.

The declarative Puppet language gives you a single syntax for describing
desired state across Windows and Unix-like operating systems, network devices,
and containers. You don't have to switch languages and toolsets every time you
start work on a new system. Learning Puppet gives you a skillset that can be
carried across projects and roles.

With a server-agent architecture, there's no need to connect to systems
individually to make changes. Once the agent service is running on a system,
it periodically establishes a secure connection to the Puppet server, fetches
any code you've applied to it, and makes the changes necessary to bring
the system in line with the desired state. The fact that
centralized control is built in from Puppet's foundations makes monitoring and
compliance much easier.

## The Puppet agent

As we noted above, Puppet is actually a variety of tools and
services that work together to help you manage and coordinate the systems in
your infrastructure. Though this ecosystem gives you a great degree of power
and control, the complexity can leave a new user wondering where to start.

By initially introducing Bolt, and now the Puppet agent and some of the
command line tools included in
the agent installation, there should be a balance between the
big-picture view of Puppet and the the bottom-up fundamentals. You'll begin to
understand the agent's role in the broader Puppet architecture, as well as the
details of how it interacts with the system where it's installed.

The Puppet agent runs on every system that you want Puppet to manage. The
agent serves as the bridge between the system where it's installed and the
Puppet server. The agent communicates in two directions: out to the
Puppet server to see how its system should be configured, and then inward to native
system tools to check the actual state of the system and to make changes
to bring it in line with the desired state.

When you install the Puppet agent you get a set of command-line tools that help
you interact directly with a system in the same way the Puppet agent does.
Using these tools will help you understand how the Puppet agent sees and
modifies the state of the system where it's running.

## Agent installation

The Learning VM itself has Puppet Enterprise
pre-installed, including the Puppet server service. For each quest, the quest
tool provides one or more agent systems that you explore and configure
with Puppet.

For this quest, there is a fresh system where you can install the Puppet
agent and explore some of the tools it provides. The Puppet server hosts an
agent install script that makes it easy to install the Puppet agent on any
system that can access the Puppet server.

<div class = "lvm-task-number"><p>Task 1:</p></div>

To get started, use the `bolt` tool that was introduced in the previous quest. Copy and run the following command to
load the agent installer from the Puppet server and run it on the agent system:

    bolt command run "sh -c 'curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash'" --targets docker://hello.puppet.vm

You will see text stream across the screen as the installation runs.

You can find full documentation of the agent installation process, including specific
instructions for Windows and other operating systems in the [installation
documentation](https://puppet.com/docs/pe/latest/installing_agents.html).

## Resources

As noted above, the Puppet agent comes with a set of supporting tools you
can use to explore your system. Now that the agent is
installed, use these tools to see what they can teach you about how
Puppet works.

One of Puppet's core concepts is the *resource abstraction layer*. For Puppet, 
each aspect of the system you want to manage (such as a
user, file, service, or package) is represented in code as a unit called
a *resource*. The `puppet resource` tool lets you view and modify these
resources directly.

<div class = "lvm-task-number"><p>Task 2:</p></div>

Using the following command, connect to the system where the agent was just installed. Enter the password `puppet` when prompted.

    ssh learning@hello.puppet.vm

Next run the following command to ask Puppet to describe a file resource:

    sudo puppet resource file /tmp/test

What you see is the Puppet code representation of a resource. In this case,
the resource's type is `file`, and its path is
`/tmp/test`:

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

The resource syntax can be broken down into its components so its
anatomy can be understood a little more clearly.

```puppet
type { 'title':
  parameter => 'value',
}
```

The **type** is the kind of thing the resource describes. It can be a **core
type** like a user, file, service, or package, or a **custom type** that you
have implemented yourself or installed from a module. 

Custom types
describe resources that might be specific to a service or application (for
example, an Apache vhost or MySQL database) that Puppet doesn't know about out
of the box.

The body of a resource is a list of **parameter value pairs** that follow the
pattern `parameter => value`. The parameters and possible values vary from type
to type. They specify the state of the resource on the system. Documentation
for resource parameters is provided in the [Resource Type
Reference](https://puppet.com/docs/puppet/latest/types/).

The **resource title** is a unique name that Puppet uses to identify the
resource internally. In the case of the file resource above, the
resource's title was the path of the file on the system: `/tmp/test`. Each
resource type has a unique identifying feature that can be used as the resource
title. A `user` resource uses the account name as a title, for example, and
a `package` resource uses the name of the package you want to manage.

Now that you're more familiar with the resource syntax, take another look
at that file resource.

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

Notice that it has a single parameter value pair: `ensure => 'absent'`. The
`ensure` parameter tells us the basic state of a resource. For the *file* type,
this parameter describes if the file exists on the system and if it does,
whether it's a normal file, a directory, or a link.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Puppet is indicating that this file doesn't exist. So what happens when
you use the `touch` command to create a new empty file at that path? Run:

    touch /tmp/test

Use the `puppet resource` tool to see how this change is represented in
Puppet's resource syntax:

    sudo puppet resource file /tmp/test

Now that the file exists on the system, Puppet has more to say about it. It
shows the `ensure` and `content` parameters and their values,
plus information about the file's owner, when it was created, and
when it was last modified.

```puppet
file { '/tmp/test':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

The value of the `content` parameter might not be what you expected. When the
`puppet resource` tool interprets a file in this resource declaration syntax,
it converts the content to an MD5 hash. Puppet uses the hash to quickly
compare the actual content of a file on your system against the expected
content to see if has changed.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Next, use the `puppet resource` tool to add some content to our file.

Running `puppet resource` with a `parameter=value` argument tells Puppet to
modify the resource on the system to match the value you set. (Note that while
this is a great way to test out changes in a development environment, it's not
a good way to manage production infrastructure.

Run the following command:

    sudo puppet resource file /tmp/test content='Hello Puppet!'

Puppet will display some output as it checks the hash of the existing content
against the new content you provided. When it sees that the hashes don't match,
it sets the file's content to the value of the command's `content` parameter.

Look at the file to see the modified content by running:

    cat /tmp/test

### Types and Providers

This translation back and forth between the state of the system and Puppet's
resource syntax is the heart of Puppet's resource abstraction layer. To get
a better understanding of how this works, let's take a look at another resource
type, the `package`.

<div class = "lvm-task-number"><p>Task 5:</p></div>

As an example, run the following command to install the package for the
Apache webserver `httpd`:

    sudo puppet resource package httpd

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

Each resource **type** has a set of **providers**. A
**provider** is the translation layer that sits between Puppet's resource
representation and the native system tools it uses to discover and modify the
underlying system state. Each resource type generally has a variety of
different providers.

The quickest way to see the inner workings of a provider
is to break it. Tell Puppet to install a nonexistent package named
`bogus-package` by running:

    sudo puppet resource package bogus-package ensure=present

The error message tells you that yum wasn't able to find the
specified package, and lists the command that Puppet's yum provider tried to
run when it saw that the package wasn't already installed:

```
Error: Execution of '/bin/yum -d 0 -e 0 -y install bogus-package' returned 1:
Error Nothing to do
```

Puppet selects a default provider based on the agent's operating system and
whether the commands associated with that provider are available. You
can override this default by setting a resource's `provider` parameter.

Try installing the same fake package again, this time with the `gem`
provider:

     sudo puppet resource package bogus-package ensure=present provider=gem

You'll see a similar error with a failed `gem` command instead of the `yum`
command:

```
Error: Execution of '/bin/gem install --no-rdoc --no-ri bogus-package'
returned 2: ERROR:  Could not find a valid gem 'bogus-package' (>= 0) in any repository
Error: /Package[bogus-package]/ensure: change from absent to present failed: 
Execution of '/bin/gem install --no-rdoc --no-ri bogus-package' returned 2: 
ERROR:  Could not find a valid gem 'bogus-package' (>= 0) in any repository
```

Now that you know what's happening in the background, try installing
a real package with the default provider:

    sudo puppet resource package httpd ensure=present

This time, Puppet installs the package. The value of the
`ensure` parameter shows you the specific version of the installed package:

```puppet
package { 'httpd':
  ensure => '2.4.6-93.el7.centos',
}
```

When you don't specify a version of the package to install, Puppet
defaults to installing the latest available version and displays this version
number as the value of the `ensure` attribute.

Now that you've had a chance to explore this system with the newly installed
Puppet agent, exit to return to the Puppet server before you continue to the
next quest.

    exit

## Review

In this quest, you learned what Puppet is and some of the advantages of
managing your infrastructure with Puppet's declarative domain-specific
language and server-agent architecture.

You installed the Puppet agent on a new system using Bolt. Once the agent and suite of
supporting tools were installed, you learned the fundamentals of Puppet's
**resource abstraction layer**, including **resources**, resource
**types**, and the **providers** that translate between your Puppet code and
the native system tools.

Now that you've learned some of the core concepts behind Puppet, you're ready
to use these ideas in a more realistic workflow. The `puppet
resource` command is a great way to explore a system or test Puppet code, but
it's not the tool you'll be using to automate your configuration management.

In the next quest, you'll learn how to save Puppet code to a file called a
**manifest** and organize it into a **module** within your Puppet server's
**codedir**. This structure lets Puppet keep track of where to find all the
resources it needs to manage your infrastructure.

And you'll see how the Puppet agent communicates with your Puppet server to
fetch a compiled list of resources called a **catalog** based on Puppet code
kept on it.

## Additional Resources

* Watch our on-demand webinar ["Introduction to Puppet Enterprise"](https://puppet.com/resources/webinar/introduction-to-puppet-enterprise)
* Read about installing Puppet Enterprise on our [docs page](https://puppet.com/docs/pe/latest/installing_pe.html)
* Take a look at our [What is Puppet](https://learn.puppet.com/course/what-is-puppet) and [What is Puppet Enterprise](https://learn.puppet.com/course/what-is-puppet-enterprise) and [Resources](https://learn.puppet.com/course/resources) [self-paced lessons](https://learn.puppet.com/category/self-paced-training).
* Puppet basics are covered in-depth in our Getting Started with Puppet course. Explore our [in-person](https://learn.puppet.com/category/instructor-led-training) and [online](https://learn.puppet.com/category/online-instructor-led-training) training options for more information.
