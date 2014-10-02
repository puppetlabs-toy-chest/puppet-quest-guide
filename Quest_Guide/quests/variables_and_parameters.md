---
title: Variables and Class Parameters
layout: default
---

# Variables and Class Parameters

### Prerequisites

- 

## Quest Objectives

- Learn how varaibles and parameters can make modules more adaptable.

## Getting Started

In this quest you'll get a taste of how variables fit into good module design, and you'll learn how to integrate them into your own Puppet classes and resource declarations.

If you completed the NTP and MySQL quests, you've already seen how parameterized classes can be used to adapt a module to your specific needs. In this quest, you'll see how to include parameters in your own classes.

To explore these two concepts, you'll be writing a module to manage a user account. First, you'll write a simple class using a few variables, then you'll see how you can add parameters your class to let you set those variables when the class is declared.

When you're ready to get started, type the following command to begin:

	quest --start variables

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton


Puppet's variable syntax lets you assign a name to a bit of data, and use that variable name later in your manifest to refer to that data you've assigned to it. In Puppet's syntax, variable names are prefixed with a `$` (dollar sign), and data is assigned with the `=` operator.

Assigning a short string to a variable, for example, looks like this:

{% highlight puppet %}
$myvariable = "look, data!"
{% endhighlight %}

Once you have defined a variable you can use it anywhere in your manifest you would have used the assigned value.

The basics of variables are simple enough, and will seem familiar if you know another scripting or programming language. However, there are a few caveats you should be aware of when using variables in Puppet:

1. Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest *before* you can use it.

2. If you try to use a variable that has not been defined, the Puppet parser won't complain. Instead, Puppet will treat the variable as having the special `undef` value.

3. You can only assign a variable once within a single scope.

### Variable Interpolation

**Variable interpolation** gives you a way to insert a string stored as a variable into another string. Interpolation can be handy in a lot of cases, but you'll probably use it most often to deal with paths for files and directories. For instance, if you wanted Puppet to manage a bunch of files in the `/var/www/html` directory, you could assign this directory path to a variable:

{% highlight puppet %}
$html_dir = '/var/root/www/html/'
{% endhighlight %}

Once the variable is set, you can use the variable interpolation syntax to insert it into a string. The variable name is preceded by a `$` and wrapped in curly braces (`${var_name}`). For example, you might use it in the title of a few *file* resource declarations:

{% highlight puppet %}
file { "${html_dir}index.html":
  ...
}
file { "${html_dir}about.html":
  ...
}
{% endhighlight %}

Not only is this more concise, but using variables allows you to set the directory once, depending, for instance, on the kind of server you're running, and let that specified directory be applied throughout your class.

Note that a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string. These double quotation marks tell Puppet to find and parse special syntax within the string, rather than interpreting it literally. Using double quotes for a string *without* any interpolated variables will work, but it's against the Puppet style guide.

## Manage a User wtih Variables

To better understand how variables work in context, we'll walk you through creating a simple module to manage a User account on your system. Realistically, creating a whole module just to manage a single user wouldn't be best use of your time. Once you have this module working, however, we'll show you how to extend it to do some more interesting things.

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

Note that if you wanted to make a change, you would have to edit a single line instead of a half-dozen or so. While there are more advanced forms of data separation in Puppet, the basic principle is the same: The more distinct your code is from the underlying data, the more resuable it is, and the less difficult it will be to refactor when you have to make changes later.

Once you've validated your manifest with the `puppet parser` tool, create a test for your manifest with an `include` statement for the accounts class you created.

Run the test, using the `--noop` flag for a dry run before triggering your real `puppet apply`.

## Class Parameters

> Freedom is not the absence of obligation or restraint, but the freedom of movement within healthy, chosen parameters.

> -Kristin Armstrong

Now that you've created your basic `accounts` class and replaced some of the values in your resource declarations with variables, we'll move on to **class parameters**. Class parameters give you a way to set the variables within a class as it's **declared** rather than when the class is **defined**.

When defining a class, include a list of parameters and optional default values between the class name and the opening curly brace. So a parameterized class is defined as below:

{% highlight puppet %}
class classname ( $parameter = 'default' ) {
  ...
}
{% endhighlight %}

Once defined, a parameterized class can be **declared** with a syntax similar to that of resource declarations, including key value pairs for each parameter you want to set.

{% highlight puppet %}
class {'classname': 
  parameter => 'value',
}
{% endhighlight %}

Say you want to create a user not just on the Learning VM, but on each node in your infrastructure. And say you want some different values set for each of these different users. Instead of rewriting the whole class or module with these minor changes, you can use class parameters to customize these values as the class is declared.

To get started re-writing your `accounts` class with parameters, reopen the `accounts/manifests/init.pp` manifest. You've already written variables into the resource declarations, so turning it into a parameterized class will be quick. Just add your three parameters in a pair of parenthesis following the name of the class:

{% highlight puppet %}
class accounts ( $name, $comment, $uid ) {
{% endhighlight %}

Then go ahead and delete the variable assignments from the beginning of the class. There, that's it! Just be sure to check your syntax, and your new class definition is all set.

As before, use the test manifest to declare the class. Open `accounts/tests/init.pp`, and declare the accounts class. Instead of the simple `include` statement, use the parameterized class declaration syntax to set each of the class parameters:

{% highlight puppet %}
class {'accounts': 
  name    => 'rick',
  comment => 'Richard Deckard',
  uid     => '511',
}
{% endhighlight %}

Now give it a try. Go ahead and do a `--noop` run, then apply the test. If you like, use the `puppet resource` tool to check that the new user has been created.

## Review

In this quest you've learned how to take your Puppet manifests to the next level by using variables. There are even more levels to come, but this is a good start. We learned how to assign a value to a variable and then reference the variable by name whenever we need its content. We also learned how to interpolate variables, and how Facter facts are global variables available for you to use.

In addition to learning about variables, interpolating variables, and facts, you also gained more hands-on learning with constructing Puppet manifests using Puppet's DSL. We hope you are becoming more familar and confident with using and writing Puppet code as you are progressing.

Looking back to the Power of Puppet Quest, can you identify where and how variables are used in the `lvmguide` class?

