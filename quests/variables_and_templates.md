{% include '/version.md' %}

# Variables and Templates

## Quest objectives

- TBD

## Getting started

In the last quest, we set up a module to mange the Pasture application. So far,
however, that module is very static. All the values used to define your
resources are hard-coded into the resource declarations, and the configuration
file and service unit file are both managed by static source files in the
module's `files` directory.

In this quest, we'll introduce parameters and templates, both of which use
variables to make your code much more adaptable.

When you're ready to get started, enter the following command:

    quest begin variables_and_templates

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton

Variables allow a value to be stored and accessed by name later in your
manifest. This is one of the core Puppet language features that allows you
to write flexibility into your code.

A variable name is prefixed with a `$` (dollar sign), and a value is assigned
with the `=` operator. Assigning a short string to a variable, for example,
looks like this:

```puppet
$my_variable = 'look, a string!'
```

Once you have defined a variable you can use it anywhere in your manifest where
you want to use the assigned value. Note that variables are parse-order
dependent, which means that a variable must be defined before it can be used.
Trying to use an undefined variable will result in a special `undef` value.
Though this may result in explicit errors, in some cases it will still lead
to a valid catalog with unexpected contents.

Technically, Puppet variables are actually *constants* from the perspective of
the Puppet parser as it parses your Puppet code to create a catalog. Once a
variable is assigned, the value is fixed and cannot be changed. The
*variability*, here, refers to the fact that a variable can have a different
value set across different Puppet runs or across different systems in your
infrastructure.

Let's start by setting up a few variables. We'll define the default
character the cowsay application will use, the port we want to service to
run on, and path of the configuration file.

Open your `init.pp` manifest:

    vim pasture/manifests/init.pp

Assign these variables at the top of your class. Replace the hard-coded
references to the `/etc/pasture_config.yaml` configuration filepath with the
variable.

```puppet
class pasture {

  $pasture_port        = '80'
  $default_character   = 'sheep'
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  file { $pasture_config_file:
    source  => 'puppet:///modules/pasture/pasture_config.yaml',
    notify  => Service['pasture'],
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }

  servive { 'pasture':
    ensure    => running.
  }

}
```

We haven't yet done anything with the `$pasture_port` or `$default_character`
variables. To use these, we need a way to pass them into our configuration
file. We'll also need to pass the `$pasture_config_file` variable to our
service unit file so the service will start our Pasture process with the
configuration file we specify.

## Templates

Many of the tasks involved in system configuration and administration come down
to managing the content of text files. Some of these tasks are commonly managed
by tools that offer a level of abstraction above this level of the text file.
To manage users on a *nix system, for example, you use a command like `useradd`
rather than directly edit the contents of `/etc/passwd` and `/etc/shadow`. In
these cases, Puppet's providers will use these higher-level commands to
interact with the underlying system state.

In many cases, however, editing a text file directly remains the best (or only)
way to configure some component of your system. This means that Puppet needs a
flexible way manage these files.

The most direct way to handle this is through a templating language. A template
is similar to a text file, but offers a syntax for inserting variables as well
as some more advanced language features like conditionals and iteration. This
flexibility lets you manage a wide variety of file formats with a single tool.

The main limitation of templates is that they're all-or-nothing. The template
must define the entire file you want to manage. If you need to manage only a
single line or value in a file, you may want to investigate
[Augeas](https://docs.puppet.com/guides/augeas.html),
[concat](https://forge.puppet.com/puppetlabs/concat), or the
[file_line](https://forge.puppet.com/puppetlabs/stdlib#file_line) resource
type.

## Embedded Puppet templating language

Puppet supports two templating languages, [Embedded Puppet
(EPP)](https://docs.puppet.com/puppet/latest/lang_template_epp.html) and
[Embedded Ruby
(ERB)](https://docs.puppet.com/puppet/latest/lang_template_erb.html).

EPP templates were released in Puppet 4 to provide a Puppet-native templating
language that would offer several improvements over the ERB templates that had
been inherited from the Ruby world. Because EPP is now the preferred method,
it's what we'll be using in this quest. Once you understand the basics of
templating, however, you can easily the ERB format by referring to the
documentation.

An EPP template is a plain-text document interspersed with tags that allow
you to customize the content.

It will be easier to explain the syntax with a concrete exampl, so let's create
a template to help manage Pasture's configuration file.

First, you'll need to create a `templates` directory in your `pasture` module.

    mkdir pasture/templates

Next, create a `pasture_config.yaml.epp` template file.

    vim pasture/templates/pasture_config.yaml.epp

The first element of an EPP template should always be a **parameter tag**. This
declares which parameters your template will accept and allows you to set their
default values. Though this tag isn't technically required for an EPP template
to work, explicitly declaring your variables here will make your template more
readable and easier to maintain. It's also generally good practice to add a
comment to the beginning of the file to let people who might come across it
know that it's managed by Puppet so they don't attempt to make manual changes,
only to have them reverted the next time Puppet runs. This comment is intended
to be included directly in the final file, so remember to use the comment
syntax native to the file format you're working with.

```
<%- | $pasture_port      = '80',
      $default_character = 'sheep',
| -%>
# This file is managed by Puppet. Please do not make manual changes.
```

The bars (`|`) surrounding the list of parameters are a special syntax that
defined the parameters tag. The `<%` and `%>` are the opening and closing tag
delimiters that distinguish EPP tags from the body of the file. Those hyphens
(`-`) next to the tag delimiters will remove indendentation and whitespace
before and after the tag. This allows you to put this parameter tag at the
beginning of the file, for example, without the newline character after the
tag creating an empty line at the beginning of the output file.

Next, we'll use these variables to set values for the port and character
configuration options:

```
<%- | $pasture_port      = '80',
      $default_character = 'sheep',
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
  character: <%= $default_character %>
  port:      <%= $pasture_port %>
```

The `<%= ... %>` tags we use to insert our variables into the file are called
**expression-printing tags**. These tags insert the content of a Puppet
expression, in this case the string values assigned to our variables.

Now that this template is set up, let's return to our `init.pp` manifest
and see how to use it to define the content of a `file` resource.

First, save your template file and exit Vim.

Now open your `init.pp` manifest.

    vim pasture/manifests/init.pp 

The `file` resource type has two different parameters that can be used to
define the content of the managed file: `source` and `content`.

As we discussed earlier, `source` takes the URI of a source file like the ones
we've placed in our module's `files` directory. The `content` parameter can
takes a string as a value and sets the content of the managed file to that
string.

To set a file's content with a template, we'll use Puppet's built-in `epp()`
function to parse our EPP template file and use the resulting string as the
value for the `content` parameter.

This `epp()` function takes two arguments: first, a file reference in the
format `'<MODULE>/<TEMPLATE_NAME>'` that specifies the template file you want
to use.  Second a hash of variable names and values you want to pass to the
template.

To avoid cramming all our variables into the `epp()` function, we'll put them
in a variable called `$pasture_config_hash` just before the file resource.

```puppet
class pasture {

  $pasture_port        = '80'
  $default_character   = 'sheep'
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  $pasture_config_hash = { 
    'pasture_port'      => $pasture_port,
    'default_character' => $default_character,
  }

  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }

  servive { 'pasture':
    ensure    => running.
  }

}
```

Now that that's set, we can repeat the process for the service unit file.

Save and exit your `init.pp` file.

Rather than start from scratch, let's copy the existing file to use as a base
for our template:

    cp pasture/files/pasture.service pasture/templates/pasture.service.epp

Now open the file with Vim to templatize it:

    vim pasture/templates/pasture.service.epp

Add your parameters tag and comment to the beginning of the file. Set the
`--config_file` argumnet of the start command to to value of
`$pasture_config_fle`

```
<%- | $pasture_config_file = '/etc/pasture_config.yaml' | -%>
# This file is managed by Puppet. Please do not make manual changes.
[Unit]
    Description=Run the pasture service

    [Service]
    ExecStart=/usr/local/bin/pasture start --config_file <%= $pasture_config_file %>

    [Install]
    WantedBy=multi-user.target
```

Now return to your `init.pp` manifest:

    vim /pasture/manifests/init.pp

And modify the file resouce for your service unit file to use the template you
just created.

```puppet
class pasture {

  $pasture_port        = '80'
  $default_character   = 'sheep'
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  $pasture_config_hash = {
    'pasture_port'      => $pasture_port,
    'default_character' => $default_character,
  }

  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }

  $pasture_service_hash = {
    'pasture_config_file' => $pasture_config_file,
  }

  file { '/etc/systemd/system/pasture.service':
    content => epp('pasture/pasture.service.epp', $pasture_service_hash),
    notify  => Service['pasture'],
  }

  servive { 'pasture':
    ensure    => running.
  }

}
```

When you're finished, use the `puppet parser` tool to check your syntax.

    puppet parser validate pasture/manifests/init.pp

## Review

