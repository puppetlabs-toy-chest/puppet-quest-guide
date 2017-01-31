{% include '/version.md' %}

# Package File Service

## Quest objectives

- TBD 

## Getting started

When you're ready to get started, enter the following command:

    quest begin file_package_service

## The package, file, resource pattern 

In the previous quest, you created a simple module to manage the cowsay
package. Often, however, you'll need Puppet to manage several related resources
in concert in order to get your managed node to a desired state. These groups
of resources often follow a "package, file, service" pattern. A package
resource manages the software package itself, a file resource allows you to
customize a related configuration file, and a service resource starts the
service provided by the software you've just installed and configured.

To build on your existing cowsay module, we've created a simple Ruby
application called Pasture. Pasture extends cowsay to provide a simple RESTful
API so that your cows can be accessible over HTTP—we call this cowsay as a
service (CaaS). If you're curious, you can find the source code
[here](https://github.com/puppetlabs/pltraining-pasture).

Just like the cowsay command line tool, we'll use a package resource with the
`gem` provider to install Pasture.

Next, because Pasture reads from a configuration file, we're going to use a
file resource to manage its settings.

Finally, we want Pasture to run as a persistent background process, rather than
running once like the Cowsay command line tool. It needs to listen for incoming
requests and serve out cows as needed. To set this up, we'll first have to
create a file resource to define the service, then use a service resource to
ensure that it's running.

## Package

Before getting started, be sure you're in your Puppet master's `modules`
directory.

    cd /etc/puppetlabs/code/environments/production/modules

Create a new directory structure for your `pasture` module. This time, the
module will include two subdirectories: `manifests`, and `files`.

    mkdir -p pasture/{manifests, files}

Open a new `init.pp` manifest to begin your definition of the main `pasture`
class. 

    vim pasture/manifests/init.pp

So far, this should look just like the `cowsay` class, except that the package
resource will manage the `pasture` package instead of `cowsay`.

```puppet
class pasture {
  package { 'pasture':
    ensure   => present,
    provider => gem,
  }
}
```

Use the `puppet parser` tool to validate your syntax and make any changes
necessary:

    puppet parser validate pasture/manifests/init.pp

Before continuing on, let's apply this class to see where this file resource
has gotten us.

Open your `site.pp` manifest:

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Create a new node definition for the `pasture.puppet.vm` node we've set up for
this quest. Include the `pasture` class you just wrote.

```puppet
node pasture.puppet.vm {
  include pasture
}
```

Now connect to the `pasture.puppet.vm` node:

    ssh learning@pasture.puppet.vm 

And trigger a Puppet agent run:

    puppet agent -t

With the `pasture` gem installed, you can use the `pasture start` command
to start the pasture process. We haven't set up a service to manage this
process yet, but you can add an ampersand (`&`) after the command to start
it in the background.

    pasture start &

Use the `curl` command to test the Pasture API. The request takes two
parameters, `string`, which defines the message to be returned, and
`character`, which sets the character you want to speak the message. By
default, the process listens on port 4567. Try the following command:

    curl 'localhost:4567?string=Hello!'

By default, your message will be spoken by the cow character. Let's try passing
in another parameter to change this:

    curl 'localhost:4567?string=Hello!&character=elephant'

Feel free to experiemnt with other parameters. When you're done, foreground the
process:

    fg

And use `CTRL-C` to end the process, and disconnect from the agent node.

    exit

## File

Packages you install with Puppet often have configuration files that let you
customize their behavior. We've written the Pasture gem to use a very simple
configuration file, but once you understand the basic concept, it will be very
easy to extend to more complex configurations.

You already created a `files` directory inside the `pasture` module directory.
Just like placing manifests inside a module's `manifests` directory lets Puppet
find the classes they define, you can make any files your module needs
available to Puppet by placing them in the module's `files` directory.

Go ahead and create a file called `pasture_config.yaml`.

    vim pasture/files/pasture_config.yaml

Include a line here to set the default character to `elephant`.

```yaml
---
  character: elephant
```

With this source file in place, you can now create a `file` resource to manage
it on your agent node.

The `file` resource takes a `source` parameter, which allows you to specify a
source file that will define the content of the managed file. As its value,
this parameter takes a URI. While it's possible to point to other locations,
you'll typically use this to specify a file in your module's `files` directory.
Puppet uses a shortened `puppet:` URI format to refer to these module files
kept on your Puppet master. This format follows the pattern
`puppet:///modules/<MODULE NAME>/<FILE PATH>`.  (Notice the triple forward
slash just after `puppet:`. This stands in for the implied path to the modules
on your Puppet master. You can always refer back to the
[docs](https://docs.puppet.com/puppet/latest/reference/types/file.html#file-attribute-source)
for a reminder if you have trouble remembering the precise URI format.)

Return to your `init.pp` manifest.

    vim pasture/manifests/init.pp

And add a file resource declaration.

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }
}
```

Check your syntax with the `puppet parser` tool:

    puppet parser validate pasture/manifests/init.pp

## Service

While some packages set up their own service unit files, Pasture does not.
It's easy enough to use the file resource to create your own. First, create a
file called `pasture.service`.

    vim pasture/files/pasture.service

Include the following contents:

```
[Unit]
    Description=Run the pasture service
   
    [Service]
    ExecStart=/usr/local/bin/pasture start
   
    [Install]
    WantedBy=multi-user.target
```

Now open your `init.pp` manifest again:

    vim pasture/manifests/init.pp

First, add a file resource to manage your service unit file:

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
  }

}
```

Next, add the service resource itself:

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
  }

  servive { 'pasture':
    ensure => running.
  }

}
```

## Resource ordering

There's one more step before this class is complete. We need a way to ensure
that the resources defined in this class are managed in the correct order. The
"package, file, service" pattern describes the common dependency relationships
among these resources: we want to install a package, write a configuration
file, and start a service, in that order. Furthermore, if we make changes to
the configuration file later, we want Puppet to restart our service so it can
pick up those changes.

Though Puppet code will default to managing resources in the order they're
written in a manifest, we strongly recommend that you make dependencies among
resources explicit through [relationship
metaparameters](https://docs.puppet.com/puppet/latest/lang_relationships.html#syntax-relationship-metaparameters).
(A metaparameter looks just like any other parameter, but it affects *how*
Puppet handles a resource rather than directly defining its desired state.)

For our class, we'll use two relationship metaparameters: `before` and
`notify`. `before` tells Puppet that the current resource must come before the
target resource. Like `before`, notify tells Puppet that the current resource
must come before the target resource, but if the target resource is a service,
it will also restart the service whenever the current resource is changed.

The value of a relationship metaparameter is a [resource
reference](https://docs.puppet.com/puppet/latest/lang_data_resource_reference.html)
that specifies the target resource. The syntax for a resource reference is the
capitalized resource type, followed by square brackets containing the resource
title: `Type['title']`. 

If your `init.pp` manifest isn't already open, go ahead and open it again.

    vim pasture/manifests/init.pp

Add relationship metaparameters to define the dependencies among your
`package`, `file`, and `service` resources.

```puppet
class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
    before   => File['/etc/pasture_config.yaml'],
  }

  file { '/etc/pasture_config.yaml':
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

When you're finished, check your syntax one more time with the `puppet parser`
tool:

    puppet parser validate pasture/manifests/init.pp

The `pasture.puppet.vm` node is still classified with this `pasture` class.
When you return to the node and do another puppet agent run, the master will
pick up these added file and service resources and include them in the catalog
it returns to the node.

Go ahead and connect to `pasture.puppet.vm`.

    ssh learning@pasture.puppet.vm

And trigger another Puppet agent run.

    puppet agent -t

Now that the `pasture` service is configured and running, disconnect from the
agent node.

    exit

From the master, use the `curl` command to retrieve an ASCII elephant from
port 4567 of the `pasture.puppet.vm` node:

    curl 'pasture.puppet.vm:4567?string=Hello!'

## Review
