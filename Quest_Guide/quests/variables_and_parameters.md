---
title: Variables and Class Parameters
layout: default
---

# Variables and Class Parameters

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Manifest Quest

## Quest Objectives

- Learn how varaibles and parameters can make modules more adaptable.
- Use variable interpolation to insert variables into strings.
- Use system data from facter to assign variables.

## Getting Started

In this quest you will learn how to assign, invoke, and interpolate variables.

When you're ready to get started, type the following command to begin:

	quest --start variables

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton


Puppet's variable syntax lets you assign a name to a bit of data, and use that variable name later in your manifest to refer to that data you've assigned to it. In Puppet's syntax, variable names are prefixed with a `$` (dollar sign), and data is assigned with the `=` operator.

Assigning a short string to a variable, for example, would look like this:

{% highlight puppet %}
$myvariable = "look, data!"
{% endhighlight %}

Once you have defined a variable you can use it anywhere in your manifest you would have used the assigned value.

The basics of variables are simple enough, and will seem familiar if you know another scripting or programming language. However, there are a few caveats you should be aware of when using variables in Puppet:

1. Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest *before* you can use it.

2. If you try to use a variable that has not been defined, the Puppet parser won't complain. Instead, Puppet will treat the variable as having the special `undef` value.

3. You can only assign a variable once within a single scope.

## Variable Interpolation

**Variable interpolation** allows you to replace occurences of the variable with the *value* of the variable. In practice this helps with creating a string, the content of which contains another string which is stored in a variable. To interpolate a variable in a string, the variable name is preceded by a `$` and wrapped in curly braces (`${var_name}`). 

A string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string. These double quotation marks tell Puppet to find and parse special syntax within the string, rather than interpreting it literally.

`"Variable interpolation is ${adjective}!"`  

{% tip %}
Using double quotes for a string without any interpolated variables will still work, but isn't considered good style.
{% endtip %}

## Manage a User wtih Variables

To better understand how variables work in context, we'll walk you through creating a simple module to manage a User account on your system. Of course, creating a whole module to manage a single user generally wouldn't be worth the effort, but once you have this module working, we'll show you how to extend it to do some more interesting things.

For now, you'll create an `accounts` class to manage a *user*, a *group*, and a *file* (the user's home directory) resource. Instead of assigning all the values for these resources directly, you'll define some variables at the beginning of the class and use these variables throughout your resource declarations.

First, you'll need to create the directory structure for your module.

Make sure you're in the `modules` directory for Puppet's modulepath.

	cd /etc/puppetlabs/puppet/modules/

Now create an `accounts` directory:

	mkdir accounts
	
...and your `manifests` and `tests` directories:

	mkdir accounts/{manifests,tests}

Now you're ready to create your main manifest, where you'll define the `accounts` class.

	vim /accounts/manifests/init.pp

{% highlight puppet %}
class accounts {

  $name    = 'paphos'
  $comment = 'Paphos of Cyprus'
  $uid     = '510'

  user { $name:
    ensure  => 'present',
    home    => "/home/${name}",
    comment => $comment
    uid     => $uid,
  }

  group { $name:
    gid => $uid
  }

  file { "/home/${name}":
    ensure => 'directory',
    owner  => $name,
    group  => $name,
    mode   => 0750,
  }

}
{% endhighlight %}

It might seem a little pointless, at first, to make this kind of substitution, especially as the variable names aren't even much shorter than the strings they represent. Note, however, that if you wanted to make a change, you would have to edit a single line instead of a half-dozen or so. 

While there are more advanced forms of data separation in Puppet, the basic principle is the same. The more distinct your code is from the underlying data, the more resuable it is, and the less difficult it will be to refactor when you have to make changes later.

Once you've validated your manifest with the `puppet parser` tool, create a test for your manifest with an `include` statement for the accounts class you created.

Run the test, using the `--noop` flag for a dry run before triggering your real `puppet apply`.

## Class Parameters

> Freedom is not the absence of obligation or restraint, but the freedom of movement within healthy, chosen parameters.

> -Kristin Armstrong

Class **parameters** give you a way to set the variables within a class definition as the class is declared. 

When defining a class, you can include a list of parameters and optional default values between the class name and the opening curly brace.

So a parameterized class is defined as below:

{% highlight puppet %}
class classname ( $parameter = 'default' ) {
  ...
}
{% endhighlight %}

A parameterized class is declared with a syntax similar to that of resource declarations, including key value pairs for each parameter you want to set.

{% highlight puppet %}
class {'classname': 
  parameter => 'value',
}
{% endhighlight %}

Now you've got a quick way to create an account, complete with a group and home directory. But say you want to create a user not just on the Learning VM, but on each node in your infrastructure? And say you want some different values set for each of these different users? Instead of rewriting the whole class or module with these minor changes, you can use class parameters to customize these values as the class is declared.

Reopen the `accounts/manifests/init.pp` manifest. You've already written variables into the resource declarations, so turning it into a parameterized class with be quick. Just add your three variables in the first line like so:

{% highlight puppet %}
class accounts ( $name, $comment, $uid ) {
{% endhighlight %}

Then go ahead and delete the variable assignments from the beginning of the class. There, that's it! Just be sure to check your syntax, and you're all set.

Now open the `accounts/tests/init.pp` test manifest, and declare the accounts class with the following parameters:

{% highlight puppet %}
class {'accounts': 
  name    => 'rick',
  comment => 'Richard Deckard',
  uid     => '511',
}
{% endhighlight %}

Now give it a try. Go ahead and do a `--noop` run, then apply the test.

## Review

In this quest you've learned how to take your Puppet manifests to the next level by using variables. There are even more levels to come, but this is a good start. We learned how to assign a value to a variable and then reference the variable by name whenever we need its content. We also learned how to interpolate variables, and how Facter facts are global variables available for you to use.

In addition to learning about variables, interpolating variables, and facts, you also gained more hands-on learning with constructing Puppet manifests using Puppet's DSL. We hope you are becoming more familar and confident with using and writing Puppet code as you are progressing.

Looking back to the Power of Puppet Quest, can you identify where and how variables are used in the `lvmguide` class?

