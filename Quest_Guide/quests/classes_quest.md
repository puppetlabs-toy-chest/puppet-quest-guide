---
title: Classes
layout: default
---

# Classes

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Manifest Quest
- Variables Quest
- Conditions Quest
- Ordering Quest

## Quest Objectives

 - Understand what a *class* means in Puppet's Language
 - Learn how to use a class definition
 - Understand the difference between defining and declaring a class

## Getting Started

So we've mentioned the term *class* in previous quests. In this quest we cover
the use of classes within a Puppet manifest to group resource declarations (and
everything we've learned up to this point) into reusable blocks of Puppet code.
When you're ready to get started, type the following command:

    quest --start classes

{% aside This is just an example %}
We've written this quest to help you learn the functionality and purpose of
classes. To keep things simple, we will write code to both define classes and
include them within a single manifest. Keep in mind however, that in practice
you will always define your classes in a separate manifest. In the Modules Quest
we will show you the proper way to define classes and declare classes.
{% endaside %}

## Defining Classes

In Puppet's language **classes** are named blocks of Puppet code. Once you have
defined a class, you can invoke it by name. Puppet will manage all the resources
that are contained in the class defintion once the class is invoked. Please
remember that classes in Puppet are not related to classes in Object Oriented
Programming. In Puppet, classes serve as named containers for blocks of Puppet
code.

Let's dive right in, and look at an example of a class definition. We have
created a class definition for you. Look at the contents of the file
`/root/examples/modules1-ntp1.pp`. Open it using `nano` or your favorite text
editor. 

The file should contain the following code:

{% highlight puppet %}

class ntp {
  case $operatingsystem {
    centos, redhat: {
      $service_name = 'ntpd'
      $conf_file    = 'ntp.conf.el'
    }
    debian, ubuntu: {
      $service_name = 'ntp'
      $conf_file    = 'ntp.conf.debian'
    }
  }

  package { 'ntp':
    ensure => installed,
  }
  file { 'ntp.conf':
    path    => '/etc/ntp.conf',
    ensure  => file,
    require => Package['ntp'],
    source  => "/root/examples/answers/${conf_file}"
  }
  service { 'ntp':
    name      => $service_name,
    ensure    => running,
    enable    => true,
    subscribe => File['ntp.conf'],
  }
}
{% endhighlight %}

That's a class definition. As you can see, there is a `case` statement, and
three resources, all contained within the following pair of curly braces:

{% highlight puppet %}
class ntp {

}
{% endhighlight %}

The conditional (`case` statement) sets up the value for the `$service_name` and
`$conf_file` variables appropriately for a set of operating systems. Three
resources - a package, a file, and a service are defined, which use the
variables to provide flexibility.

Now what would happen if we applied this manifest, containing the class
definition?

{% task 1 %}

Apply the manifest containing the `ntp` class definition:

  puppet apply /root/examples/modules1-ntp1.pp

That's funny. Nothing happened, and nothing changed on the system!

This is because the class in the `modules1-ntp1.pp` manifest is only being
defined and not declared. When you applied the manifest, it is as if Puppet
went, "Ok! Got it. When you ask for class ntp, I am to know that it refers to
everything in the definition." You have to _declare_ the class in order to make
changes and manage the resources specified in the definition. Declared? What's
that? We will discuss that next.


## Declaring Classes

In the previous section, we saw an example of a class definition and learned
that a class is a collection of resources. The question that still needs
answering is, how can we use the class definition? How can we tell Puppet to use
the definition as part of configuring a system?

The simplest way to direct Puppet to apply a class definition on a system is by
using the `include` directive. For example, to invoke class ntp you would have
to say:

    include ntp

in a Puppet Manifest, and apply that manifest.

Now you might wonder how Puppet knows *where* to find the definition for the
class. Fair question. The answer involves Modules, the subject of our next
lesson. For now, since we want to try applying the definition for class ntp,
let's put the line `include ntp` right after the class definition.

We have already done that for you, open the file
`/root/examples/modules1-ntp2.pp`:

    nano /root/examples/modules1-ntp2.pp

You should see the line:

    include ntp

as the very last line of the file.

{% task 2 %}

Declare class ntp

Go ahead and now apply the manifest `/root/examples/modules1-ntp2.pp`.

  HINT: Use the puppet apply tool. Refer to the Manifests Quest.

Great! This time Puppet actually managed the resources in the definition of
class ntp. 

Again, please do not ever do this above example in real life, since you _always_
want to separate the definition from the declaration. This is just an example to
show you the functionality and benefit of classes. In the Modules Quest we will
show you the proper way to define classes and declare classes separately.

## A detailed look at the lvmguide class 

In the Power of Puppet Quest, we used a class called `lvmguide` to help us set
up the website version of this Quest Guide. The `lvmguide` class gives us a nice
illustration of structuring a class definition. We've included the code from the
`lvmguide` class declaration below for easy reference as we talk about defining
classes. Don't worry if a few things remain unclear at this point. For now,
we're going to focus primarily on how class definitions work.

{% highlight puppet %}
class lvmguide (
  $document_root = '/var/www/html/lvmguide',
  $port          = '80',
) {

  # Manage apache, the files for the website will be 
  # managed by the quest tool
  class { 'apache':
    default_vhost => false,
  }
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }
}
{% endhighlight %}

In this example we've **defined** a class called `lvmguide`. The first line of
the class definition begins with the word `class`, followed by the name of the
class we're defining: in this case, `lvmguide`.

{% highlight puppet %}
class lvmguide (
{% endhighlight %}

Notice that instead of the usual curly bracket, there is an open parenthesis at
the end of this first line, and it isn't until after the closing parenthesis
that we see the opening curly bracket.

{% highlight puppet %}
class lvmguide (  
  $document_root = '/var/www/html/lvmguide',
  $port = '80',
){
{% endhighlight %}

The variable declarations contained in these parentheses are called class
**parameters**.

Class parameters allow you to pass a set of parameters to a class. In this case,
the parameters are `$document_root` and `$port`. The values assigned to these
parameters in the class definition are the **default values**, which will be
used whenever values for the parameters are not passed in.

The first item you see inside the curly braces is... another class! One of the
advantages of keeping your classes modular is that you can easily pull together
all the classes you need to achieve a particular purpose.

{% highlight puppet %}
  class { 'apache':
    default_vhost => false,
  }
{% endhighlight %}

Notice how the code looks similar to how you might describe a user, file or
package resource. It looks like a _declaration_. It is, indeed, a *class
declaration*. This is an alternative to using `include` to invoke existing class
definitions. In this case, we wanted to set up an apache server to host our
Quest Guide content as a website. Instead of trying to reinvent the wheel, we
are able to pull in the existing `apache` class from the `apache` module we
downloaded from the Forge.  

If we had wanted to include the `apache` class with its default parameter
settings, we could have used the `include apache` syntax. Turns out that just
like the `lvmguide` class, the `apache` class is defined to accept parameters.
Since we wanted to set the `default_vhost` parameter, we used the resource-like
class declaration syntax. This allows us to set `default_vhost` to `false`.

Our final code block in the class definition is a resource declarations:

{% highlight puppet %}
  apache::vhost { 'learning.puppetlabs.vm':
    port    => $port,
    docroot => $document_root,
  }
{% endhighlight %}

First, we declare an `apache::vhost` resource type, and pass along values from
our class parameters to its `port` and `docroot` attributes. The `apache::vhost`
resource type is defined in, and provided by the `apache` module that we
installed, and helps manage the configuration of Apache2 Virtual Hosts.

As in the above example, class definitions give you a concise way to group other
classes and resource declarations into re-usable blocks of Puppet code. You can
then selectively assign these classes to different machines across your
Puppetized network in order to easily configure those machines to fulfill the
defined function. Now that the `lvmguide` class is defined, enabling the Quest
Guide website on other machines would be as easy as assigning that class in the
PE Console.

## Review

We learned about classes, and how to define them. We also learned two ways to
invoke classes - using the `include` keyword, and declaring classes using a
syntax similar to resource declarations. Classes are a whole lot more useful
once we understand what modules are, and we will learn about modules in the next
quest.
