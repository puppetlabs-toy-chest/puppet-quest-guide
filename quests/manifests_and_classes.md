{% include '/version.md' %}

# Manifests and classes

## Quest objectives

- 

## Getting started

So far you've learned about the basics of Puppet's **Resource Abstraction
Layer** and the the relationship between the Puppet agent and master. Puppet
is all about defining a desired state for your infrastructure, but you may have
noticed that other than modifying a few basic resources, we haven't written
much Puppet code.

As you get started learning Puppet, you may notice that the patterns and
workflows used to organize, maintain and deploy Puppet code are often more
challenging than writing the code itself. Though getting code to do cool things
is more satisfying than learning best-practices, it's worth taking some time
now to set up a solid foundation on which you'll be able to build more compelx
projects.

In this quest, you'll learn how Puppet code is organized into **manifests**,
**classes** and **modules**. Because these concepts all rely on one-another,
we'll cover a lot of ground in this quest to introduce them all. Don't worry if
you feel like you're missing some details—we'll do a deeper dive into some of
these concepts in a later quest.

When you're ready to get started, enter the following command:

    quest begin manifests_and_classes

### Manifests

> Imagination is a force that can actually manifest a reality.

> -James Cameron

At its simplest, a **manifest** is nothing more than some puppet code saved to
a file with the `.pp` extension. The contents include the same resource
declarations you saw with the `puppet resource` tool as well as some additional
syntax to define logic and variables.

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

Now we can apply this manifest directly with the `puppet apply` tool. (Like the
`puppet resource` tool, `puppet apply` can be very useful for testing and
experimentation, but isn't typically be part of a production workflow.)

    puppet apply /tmp/hello.pp 

As we discuss **classes** and **modules** below, you'll see that saving Puppet
code to a file lets you keep things organized in a way Puppet can recognize.

### Classes and modules

For Puppet, a **class** is a named block of Puppet code. **Defining** a class
combines a group of resources into single reusable and configurable unit. Once
**defined**, a class can then be **declared** to tell Puppet to apply the
resources it contains.

This difference between defining and declaring classes allows you to build up a
library of Puppet code on your master (ideally synchronized with a control
repository—more on this later), then use a classifier such as the node block in
your `site.pp` manifest or the PE console to selectively apply that code across
the nodes on your infrastructure.

To organize all of your classes (and any other bits of data and code they
might rely on), Puppet uses a directory structure called a module. When Puppet
runs, it looks through any modules kept in a directory on the master called the
**modulepath** and makes all the classes defined there available to be used.

All this will be much easier to understand with an example in front of you, so
let's dive in and write a simple module.

## Write a cowsay module

Note that instead of logging in to an agent node, we're working directly on
the Puppet master.

First, use `cd` to navigate to Puppet's **modulepath** directory.

    cd /etc/puppetlabs/code/environment/production/modules

Create a simple directory structure for a module called `cowsay`. (The `-p`
flag allows you to create the `cowsay` parent directory and `manifests`
subdirectory at once.)

    mkdir -p cowsay/manifests

A module is simply a top level directory named for the module itself, and a set
of subdirectories to keep your manifests, files, templates, test examples, and
plugins. Published modules also include a `metadata.json` file that lists the
module's author, dependencies, and some other information about the project.

In this case, all you need is a manifest, so the module structure is very
simple. 

First, you'll use Puppet to manage the *cowsay* package. Cowsay lets you print
a message in the speech bubble of an ASCII cow. It may not be critical software
(unless you're founding a Cowsay as a Service [CaaS] startup!), but it works
well as a simple example. You'll also install the *fortune* package, which will
give you and your cow access to a database of sayings and quotations.

To use the `cowsay` command, you need to have the cowsay package installed. You
can use a `package` resource to handle this installation, but you don't want to
put that resource declaration just anywhere.

<div class = "lvm-task-number"><p>Task 1:</p></div>

We'll create a `cowsay.pp` manifest, and within that manifest we'll define a
class that can manage the cowsay package.

Use vim to create a `cowsay.pp` manifest:

    vim cowsayings/manifests/cowsay.pp

Enter the following class definition, then save and exit (`:wq`):

```puppet
class cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
```

Validate your code before you apply it. Use the `puppet parser` tool to check
the syntax of your new manifest:

    puppet parser validate cowsayings/manifests/cowsay.pp
	
The parser will return nothing if there are no errors. If it does detect a
syntax error, open the file again and fix the problem before continuing.

If you try to directly apply your new manifest, nothing on the system will
change. (If you like, use the `puppet apply` command to give it a try.) This is
because your manifest has *defined* a cowsay class, but haven't *declared* it
anywhere. Puppet knows that the cowsay class exists, but it hasn't been told
to do anything with it.

First, open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environment/production/manifests/site.pp

To classify your `hello.puppet.vm` node with the `cowsay` class.

	
Save and exit.

Before applying any changes to your system, it's always a good idea to use the
`--noop` flag to do a 'dry run' of the Puppet agent. This will compile the
catalog and notify you of the changes that Puppet would have made without
actually applying any of those changes to your system.

    puppet apply --noop cowsayings/examples/cowsay.pp

(If you're running offline or have restrictive firewall rules, you may need to
manually install the gems from the local cache on the VM. In a real
infrastructure, you might consider setting up a local rubygems mirror with a
tool such as [Stickler](https://github.com/copiousfreetime/stickler).
`gem install --local --no-rdoc --no-ri /var/cache/rubygems/gems/cowsay-*.gem`)

You should see an output like the following:

    Notice: Compiled catalog for learn.localdomain in environment production in
    0.62 seconds
    Notice: /Stage[main]/Cowsayings::Cowsay/Package[cowsay]/ensure: current_value
    absent, should be present (noop)
    Notice: Class[Cowsayings::Cowsay]: Would have triggered 'refresh' from 1
    events
    Notice: Stage[main]: Would have triggered 'refresh' from 1 events
    Notice: Finished catalog run in 1.08 seconds

<div class = "lvm-task-number"><p>Task 3:</p></div>

If your dry run looks good, go ahead and run `puppet apply` again without the
`--noop` flag. If everything went according to plan, the cowsay package is now
installed on the Learning VM. Give it a try!

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

### Fortune

But this module isn't just about cowsay; it's about cow *sayings*. With the
fortune package, you can provide your cow with a whole database of wisdom.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Create a new manifest for your fortune class definition:

    vim cowsayings/manifests/fortune.pp
	
Write your class definition here:

```puppet
class cowsayings::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
```

<div class = "lvm-task-number"><p>Task 5:</p></div>

Again, you'll want to validate your new manifests syntax with the `puppet parser
validate` command. When everything checks out, you're ready to make your test
manifest:

    vim cowsayings/examples/fortune.pp
	
As before, use `include` to declare your `cowsayings::fortune` class. 

<div class = "lvm-task-number"><p>Task 6:</p></div>

Apply the `cowsayings/examples/fortune.pp` manifest with the `--noop` flag. If 
everything looks good, apply again without the flag.

Now that you have both packages installed, you can use them together. Try piping
the output of the `fortune` command to `cowsay`:

    fortune | cowsay
	
So you've installed two packages that can work together to do something more
interesting than either would do on its own. This is a bit of a silly example,
of course, but it's not so different than, say, installing packages for both
Apache and PHP on a webserver. 

### Main class: init.pp

Often a module will gather several classes that work together into a single
class to let you declare everything at once.

Before creating the main class for cowsayings, however, a note on **scope**. You
may have noticed that the classes you wrote for cowsay and fortune were both
prepended by `cowsayings::`. When you declare a class, this scope syntax tells
Puppet where to find that class; in this case, it's in the cowsayings module. 

For the main class of a module, things are a little different. The main
class shares the name of the module itself, but instead of following the pattern of
naming the manifest for the class it contains, Puppet recognizes the special
file name `init.pp` for the manifest that will contain a module's
main class.

<div class = "lvm-task-number"><p>Task 7:</p></div>

So to contain your main `cowsayings` class, create an `init.pp` manifest in the
`cowsayings/manifests` directory:

    vim cowsayings/manifests/init.pp
	
Here, you'll define the `cowsayings` class. Within it, use the same
`include` syntax you used in your tests to declare the `cowsayings::cowsay` and
`cowsayings::fortune` classes.

```puppet
class cowsayings {
  include cowsayings::cowsay
  include cowsayings::fortune
}
```

Save the manifest, and check your syntax with the `puppet parser` tool.

<div class = "lvm-task-number"><p>Task 8:</p></div>

At this point, you already have both packages you want installed on the
Learning VM. Applying the changes again wouldn't actually do anything. For the
sake of testing, you can use the `puppet resource` tool to delete them so
you can try out the functionality of your new `cowsayings` class:

    puppet resource package fortune-mod ensure=absent
    puppet resource package cowsay ensure=absent provider=gem

Next, create a test for the `init.pp` manifest in the examples directory.

    vim cowsayings/examples/init.pp
	
Here, just declare the `cowsayings` class:

    include cowsayings

<div class = "lvm-task-number"><p>Task 9:</p></div>

Good. Now that the packages are gone, do a `--noop` first, then apply your
`cowsayings/examples/init.pp` test.

## Review

We covered a lot in this quest. We promised manifests and classes, but you got a
little taste of how Puppet modules work as well.

A *class* is a collection of related resources and other classes which, once
defined, can be declared as a single unit. Puppet classes are also singleton,
which means that unlike classes in object oriented programming, a Puppet class
can only be declared a single time on a given node.

A *manifest* is a file containing Puppet code, and appended with the `.pp`
extension. In this quest, we used manifests in the `./manifests` directory each
to define a single class, and used a corresponding test manifest in the
`./examples` directory to declare each of those classes.

There are also a few details about classes and manifests we haven't gotten to
just yet. As we mentioned in the Power of Puppet quest, for example, classes
can also be declared with *parameters* to customize their functionality. Don't
worry, we'll get there soon enough!
