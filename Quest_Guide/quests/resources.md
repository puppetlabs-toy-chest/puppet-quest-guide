---
title: Resources
layout: default
---

# Resources

## Quest objectives

- Understand how resources on the system are modeled in Puppet's Domain Specific
  Language (DSL).
- Use Puppet to inspect resources on your system.
- Use the Puppet Apply tool to make changes to resources on your system.
- Learn about the Resource Abstraction Layer (RAL).

## Getting Started

Before you go on to learn the more complex aspects of Puppet, you should start
with a solid understanding of **resources**, the fundamental building
blocks of Puppet's declarative modeling syntax.

In this quest, you will learn what resources are and how to inspect and modify
them with Puppet command-line tools.

When you're ready to get started, type the following command:

    quest --start resources

## Resources

> For me, abstraction is real, probably more real than nature. I'll go further
> and say that abstraction is nearer my heart. I prefer to see with closed eyes.

> -Joseph Albers

There's a big emphasis on novelty in technology. We celebrate the trail-blazers
who spark our imagination and guide us to places we hadn't imagined. Often, however,
it's not these frontier fireworks themselves that truly drive innovation in a field.
It's something more basic: abstraction. Taking common tasks and abstracting away
the complexities and pitfalls doesn't just make those tasks themselves easier, it gives you
the stable, repeatable, and testable foundation you need to build something new.

For Puppet, this foundation is a system called the *resource abstraction layer*.
Puppet interprets any aspect of your system configuration you want to manage
(users, files, services, and packages, to give some common examples) as a unit
called a *resource*. Puppet knows how to translate back and forth between
the resource syntax and the 'native' tools of the system it's running on. Ask Puppet
about a user, for example, and it can represent all the information about that user
as a resource of the *user* type. Of course, it's more useful to work in the opposite
direction. Describe how you want a user resource to look, and Puppet can go out and
make all the changes on the system to actually create or modify a user to match that
description.

The block of code that describes a resource is called a **resource declaration**.
These resource declarations are written in Puppet code, a Domain Specific Language
(DSL) based on Ruby.

### Puppet's Domain Specific Language

A good understanding of the Puppet DSL is a key first step in learning how to
use Puppet effectively. While tools like the PE console give you quite a bit of power
to make configuration changes at a level above the code implementation, it always
helps to have a solid understanding of the Puppet code under the hood.

Puppet's DSL is a *declarative* language rather than an *imperative* one. This
means that instead of defining a process or set of commands, Puppet code
describes (or declares) only the desired end state. With this desired state described,
Puppet relies on built-in *providers* to handle with implementation.

One of the points where there is a nice carry over from Ruby is the *hash*
syntax. It provides a clean way to format this kind of declarative model, and is
the basis for the *resource declarations* you'll learn about in this
quest.

As we mentioned above, a key feature of Puppet's declarative model is that it
goes both ways; that is, you can inspect the current state of any existing resource
in the same syntax you would use to declare a desired state.

{% task 1 %}
---
- execute: puppet resource user root
{% endtask %}

Use the *puppet resource* tool to take a look at your root user account. The
syntax of the command is: *puppet resource \<type\> \<name\>*.

    puppet resource user root 
	
You'll see something like the following:

{% highlight puppet %}
user { 'root':
  ensure           => 'present',
  comment          => 'root',
  gid              => '0',
  home             => '/root',
  password         => '$1$jrm5tnjw$h8JJ9mCZLmJvIxvDLjw1M/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '0',
}
{% endhighlight %}

This resource declaration syntax is composed of three main components:

- Type
- Title
- Attribute value pairs

We'll go over each of these below.

### Resource Type

You'll get used to the resource syntax as you use it, but for this first look
we'll go through the example point by point.

We'll start with the first line first:

{% highlight puppet %}
  user { 'root':
    ...
  }
{% endhighlight %}

The word `user`, right _before_ the curly brace, is the **resource type**.
The type represents the kind of thing that the resource describes. It tells
Puppet how to interpret the rest of the resource declaration and what kind of
providers to use for managing the underlying system details.

Puppet includes a number of built-in resource types, which allow you to manage
aspects of a system. Below are some of the core resource types you'll encounter
most often:

* `user` A user
* `group` A user group
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job
* `exec` An external command
* `host` A host entry

If you are curious to learn about all of the built-in resources types
available, see the [Type Reference
Document](http://docs.puppetlabs.com/references/latest/type.html) 
or try the command `puppet describe --list`.

### Resource Title

Take another look at the first line of the resource declaration. 

{% highlight puppet %}
  user { 'root':
    ...
  }
{% endhighlight %}

The single quoted word `'root'` just before the colon is the resource **title**.
Puppet uses the resource title as its own internal unique identifier for that
resource. This means that no two resources of the same type can have the same title.

In our example, the resource title, `'root'`, is also the name of the user we're inspecting
with the `puppet resource` command. Generally, a resource title will match the name
of the thing on the system that the resource is managing. A package resource will
usually be titled with the name of the managed package, for example, and a file resource
will be titled with the full path of the file.

Keep in mind, however, that when you're creating your own resources, you can set
these values explicitly in the body of a resource declaration instead of letting them
default to the resource title. For example, as long as you explicitly tell Puppet
that a user resource's `name` is `'root'`, you can actually give the resource any
title you like. (`'superuser'`, maybe, or even `'spaghetti'`) Just because you *can* do
this, though, doesn't mean it's generally a good idea! Unless you have a good
reason to do otherwise, letting Puppet do it's defaulting magic with titles
will save you typing and make your puppet code more readable.

### Attribute Value Pairs

Now that we've covered the *type* and *title*, take a look at the body of the
resource declaration.

{% highlight puppet %}
user { 'root':
  ensure           => 'present',
  comment          => 'root',
  gid              => '0',
  home             => '/root',
  password         => '$1$jrm5tnjw$h8JJ9mCZLmJvIxvDLjw1M/',
  password_max_age => '99999',
  password_min_age => '0',
  shell            => '/bin/bash',
  uid              => '0',
}
{% endhighlight %}

After the colon in that first line comes a hash of **attributes** and their
corresponding **values**. Each line consists of an attribute name, a `=>`
(pronounced 'hash rocket'), a value, and a final comma. For instance, the
attribute value pair `home => '/root',` indicates that root's home is set to the
directory `/root`.

So to bring this all together, a resource declaration will match the following
pattern:

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside Trailing comma %}
The comma at the end of the final attribute value pair isn't required by the parser, but it is
best practice to include it for the sake of consistency. Leave it out, and you'll
inevitably forget to insert it when you add another attribute value pair on the
following line!
{% endaside %}

{% task 2 %}
---
- execute: "puppet describe user | less"
  input:
    - 'q'
{% endtask %}

Of course, the real meat of a resource is in these attribute value pairs. You
can't do much with a resource without a good understanding of its attributes.
The `puppet describe` makes this kind of information easily available from
the command line.

Use the *puppet describe* tool to get a description of the *user* type,
including a list of its parameters.

    puppet describe user | less
	
(You can use the `jk` key mapping or the arrow keys to scroll, and `q` to exit
*less*.)
	
No need to read all the way through, but take a minute to skim the *describe*
page for the *user* type. Notice the documentation for some of the attributes
you saw for the *root* user.

## Puppet Apply

You can use the `puppet apply` tool with the `-e` (`--execute`) flag to execute
a bit of Puppet code. Though `puppet apply -e` is limited to one-off changes, it's
a great tool for tests and exploration.

{% task 3 %}
---
- execute: |
    puppet apply -e "user { 'galatea': ensure => 'present', }"
{% endtask %}

In this task, you'll create a new user called *galatea*. Puppet uses reasonable
defaults for unspecified user attributes, so all you need to do to create a new
user is set the `ensure` attribute to `present`. This `present` value tells
Puppet to check if the resource exists on the system, and to create the specified
resource if it does not.

    puppet apply -e "user { 'galatea': ensure => 'present', }"

Use the `puppet resource` tool to take a look at user `galatea`. Type the
following command:

    puppet resource user galatea

Notice that while the *root* user had a *comment* attribute, Puppet hasn't
created one for your new user. As you may have noticed looking over the *puppet
describe* entry for the user type, this *comment* is generally the full name of
the account's owner.

{% task 4 %}
---
- execute: "puppet resource -e user galatea"
  input:
    - "o"
    - "  comment => 'Galatea of Cyprus',"
    - "\e"
    - ":"
    - "wq\r"
{% endtask %}

Though you could add a comment with the `puppet apply -e`, you'd have to cram
the whole resource declaration into one line, and you wouldn't be able to see
the current state of the resource before making your changes. Luckily, the
`puppet resource` tool can also take a `-e` flag. This will drop the current
state of a resource into a text editor where you can make any changes
you like.

Let's give it a try:

    puppet resource -e user galatea
	
You should see the same output for this resource as before, but this time it will be
opened in a text editor (Vim, by default). To add a *comment* attribute, insert
a new line to the resource's list of attribute value pairs. (If you're not used
to Vim, note that you must use the `i` command to enter insert mode before you
can insert text.)

    comment => 'Galatea of Cyprus',
	
Save and exit (`ESC` to return to command mode, and `:wq` to save and exit Vim), and the
resource declaration will be applied with the added comment. If you like, use
the `puppet resource` tool again to inspect the result.

## Review

So let's rehash what you learned in this quest. First, we covered two very
important Puppet topics: the Resource Abstraction Layer and the anatomy of a
resource. To dive deeper into these topics, we showed you how to use the `puppet
describe` and `puppet resource` tools, which also leads to a better
understanding of Puppet's Language.

We also showed you how you can change the state of the system by declaring
resources with the `puppet apply` and `puppet resource` tools. These tools
will be useful as you progress through the following quests!
