{% include '/version.md' %}

# Variables and Parameters

## Quest objectives

- TBD

## Getting started

In this quest, you'll learn how to use variables and class parameters to add
flexibility to your Puppet code.

When you're ready to get started, enter the following command:

    quest begin variables_and_parameters

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton

In Puppet, variable names are prefixed with a `$` (dollar sign), and a value is
assigned with the `=` operator.

Assigning a short string to a variable, for example, looks like this:

```puppet
$myvariable = 'look, a string!'
```

Once you have defined a variable you can use it anywhere in your manifest where
you want to use the assigned value.

There are a few caveats you should be aware of when using variables in Puppet:

1. Unlike resource declarations, variable assignments are parse-order
dependent.  This means that you must assign a variable in your manifest
*before* you can use it.

2. If you try to use a variable that has not been defined, the Puppet parser
won't complain. Instead, Puppet will treat the variable as having the special
`undef` value. Though this may cause an error later in the compilation process,
in some cases it will pass through and cause unexpected results.

3. You can only assign a variable once within a single scope. Once it's
assigned, the value cannot be changed. The value of a Puppet variable may
change across Puppet runs or vary across different systems in your
infrastructure, but on a single run of the Puppet agent on a single system it
can only be set once..

### Variable interpolation

**Variable interpolation** lets you insert the value of a variable into a
string.

For instance, if your webserver is serving files from the `/var/www/html`
directory, you can assign this directory path to a variable:

```puppet
$docroot = '/var/www/html'
```

Once the variable is set, you can avoid repeating the same directory path by
inserting the `$docroot` variable into the beginning of any string.

For example, you can use it in the title of a resource declaration:

```puppet
file { "${docroot}/index.php":
  ...
}
```

Notice the different variable syntax here. The variable name is wrapped in
curly braces, and the whole thing is preceded by the `$` (`${var_name}`).

Also note that a string that includes an interpolated variable must be wrapped
in double quotation marks (`"..."`), rather than the single quotation marks
that surround an ordinary string. These double quotation marks tell Puppet to
find and parse special syntax within the string, rather than interpreting it
literally.

Now that you know how variable interpolation works, return to your `cowsay`
module and use what you learned to make some refinements.

First, navigate to your **modulepath** directory. (If you're getting tired of
typing this out, you can use the 'tab' key to autocomplete each directory name
as you begin typing, or use `CTRL-R` and begin typing to search your bash
history for the previous time you entered the full command.)

    cd /etc/puppetlabs/code/environments/production/modules

Open the `init.pp` of your 'cowsay' module.

    vim cowsay/init.pp

Edit the manifest to set a `$docroot` variable and interpolate it into the
title of your file resource.

```puppet
class cowsay {

  $docroot = '/var/www/html/'

  include cowsay::fortune
  include cowsay::webserver

  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }

  file { "${docroot}index.php":
    source => 'puppet:///modules/cowsay/index.php',
  }
}
```

Notice that we're still setting using `/var/ww/html/` as our `$docroot`
because this is the default for the `apache` module. If we want to change where
our file is kept, we'll also need a way to change the Apache configuration to
point to that new location. To do this, we can use a **class parameter**.

Let's revisit your `cowsay::webserver` class. The directory Apache serves is
specified by something called a virtual host or 'vhost' for short. Configuring
virtual hosts allows you to associate a specific URL used to access your
server with a web directory or application on your system.  

The `apache` module uses a default vhost configured to serve `/var/www/html` to
any incoming connections.

To override this default, you need to set the `default_vhost` parameter to
`false`

## Manage web content with variables

To better understand how variables work in context, we'll walk you through
creating a simple `web` module that will put them to use.

<div class = "lvm-task-number"><p>Task 1:</p></div>

First, you'll need to create the directory structure for your module.

Make sure you're in the `modules` directory for Puppet's modulepath.

    cd /etc/puppetlabs/code/environments/production/modules/

Now create an `web` directory and your `manifests` and `examples` directories:

    mkdir -p web/{manifests,examples}

<div class = "lvm-task-number"><p>Task 2:</p></div>

With this structure in place, you're ready to create your main manifest 
where you'll define the `web` class. Create the file with vim:

    vim web/manifests/init.pp

And then add the following contents (remember to use `:set paste` in vim):

```puppet
class web {

  $doc_root = '/var/www/quest'
  
  $english = 'Hello world!'
  $french  = 'Bonjour le monde!'

  file { "${doc_root}/hello.html":
    ensure  => file,
    content => "<em>${english}</em>",
  }
  
  file { "${doc_root}/bonjour.html":
    ensure  => file,
    content => "<em>${french}</em>",
  }

}
```

Note that if you wanted to make a change to the `$doc_root` directory, you'd
only have to do this in one place. While there are more advanced forms of data
separation in Puppet, the basic principle is the same: The more distinct your
code is from the underlying data, the more reusable it is, and the less
difficult it will be to refactor when you have to make changes later.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Once you've validated your manifest with the `puppet parser` tool, you still
need to create a test for your manifest with an `include` statement for the web
class you created (you covered testing in the "Modules" quest).

Create a `web/examples/init.pp` manifest and insert `include web`. Save and
exit the file.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Apply the newly created test using the `--noop` flag
(`puppet apply --noop web/examples/init.pp`):

    puppet apply --noop web/examples/init.pp

If your dry run looks good, run `puppet apply` again without the flag.

Take a look at `<VM'S IP>/hello.html` and `<VM'S IP>/bonjour.html` to see your new pages.

## Class parameters

> Freedom is not the absence of obligation or restraint, but the freedom of
> movement within healthy, chosen parameters.

> -Kristin Armstrong

Now that you have a basic `web` class done, we'll move on to **class
parameters**. Class parameters give you a way to set the variables within a
class as it's **declared** rather than hard-coding them into a class definition.

When defining a class, include a list of parameters and optional default values
between the class name and the opening curly brace:

```puppet
class classname ( $parameter = 'default' ) {
  ...
}
```

Once defined, a parameterized class can be **declared** with a syntax similar to
that of resource declarations, including key value pairs for each parameter you
want to set.

```puppet
class {'classname': 
  parameter => 'value',
}
```

Say you want to deploy your webpage to servers around the world, and want
changes in content depending on the language in each region. Instead of rewriting
the whole class or module for each region, you can use class parameters
to customize these values as the class is declared.

<div class = "lvm-task-number"><p>Task 5:</p></div>

To get started re-writing your `web` class with parameters, reopen the
`web/manifests/init.pp` manifest. To create a new regionalized page, you
need to be able to set the message and page name as class parameters.

```puppet
class web ( $page_name, $message ) {
```

Now create a third file resource declaration to use the variables set by your
parameters:

```puppet
file { "${doc_root}/${page_name}.html":
  ensure  => file,
  content => "<em>${message}</em>",
}
```

<div class = "lvm-task-number"><p>Task 6:</p></div>

As before, use the test manifest to declare the class. You'll open
`web/examples/init.pp` and replace the simple `include` statement with the
parameterized class declaration syntax to set each of the class parameters:

```puppet
class {'web': 
  page_name => 'hola',
  message   => 'Hola mundo!',
}
```

<div class = "lvm-task-number"><p>Task 7:</p></div>

Now give it a try. Go ahead and do a `--noop` run, then apply the test.

Your new page should now be available at `<VM'S IP>/hola.html`!

Before moving on, it's important to note that there's a limitation here.
Puppet classes are *singleton* which means that a class can only be applied
once on a given node. In this case, you would only be able to configure each
webserver to have a single parameter-specified language page in addition to the
two hard coded pages. If you want to repeat the same resource or set of
resources multiple times on the *same* node, you can use something called a
*defined resource type*, which we will cover in a later quest.

## Review

In this quest you've learned how to take your Puppet manifests to the next level
by using variables. You learned how to assign a value to a variable and then
reference the variable by name whenever you need its content. You also learned
how to interpolate variables and add parameters to a class.
