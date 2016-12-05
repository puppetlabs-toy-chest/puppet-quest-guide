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

  file { "${docroot}/index.php":
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
all incoming connections on port 80. To specify our own directory, we'll need
to override this default and use the `apache` module to define a custom
`vhost`. We'll be walking you through this process step-by-step, but this is a
good time to take a look at the [module documentation](https://forge.puppet.com/puppetlabs/apache#apache) on the Forge. See if you can figure out what steps you'll
need to take and check yourself against the instructions below.

If you took a minute to look through the documentation, you may have noticed
the following code block:

```puppet
class { 'apache':
  default_vhost => false,
}

This is an example of a **parameterized** class declaration. It looks a lot
like the resource declarations you've already worked with. In fact, this is
often referred to as a **resource-like** method of class declaration, as
opposed to the **include** syntax you've been using up to this point. The
parameters you set are passed through to the class as variables, where they
are used (often in conjunction with conditional logic, which we'll cover
in a later quest) to customize the class.

A key difference between this *parameterized* or *resource-like* class
declaration and the *include* is that a class can be *included* multiple times
on the same system, but only declared once in the *resource-like* form. This
is because an include statement tells Puppet to use all the class defaults, so
multiple declarations can't conflict. When Puppet sees an include for the
second time, it can say "got that already, let's move on." There's no guarantee
that two parameterized declarations will lead to the same outcome, however, so
when Puppet sees a second parameterized declaration for the same class, it will
give you an error that the class has already been declared.

Open your `webserver.pp` manifest:

    vim cowsay/manifests/webserver.pp

Remove your `include apache` line and add a parameterized class declaration,
setting the value of the `default_vhost` parameter to `false`.

At this point, your manifest should look like this:

```puppet
class cowsay::webserver {

  include apache::mod::php

  class { 'apache':
    default_vhost => false,
  }
}
```

Now that you've disabled the default vhost, you need to define your own. You
also need a way to pass in your custom `$docroot` variable.

Our first step will be to add a `$docroot` parameter to the `cowsay::webserver`
class. We'll provide a default value of `/var/www/html/` for this parameter so
our class will use that value if the parameter isn't set. A class's list of
parameters and defaults is set in a pair of parentheses between the class name
and opening curly bracket (`{`) of the class definition. The pairs take a
`$parametername = default_value` format, and are separated by commas. (Note
that it's best practice to include a trailing comma at the end of this list of
parameters, even if it only includes a single item. This consistency means you
don't have to remember to add a comma to the previous item if you extend the
list later.)

Your class definition with the `$docroot` parameter should look like the
following:

```puppet
class cowsay::webserver(
  $docroot = '/var/www/html/',
){

  include apache::mod::php

  class { 'apache':
    default_vhost => false,
  }
}
```

You can access its value of this parameter with the `$docroot` variable within
your class. In this case, you'll use it to declare your vhost.  The `apache`
module makes customizing a vhost easy by providing an `apache::vhost` resource
type.

Declare an `apache::vhost` with the title `'webserver.puppet.vm'`, the
`port` parameter set to `80` and the `docroot` set to the `$docroot` variable.

```puppet
class cowsay::webserver(
  $docroot = '/var/www/html/',
){

  include apache::mod::php

  class { 'apache':

    default_vhost => false,
  }

  apache::vhost { 'webserver.puppet.vm':
    port    => '80',
    docroot => $docroot,
  }
}
```

When you're done, save your manifest and exit Vim. (Remember, `ESC` to exit
insert mode and `:wq` to save and exit.)

Now your `cowsay::webserver` class is good to go, but remember, it's called
from your module's main `cowsay` class. This means that we have a final layer
of parameterization left. Just like you're passing your `$docroot` value
through your `cowsay::webserver` class to the `apache::vhost` resource, you'll
need to pass it through from the the `cowsay` class to `cowsay::webserver`.
This will let you set the value as you like when you classify your node.

Open your `init.pp` manifest.

    vim cowsay/manifests/init.pp

Add the same `$docroot` parameter to this class, and replace your `include
cowsay::webserver` line with a parameterized class declaration that sets the
`docroot` parameter to the `$docroot` variable.

```puppet
class cowsay(
  $docroot = '/var/www/html/',
){
  include cowsay::fortune

  class { 'cowsay::webserver':
    docroot => $docroot,
  }

  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }

  file { '${docroot}/index.php':
    source => 'puppet:///modules/cowsay/index.php',
  }
}
```

Take a moment to validate your classes with the `puppet parser validate` tool
and make any corrections necessary.

    puppet parser validate cowasy/manifests/*.pp

Now open your `site.pp` manfest.

    vim /etc/puppetlabs/code/environments/production/manifests/init.pp

And replace the `include cowsay` line with a parameterized declaration. Let's
set the `docroot` parameter to `/var/www/cowsay/`.

```puppet
node 'webserver.puppet.vm' {
  class { 'cowsay':
    docroot => 'var/www/cowsay/',
  }
}
```

Now connect to your webserver node:

    ssh learning@webserver.puppet.vm

And trigger a puppet run:

    sudo puppet agent -t

## Review

