{% include '/version.md' %}

# Package file service

## Quest objectives

- Learn how to use the `package`, `file` and `service` resources together to
  manage an application.
- Use resource ordering metaparameters to define dependencies among resources. 

## Getting started

When you're ready to get started, enter the following command:

    quest begin package_file_service

## The package, file, service pattern 

In the previous quest, you created a simple module to manage the `cowsay` and
`fortune-mod` packages. Often, however, you'll need Puppet to manage several
related resource types to get your managed system to its desired state. The
`package`, `file`, and `service` resource types are used in concert often
enough that we talk about them together as the "package, file, service"
pattern. A package resource manages the software package itself, a file
resource allows you to customize a related configuration file, and a service
resource starts the service provided by the software you've just installed and
configured.

To give you an example to work with in this and the following quests, we've
created a simple Ruby application called Pasture. Pasture provides cowsay's
functionality over RESTful API so that your cows can be accessible over HTTP—we
might call this cowsay as a service (CaaS). (You can find the source code
[here](https://github.com/puppetlabs/pltraining-pasture)). Though this Pasture
application is whimsical, its simplicity allows us to focus on Puppet itself
without taking detours to cover the features and caveats of a more complex
application.

Just like the cowsay command line tool, we'll use a `package` resource with the
`gem` provider to install Pasture.

Next, because Pasture reads from a configuration file, we're going to use a
`file` resource to manage its settings.

Finally, we want Pasture to run as a persistent background process, rather than
running once like the cowsay command line tool. It needs to listen for incoming
requests and serve out cows as needed. To set this up, we'll first have to
create a `file` resource to define the service, then use a `service` resource
to ensure that it's running.

## Package

<div class = "lvm-task-number"><p>Task 1:</p></div>

Before getting started, be sure you're in your Puppet master's `modules`
directory.

    cd /etc/puppetlabs/code/environments/production/modules

Create a new directory structure for your `pasture` module. This time, the
module will include two subdirectories: `manifests` and `files`.

    mkdir -p pasture/{manifests,files}

<div class = "lvm-task-number"><p>Task 2:</p></div>

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
necessary.

    puppet parser validate pasture/manifests/init.pp

<div class = "lvm-task-number"><p>Task 3:</p></div>

Before continuing, let's apply this class to see where this file resource
has gotten us.

Open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Create a new node definition for the `pasture.puppet.vm` node we've set up for
this quest. Include the `pasture` class you just wrote.

```puppet
node 'pasture.puppet.vm' {
  include pasture
}
```
<div class = "lvm-task-number"><p>Task 4:</p></div>

Now connect to the `pasture.puppet.vm` node.

    ssh learning@pasture.puppet.vm 

And trigger a Puppet agent run.

    sudo puppet agent -t

<div class = "lvm-task-number"><p>Task 5:</p></div>

With the `pasture` gem installed, you can use the `pasture start` command. We haven't set up a service to manage this
process yet, but you can add an ampersand (`&`) after the command to start
it in the background.

    pasture start &

As the process starts, it will write some output to your terminal, but will not
prevent you from entering new commands. If you want a clean prompt for your
next command, just hit the `enter` key.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Use the `curl` command to test the Pasture API. The request takes two
parameters, `string`, which defines the message to be returned, and
`character`, which sets the character you want to speak the message. By
default, the process listens on port 4567. Try the following command:

    curl 'localhost:4567/api/v1/cowsay?message=Hello!'

By default, your message will be spoken by the cow character. Let's try passing
in another parameter to change this.

    curl 'localhost:4567/api/v1/cowsay?message=Hello!&character=elephant'

<div class = "lvm-task-number"><p>Task 7:</p></div>

Feel free to experiment with other parameters. When you're done, use the `fg`
command to foreground the `pasture` process:

    fg

Use the `CTRL-C` key combination to end the process:  

`CTRL-C`  

If `fg` doesn't foreground the process, use the `ps` command to find the
`pasture` process's PID and use the `kill` command with that PID (e.g. `kill
5983`) to stop the process.

Once you've stopped the process, disconnect from the agent node.

    exit

## File

Packages you install with Puppet often have configuration files that let you
customize their behavior. We've written the Pasture gem to use a simple
configuration file. Once you understand the basic concept, it will be easy to
extend to more complex configurations.

You already created a `files` directory inside the `pasture` module directory.
Just like placing manifests inside a module's `manifests` directory allows Puppet
to find the classes they define, placing files in the module's `files` directory
makes them available to Puppet.

<div class = "lvm-task-number"><p>Task 8:</p></div>

Create a `pasture_config.yaml` file in your module's `files` directory.

    vim pasture/files/pasture_config.yaml

Include a line here to set the default character to `elephant`.

```yaml
---
:default_character: elephant
```

With this source file saved to your module's `files` directory, you can use
it to define the content of a `file` resource.

The `file` resource takes a `source` parameter, which allows you to specify a
source file that will define the content of the managed file. As its value,
this parameter takes a URI. While it's possible to point to other locations,
you'll typically use this to specify a file in your module's `files` directory.
Puppet uses a shortened URI format that begins with the `puppet:` prefix to
refer to these module files kept on your Puppet master. This format follows the
pattern `puppet:///modules/<MODULE NAME>/<FILE PATH>`. Notice the triple
forward slash just after `puppet:`. This stands in for the implied path to the
modules on your Puppet master.

Don't worry if this URI syntax seems complex. It's pretty rare that you'll need
to use it for anything other than referring to files within your modules, so
the pattern above is likely all you'll need to learn. You can always refer back
to the
[docs](https://docs.puppet.com/puppet/latest/reference/types/file.html#file-attribute-source)
for a reminder.

<div class = "lvm-task-number"><p>Task 9:</p></div>

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

Check your syntax with the `puppet parser` tool.

    puppet parser validate pasture/manifests/init.pp

## Service

While the cowsay command you installed in the previous quest runs once and
exits, Pasture is intended to be run as a service. A Pasture process will run
in the background and listen for any incoming requests on its designated port.
Because our agent node is running CentOS 7, we'll use the [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service manager to handle our Pasture process.
Although some packages set up their own service unit files, Pasture does not.
It's easy enough to use a `file` resource to create your own. This service unit
file will tell systemd how and when to start our Pasture application.

<div class = "lvm-task-number"><p>Task 10:</p></div>

First, create a file called `pasture.service`.

    vim pasture/files/pasture.service

Include the following contents:

```
[Unit]
Description=Run the pasture service

[Service]
Environment=RACK_ENV=production
ExecStart=/usr/local/bin/pasture start

[Install]
WantedBy=multi-user.target
```

If you're not familiar with the format of a systemd unit file, don't worry
about the details here. The beauty of Puppet is that the basic principles you
learn with this example will be easily portable to whatever system you work
with.

<div class = "lvm-task-number"><p>Task 11:</p></div>

Now open your `init.pp` manifest again.

    vim pasture/manifests/init.pp

First, add a file resource to manage your service unit file.

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

Next, add the `service` resource itself. This resource will have the title
`pasture` and a single parameter to set the state of the service to `running`.

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

  service { 'pasture':
    ensure => running,
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
A metaparameter is a parameter, that affects *how* Puppet handles a resource
rather than directly defining its desired state. Relationship metaparameters
tell Puppet about ordering relationships among your resources.

For our class, we'll use two relationship metaparameters: `before` and
`notify`. `before` tells Puppet that the current resource must come before the
target resource. The `notify` metaparameter is like `before`, but if the target
resource is a service, it has the additional effect of restarting the service
whenever Puppet modifies the resource with the metaparameter set. This is
useful when you need Puppet to restart a service to pick up changes in a
configuration file.

Relationship metaparameters take a [resource
reference](https://docs.puppet.com/puppet/latest/lang_data_resource_reference.html)
as a value. This resource reference points to another resource in your Puppet
code. The syntax for a resource reference is the capitalized resource type,
followed by square brackets containing the resource title: `Type['title']`. 

<div class = "lvm-task-number"><p>Task 12:</p></div>

If your `init.pp` manifest isn't already open, go ahead and open it again.

    vim pasture/manifests/init.pp

Add relationship metaparameters to define the dependencies among your
`package`, `file`, and `service` resources. Take a moment to think through
what each of these relationship metaparameters does and why.

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
    source  => 'puppet:///modules/pasture/pasture.service',
    notify  => Service['pasture'],
  }

  service { 'pasture':
    ensure => running,
  }

}
```

When you're finished, check your syntax one more time with the `puppet parser`
tool.

    puppet parser validate pasture/manifests/init.pp

The `pasture.puppet.vm` node is still classified with this `pasture` class.
When you return to the node and do another puppet agent run, the master will
pick up these added file and service resources and include them in the catalog
it returns to the node.

<div class = "lvm-task-number"><p>Task 13:</p></div>

Go ahead and connect to `pasture.puppet.vm`.

    ssh learning@pasture.puppet.vm

And trigger another Puppet agent run.

    sudo puppet agent -t

Now that the `pasture` service is configured and running, disconnect from the
agent node.

    exit

From the master, use the `curl` command to retrieve an ASCII elephant from
port 4567 of the `pasture.puppet.vm` node.

    curl 'pasture.puppet.vm:4567/api/v1/cowsay?message=Hello!'

## Review

In this quest, we got into some of the specifics of writing Puppet code.
You used the common "package, file, service" pattern to configure the Pasture
application and set up a service unit to run its process on your server.

You learned how to make a file available to Puppet by placing it in your
module's `files` directory. With that file in place, you learned how to use it
in a `file` resource with the `source` parameter and a URI.

Finally, we went over resource ordering. You used the `before` and `notify`
metaparameters to define relationships among the resources in your class to
ensure that Puppet will manage the resources in the correct order and refresh
the service when its configuration file is modified.

In the next quest, you'll learn to make this class more flexible by adding
variables and replacing your static files with templates.

## Additional Resources

* Our [docs page](https://docs.puppet.com/puppet/latest/lang_relationships.html) covers resource relationships in more depth, including some alternative syntax forms you might run into reading others’ Puppet code.
* Resource relationships are also covered by [a lesson](https://learn.puppet.com/elearning/relationships) in our [self-paced course catalog](https://learn.puppet.com/category/self-paced-training).
