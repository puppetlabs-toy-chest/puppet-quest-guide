---
title: Variables and Parameters
layout: default
---

# Variables and Parameters

## Quest objectives

- Learn how to assign and evaluate variables in a manifest.
- Use the string interpolation syntax to mix variables into strings.
- Set variable values with class parameters.

## Getting started

If you completed the NTP and MySQL quests, you've already seen how class
parameters let you adjust classes from a module to suit your specific needs.
In this quest, we'll show you how to integrate variables into your classes
and make those variables accessible to be set through parameters.

To explore these concepts, you'll write a module to manage a static HTML website.
First, you'll create a simple web class with `file` resource declarations to manage
your website's HTML documents. By assigning repeated values like filepaths to
variables, you will make your class more concise and easier to refactor later.
Once this basic class structure is complete, you'll add parameters. This will
let you set the value of your class's variables as you declare it.

When you're ready to get started, enter the following command:

    quest --start variables_and_parameters

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton


In Puppet, variable names are prefixed with a `$`
(dollar sign), and a value is assigned with the `=` operator.

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
`undef` value. Though this may cause an error later in the compilation process,
in some cases it will pass through and cause unexpected results.

3. You can only assign a variable once within a single scope. Once it's
assigned, the value cannot be changed. The value of a Puppet variable may vary
across different systems in your infrastructure, but not within them.

### Variable interpolation

**Variable interpolation** lets you insert the value of a variable into a string.
For instance, if you wanted Puppet to manage several files in the `/var/www/html/questguide`
directory, you could assign this directory path to a variable:

{% highlight puppet %}
$doc_root = '/var/root/www/html/questguide/'
{% endhighlight %}

Once the variable is set, you can avoid repeating the same directory path by
inserting the `$doc_root` variable into the beginning of any string.

For example, you might use it in the title of a few *file* resource declarations:

{% highlight puppet %}
file { "${doc_root}index.html":
  ...
}
file { "${doc_root}about.html":
  ...
}
{% endhighlight %}

Notice the different variable syntax here. The variable name is wrapped in curly
braces, and the whole thing is preceded by the `$` (`${var_name}`).

Also note that a string that includes an interpolated variable must be wrapped in
double quotation marks (`"..."`), rather than the single quotation marks that
surround an ordinary string. These double quotation marks tell Puppet to find
and parse special syntax within the string, rather than interpreting it
literally.

## Manage web content with variables

To better understand how variables work in context, we'll walk you through
creating a simple `web` module that will put them to use.

{% task 1 %}
---
- execute: mkdir /etc/puppetlabs/code/environments/production/modules/web
- execute: mkdir /etc/puppetlabs/code/environments/production/modules/web/{manifests,tests}
{% endtask %}

First, you'll need to create the directory structure for your module.

Make sure you're in the `modules` directory for Puppet's modulepath.

    cd /etc/puppetlabs/code/environments/production/modules/

Now create an `web` directory:

    mkdir web
	
...and your `manifests` and `tests` directories:

    mkdir web/{manifests,tests}

{% task 2 %}
---
- file: /etc/puppetlabs/code/environments/production/modules/web/manifests/init.pp
  content: |
    class web {
    
      $doc_root = '/var/www/html/questguide/'
    
      $english = 'Hello world!'
      $french = 'Bonjour le monde!'
    
      file { "${doc_root}hello.html":
        ensure => 'present',
        content => "<em>${english}</em>",
      }
    
      file { "${doc_root}bonjour.html":
        ensure => 'present',
        content => "<em>${french}</em>",
      }
    }
{% endtask %}

With this structure in place, you're ready to create your main manifest 
where you'll define the `web` class.

    vim web/manifests/init.pp

{% highlight puppet %}
class web {

  $doc_root = '/var/www/html/questguide/'
  
  $english = 'Hello world!'
  $french = 'Bonjour le monde!'

  file { "${doc_root}hello.html":
    ensure => 'present',
    content => "<em>${english}</em>",
  }
  
  file { "${doc_root}bonjour.html":
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
- file: /etc/puppetlabs/code/environments/production/modules/web/tests/init.pp
  content: include web
{% endtask %}

Once you've validated your manifest with the `puppet parser` tool, create a test
for your manifest with an `include` statement for the web class you created.

{% task 4 %}
---
- execute: puppet apply /etc/puppetlabs/code/environments/production/modules/web/tests/init.pp
{% endtask %}

Run the test, using the `--noop` flag for a dry run before triggering your real
`puppet apply`.

Take a look [here](/hello.html) and [here](/bonjour.html) to see your new pages.

## Class parameters

> Freedom is not the absence of obligation or restraint, but the freedom of
> movement within healthy, chosen parameters.

> -Kristin Armstrong

Now that you have a basic `web` class done, we'll move on to **class
parameters**. Class parameters give you a way to set the variables within a
class as it's **declared** rather than hard-coding them into a class definition.

When defining a class, include a list of parameters and optional default values
between the class name and the opening curly brace:

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

Say you want to deploy your webpage to servers around the world, and want
changes in content depending on the language in each region. Instead of rewriting
the whole class or module for each region, you can use class parameters
to customize these values as the class is declared.

{% task 5 %}
---
- execute: vim /etc/puppetlabs/code/environments/production/modules/web/manifests/init.pp
  input:
    - "/class web\r"
    - "2Wi"
    - "( $page_name, $message ) "
    - "\e"
    - "GO"
    - |
      file { "${doc_root}${page_name}.html":
        ensure => 'present',
        content => "<em>${message}</em>",
      }
    - "\e"
    - ":wq\r"
{% endtask %}

To get started re-writing your `web` class with parameters, reopen the
`web/manifests/init.pp` manifest. To create a new regionalized page, you
need to be able to set the message and page name as class parameters.

{% highlight puppet %}
class web ( $page_name, $message ) {
{% endhighlight %}

Now create a third file resource declaration to use the variables set by your
parameters:

{% highlight puppet %}
file { "${doc_root}${page_name}.html":
  ensure => 'present',
  content => "<em>${message}</em>",
}
{% endhighlight %}

{% task 6 %}
---
- execute: vim /etc/puppetlabs/code/environments/production/modules/web/tests/init.pp
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
- execute: puppet apply /etc/puppetlabs/code/environments/production/modules/web/tests/init.pp
{% endtask %}

Now give it a try. Go ahead and do a `--noop` run, then apply the test.

Your new page should now be available [here](/hola.html)!

## Review

In this quest you've learned how to take your Puppet manifests to the next level
by using variables. You learned how to assign a value to a variable and then
reference the variable by name whenever you need its content. You also learned
how to interpolate variables and add parameters to a class.
