{% include '/version.md' %}

# Conditional Statements

## Quest objectives
 - TBD

## Getting started

In this quest, we'll discuss conditional statements. Conditional statements let
you write Puppet code to will behave differently in different contexts.

To start this quest enter the following command:

    quest begin conditional_statements

## Writing for flexibility

>The green reed which bends in the wind is stronger than the mighty oak which
>breaks in a storm.

> -Confucius

Because Puppet manages configurations on a variety of systems fulfilling a
variety of roles, great Puppet code means flexible and portable Puppet code.
While the *types* and *providers* that form the core of Puppet's *resource
abstraction layer* can translate your Puppet code into the native tools on
a wide variety of systems, there is still quite a bit of variation that you
must account for on the level of Puppet code itself.

A good rule of thumb is that the resource abstraction layer answers **how**
questions, while the Puppet code itself answers **what** questions.

For example, your Puppet code doesn't need to directly address **how** an
Apache package is installed, but depending on whether you're managing a RedHat
or Debian system, your Puppet code will need to tell Puppet to manage either
the `httpd` or `apache2` package. If you look at the `puppetlabs-apache` module
on the [Forge](forge.puppet.com), you'll [this package name and numerous other
variables](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/params.pp#L59)
set based on an `if` statement using the `osfamily` fact. (You may notice that
this module uses an un-structured `$::osfamily` format for this fact to
preserve backwards compatibility. You can read more about this form of
reference on [the docs
page](https://docs.puppet.com/puppet/latest/lang_facts_and_builtin_vars.html#classic-factname-facts))

Simplified, the conditional statement looks like this:

```puppet
if $::osfamily == 'RedHat' {
  ...
  $apache_name = 'httpd'
  ...
} elsif $::osfamily == 'Debian' {
  ...
  $apache_name = 'apache2'
  ...
}
```

Elsewhere in the module, you'll find a [package resource](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/package.pp#L32) uses this variable to set its `name` parameter.

```puppet
package { 'httpd':
  ensure => $ensure,
  name   => $::apache::apache_name,
  notify => Class['Apache::Service'],
}
```

Remember that because the `name` parameter is being explicitly set here, the
resource *title* (`httpd`) only serves as an internal identifier for the
resource—it doesn't actually determine the name of the package that will be
installed.

You may also notice that this `$::apache::apache_name` variable name is a
little more complex than the simple `$apache_name` that was set by the
conditional. You don't need to worry about the details for the moment, but
the `::apache::` part is a way of telling Puppet exactly where to find a
variable that was assigned in a different class.

## Conditions

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Now that you've seen this real-world example of how and why a conditional
statement can be used to create more flexible Puppet code, let's take a moment
to discuss how these statements work and how to write them. 

Conditional statements return different values or execute different blocks of
code depending on the value of a specified variable.

Puppet supports a few different ways of implementing conditional logic:
 
 * `if` statements,
 * `unless` statements,
 * case statements, and
 * selectors.

Because the same concept underlies these different forms of conditional logic
available in Puppet, we'll only cover the `if` statement in the tasks for this
quest. Once you have a good understanding of how to implement `if` statements,
we'll leave you with descriptions of the other forms and some notes on when you
may find them useful.

An `if` statement includes a condition followed by a block of Puppet code that
will only be executed **if** that condition evaluates as **true**. Optionally,
an `if` statement can also include any number of `elsif` clauses and an `else`
clause.

- If the `if` condition fails, Puppet moves on to the `elsif` condition (if one
  exists).
- If both the `if` and `elsif` conditions fail, Puppet will execute the code in
  the `else` clause (if one exists).
- If all the conditions fail, and there is no `else` block, Puppet will do
  nothing and move on.

## Pick a server

Let's return to our Pasture example module. The application is build on the
[Sinatra](http://www.sinatrarb.com/) framework. Out of the box, Sinatra
supports a few different options for the server the service will run: WEBrick,
Thin, or Mongrel. In production, you would likely use a more robust option such
as [Passenger](https://www.phusionpassenger.com/) or
[Unicorn](http://bogomips.org/unicorn/), but these built-in options will be
more than adequate for the sake of this lesson.

We can select which server is used with the application's configuration file,
but the options other than the default WEBrick must be installed separately.
Using the `if` statement discussed above, we'll configure the module to manage
the necessary Thin or Mongrel package resource if one of these servers is
selected.

Open the module's `init.pp` manifest.

    vim pasture/manifests/init.pp

First, create a class parameter to manage the server configuration option. The
beginning of your class should look like the following example:

```puppet
class pasture (
  $port              = '80',
  $default_character = 'sheep',
  $default_message   = '',
  $config_file       = '/etc/pasture_config.yaml',
  $sinatra_server    = 'webrick',
){
```

Next we'll add the `$sinatra_server` variable to the `$pasture_config_hash` so
that it can be passed through to the configuration file template.

```puppet
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
    'sinatra_server'    => $sinatra_server,
  }
```

Once that's complete, open the `pasture_config.yaml.epp` template.

    vim pasture/templates/pasture_config.yaml.epp

Add the `$sinatra_server` variable to the params block at the beginning of the
template. The application will pass any key value pairs under the
`:sinatra_settings:` key to the configuration of Sinatra itself.

```yaml
<%- | $pasture_port      = '80',
      $default_character = 'sheep',
      $default_message   = '',
      $sinatra_server    = 'webrick',
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
  :default_character: <%= $default_character %>
  :default_message:   <%= $default_message %>
  :sinatra_settings:
    :port:   <%= $pasture_port %>
    :server: <%= $sinatra_server %>
```

Now that your module is able to manage this setting, we'll add a conditional
statement to manage the required packages for our Thin and Mongrel webservers.

Return to your `init.pp` manifest.

    vim pasture/manifests/init.pp

You can wrap a package resource in an `if` statment to tell your class to only
manage the resource if the `$sinatra_server` variable is `thin` or `mongrel`.

Both of these servers are available as gems, so you will use the `gem`
provider for the package.

Finally, we will add a `notify` parameter pointing to our service resource.
This will ensure that the server package is managed before the service, and
that any updates to the package will trigger a restart of the service.

```puppet
class pasture (
  $port              = '80',
  $default_character = 'sheep',
  $default_message   = '',
  $config_file       = '/etc/pasture_config.yaml',
  $sinatra_server    = 'webrick',
){

  package { 'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File[$pasture_config_file],
  }

  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
    'sinatra_server'    => $webrick,
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
    ensure    => running.
  }

  if $sinatra_server == 'thin' or 'mongrel'  {
    package { $sinatra_server:
      provider => 'gem',
      notify   => Service['pasture'],
    }
  }

}
```

With these changes to your class, we easily accomidate different servers for
different agent nodes in your infrastructure. For example, we may want to use
the default WEBrick server on a development node and the Thin server on your
production node. There are more robust ways to manage this kind of environment
configuration, but for now, we will classify each node in a distinct node
definition in the `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

```puppet
node 'pasture-dev.puppet.vm' {
  include pasture
}
node 'pasture-prod.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
  }
}
```

Now connect to each node and trigger a Puppet agent run.

    ssh learning@pasture-dev.puppet.vm

    sudo puppet agent -t

And

    ssh learning@pasture-prod.puppet.vm

    sudo puppet agent -t

TODO: Add specific instructions to confirm that the correct server is running
on each.

## Review

TBD
