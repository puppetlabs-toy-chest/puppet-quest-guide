---
title: Resources
layout: default
---

# Resources

### Prerequisites

- Welcome Quest
- Power of Puppet Quest

## Quest Objectives

- Understand how resources on the system are modeled in Puppet's Domain Specific
  Language (DSL).
- Use Puppet to inspect resources on your system.
- Use the Puppet Apply tool to make changes to resources on your system.
- Learn about the Resource Abstraction Layer (RAL).

## Getting Started

In this quest, you will be introduced to **resources**, the fundamental building
blocks of Puppet's declarative modeling syntax. You will learn how to inspect
and modify resources on the Learning VM using Puppet command-line tools. A
thorough understanding of how the Puppet resource syntax reflects the state of a
system will be an important foundation as you continue to learn the more complex
aspects of Puppet and its DSL.

When you're ready to get started, type the following command:

    quest --start resources

## Resources

> For me, abstraction is real, probably more real than nature. I'll go further
> and say that abstraction is nearer my heart. I prefer to see with closed eyes.

> -Joseph Albers

Resources are the fundamental units for modeling system configurations. Each
resource describes some aspect of a system and its state, like a service that
should be running or a package you want installed. The block of code that
describes a resource is called a **resource declaration**. These resource
declarations are written in Puppet code, a Domain Specific Language (DSL) built
on Ruby.

### Puppet's Domain Specific Language

Puppet's DSL is a *declarative* language rather than an *imperative* one. This
means that instead of defining a process or set of commands, Puppet code
describes (or declares) only the desired end state, and relies of built-in
*providers* to deal with implementation.

When Luke Kanies was initially designing Puppet, he experimented with several
languages before settling on Ruby as the best match for his vision of a
transparent and readable way to model system states. While the Puppet DSL has
inherited many of these appealing aspects of Ruby, you're better off thinking of
it as a distinct language. While a bit of Ruby knowledge certainly won't hurt in
your quest to master Puppet, you don't need to know any Ruby to use Puppet, and
you may even end up in trouble if you blindly assume that things will carry
over.

One of the points where there is a nice carry over from Ruby is the *hash*
syntax. It provides a clean way to format this kind of declarative model, and is
the basis for the *resource declarations* you'll be learning about in this
quest.

A nice feature of Puppet's declarative model is that it goes both ways; that is,
you can inspect the current state of any existing resource in the same syntax
you would use to declare a desired state.

{% task 1 %}
---
- execute: puppet resource user root
{% endtask %}

Using the *puppet resource* tool, take a look at your root user account. Note
the pattern of the command will be: *puppet resource \<type\> \<name\>*.

    puppet resource user root 
	
You'll see something like the following.

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

It's a little abstract, but a nice portrait, don't you think?

### Resource Type

To be sure that you have a solid understanding of how resources are represented,
we'll go through this example point by point.

Take a look at your first line in the above resource declaration.

{% highlight puppet %}
  user { 'root':
{% endhighlight %}

The word `user`, right _before_ the curly brace, is the **resource type**.

Puppet includes a variety of built-in resource types, which allow you to manage
various aspects of a system. Below are some of the core resource types you'll
likely encounter most often: 

* `user` A user
* `group` A user group
* `file` A specific file
* `package` A software package
* `service` A running service
* `cron` A scheduled cron job
* `exec` An external command
* `host` A host entry

If you are curious to learn about all of the different built-in resources types
available for you to manage, see the [Type Reference
Document](http://docs.puppetlabs.com/references/latest/type.html) 

### Resource Title

Take another look at the first line of the resource declaration. 

{% highlight puppet %}
  user { 'root':
{% endhighlight %}

The single quoted word 'root' just before the colon is the resource **title**.
Puppet uses a resource's title as a unique identifer for that resource. This
means that no two resources of the same type can share a title. In the case of
the user resource, the title is also the name of the user account being managed.

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
attribute value pair `home => '/root',` indicates that your home is set to the
directory `/root`.

So to bring this all together, a resource declaration will match the following
pattern:

{% highlight puppet %}
type {'title':
    attribute => 'value',
}
{% endhighlight %}

{% aside The Trailing Comma %}
Though the comma at the end of the final attribute value pair isn't strictly
necessary, it is best practice to include it for the sake of consistency. Leave
it out, and you'll inevitably forget to insert it when you add another attribute
value pair on the following line!
{% endaside %}

So in the world of Puppet, you and everything around you can be respresented as
a resource, and resources follow this tidy declarative syntax. As pretty as they
are, presumably you don't want to just look at resources all day, you want to
change them! 

You can, and easily. But before making any changes, take a moment to learn a bit
more about the user type. You'll want a way of knowing *what* you're changing
before you start changing attributes. 

{% task 2 %}
---
- execute: "puppet describe user | less"
  input:
    - 'q\r'
{% endtask %}

Use the *puppet describe* tool to get a description of the *user* type,
including a list of its parameters.

    puppet describe user | less
	
(You can use the `jk` key mapping or the arrow keys to scroll, and `q` to exit
*less*.)
	
No need to read all the way through, but take a minute to skim the *describe*
page for the *user* type. Notice the documentation for some of the attributes
you saw for the *root* user.

## Puppet Apply

You can use the Puppet resource declaration syntax with the *puppet apply* tool
to make quick changes to resources on the system. (Note, though, that while
*puppet apply* is great for tests and exploration, it's limited to this kind of
one-off change. We'll get to the more robust ways to manage resources in later
quests.)

{% task 3 %}
---
- execute: |
    puppet apply -e "user { 'galatea': ensure => 'present', }"
{% endtask %}

You can use the *puppet apply* tool with the *-e* (*--execute*) flag to execute
a bit of Puppet code. In this example, you'll create a new user called
*galatea*. Puppet uses some defaults for unspecified user attributes, so all
you'll need to do to create a new user is set the 'ensure' attribute to
'present'. This 'present' value tells Puppet to check if the resource exists on
the system, and to create the specified resource if it does not.

    puppet apply -e "user { 'galatea': ensure => 'present', }"

Use the `puppet resource` tool to take a look at user *galatea*. Type the
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

While puppet apply with the `-e` flag can be handy for quick one-liners, you can
pass an `--execute` (incidentally, also shortened to `-e`) flag to the `puppet
resource` tool to edit and apply changes to a resource.

    puppet resource -e user galatea
	
You'll see the same output for this resource as before, but this time it will be
opened in a text editor (vim, by default). To add a *comment* attribute, insert
a new line to the resource's list of attribute value pairs. (If you're not used
to Vim, note that you must use the `i` command to enter insert mode before you
can insert text.)

    comment => 'Galatea of Cyprus',
	
Save and exit (`esc` to return to command mode, and `:wq` in vim), and the
resource declaration will be applied with the added comment. If you like, use
the `puppet resource` tool again to inspect the result.

{% aside Quest Progress %}
Have you noticed that when you successfully finish a task, the 'completed tasks'
in the lower right corner of your terminal increases? Remember, you can also
check your progress by entering the following command:

    quest --progress

{% endaside %}

## The Resource Abstraction Layer

As we mentioned at the beginning of this quest, Puppet takes the descriptions
expressed by resource declarations and uses *providers* specific to the
operating system to realize them. These providers abstract away the complexity
of managing diverse implementations of resource types on different systems. As a
whole, we call this system of resource types and providers the **Resource
Abstraction Layer** or **RAL**.

In the case of users, Puppet can use providers to manage users with LDAP,
Windows ADSI, AIX, and several other providers depending on a node's system.
Similarly, when you wish to install a package, you can stand back and watch
Puppet figure out whether to use 'yum', 'apt', 'rpm', or one of several other
providers for package management. This lets you set aside the
implementation-related details of managing the resources, such as the names of
commands (is it `adduser` or `useradd`?), arguments for the commands, and file
formats, and lets you focus on the end result.

## Review

So let's rehash what you learned in this quest. First, we covered two very
important Puppet topics: the Resource Abstraction Layer and the anatomy of a
resource. To dive deeper into these topics, we showed you how to use the `puppet
describe` and `puppet resource` tools, which also leads to a better
understanding of Puppet's Language. We also showed you how you can actually
change the state of the system by declaring resources with the `puppet apply`
and `puppet resource` tools. These tools will be useful as you progress through
the following quests.
