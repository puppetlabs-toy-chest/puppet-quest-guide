{% include '/version.md' %}

# Roles and Profiles

## Quest objectives

- Learn how to organize your code into **profile** classes specific to your
  site's infrastructure.
- Bring multiple profile classes together to define a **role** class that will
  allow you to fully specify the role of a server in your infrastructure with a
  single class.

## Getting started

In the last quest, we shifted from managing the Pasture application on a single
system to distributing its components across the `pasture-prod.puppet.vm` and
`pasture-db.puppet.vm` hosts. The application server and database server you
configured each play a different role in your infrastructure and have a
different classification in Puppet.

As your Puppetized infrastructure grows in scale and complexity, you'll need to
manage more and more kinds of systems.  Defining all the classes and parameters
for these systems directly in your `site.pp` manifest doesn't scale well. The
**roles and profiles** pattern gives you a consistent and modular way to define
how the components provided your Puppet modules come together to define each
different kind of system you need to manage.

When you're ready to get started, enter the following command:

    quest begin roles_and_profiles

## What are roles and profiles?

The **roles and profiles** pattern we cover in this quest isn't a new tool or
feature in the Puppet ecosystem. Rather, it's a way of using the tools we've
already introduced to create something you can maintain and expand as your
Puppetized infrastructure evolves.

The explanation of roles and profiles begins with what we call **component
modules**. Component modules—like your Pasture module and the PostgreSQL module
you downloaded from the Forge—are designed to configure a specific piece of
technology on a system. The classes these modules provide are written to be
flexible. Their parameters provide an API you can use to specify precisely how
you need the component technology to be configured.

The roles and profiles pattern gives you a consistent way to organize these
component modules according to the specific applications in your
infrastructure.

A **profile** is a class that calls declares one or more related component
modules and sets their paramaters as needed. The set of profiles on a system
defines and configures the the technology stack it needs to fulfull its
business role.

A **role** is a class that combines one or more profiles to define the desired
state for a whole system. A role should correspond to the business purpose of a
server. If your CTO asks what a system is for, the role should fit that
high-level answer: something like "a database server for the Pasture
application." A role itself should **only** compose profiles and set their
parameters—it should not have any parameters itself.

## Writing profiles

Using roles and profiles is a design pattern, not something written into the
Puppet source code. As far as the Puppet parser is concerned, the classes that
define your roles and profiles are no different than any other class.

To get started setting up your profiles, create a new `profile` module
directory in your modulepath:

    mkdir -p profile/manifests

We'll begin by creating a set of profiles related to the Pasture application.
The profiles for the application server will manage two different
configurations: a 'large' deployment that connects to an external database, and
a 'small' deployment that makes use of the default SQLite database. In addition
to these two application server profiles, we'll create a profile to manage the
supporting PostgreSQL database.

To make it clear that all of these profiles relate to the Pasture application,
we'll place them in a `pasture` subdirectory within `profile/manifests`.

Create that subdirectory:

    mkdir profile/manifests/pasture

Next, create a profile for the development instance of the Pasture application.

    vim profile/manifests/pasture/app_large.pp

Here, you'll define the `profile::pasture::app_large` class.

```puppet
class profile::pasture::app_large {
  class { 'pasture':
    default_message   => 'Hello Puppet!',
    sinatra_server    => 'thin',
    default_character => 'elephant',
    db_uri            => 'postgres://pasture_user:m00!@pasture_db.puppet.vm/pasture',
  }
}
```

Next, create a profile for the small instance of your application.

    vim profile/manifests/pasture/app_small.pp

Here, we'll leave the `default_character` and `db_uri` parameters unset to use
the component module defaults.

```puppet
class profile::pasture::app_small {
  class { 'pasture':
    default_message   => 'Hello Puppet!',
    sinatra_server    => 'thin',
  }
}
```

Next, we'll use our `pasture::pasture_db` component class to create a profile
for the Pasture database:

    vim profile/manifests/pasture/db.pp

We don't need to customize any parameters here, so you can use the `include`
syntax to declare the `pasture::pasture_db` class.

```puppet
class profile::pasture::db
  include pasture::pasture_db
}
```

While these profiles define the configuration of components directly related to
the Pasture application, you'll likely want to manage some other details of
your application and database servers that aren't directly related to these
functions.

In a real infrastructure, you might want to create profiles to manage things
like user accounts, DHCP configuration, firewall rules, and NTP. We're not
going to go into these topics here, but by way of example, we'll create an
`motd` profile to wrap the `motd` class you created earlier. This can stand in
for the variety of components you might want to manage on a system that
aren't directly tied to its business role.

Create a manifest to define your `profile::motd` profile.

    vim profile/manifests/motd.pp

Like the `profile::pasture::db` profile class, the `profile::motd` class is
simply be a wrapper class with an `include` statement for the `motd` class.

```puppet
class profile::motd {
  include 'motd'
}
```

## Writing roles

Now you have a few profiles available. Each of these profiles defines how a
component on a system should be configured. A role combines one or more
profiles to define the entire stack of technology you want Puppet to manage on
a system.

While profiles define specific technologies, roles are always generic. For
example, `role::webserver` and `role::database` are appropriate roles, while
`role::apache_server` and `role::mysql_database` are not.

You may have a wide variety of webservers in your infrastructure. Rather than
creating a different role for each of these types of webserver, create a single
`role::webserver` class and use conditional logic to determine which profiles
it includes.

In this case, we'll need two roles to define the systems involved in the
Pasture application: `role::app_server` and `role::database`. First, create the
directory structure for your `role` module.

    mkdir -p role/manifests

Create a manifest to define your `role::app_server` role.

    vim role/manifests/app_server.pp

Here, we'll use conditional logic to decide whether to apply the large or small
version of our application.  With facts and conditionals, you can use any
system information to determine the stack of profiles that will fulfill the
role.  In this case, we'll base this decision on the node name. The quest tool
created a `pasture-app-small.puppet.vm` and `pasture-app-large.puppet,vm` node
for this quest, so we can determine the appropriate profile based on whether
the node name includes the string "small" or "large".

Regardless of the application profile we choose, we'll want to include
`profile::motd`, so we'll put this after the conditional.

```puppet
class role::app_server {
  if 'large' in $facts['name'] {
    include profile::pasture::app_large
  } elsif 'small' in $facts['name'] {
    include profile::pasture::app_small
  } else {
    fail("The #{$facts['name'] node name must match 'large' or 'small' to determine an appropriate profile.}")
  }
  include profile::motd
}
```

Next, create a role for your database server:

    vim role/manifests/database.pp

We're only using one database profile, so this role won't require any
conditional logic.

```puppet
class role::database {
  include profile::pasture::db
  include profile::motd
}
```

## Classification with the PE console

  

## Review

TBD
More resources!
