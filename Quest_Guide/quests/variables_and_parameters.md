---
title: Variables and Class Parameters
layout: default
---

# Variables and Class Parameters

### Prerequisites

- Welcome
- Power of Puppet
- Resources
- Manifests and Classes
- Modules

## Quest Objectives

- Learn how variables and parameters can make your modules adaptable.

## Getting Started

In this quest you'll get a taste of how variables fit into good module design,
and you'll learn how to integrate them into your own Puppet classes and resource
declarations.

If you completed the NTP and MySQL quests, you've already seen how parameterized
classes can be used to adapt a module to your specific needs. In this quest,
you'll see how to include parameters in your own classes.

To explore these two concepts, you'll be writing a module to manage a user
account. First, you'll write a simple class using a few variables, then you'll
add parameters to your class so that those variables can be set when the class
is declared.

When you're ready to get started, type the following command to begin:

    quest --start variables

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton


Puppet's variable syntax lets you assign a name to a bit of data, so you can use
that variable name later in your manifest to refer to the value assigned to it.
In Puppet's syntax, variable names are prefixed with a `$` (dollar sign), and a
value is assigned with the `=` operator.

Assigning a short string to a variable, for example, would look like this:

{% highlight puppet %}
$myvariable = 'look, a string!'
{% endhighlight %}

Once you have defined a variable you can use it anywhere in your manifest you
would have used the assigned value.

The basics of variables will seem familiar if you know another scripting or
programming language. However, there are a few caveats you should be aware of
when using variables in Puppet:

1. Unlike resource declarations, variable assignments are parse-order dependent.
This means that you must assign a variable in your manifest *before* you can use
it.

2. If you try to use a variable that has not been defined, the Puppet parser
won't complain. Instead, Puppet will treat the variable as having the special
`undef` value.

3. You can only assign a variable once within a single scope. Once it's
assigned, the value cannot be changed. (If this makes you wonder how accurate
the term "variable" is, you're not alone!)

### Variable Interpolation

**Variable interpolation** gives you a way to insert a string stored as a
variable into another string. For instance, if you want Puppet to manage the
files in the `/var/www/html/lvmguide` directory you set up in the Power of
Puppet quest, you can assign this directory path to a variable:

{% highlight puppet %}
$doc_root = '/var/root/www/html/lvmguide'
{% endhighlight %}

Once the variable is set, you can use the variable interpolation syntax to
insert it into a string. The variable name is preceded by a `$` and wrapped in
curly braces (`${var_name}`). For example, you might use it in the title of a
few *file* resource declarations:

{% highlight puppet %}
file { "${doc_root}/index.html":
  ...
}
file { "${doc_root}/about.html":
  ...
}
{% endhighlight %}

Not only is this more concise, but using variables allows you to set the
directory once, depending, for instance, on the kind of server you're running,
and let that specified directory be applied throughout your class.

Note that a string that includes an interpolated variable must be wrapped in
double quotation marks (`"..."`), rather than the single quotation marks that
surround an ordinary string. These double quotation marks tell Puppet to find
and parse special syntax within the string, rather than interpreting it
literally.

## Manage a Web Content with Variables

To better understand how variables work in context, we'll walk you through
creating a simple `web` module to drop some new files into the directory served
by the Apache service you set up in the Power of Puppet quest.

{% task 1 %}
---
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/web
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/web/{manifests,tests}
{% endtask %}

First, you'll need to create the directory structure for your module.

Make sure you're in the `modules` directory for Puppet's modulepath.

    cd /etc/puppetlabs/puppet/environments/production/modules/

Now create an `web` directory:

    mkdir web
	
...and your `manifests` and `tests` directories:

    mkdir web/{manifests,tests}

{% task 2 %}
- file: /etc/puppetlabs/puppet/environments/production/modules/web/manifests/init.pp
  content: |
    class web {
    
      $doc_root = '/var/www/html/lvmguide'
    
      $english = 'Hello world!'
      $french = 'Bonjour le monde!'
    
      file { "${doc_root}/hello.html":
        ensure => 'present',
        content => "<em>${english}</em>",
      }
    
      file { "${doc_root}/bonjour.html":
        ensure => 'present',
        content => "<em>${french}</em>",
      }
    }
{% endtask %}

Now you're ready to create your main manifest, where you'll define the `web`
class.

    vim web/manifests/init.pp

{% highlight puppet %}
class web {

  $doc_root = '/var/www/html/lvmguide'
  
  $english = 'Hello world!'
  $french = 'Bonjour le monde!'

  file { "${doc_root}/hello.html":
    ensure => 'present',
    content => "<em>${english}</em>",
  }
  
  file { "${doc_root}/bonjour.html":
    ensure => 'present',
    content => "<em>${french}</em>",
  }

}
{% endhighlight %}

Note that if you wanted to make a change to the `$doc_root` directory, you'd
only have to do this in one place. While there are more advanced forms of data
separation in Puppet, the basic principle is the same: The more distinct your
code is from the underlying data, the more resuable it is, and the less
difficult it will be to refactor when you have to make changes later.

{% task 3 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/web/tests/init.pp
  content: include web
{% endtask %}

Once you've validated your manifest with the `puppet parser` tool, create a test
for your manifest with an `include` statement for the web class you created.

{% task 4 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/web/tests/init.pp
{% endtask %}

Run the test, using the `--noop` flag for a dry run before triggering your real
`puppet apply`.

From your web browser on your host machine, connect to `http://<LVM's
IP>/hello.html` and `http://<LVM's IP>/bonjour.html`, and you'll see pages
you've set up.

## Class Parameters

> Freedom is not the absence of obligation or restraint, but the freedom of
> movement within healthy, chosen parameters.

> -Kristin Armstrong

Now that you've created your basic `web` class and replaced some of the values
in your resource declarations with variables, we'll move on to **class
parameters**. Class parameters give you a way to set the variables within a
class as it's **declared** rather than when the class is **defined**.

When defining a class, include a list of parameters and optional default values
between the class name and the opening curly brace. So a parameterized class is
defined as below:

{% highlight puppet %}
class classname ( $parameter = 'default' ) {
  ...
}
{% endhighlight %}

Once defined, a parameterized class can be **declared** with a syntax similar to
that of resource declarations, including key value pairs for each parameter you
want to set.

{% highlight puppet %}
class {'classname': 
  parameter => 'value',
}
{% endhighlight %}

Say you want to make these pages available not just on the Learning VM, but on
each node in your infrastructure, but that you want a few changes on each one.
Instead of rewriting the whole class or module with these minor changes, you can
use class parameters to customize these values as the class is declared.

{% task 5 %}
---
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/web/manifests/init.pp
  input:
    - "/class web\r"
    - "2Wi"
    - "( $page_name, $message ) "
    - "\e"
    - "GO"
    - |
      file { "${doc_root}/${page_name}.html":
        ensure => 'present',
        content => "<em>${message}</em>",
      }
    - "\e"
    - ":wq\r"
{% endtask %}

To get started re-writing your `web` class with parameters, reopen the
`web/manifests/init.pp` manifest. You've already written variables into the
resource declarations, so turning it into a parameterized class will be quick.
Just add your parameters in a pair of parenthesis following the name of the
class:

{% highlight puppet %}
class web ( $page_name, $message ) {
{% endhighlight %}

Now create a third file resource declaration to use the variables set by your
parameters:

{% highlight puppet %}
file { "${doc_root}/${page_name}.html":
  ensure => 'present',
  content => "<em>${message}</em>",
}
{% endhighlight %}

{% task 6 %}
---
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/web/tests/init.pp
  input:
    - "ddi"
    - "class {'web':\r"
    - "  page_name => 'hola',\r"
    - "  message => 'Hola mundo!',\r"
    - "}"
    - "\e"
    - ":"
    - "wq\r"
{% endtask %}

As before, use the test manifest to declare the class. You'll open
`web/tests/init.pp` and replace the simple `include` statement with the
parameterized class declaration syntax to set each of the class parameters:

{% highlight puppet %}
class {'web': 
  page_name => 'hola',
  message   => 'Hola mundo!',
}
{% endhighlight %}

{% task 7 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/web/tests/init.pp
{% endtask %}

Now give it a try. Go ahead and do a `--noop` run, then apply the test.

Your new page should now be available as `http://<LVM's IP>/hola.html`!

## Review

In this quest you've learned how to take your Puppet manifests to the next level
by using variables. You learned how to assign a value to a variable and then
reference the variable by name whenever you need its content. You also learned
how to interpolate variables.

In addition to learning about variables, interpolating variables, and facts, you
also gained more hands-on learning with constructing Puppet manifests using
Puppet's DSL. We hope you are becoming more familar and confident with using and
writing Puppet code as you are progressing.
