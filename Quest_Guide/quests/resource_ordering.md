---
title: Ordering
layout: default
---

# Resource Ordering

### Prerequisites

- Welcome
- Power of Puppet
- Resources
- Manifests and Classes
- Modules
- Variables and Class Parameters
- Conditions

## Quest Objectives

 - Understand why some resources must be managed in a specific order.
 - Use the `before`, `require`, `notify`, and `subscribe` metaparameters to
   effectively manage the order that Puppet applies resource declarations.

## Getting Started

This quest will help you learn more about specifying the order in which Puppet
should manage resources in a manifest. When you're ready to get started, type
the following command:

    quest --start ordering

## Autorequires and Explicit Ordering

We are likely to read instructions from top to bottom and execute them in that
order. When it comes to resource declarations in a Puppet manifest, Puppet does
things a little differently. It works through the problem as though it were
given a list of things to do, and it was left to decide the most efficient way
to get them done.

The **catalog** is a compilation of all the resources that will be applied to a
given system, and the relationships between those resources. For some resource
types, Puppet is clever enough to figure out necessary relationships among
resources itself. These implicit resource relationships are called
**autorequires**.

You can see what a resource can autorequire with the `puppet describe` tool.

Take a look at the entry for the `file` resource:

    puppet describe file
	
A few paragraphs down, you'll see the following section:

  **Autorequires:** If Puppet is managing the user or group that owns a file,
  the file resource will autorequire them. If Puppet is managing any parent
  directories of a file, the file resource will autorequire them.

(The information you find with the `describe` tool can also be found in the
[type reference](https://docs.puppetlabs.com/references/latest/type.html)
section of Puppets docs site.)

When you declared `user` and `file` resources in your `accounts` module, the
autorequires of these resources ensured that everything went smoothly. 

Sometimes, however, you will need to tell Puppet explicitly that a resource
declaration is applied before another. For instance, if you wish to declare that
a service should be running, you need to ensure that the package for that
service is installed and configured before you can start the service. Just as
Puppet's built-in providers don't (and shouldn't!) automatically decide what
package you might want to use on a given operating system, Puppet doesn't try to
guess what services are associated with a given package.

Often, more than one package provides the same service, and what if you are
using a package you built yourself? Since Puppet cannot *always* conclusively
determine the mapping between a package and a service (the names of the software
package and the service or executable it provides are not always the same
either), it is up to the user to specify the relationship between them.

To overcome this issue, Puppet's syntax includes a few different ways to
explicitly manage resource ordering.

## Relationship Metaparameters

One way of telling Puppet what order to use when managing resources is by
including ordering **metaparameters** in your resource declarations.

Metaparameters are attributes that can be set in any resource to tell Puppet
*how* to manage that resource. In addition to resource ordering, metaparameters
can help with things like logging, auditing, and scheduling. For now, however,
we'll be concentrating only on resource ordering metaparameters.

There are four metaparameter **attributes** that you can include in your
resource declaration to order relationships among resources.

* `before` causes a resource to be applied **before** a specified resource.
* `require` causes a resource to be applied **after** a specified resource.
* `notify` causes a resource to be applied **before** the specified resource, 
  just as with `before`. Additionally, notify will generate a refresh event for 
  the specified resource when the notifying resource changes.
* `subscribe` causes a resource to be applied **after** the specified resource,
  just as with `after`. The subscribing resource will be refreshed if the 
  target resource changes.

The **value** of the relationship metaparameter is the title or titles (in an
array) of one or more target resources.

Here's an example of how the `notify` metaparameter is used:

{% highlight puppet %}
file {'/etc/ntp.conf':
  ensure => file,
  source => 'puppet:///modules/ntp/ntp.conf',
  notify => Service['ntpd'],
}

service {'ntpd':
  ensure => running,
}
{% endhighlight %}

In the above, the file `/etc/ntp.conf` is managed. The contents of the file are
sourced from the file `ntp.conf` in the ntp module's files directory. Whenever
the file `/etc/ntp.conf` changes, a refresh event is triggered for the service
with the title `ntpd`. By virtue of using the notify metaparameter, we ensure
that Puppet manages the file first, before it manages the service, which is to
say that `notify` implies `before`.

Refresh events, by default, restart a service (such as a server daemon), but you
can specify what needs to be done when a refresh event is triggered, using the
`refresh` attribute for the `service` resource type, which takes a command as
the value.

In order to better understand how to explicitly specify relationships between
resources, we're going to use SSH as our example. Setting the
`GSSAPIAuthentication` setting for the SSH daemon to `no` will help speed up the
login process when one tries to establish an SSH connection to the Learning VM. 

Let's try to disable GSSAPIAuthentication, and in the process, learn about
resource relationships.

Before getting started, ensure that you're in the `modules` directory:

    cd /etc/puppetlabs/puppet/environments/production/modules

{% task 1 %}
---
- execute: mkdir -p /etc/puppetlabs/puppet/environments/production/modules/sshd/{tests,manifests,files}
{% endtask %}

Create an `sshd` directory and create `tests`, `manifests`, and `files`
subdirectories.

{% task 2 %}
---
- execute: cp /root/examples/sshd_config /etc/puppetlabs/puppet/environments/production/modules/sshd/files/sshd_config
{% endtask %}

We've already prepared an `sshd_config` file to use as a base for your source
file. Copy it into your module's `files` directory:

    cp /root/examples/sshd_config sshd/files/sshd_config

{% task 3 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  content: |
    class sshd {  

      file { '/etc/ssh/sshd_config':
        ensure => file,
        mode => 600,
        source => 'puppet:///modules/sshd/sshd_config',
      }

    }

{% endtask %}

Create a `sshd/manifests/init.pp` manifest with the following class definition:

{% highlight puppet %}
class sshd {

  file { '/etc/ssh/sshd_config':
    ensure => file,
    mode   => 600,
    source => 'puppet:///modules/sshd/sshd_config',
  }
  
}
{% endhighlight %}

This will tell Puppet to ensure that the file `/etc/ssh/sshd_config` exists, and
that the contents of the file should be sourced from the file
`sshd/files/sshd_config`. The `source` attribute also allows us to use a
different URI to specify the file, something we discussed in the Modules
quest. For now, we are using a file in `/root/examples` as the content source
for the SSH daemon's configuration file.

Now let us disable GSSAPIAuthentication.

{% task 4 %}
---
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/files/sshd_config
  input:
    - "/GSSAPIAuthentication yes\r"
    - ":%s/yes/no/g\r"
    - ":wq\r"
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  input: 
    - "/class sshd {\r"
    - o
    - |
      service { 'sshd':
        ensure     => running,
        enable     => true,
        subscribe  => File['/etc/ssh/sshd_config'],
      }
    - "\e"
    - ":wq\r"
{% endtask %}

Disable GSSAPIAuthentication for the SSH service

Edit the `sshd/files/sshd_config` file.  
Find the line that reads:

    GSSAPIAuthentication yes

and edit it to read:

    GSSAPIAuthentication no  

Save the file and exit the text editor.

Even though we have edited the source for the configuration file for the SSH
daemon, simply changing the content of the configuration file will not disable
the GSSAPIAuthentication option. For the option to be disabled, the service (the
SSH server daemon) needs to be restarted. That's when the newly specified
settings will take effect.

Let's now add a metaparameter that will tell Puppet to manage the `sshd` service
and have it `subscribe` to the config file. Add the following Puppet code below
your file resource in the `sshd` module's `init.pp` manifest:

{% highlight puppet %}
service { 'sshd':
  ensure     => running,
  enable     => true,
  subscribe  => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

Notice that in the above the `subscribe` metaparameter has the value
`File['/etc/ssh/sshd_config']`. The value indicates that we are talking about a
file resource (that Puppet knows about), with the _title_
`/etc/ssh/sshd_config`. That is the file resource we have in the manifest.
References to resources always take this form. Ensure that the first letter of
the type ('File' in this case) is always capitalized when you refer to a
resource in a manifest.

{% task 5 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp
  content: include sshd
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp
{% endtask %}

Create a test manifest to include your `sshd` class.

Let's apply the change. Remember to check syntax and do a dry-run using the
`--noop` flag before using `puppet apply` to run your test manifest.

You will see Puppet report that the content of the `/etc/ssh/sshd_config` file
changed. You should also be able to see that the SSH service was restarted. 

In the above example, the `service` resource will be applied **after** the
`file` resource. Furthermore, if any other changes are made to the targeted file
resource, the service will refresh.

## Package/File/Service

Wait a minute! We are managing the service `sshd`, we are managing its
configuration file, but all that would mean nothing if the SSH server package is
not installed. So, to round it up, and make our manifest complete with regards
to managing the SSH server on the VM, we have to ensure that the appropriate
`package` resource is managed as well. 

On CentOS machines, such as the VM we are using, the `openssh-server` package
installs the SSH server. 

- The package resource makes sure the software and its config file are
  installed.
- The file resource config file depends on the package resource.
- The service resources subscribes to changes in the config file.

The **package/file/service** pattern is one of the most useful idioms in Puppet.
It’s hard to overstate the importance of this pattern! If you only stopped here
and learned this, you could still get a lot of work done using Puppet.

To stay consistent with the package/file/service idiom, let's dive back into the
sshd init.pp file and add the `openssh-server` package to it.

{% task 6 %}
---
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  input:
    - "/class sshd {\r"
    - "o"
    - |
        package { 'openssh-server':
          ensure => present,
          before => File['/etc/ssh/sshd_config'],
        }
    - "\e"
    - ":wq\r"
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp
{% endtask %}

Manage the package for the SSH server

Add the following code above your file resource in your `sshd/manifests/init.pp`
manifest

{% highlight puppet %}
package { 'openssh-server':
  ensure => present,
  before => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

Make sure to check the syntax. Once everything looks good, go ahead and apply
the manifest.

Notice that we use `before` to ensure that the package is managed before the
configuration file is managed. This makes sense, since if the package weren't
installed, the configuration file (and the `/etc/ssh/` directory that contains
it would not exist. If you tried to manage the contents of a file in a directory
that does not exist, you are destined to fail. By specifying the relationship
between the package and the file, we ensure success.

Now we have a manifest that manages the package, configuration file and the
service, and we have specified the order in which they should be managed.

## Review

In this Quest, we learned how to specify relationships between resources, to
provide for better control over the order in which the resources are managed by
Puppet. We also learned of the Package-File-Service pattern, which emulates the
natural sequence of managing a service on a system. If you were to manually
install and configure a service, you would first install the package, then edit
the configuration file to set things up appropriately, and finally start or
restart the service.
