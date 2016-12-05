{% include '/version.md' %}

# Manifests and classes

## Quest objectives

- TBD 

## Getting started

So far you've learned about the basics of Puppet's **Resource Abstraction
Layer** and the the relationship between the Puppet agent and master. Puppet
is all about defining a desired state for your infrastructure, but you may have
noticed that other than modifying a few basic resources, we haven't written
much Puppet code.

As you get started learning Puppet, you'll likely notice that the patterns and
workflows used to organize, maintain and deploy Puppet code can be more
challenging than writing the code itself. Getting started with good design
patterns early helps you keep everything working smoothly as you start managing
a more complex Puppet infrastructure down the line. 

In this quest, we'll cover some of the basics of how Puppet code is managed and
applied across your infrastructure. You'll learn how Puppet code is organized
into **manifests**, **classes** and **modules**, and how to apply classes to
nodes with the `site.pp` manifest.

These basics will set you up for a more complete Puppet workflow that we'll
cover later in this guide, including a git control repository, module
management with a Puppetfile, deployment with code manager, and the roles and
profiles classification pattern.

When you're ready to get started, enter the following command:

    quest begin manifests_and_classes

### Manifests

> Imagination is a force that can actually manifest a reality.

> -James Cameron

At its simplest, a Puppet **manifest** is nothing more than some Puppet code
saved to a file with the `.pp` extension. This code is written in the Puppet
**Domain Specific Language** (DSL). You already saw some examples of this DSL
as you learned about the resource declarations Puppet uses to represent the
state of a system. The Puppet DSL includes these resource declarations along
with a set of other language features that let you control which resources
are applied on a system and what values are set for those resourses'
parameters.

Let's go ahead and create a throw-away manifest in our `/tmp/` directory to see
how this works. 

    vim /tmp/hello.pp

Enter the following resoure declaration:

```puppet
notify { 'Hello Puppet!':
  message => 'Hello Puppet!',
}
```

(Remember, use `ESC` then `:wq` to save and exit.)

Now apply this manifest directly with the `puppet apply` tool. (Like the
`puppet resource` tool, `puppet apply` can be very useful for testing and
experimentation, but isn't typically be part of a production workflow.)

    puppet apply /tmp/hello.pp 

Now that you know how to save Puppet code to a file, the next step is to
organize this code in a way the Puppet master can recognize.

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
apply a class to a node, the Puppet master will look in its **modulepath** for
a module directory matching the class name, then look in that module's
`manifests` subdirectory to find the manifest containing the class definition.
It then reads the Puppet code contained in that class definition and uses it
to compile a catalog defining a desired state for the node.

All this will be much easier to understand with an example in front of you.
Let's dive in and write a simple module.

## Write a cowsay module

While editing Puppet code directly on a production Puppet master wouldn't be a
good, we'll be working directly on the Master (that is, the Learning VM
itself) to help you understand the basic concepts before moving on to cover
the more complex workflow you would use to develop and test code before
deploying it to production.

Use `cd` to navigate to Puppet's **modulepath** directory.

    cd /etc/puppetlabs/code/environment/production/modules

Create a simple directory structure for a new module we'll call `cowsay`. (The
`-p` flag allows you to create the `cowsay` parent directory and `manifests`
subdirectory at once.)

    mkdir -p cowsay/manifests

In this case, all you need is a `manifests` directory, so the module structure
is very simple. 

First, we'll write a class to manage the *cowsay* package. Cowsay lets you
print a message a the speech bubble coming from the mouth of an ASCII cow.

To use the `cowsay` command, you need to have the cowsay package installed. You
can use a `package` resource to handle this installation, but you don't want to
put that resource declaration just anywhere.

<div class = "lvm-task-number"><p>Task 1:</p></div>

The main class with a name matching the name of the module itself is always
kept in a manifest with the special name `init.pp`.

Use vim to create an `init.pp` manifest in your module's `manifests` directory:

    vim cowsayings/manifests/init.pp

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

    puppet parser validate cowsayings/manifests/cowsay.pp
	
The parser will return nothing if there are no errors. If it does detect a
syntax error, open the file again and fix the problem before continuing. Be
aware that this validataion can only catch simple syntax errors, and won't let
you know about other possible issues in your manifests.

Now that the `cowsay` class is defined in the `init.pp` manifest in your cowsay
module, your Puppet master will know exactly what you do when you tell it to
apply the `cowsay` class to a node.

In the setup for this quest, the quest tool created a `cowsay.puppet.vm` node.
Let's apply the `cowsay` class to this node. First, open your `site.pp`
manifest.

    vim /etc/puppetlabs/code/environment/production/manifests/site.pp

At the end of the `site.pp` manifest, insert the following code:

```puppet
node 'cowsay.puppet.vm' {
  include cowsay
}
```

Save and exit.

The `include cowsay` line simply tells the Puppet master to include your
`cowsay` class when it compiles a catalog for the `cowsay.puppet.vm` node. This
is one of two ways to declare a class. The other is called a resource-like
class declaration, and allows you to pass in parameters to customize the
details of a class as you declare it. We'll go into more details on the
differences between the **include** syntax and the **resource-like** class
declaration when we discuss class parameters in a later quest.

Now that you've classified your `cowsay.puppet.vm` node with the `cowsay`
class, let's connect to that node and trigger a Puppet agent run to see the
changes applied.

    ssh learning@cowsay.puppet.vm

Before applying any changes to your system, it's always a good idea to use the
`--noop` flag to do a 'dry run' of the Puppet agent. This will compile the
catalog and notify you of the changes that Puppet would have made without
actually applying any of those changes to your system. It's a good way to catch
any issues the `puppet parser validate` command can't detect, and gives you a
chance to check that you're actually applying the changes you expect.

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
