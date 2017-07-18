{% include '/version.md' %}

# Variables and templates

## Quest objectives

- Learn about variables assignment and use.
- Learn how to create an EPP template.
- Use the hash syntax to pass variables to an EPP template.

## Getting started

In this quest, we introduce variables and templates. Once you assign a
value to a variable in a Puppet manifest, you can use that variable throughout
the manifest to yield the assigned value. Through templates, you can
incorporate these variables into the content of any files your Puppet
manifest manages.

While it's convenient to introduce variables and templates here as a pair,
as you work through the rest of this quest guide, you'll see that variables
are used along with many of Puppet's other features to help write adaptable
Puppet code.

When you're ready to get started, enter the following command:

    quest begin variables_and_templates

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton

Variables allow a value to be bound to a name, which can then be used later
in your manifest.

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

<div class = "lvm-task-number"><p>Task 1:</p></div>

Let's start by setting up a few variables. We'll define the default
character the cowsay application will use, the port we want to service to
run on, and path of the configuration file.

Open your `init.pp` manifest.

    vim pasture/manifests/init.pp

Assign these variables at the top of your class. Replace the hard-coded
references to the `/etc/pasture_config.yaml` configuration filepath with the
variable.

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
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
  service { 'pasture':
    ensure    => running,
  }
}
```

We haven't yet done anything with the `$pasture_port` or `$default_character`
variables. To use these, we need a way to pass them into our configuration
file. We'll also need to pass the `$pasture_config_file` variable to our
service unit file so the service will start our Pasture process with the
configuration file we specify if we change it to something other than the default.

## Templates

Many of the tasks involved in system configuration and administration come down
to managing the content of text files. The most direct way to handle this is
through a templating language. A template is similar to a text file but offers
a syntax for inserting variables as well as some more advanced language
features like conditionals and iteration. This flexibility lets you manage a
wide variety of file formats with a single tool.

The limitation of templates is that they're all-or-nothing. The template must
define the entire file you want to manage. If you need to manage only a single
line or value in a file because another process or Puppet module will manage a
different part of the file, you may want to investigate
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
templating, however, you can easily use the ERB format by referring to the
documentation.

An EPP template is a plain-text document interspersed with tags that allow
you to customize the content.

<div class = "lvm-task-number"><p>Task 2:</p></div>

It will be easier to explain the syntax with a concrete example, so let's create
a template to help manage Pasture's configuration file.

First, you'll need to create a `templates` directory in your `pasture` module.

    mkdir pasture/templates

Next, create a `pasture_config.yaml.epp` template file.

    vim pasture/templates/pasture_config.yaml.epp

Best practice is to begin your EPP template with a *parameter tag*. This
declares which parameters your template will accept and allows you to set their
default values. A template will work without this tag, but explicitly declaring
your variables here makes your template more readable and easier to
maintain.

It's also good practice to add a comment to the beginning of the file so
people who might come across it know that it's managed by Puppet and any manual
changes they make will be reverted the next time Puppet runs. This comment is
intended to be included directly in the final file, so remember to use the
comment syntax native to the file format you're working with.

The beginning of your template should look like the following. We'll explain
the details of the syntax below.

```
<%- | $port,
      $default_character,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
```

The bars (`|`) surrounding the list of parameters are a special syntax that
define the parameters tag. The `<%` and `%>` are the opening and closing tag
delimiters that distinguish EPP tags from the body of the file. Those hyphens
(`-`) next to the tag delimiters will remove indendentation and whitespace
before and after the tag. This allows you to put this parameter tag at the
beginning of the file, for example, without the newline character after the
tag creating an empty line at the beginning of the output file.

Next, we'll use the variables we set up to define values for the port and
character configuration options.

```
<%- | $port,
      $default_character,
      $default_message,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
:default_character: <%= $default_character %>
:default_message:   <%= $default_message %>
:sinatra_settings:
  :port: <%= $port %>
```

The `<%= ... %>` tags we use to insert our variables into the file are called
*expression-printing tags*. These tags insert the content of a Puppet
expression, in this case the string values assigned to our variables.

Now that this template is set up, let's return to our `init.pp` manifest
and see how to use it to define the content of a `file` resource.

First, save your template file and exit Vim.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Now open your `init.pp` manifest.

    vim pasture/manifests/init.pp

The `file` resource type has two different parameters that can be used to
define the content of the managed file: `source` and `content`.

As we discussed earlier, `source` takes the URI of a source file like the ones
we've placed in our module's `files` directory. The `content` parameter
takes a string as a value and sets the content of the managed file to that
string.

To set a file's content with a template, we'll use Puppet's built-in `epp()`
function to parse our EPP template file and use the resulting string as the
value for the `content` parameter.

This `epp()` function takes two arguments: First, a file reference in the
format `'<MODULE>/<TEMPLATE_NAME>'` that specifies the template file
to use. Second, a hash of variable names and values to pass to the
template.

To avoid cramming all our variables into the `epp()` function, we'll put them
in a variable called `$pasture_config_hash` just before the file resource.

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
  }
  file { $pasture_config_file:
    content => epp('pasture/pasture_config.yaml.epp', $pasture_config_hash),
    notify  => Service['pasture'],
  }
  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }
  service { 'pasture':
    ensure    => running,
  }
}
```

Now that that's set, we can repeat the process for the service unit file.

Save and exit your `init.pp` file.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Rather than start from scratch, let's copy the existing file to use as a base
for our template.

    cp pasture/files/pasture.service pasture/templates/pasture.service.epp

Now open the file with Vim to templatize it.

    vim pasture/templates/pasture.service.epp

Add your parameters tag and comment to the beginning of the file. Set the
`--config_file` argument of the start command to the value of
`$pasture_config_fle`

```
<%- | $pasture_config_file = '/etc/pasture_config.yaml' | -%>
# This file is managed by Puppet. Please do not make manual changes.
[Unit]
Description=Run the pasture service

[Service]
Environment=RACK_ENV=production
ExecStart=/usr/local/bin/pasture start --config_file <%= $pasture_config_file %>

[Install]
WantedBy=multi-user.target
```

<div class = "lvm-task-number"><p>Task 5:</p></div>

Now return to your `init.pp` manifest.

    vim pasture/manifests/init.pp

And modify the file resouce for your service unit file to use the template you
just created.

```puppet
class pasture {

  $port                = '80'
  $default_character   = 'sheep'
  $default_message     = ''
  $pasture_config_file = '/etc/pasture_config.yaml'

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
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
  service { 'pasture':
    ensure    => running,
  }
}
```

When you're finished, use the `puppet parser` tool to check your syntax.

    puppet parser validate pasture/manifests/init.pp

<div class = "lvm-task-number"><p>Task 6:</p></div>

Connect to `pasture.puppet.vm` to trigger a Puppet run and test your changes.
The quest tool created a new node with that name for this quest, added that
system to the Learning VM's `/etc/hosts`, and handled the cert signing
process for you. Though this is a new system, it has the same name as the one
you were working on in the previous quest, so the classification in your `site.pp`
manifest will still apply.

    ssh learning@pasture.puppet.vm

Trigger a Puppet agent run.

    sudo puppet agent -t

If the run throws any errors, go back and review your code. Remember that the
`puppet parser` tool can check for syntax errors, but it does not guarantee
that your Puppet code can be correctly compiled into a catalog and define the
state you intend.

Once the Puppet run has successfully completed, disconnect to return to your
session on the Learning VM itself.

    exit

Use the `curl` command again to see that your changes to the defaults have
taken effect.

    curl 'pasture.puppet.vm/api/v1/cowsay?message=Hello!'

## Review

In this quest, we introduced *variables* and *templates*. You reworked the
`pasture` module to replace hard-coded values in your resources and
configuration files with variables.

With variables set in your manifest, you saw how to use the hash syntax and
EPP template function to pass those variables into a template. Within an `.epp`
template, we covered the *parameter tag*, which is used at the beginning of
a template to specify which variables are available within the template, and
*expression-printing tags*, which are used to insert variable values into the
content of your templatized file.

We mentioned that variables are an important part of the concepts we'll
introduce in the following quests. In the next quest, you'll see how to create
a *parameterized class*, which will allow you to set important variables
in your class as you declare it. Parameters allow you to customize how a class
is configured without editing code in the module where the class is defined.

## Additional Resources

* Our docs page has more information on [variables](https://docs.puppet.com/puppet/latest/lang_variables.html) and [templates](https://docs.puppet.com/puppet/latest/lang_template.html).
* These topics are also covered in more depth in our [in-person](https://learn.puppet.com/category/instructor-led-training) and [online](https://learn.puppet.com/category/online-instructor-led-training) trainings.
