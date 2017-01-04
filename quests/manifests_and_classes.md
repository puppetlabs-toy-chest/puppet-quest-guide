{% include '/version.md' %}

# Manifests and classes

## Quest objectives

- TBD 

## Getting started

So far you've learned about the basics of Puppet's **Resource Abstraction
Layer**, the relationship between the Puppet agent and master, and the
communication between the agent and master involved in a Puppet agent run.
Other than modifying a few basic resources, however, you haven't yet written
much Puppet code.

As you get started learning Puppet, you'll likely notice that the patterns and
workflows used to organize, maintain and deploy Puppet code can be just as
involved as writing the code itself. Getting started with good design patterns
early will help keep everything working smoothly as you start managing a more
complex Puppet infrastructure. This means that this guide puts early
emphasis on learning structure and organization, even if some of these
patterns may seem unnecessary for the simple applications we use as examples.

In this quest, we cover some of the basics of how Puppet code is managed and
applied across your infrastructure. You'll learn how Puppet code is organized
into **manifests**, **classes** and **modules**, and how to apply classes to
nodes with the `site.pp` manifest.

These basics will put you on a solid footing later in this guide as we discuss
more advanced workflow topics such as a git control repository, module
management with a Puppetfile, deployment with code manager, and the roles and
profiles classification pattern.

When you're ready to get started, enter the following command:

    quest begin manifests_and_classes

### Manifests

> Imagination is a force that can actually manifest a reality.

> -James Cameron

At its simplest, a Puppet **manifest** is Puppet code saved to a file with the
`.pp` extension. This code is written in the Puppet **Domain Specific
Language** (DSL). You already saw some examples of this DSL as you learned
about the resource declarations Puppet uses to represent the state of a system.
The Puppet DSL includes these resource declarations along with a set of other
language features that let you control which resources are applied on a system
and what values are set for those resourses' parameters.

Go ahead and ssh to the node we've created for this quest:

    ssh learning@cowsay.puppet.vm

Create a throw-away manifest in our `/tmp/` directory to see how this works. 

    vim /tmp/hello.pp

Use the same notify resource declaration you included in your `site.pp` in the
previous quest:

```puppet
notify { 'Hello Puppet!': }
```

(Remember, use `ESC` then `:wq` to save and exit.)

Rather than classifying this node on the master and triggering a Puppet agent
run, apply this manifest directly with the `puppet apply` tool. Like the
`puppet resource` tool, `puppet apply` isn't part of a typical agent/master
architecture, but it can be very useful for this kind of testing and
experimentation.

    puppet apply /tmp/hello.pp 

Note that even though your Puppet code should ultimately be run from the
master, we're using an agent node for testing. You wouldn't want to get in the
habit of testing code on your Puppet master itself.

Now you know how to save Puppet code to a file, but how to you bridge the gap
between this saved Puppet code and the `site.pp` manifest where you define
node classification? The first step is to organize your Puppet code into
**classes** and **modules**.

### Classes and modules

For Puppet, a **class** is named block of Puppet code. **Defining** a class
combines a group of resources into single reusable and configurable unit. Once
**defined**, a class can then be **declared** to tell Puppet to apply the
resources it contains.

A useful class brings together a set of resources that manage one logical
component of a system. For example, a class written to manage a MS SQL Server
might include resources to manage the package, configuration files, and service
for the MS SQL Server instance. Because each of these components relies on the
others, it makes sense to combine them—you're not likely to want a server, for
example, with *only* the configuration files, but no package installed.

A **module** is a directory structure that lets Puppet keep track of where to
find the manifests that contain your classes. (A module is also where you keep
other data a class might rely on, such as the templates you would use to manage
configuration files, but for now, we'll focus the classes themselves.) When you
apply a class to a node, the Puppet master will check in a list of directories
called a **modulepath** for a module directory matching the class name, then
look in that module's `manifests` subdirectory to find the manifest containing
the class definition.  It then reads the Puppet code contained in that class
definition and uses it to compile a catalog defining a desired state for the
node.

All this will be much easier to understand with an example in front of you.
Let's dive in and write a simple module.

## Write a cowsay module

By way of example, we'll walk you through the steps involved in writing a
module to manage a small program called cowsay. Cowsay lets you print a message
inside a speech bubble coming from the mouth of an ASCII cow.

While you would normally write your Puppet code on a development system before
testing it and promoting it to your Puppet master, we'll be working directly on
the master (that is, the Learning VM itself) to help you understand how Puppet
organizes and accesses code. We'll cover a more complete workflow in a later
quest.

Before you create a new manifest, you need to know where to keep it. For Puppet
to find your code, you need to place it in a module directory in Puppet's
**modulepath**.

To see what your configured modulepath is, run the following command:

    puppet config print modulepath

The output is a list of directories separated by the colon (`:`) character.

```
/etc/puppetlabs/code/environments/production/modules:/etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules
``` 

For now, we'll work in the first directory listed in the modulepath. This
directory includes modules specific to the production environment. (The second
contains modules used across all environments, and the third is modules that PE
uses to configure itself). Use `cd` to navigate to that directory.

    cd /etc/puppetlabs/code/environment/production/modules

Create a directory structure for a new module called `cowsay`. (The `-p`
flag allows you to create the `cowsay` parent directory and `manifests`
subdirectory at once.)

    mkdir -p cowsay/manifests

With this directory strucure in place, it's time to create the manifest where
we'll write the `cowsay` class.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Use vim to create an `init.pp` manifest in your module's `manifests` directory:

    vim cowsay/manifests/init.pp

If this manifest is going to contain the `cowsay` class, you might be wondering
why we're calling it `init.pp` instead of `cowsay.pp`. Most modules contain a
main class like this whose name corresponds with the name of the module itself.
This main class is always kept in a manifest with the special name `init.pp`.

Enter the following class definition, then save and exit (`:wq`):

```puppet
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
```

(Notice that we've specified `gem` as the provider for this package. Apparently
`cowsay` isn't important enough to live in any of the default yum package
repositories, so we're telling Puppet to use the `gem` provider to install a
version of the package written in Ruby and published on RubyGems.)

It's always good practice to validate your code before you try to apply it. Use
the `puppet parser` tool to check the syntax of your new manifest:

    puppet parser validate cowsay/manifests/init.pp
	
The parser will return nothing if there are no errors. If it does detect a
syntax error, open the file again and fix the problem before continuing. Be
aware that this validataion can only catch simple syntax errors, and won't let
you know about other possible errors in your manifests.

Now that the `cowsay` class is defined in your module's `init.pp` manifest,
your Puppet master knows exactly where to find the appropriate Puppet code when
you apply the `cowsay` class to a node.

In the setup for this quest, the quest tool prepared a `cowsay.puppet.vm`
node. Let's apply the `cowsay` class to this node. First, open your `site.pp`
manifest.

    vim /etc/puppetlabs/code/environment/production/manifests/site.pp

At the end of the `site.pp` manifest, insert the following code:

```puppet
node 'cowsay.puppet.vm' {
  include cowsay
}
```

Save and exit.

This `include cowsay` line tells the Puppet master to parse the contents of the
`cowsay` class when it compiles a catalog for the `cowsay.puppet.vm` node.

Now that you've added the `cowsay` class to your classification for the
`cowsay.puppet.vm` node, let's connect to that node and trigger a Puppet agent
run to see the changes applied.

    ssh learning@cowsay.puppet.vm

Before applying any changes to your system, it's always a good idea to use the
`--noop` flag to do a 'dry run' of the Puppet agent. This will compile the
catalog and notify you of the changes that Puppet would have made without
actually applying any of those changes to your system. It's a good way to catch
issues the `puppet parser validate` command can't detect, and gives you a
chance to validate that Puppet will be making the changes you expect.

    sudo puppet agent -t --noop

You should see an output like the following:

    Notice: Compiled catalog for cowsay.puppet.vm in environment production in
    0.62 seconds
    Notice: /Stage[main]/Cowsay/Package[cowsay]/ensure: current_value
    absent, should be present (noop)
    Notice: Class[Cowsay]: Would have triggered 'refresh' from 1
    events
    Notice: Stage[main]: Would have triggered 'refresh' from 1 events
    Notice: Finished catalog run in 1.08 seconds

<div class = "lvm-task-number"><p>Task 3:</p></div>

If your dry run looks good, go ahead and run the Puppet agent again without the
`--noop` flag.

    sudo puppet agent -t

Now you can try out your newly installed cowsay command:

    cowsay Puppet is awesome!

Your bovine friend clearly knows what's up.

     ____________________
    < Puppet is awesome! >
     --------------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

### Nested classes and class scope

A module will often include multiple components that work together to serve a
single function. Cowsay alone is great, but many users don't have the time to
write out a custom high-quality message on each execution of the command. For
this reason, cowsay is often used in conjunction with the `fortune` command,
which provides you and your cow with a database of sayings and wisdom to draw
on.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Disconnect from the `cowsay.puppet.vm` node to return to your master:

    exit

Create a new manifest for your `fortune` class definition:

    vim cowsay/manifests/fortune.pp

Write your class definition here:

```puppet
class cowsay::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
```

Note that unlike the main `init.pp` manifest, the filename of the manifest
shows us the name of the class it defines. In fact, because this class is
contained in the `cowsay` module, its full name is `cowsay::fortune`.  The two
colons that connect `cowsay` and `fortune` are pronounced "scope scope". Notice
how the fully scoped name of the class tells Puppet exactly where to find it in
your module path: the `fortune.pp` manifest in the `cowsay` module. This naming
pattern also helps avoid conflicts among similarly named classes provided by
different modules.

<div class = "lvm-task-number"><p>Task 5:</p></div>

Again, validate your new manifest's syntax with the `puppet parser validate`
command.

  puppet parser validate cowsay/manifests/fortune.pp

We could use another include statement in the `site.pp` manifest to classify
`cowsay.puppet.vm` with this `cowsay::fortune` class. In general, however, it's
best to keep your classification as simple as possible.

In this case, we'll use a nested class declaration to pull the
`cowsay::fortune` class into our main `cowsay` class.

    vim cowsay/manifests/init.pp

Add an include statement for your `cowsay::fortune` class to the cowsay class.

```puppet
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
  include cowsay::fortune
}
```

Use the `puppet parser validate` command to check your syntax:

    `puppet parser validate cowsay/manifests/init.pp`

Return to your `cowsay.puppet.vm` node so we can test out these changes.

    ssh learning@cowsay.puppet.vm

Trigger a Puppet agent run with the `--noop` flag to check what changes Puppet
will make.

    sudo puppet agent -t --noop

Notice that because the cowsay package is already installed, Puppet
won't make any changes to this package. Now that you've included the
`cowsay::fortune` package, however, Puppet knows that it needs to install the
`fortune-mod` package to bring your node into the desired state you defined for
it.

Trigger another Puppet run without the `--noop` flag to make these changes.

    sudo puppet agent -t

Now that you have both packages installed, you can use them together. Try
piping the output of the `fortune` command to `cowsay`:

    fortune | cowsay
	
## Review

TBD
