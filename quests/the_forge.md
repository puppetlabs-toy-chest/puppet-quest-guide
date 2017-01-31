{% include '/version.md' %}

# The Forge

## Quest objectives

- Learn how to access the Puppet Forge and find a module.
- Use class parameters to adapt a Forge module to your needs.

## Getting started

In this quest, we'll introduce you to the Forge, a repository for modules
written and maintained by the Puppet community.

When you're ready to get started, enter the following command:

    quest begin the_forge

## What is the Forge?

The [Puppet Forge](forge.puppet.com) is a public repository for Puppet modules.
The Forge gives you access to a wide variety of community maintained modules.
Using existing modules from the Forge lets manage a wide variety of
applications and systems without spending extensive time on custom module
development. Furthermore, because Forge modules are used and maintained by the
community, you'll be working with Puppet code that's already well reviewed and
tested.

The Forge also maintains lists of modules that have been checked against
standards set by Puppet's Forge team. Modules in the **Puppet Approved**
category are audited to ensure quality, reliability, and active development.
Modules in the **Puppet Supported** list are covered by Puppet Enterprise
support contacts and are maintained and tested across multiple platforms and
versions over the course of the Puppet Enterprise release lifecycle.

In this quest, you'll use a PostgreSQL module from the Forge to configure a
database the Pasture application can use to store and retrieve cow messages.

Your first step will be to find an appropriate module to use. Use the search
interface on the [Forge](forge.puppet.com) website to do a search for
`PostgreSQL`. (If you don't currently have internet access, you can continue
with this quest by skipping ahead to the installation step below—the resources
necessary to complete the quest are cached on the VM.)

IMAGE

The Forge will show several hits that match your query, including version and
release data information, downloads, a composite rating score, and a supported
or approved banner where relevant. This information can give you a quick idea
of which modules in your search result you may want to investigate further.

IMAGE

For this quest, we'll use the `puppetlabs/postgresql` module. Click on that
module title to see more information and documentation. To set up a database
for the Pasture application, you will need to set up a server, and database and
configure user permissions. Take a minute to look through the documentation to
get an idea of how you might use the module to handle this configuration. We'll
walk you through the specifics below, but you can by glancing through the
documentation that this module should meet your needs.

## Installation

Recall that a module is just a directory structure containing Puppet manifests
and any other code or data needed to manage whatever it is the module helps
you manage on a system. The Puppet master finds any modules in its *modulepath*
directories and uses the module directory structure to find the classes, files,
templates, and whatever else the module provides.

Installing a module means placing the module directory in the Puppet master's
modulepath. While you could download the module and manually move it to the
modulepath, Puppet provides tools to help manage your modules.

You may have noticed two different methods of installation near the top of the
`postgresql` module: the Puppetfile and the `puppet module` tool. For this
quest, we'll use the simpler `puppet module` tool. (As you start managing a
more complex Puppet environment and checking your Puppet code into a control
repository, however, using a Puppetfile is recommended.)

On your master, go ahead and use the `puppet module` tool to install this
module:

    puppet module install puppetlabs-postgresql --version 4.8.0

Now take a look at the directory where this was installed to see the module
directory.

    ls /etc/puppetlabs/code/environments/prodcution/modules

Notice that when you saw the module on the Forge, it was listed as
`puppetlabs/postgresql`, and when you installed it, you called it
`puppetlabs-postgresql`, but the actual directory where it installed is
`postgresql`. The `puppetlabs` corresponds to the name of the Forge user
account that uploaded the module to the Forge. This distinguishes different
users' versions of a module when you're browsing the Forge and during
installation. However, as module is installed, this account name is not
included in the module directory name. If you aren't aware of this, it could
some confusion; identically named modules will conflict if you try to install
them on the same master.

## Writing a wrapper class

While you could use the classes provided by this module directly in your node
definition blocks in the `site.pp` manifest, it's best practice to keep your
actual classification as simple as possible. We can acheive this by creating a
**wrapper class** to bundle together everything we want from the classes
provided by the `postgresql` module. We'll call this wrapper class `pasture_db`
and put it in a new `pasture_db` module.

Go ahead and create the directory structure for this module.

    mkdir -p pasture_db/manifests

Now create an `init.pp` manifest to define your main `cowsay_db` class:

    vim pasture_db/manifests/init.pp

Within this `pasture_db` class, we'll use the classes provided by the
`postgresql` module to set up a database server, the `pasture` database that
will keep track of our cow sayings.

```puppet
class pasture_db {

  include postgres::server

  postgresql::server::db { 'pasture':
    user     => 'pasture_user',
    password => postgresql_password('pasture_user', 'm00!'),
  }

}
```

With this wrapper class done, you can easily add the database server it defines
to a node definition in your `site.pp` manifest. In this case, we've kept
things simple and created a class without parameters. As needed, you might add
parameters to this wrapper class in order to pass values through to the
postgresql classes it contains.

There is a difference in how we think about what parameters to include for this
kind of infrastructure-specific wrapper class and for a class in a public Forge
module. A Forge module is intended to be as flexible as possible, so it will
generally include a large number of parameters to cover a wide variety of
configuration possibilities for the underlying software. Our wrapper class, on
the other hand, is intended to address the much smaller range of possible
configurations needed for our infrastructure. There's no need to expose more
parameters than are necessary for this purpose.

Go ahead and open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Create a node definition to classify the `pasture-db.puppet.vm` node with
the `pasture_db` class.

```puppet
node 'pasture-db.puppet.vm' {
  include pasture_db
}
```

Use the `puppet job` tool to trigger a Puppet agent run on this
`pasture-db.puppet.vm` node.

    puppet job run --nodes pasture-db.puppet.vm

The next step is to connect the `pasture-prod.puppet.vm` node to this database
server.  By default, the Pasture application can store and retrieve cow
messages in an in-memory SQLite database, but if we provide a database URI in
the configuration file, it will use that database instead.

```puppet
node 'pasture-prod.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
    db_uri         => 'postgres://pasture_user:m00!@pasture_db.puppet.vm/pasture'
  }
}
```

Use the `puppet job` tool to trigger an agent run on this node as well.

    puppet job run --nodes pasture-prod.puppet.vm

TODO: Add specific instructions to test out the database functionality.

## Review

TBD
