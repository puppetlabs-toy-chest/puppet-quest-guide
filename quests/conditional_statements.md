{% include '/version.md' %}

# Conditional Statements

## Quest objectives
 - Learn about the role of conditional statements in writing flexible Puppet code
 - Learn the syntax of the `if` statement.
 - Use an `if` statement to intelligently manage a package dependency.

## Getting started

In this quest, we'll discuss **conditional statements.** Conditional statements let
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
on the [Forge](forge.puppet.com), you'll see [this package name and numerous
other
variables](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/params.pp#L59)
set based on an `if` statement using the `osfamily` fact. (You may notice that
this module uses an un-structured `$::osfamily` format for this fact to
preserve backwards compatibility. You can read more about this form of
reference on [the docs
page](https://docs.puppet.com/puppet/latest/lang_facts_and_builtin_vars.html#classic-factname-facts))

Simplified to show only the values we're concerned with, the conditional
statement looks like this:

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

Here, the `$apache_name` variable is set to either `httpd` or `apache2`
depending on the value of the `$::osfamily` fact. Elsewhere in the module,
you'll find a [package
resource](https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/package.pp#L32)
that uses this `$apache_name` variable to set its `name` parameter.

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
Thin, or Mongrel. In production, you would likely use Sinatra wiht a more
robust option such as [Passenger](https://www.phusionpassenger.com/) or
[Unicorn](http://bogomips.org/unicorn/), but these built-in options will be
adequate for this lesson.

We can easily select which server will be used in the Pasture application's
configuration file, However, options other than the default WEBrick are not
included as pre-requisites when we install the Pasture package. To use these
other options, we'll need our module to manage them as separate `package`
resources.  However, we don't want to install these extra packages if we don't
plan on using them. Using the `if` statement discussed above, we'll configure
the `pasture` class to manage the necessary Thin or Mongrel package resource
only if one of these servers is selected.

By using a class parameter to specify the preferred server for Sinatra to use,
we can use the same value to pass on to our configuration file template and to
decide which additional packages need to be installed. Using parameters in this
way helps keep configuration coordinated across all the components of the
system your module is written to manage.

<div class = "lvm-task-number"><p>Task 1:</p></div>

Open the module's `init.pp` manifest.

    vim pasture/manifests/init.pp

First, add a `$sinatra_server` parameter with a default value of `webrick`. The
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

Next add the `$sinatra_server` variable to the `$pasture_config_hash` so that
it can be passed through to the configuration file template.

```puppet
  $pasture_config_hash = {
    'port'              => $port,
    'default_character' => $default_character,
    'default_message'   => $default_message,
    'sinatra_server'    => $sinatra_server,
  }
```

<div class = "lvm-task-number"><p>Task 2:</p></div>

Once that's complete, open the `pasture_config.yaml.epp` template.

    vim pasture/templates/pasture_config.yaml.epp

Add the `$sinatra_server` variable to the params block at the beginning of the
template with the same `webrick` default. The Pasture appication passes any
settings under the `:sinatra_settings:` key to Sinatra itself.

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

Now that your module is able to manage this setting, add a conditional
statement to manage the required packages for the Thin and Mongrel webservers.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Return to your `init.pp` manifest.

    vim pasture/manifests/init.pp

You can wrap a package resource in an `if` statment to tell your class to only
manage the resource if the `$sinatra_server` variable is `thin` or `mongrel`.

Both of these servers are available as gems, so you will use the `gem`
provider for the package.

Finally, we will add a `notify` parameter pointing to our service resource.
This will ensure that the server package is managed before the service, and
that any updates to the package will trigger a restart of the service. Your
class should look like the example below, with the conditional statement to
manage your server packages included at the end.

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

With these changes to your class, you can easily accomidate different servers
for different agent nodes in your infrastructure. For example, you may want to
use the default WEBrick server on a development system and the Thin server on
for production.

We created two new systems for this quest: `pasture-dev.puppet.vm` and
`pasture-prod.puppet,vm`. For a more complex infrastructure, you would likely
manage your development, test, and production segments of your infrastructure
by creating a distinct [envionrment](https://docs.puppet.com/puppet/latest/environments.html)
for each. For now, however, we can easily demonstrate our conditional statement
by setting up two different node definition in the `site.pp` manifest.

<div class = "lvm-task-number"><p>Task 4:</p></div>

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

## The puppet job tool

Now that you're working across multiple nodes, connecting manually with SSH to
trigger Puppet runs may start to seem a little tedious. The `puppet job` tool
lets you trigger Puppet runs across multiple nodes remotely. 

Before using this tool, we'll have take a few steps via the PE console to set
up authentication through PE's role-based access control system (RBAC).

To log in to the console, bring up a web browser on the host system you're
using to run the Learning VM and navigate to `https://<VM's IPADDRESS>`. (Note
that using `https` will take you to the console, while `http` will take you to
this quest guide.)

You may see a warning from your browser that the PE console is using a
self-signed certificate. You can safely ignore this warning and proceed to the
PE console login page. (You may have to click on an **advanced** option for the
option to proceed.)

Use the following credentials to log in:

Username: **admin**  
Password: **puppetlabs**

Once you're connected, click the **access control** menu option in the
navigation bar at near the bottom left of the screen, then select **Users**
in the *Access Control* navigation menu.

Create a new user with the **Full name** `Learning` and **Login** `learning`.

Click on the name of the new user, then click the **Generate password reset**
link. Copy the given link to a new browser tab and set the password to:
**puppet**.

Under the **Access Control** navigation bar, click the **User Roles** menu
option. Click on the link for the **Operators** role. Select the **Learning**
user from the dropdown menu, click the **Add user** button, and finally click
the **Commit 1 change** botton near the bottom right of the console screen.

With this user configured, you can use the `puppet access` command to generate
a token that will allow you to use the `puppet job` tool. We'll set the
lifetime for this token to one day so you won't have to worry about
re-authenticating as you work.

    puppet access login --lifetime 1d

When prompted, supply the username **learning** and password **puppet**.

Now you can trigger Puppet agent runs on `pasture-dev.puppet.vm` and
`pasture-prod.puppet.vm` with the `puppet job` tool. We provide the names of
the two nodes in a comma-separated list after the `--nodes` flag. (Note that
there is no space between the node names, which can make it a little hard to
tell the difference between a comma that separates node names and the dots in
the node names themselves.)

    puppet job run --nodes pasture-dev.puppet.vm,pasture-prod.puppet.vm

TODO: Add instructions to validate the changes that have taken place.

## Review

TBD
