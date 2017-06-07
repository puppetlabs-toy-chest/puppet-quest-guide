{% include '/version.md' %}

# The Forge

## Quest objectives

- Learn how to access the Puppet Forge and find a module.
- Use class parameters to adapt a Forge module to your needs.
- Create a wrapper class to integrate a Forge module into your own module.

## Getting started

In this quest, we'll introduce you to the Forge, a repository for modules
written and maintained by the Puppet community.

When you're ready to get started, enter the following command:

    quest begin the_forge

## What is the Forge?

The [Puppet Forge](forge.puppet.com) is a public repository for Puppet modules.
The Forge gives you access to community maintained modules. Using existing
modules from the Forge allows you to manage a wide variety of applications and systems
without spending extensive time on custom module development. Furthermore,
because many Forge modules are actively used and maintained by the Puppet
community, you'll be working with code that's already well reviewed and tested.
The more other users are involved with a module, the less maintenance and
testing burden you and your team will have to take on.

For those who put a high premium on vetted code and active maintenance, the
Forge maintains lists of modules that have been checked against standards set
by Puppet's Forge team. Modules in the [Puppet
Approved](https://forge.puppet.com/approved) category are audited to ensure
quality, reliability, and active development. Modules in the [Puppet
Supported](https://forge.puppet.com/supported) list are covered by Puppet
Enterprise [support](https://puppet.com/support-services/customer-support)
contracts and are maintained across multiple platforms and versions
over the course of the [Puppet Enterprise release
lifecycle](https://puppet.com/misc/puppet-enterprise-lifecycle).

So far, you've been using the Pasture application's API to return an ASCII cow
character with a message in her speech bubble. The application has another
feature we haven't mentioned yet: the ability to store custom messages in a
database and retrieve them by ID. By default, Pasture uses a simple SQLite
database to store these messages, but it can be configured to connect to an
external database.

In this quest, you'll use a PostgreSQL module from the Forge to configure a
database the Pasture application can use to store and retrieve cow messages.

Your first step will be to find an appropriate module to use. Use the search
interface on the [Forge](forge.puppet.com) website to do a search for
`PostgreSQL`.

(If you don't currently have internet access, we suggest you still read through
the section below to familiarize yourself with the Forge. All the resources
necessary to complete the quest are already cached on the VM, so no external
connection is necessary to complete the actual installation of the module.)

The Forge will show several hits that match your query, including version and
release data information, downloads, a composite rating score, and a supported
or approved banner where relevant. This information can give you a quick idea
of which modules in your search results you may want to investigate further.

For this quest, we'll use the `puppetlabs/postgresql` module. Click on that
module title to see more information and documentation.

To set up a database for the Pasture application, you will need to set up a
database server and create and configure a database instance with the correct
user and permissions. We'll walk you through the specifics below, but take a
moment to look through the module's documentation to see if you can discover
how this module can be used to define the desired state for your database
server. Can you figure out which class or classes you will use and how their
parameters should be set?

## Installation

Recall that a module is just a directory structure containing Puppet manifests
and any other code or data needed to manage whatever it is the module helps
you manage on a system. The Puppet master finds any modules in its *modulepath*
directories and uses the module directory structure to find the classes, files,
templates, and whatever else the module provides.

Installing a module means placing the module directory into the Puppet master's
modulepath. While you could download the module and manually move it to the
modulepath, Puppet provides tools to help manage your modules.

You may have noticed two different methods of installation near the top of the
`postgresql` module: the Puppetfile and the `puppet module` tool. For this
quest, we'll use the simpler `puppet module` tool. (As you start managing a
more complex Puppet environment and checking your Puppet code into a control
repository, however, using a Puppetfile is recommended. You can read more about
the Puppetfile and code management workflow
[here](https://docs.puppet.com/pe/latest/cmgmt_managing_code.html).)

<div class = "lvm-task-number"><p>Task 1:</p></div>

On your master, go ahead and use the `puppet module` tool to install this
module.

    puppet module install puppetlabs-postgresql --version 4.8.0

To confirm that this command placed the module in your modulepath, take a look
at the contents of your modules directory.

    ls /etc/puppetlabs/code/environments/production/modules

Notice that when you saw the module on the Forge, it was listed as
`puppetlabs/postgresql`, and when you installed it, you called it
`puppetlabs-postgresql`, but the actual directory where it installed is
`postgresql`. The `puppetlabs` corresponds to the name of the Forge user
account that uploaded the module to the Forge. This distinguishes different
users' versions of a module when you're browsing the Forge and during
installation. When a module is installed, this account name is not
included in the module directory name. If you aren't aware of this, it could
cause some confusion; identically named modules will conflict if you try to
install them on the same master.

To see a full list of modules installed in all modulepaths on your master, use
the `puppet module` tool's `list` subcommand.

    puppet module list

## Writing a wrapper class

Using the existing `postgresql` module, you can add a database component to the
Pasture module without having to reinvent the Puppet code needed to manage
a PostgreSQL server and database instance. Instead, we'll create what's called
a *wrapper class* to declare classes from the `postgresql` module with
the parameters needed by the Pasture application.

<div class = "lvm-task-number"><p>Task 2:</p></div>

We'll call this wrapper class `pasture::db` and define it in a `db.pp` manifest
in the `pasture` module's `manifests` directory.

    vim pasture/manifests/db.pp

Within this `pasture::db` class, we'll use the classes provided by the
`postgresql` module to set up the `pasture` database that
will keep track of our cow sayings.

```puppet
class pasture::db {

  class { 'postgresql::server':
    listen_addresses => '*',
  }

  postgresql::server::db { 'pasture':
    user     => 'pasture',
    password => postgresql_password('pasture', 'm00m00'),
  }

  postgresql::server::pg_hba_rule { 'allow pasture app access':
    type        => 'host',
    database    => 'pasture',
    user        => 'pasture',
    address     => '172.18.0.2/24',
    auth_method => 'password',
  }

}
```

With this wrapper class done, you can easily add the database server it defines
to a node definition in your `site.pp` manifest. In this case, we've kept
things simple and created a class without parameters. As needed, you might add
parameters to this wrapper class in order to pass values through to the
postgresql classes it contains.

<div class = "lvm-task-number"><p>Task 3:</p></div>

Go ahead and open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Create a node definition to classify the `pasture-db.puppet.vm` node with
the `pasture::db` class.

```puppet
node 'pasture-db.puppet.vm' {
  include pasture::db
}
```

Use the `puppet job` tool to trigger a Puppet agent run on this
`pasture-db.puppet.vm` node.

    puppet job run --nodes pasture-db.puppet.vm

Now that this database server is set up, let's add a parameter to our main
pasture class to specify a database URI and pass this through to the
configuration file.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Open your module's `init.pp` manifest.

    vim pasture/manifests/init.pp

Add a `$db` parameter with a default value of `undef`. We can use this
`undef` with a conditional in the template to say "only manage this parameter
if there's something set here". Next, add this variable to your
`$pasture_config_hash` so it will be passed through to your template. When
you've made these two additions, your class will look like the example below.

```puppet
class pasture (
  $port                = '80',
  $default_character   = 'sheep',
  $default_message     = '',
  $pasture_config_file = '/etc/pasture_config.yaml',
  $sinatra_server      = 'webrick',
  $db                  = undef,
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
    'sinatra_server'    => $sinatra_server,
    'db'                => $db,
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

  if $sinatra_server == 'thin' or 'mongrel'  {
    package { $sinatra_server:
      provider => 'gem',
      notify   => Service['pasture'],
    }
  }

}
```

<div class = "lvm-task-number"><p>Task 5:</p></div>

Next, edit the `pasture_config.yaml.epp` template. We'll use a conditional
statement to only include the `:db:` setting if there is a value set for
the `$db` variable. This will allow us to leave this option unset and use
the Pasture application's own default if we haven't explicitly set the
`pasture` class's `db` parameter.

```puppet
<%- | $port,
      $default_character,
      $default_message,
      $sinatra_server,
      $db,
| -%>
# This file is managed by Puppet. Please do not make manual changes.
---
:default_character: <%= $default_character %>
:default_message: <%= $default_message %>
<%- if $db { -%>
:db: <%= $db %>
<%- } -%>
:sinatra_settings:
  :port:   <%= $port %>
  :server: <%= $sinatra_server %>
```

Now that you've set up this `db` parameter, edit your
`pasture-app.puppet.vm` node definition.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Declare the `pasture` class and set the `db` parameter to the URI of the
`pasture` database you're running on `pasture-db.puppet.vm`.

```puppet
node 'pasture-app.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
    db             => 'postgres://pasture:m00m00@pasture-db.puppet.vm/pasture',
  }
}
```

<div class = "lvm-task-number"><p>Task 6:</p></div>

Use the `puppet job` tool to trigger an agent run on this node.

    puppet job run --nodes pasture-app.puppet.vm

With your database server set up and your application server connected to it,
you can now add sayings to the application's database and retrieve them by
ID. Let's give it a try.

First, post the message 'Hello!' to your database.

    curl -X POST 'pasture-app.puppet.vm/api/v1/cowsay/sayings?message=Hello!'

Now let's take a look at the list of available messages:

    curl 'pasture-app.puppet.vm/api/v1/cowsay/sayings'

Finally, we retrieve a message by ID:

    curl 'pasture-app.puppet.vm/api/v1/cowsay/sayings/1'

## Review

In this quest, you learned how to incorporate a module from the Forge into your
module to allow it to manage database. We began by covering the Forge website
and its search features that help you find the right module for your project.

After finding a good module, you used the `puppet module` tool to install it
into your `modules` directory. With the module installed, you created a
`pasture::db` class to define the specific database functionality you needed
for the Pasture application, and updated the main `pasture` class to define
the URI needed to connect to the database.

With this new `pasture::db` class set up and the `db` parameter added to the
main pasture class, a few changes to your `site.pp` classification let you
create a database server and connect it to your application server.

## Additional Resources

* Watch this [short video](https://fast.wistia.net/embed/iframe/uxfpduvk64?seo=false) for a basic introduction to the Forge.
* For more in-depth information on the Forge, check our [Introduction to the Forge](https://learn.puppet.com/elearning/an-introduction-to-the-forge) self-paced course.
* Our [Puppetizing Infrastructure](https://learn.puppet.com/instructor-led-training/puppetizing-infrastructure)  course focuses on using Forge modules to quickly get started managing your infrastructure with Puppet.
