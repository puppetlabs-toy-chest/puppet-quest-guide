---
title: Manifests and Classes
layout: default
---

# Manifests and Classes

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest

## Quest Objectives

- Understand the concept of a Puppet manifest
- Construct and apply manifests to manage resources
- Understand what a *class* means in Puppet's Language
- Learn how to use a class definition
- Understand the difference between defining and declaring a class

## Getting Started

In the Resources quest you learned about resources and the syntax used to
declare them in the Puppet DSL. You used the `puppet resource`, `puppet
describe`, and `puppet apply` tools to inspect, learn about, and change
resources on the system. In this quest, we're going to cover two key Puppet
concepts that will help you organize and implement your resource declarations:
*classes* and *manifests*. Proper use of classes and manifests is the first step
towards writing testable and reusable Puppet code.

When you're ready to get started, enter the following command to begin:

    quest --start manifests_classes

### Manifests

> Imagination is a force that can actually manifest a reality.

> --James Cameron

A manifest is a text file that contains Puppet code and is appended by the `.pp`
extension. It's the same stuff you saw using the `puppet resource` tool and
applied with the `puppet apply` tool, just saved as a file. 

While it's nice to be able to edit and save your Puppet code as a file,
manifests also give you a way to keep your code organized in a way that Puppet
itself can understand. In theory, you could put whatever bits and pieces of
syntactically valid Puppet code you like into a manifest. However, for the
broader Puppet architecture to work effectively, you'll need to follow some
patterns in how you write your manifests and where you put them. A key aspect of
proper manifest management is related to Puppet *classes*.

### Classes

In Puppet's DSL a **class** is a named block of Puppet code. A class will
generally manage a set of resources related to a single function or system
component. Classes often contain other classes; this nesting provides a
structured way to bring together functions of different classes as components of
a larger solution.

Using a Puppet class requires two steps. First, you'll need to *define* it by
writing a class definition and saving it in a manifest file. When Puppet runs,
it will parse this manifest and store your class definition. The class can then
be *declared* to apply it to nodes in your infrastructure.

There are a few different ways to tell Puppet where and how to apply classes to
nodes. You already saw the PE Console's node classifier in the Power of Puppet
quest, and we'll discuss other methods of node classification in a later quest.
For now, though, we'll show you how to write class definitions and use *test*
manifests to declare these classes locally.

One more note on the topic of classes. In Puppet, classes are *singleton*, which
means that a class can only be declared *once* on a given node. In this sense,
Puppet's classes are different than the kind of classes you may have encountered
in Object Oriented programming, which are often instantiated multiple times.

## Cowsayings
You had a taste of how Puppet can manage users in the Resources quest. In this
quest we'll use the *package* resource as our example. 

First, you'll use Puppet to manage the *cowsay* package. Cowsay lets you print a
message in the speech bubble of an ascii art cow. It may not be a mission
critical software (unless your mission involves lots of ascii cows!), but it
works well as a simple example. You'll also install the *fortune* package, which
will give you and your cow access to a database of sayings and quotations.

We've already created a `cowsayings` module directory in Puppet's *modulepath*,
and included two subdirectories: `manifests` and `tests`. Before getting started
writing manifests, change directories to save yourself some typing:

    cd /etc/puppetlabs/puppet/environments/production/modules

### Cowsay
{% task 1 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/cowsay.pp
  content: |
    class cowsayings::cowsay {
      package { 'cowsay':
        ensure => 'present',
      }
    }
{% endtask %}

You'll want to put the manifest with your cowsay class definition in the
manifests directory. Use vim to create a `cowsay.pp` manifest:

    vim cowsayings/manifests/cowsay.pp

Enter the following class definition, then save and exit (`:wq`):

{% highlight puppet %}
class cowsayings::cowsay {
  package { 'cowsay':
    ensure => 'present',
  }
}
{% endhighlight %}

Now that you're working with manifests, you can use some validation tools to
check your code before you apply it. Use the `puppet parser` tool to check the
syntax of your new manifest:

    puppet parser validate cowsayings/manifests/cowsay.pp
	
The parser will return nothing if there are no errors. If it does detect a
syntax error, open the file again and fix the problem before continuing.

If you try to apply this manifest, nothing on the system will change. (Give it a
shot if you like.) This is because you have *defined* a cowsay class, but
haven't *declared* it anywhere. Whenever Puppet runs, it parses everything in
the *modulepath*, including your cowsay class definition. So Puppet knows that
the cowsay class contains a resource declaration for the cowsay package, but
hasn't yet been told to do anything with it.

{% task 2 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/cowsay.pp
  content: include cowsayings::cowsay
{% endtask %}

To actually declare the class, create a `cowsay.pp` test in the tests directory.

    vim cowsayings/tests/cowsay.pp

In this manifest, *declare* the cowsay class with the `include` keyword.

    include cowsayings::cowsay
	
Save and exit.

Before applying any changes to your system, it's always a good idea to use the
`--noop` flag to do a 'dry run' of the Puppet agent. This will compile the
catalog and notify you of the changes that Puppet would have made without
actually applying any of those changes to your system.

    puppet apply --noop cowsayings/tests/cowsay.pp

You should see an output like the following:

    Notice: Compiled catalog for learn.localdomain in environment production in
    0.62 seconds
    Notice: /Stage[main]/Cowsayings::Cowsay/Package[cowsay]/ensure: current_value
    absent, should be present (noop)
    Notice: Class[Cowsayings::Cowsay]: Would have triggered 'refresh' from 1
    events
    Notice: Stage[main]: Would have triggered 'refresh' from 1 events
    Notice: Finished catalog run in 1.08 seconds

{% task 3 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/cowsay.pp
- execute: cowsay Puppet is awesome!
{% endtask %}

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

{% task 4 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/fortune.pp
  content: |
    class cowsayings::fortune {
      package { 'fortune-mod':
        ensure => 'present',
      }
    }
{% endtask %}

Create a new manifest for your fortune class definition:

    vim cowsayings/manifests/fortune.pp
	
Write your class definition here:

{% highlight puppet %}
class cowsayings::fortune {
  package { 'fortune-mod':
    ensure => 'present',
  }
}
{% endhighlight %}

{% task 5 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/fortune.pp
  content: include cowsayings::fortune
{% endtask %}

Again, you'll want to validate your new manifests syntax with the `puppet parser
validate` command. When everything checks out, you're ready to make your test
manifest:

    vim cowsayings/tests/fortune.pp
	
As before, use `include` to declare your `cowsayings::fortune` class. 

{% task 6 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/fortune.pp
{% endtask %}

Apply the `cowsayings/tests/fortune.pp` manifest with the `--noop` flag. If 
everything looks good, apply again without the flag.

Now that you have both packages installed, you can use them together. Try piping
the output of the `fortune` command to `cowsay`:

    fortune | cowsay
	
So you've installed two packages that can work together to do something more
interesting than either would do on its own. This is a bit of a silly example,
of course, but it's not so different than, say, installing packages for both
Apache and PHP on a webserver. 

### Main Class: init.pp
Often a module will gather several classes that work together into a single
class to let you declare everything at once.

Before creating the main class for cowsayings, however, a note on **scope**. You
may have noticed that the classes you wrote for cowsay and fortune were both
prepended by `cowsayings::`. When you declare a class, this scope syntax tells
Puppet where to find that class; in this case, it's in the cowsayings module. 

For the main class of a module, however, things are a little different. The main
class shares the name of the module itself. Instead of following the pattern of
the manifest for the class it contains, however, Puppet recognizes the special
file name `init.pp` as designating the manifest that will contain a module's
main class.

{% task 7 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/init.pp
  content: |
    class cowsayings {
      include cowsayings::cowsay
      include cowsayings::fortune
    }
{% endtask %}

So to contain your main `cowsayings` class, create an `init.pp` manifest in the
`cowsayings/manifests` directory:

    vim cowsayings/manifests/init.pp
	
Here, you'll define the `cowsayings` class. Within it, use the same
`include` syntax you used in your tests to declare the `cowsayings::cowsay` and
`cowsayings::fortune` classes.

{% highlight puppet %}
class cowsayings {
  include cowsayings::cowsay
  include cowsayings::fortune
}
{% endhighlight %}

Save the manifest, and check your syntax with the `puppet parser` tool.

{% task 8 %}
---
- execute: |
    puppet apply -e "package { 'fortune-mod': ensure => 'absent', } \
    package {'cowsay': ensure => 'absent, }"
- file: /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/init.pp
  content: include cowsayings
{% endtask %}

At this point, you've already got both packages you want installed on the
Learning VM. Applying the changes again wouldn't actually do anything. For the
sake of demonstration, go ahead and use a `puppet apply -e` to delete them so
you can test the functionality of your new `cowsayings` class:

    puppet apply -e "package { 'fortune-mod': ensure => 'absent', } \
     package {'cowsay': ensure => 'absent', }"

Next, create a test for the `init.pp` manifest in the tests directory.

    vim cowsayings/tests/init.pp
	
Here, just declare the `cowsayings` class:

    include cowsayings

{% task 9 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/init.pp
{% endtask %}

Good. Now that the packages are gone, do a `--noop` first, then apply your
`cowsayings/tests/init.pp` test.

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
`./tests` directory to declare each of those classes.

There are also a few details about classes and manifests we haven't gotten to
just yet. As we mentioned in the Power of Puppet quest, for example, classes
can also be declared with *parameters* to customize their functionality. Don't
worry, we'll get there soon enough!
