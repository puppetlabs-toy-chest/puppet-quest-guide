---
title: Resource Ordering
layout: default
---

# Resource ordering

## Quest objectives

 - Understand why some resources must be managed in a specific order.
 - Use the `before`, `require`, `notify`, and `subscribe` metaparameters to
   specify the order in which Puppet applies resource declarations.

## Getting started

This quest will help you learn more about specifying the order in which Puppet
should manage resources in a manifest. When you're ready to get started, type
the following command:

    quest --start ordering

## Resource order

So far, the modules you've been writing have been pretty simple. We've walked
you through minimal examples designed to demonstrate different features of Puppet and
its language constructs. Because we've only been handling a few resources at a time
in these cases, we haven't been worried about dependencies among those resources.
When you start tackling more complex problems, however, it will quickly become clear
that things have to happen in the right order. You can hardly configure a package
before it has been installed, or give ownership of a file to a user you haven't
yet created.

So how does Puppet manage these relationships? 

Remember, in a declarative language like Puppet you're describing a desired
state for a system, not listing the steps required to achieve that state.
Because Puppet manifests describe a state, not a process, you don't get the
implicit linear order of steps you would from an imperative language. Puppet
needs another way to know how to order resources.

This is where **resource relationships** come in. Puppet's resource relationship
syntax lets you explicitly define the dependency relationships among your resources.

There are a few ways to define these relationships. We'll start with the simplest,
the **relationship metaparameter**. You include relationship metaparameters in a
resource declaration with the rest of that resource's attribute value pairs.
Say you're writing a module to manage SSH, and you need to ensure that the
`openssh-server` package is installed *before* you try to manage the `sshd`
servuce. When declaring the `openssh-server`, package. You would include a `before`
metaparameter with the value `Service['sshd']`:

{% highlight puppet %}
package { 'openssh-server':
  ensure => present,
  before => Service['sshd'],
}
{% endhighlight %}

You can also approach the problem from the other direction. The `require`
metaparameter is the mirror image of `before`. It tells Puppet that the current
resource *requires* the one specified by the metaparameter.

{% aside Metaparameters%}
Metaparameters are attributes that can be set in any resource to give Puppet
extra information about how to manage a resource. In addition to resource
ordering, metaparameters can help with things like logging, auditing, and
scheduling.
{% endaside %}

Using `before` in the `openssh-server` package resource is exactly equivalent to
using `require` in the `sshd` service resource:

{% highlight puppet %}
service { 'sshd':
  ensure   => running,
  enable   => true,
  require  => Package['openssh-server'],
}
{% endhighlight %}

In both of these cases, take note of the way you refer to the target resource.
The target's *type* is capitalized, and followed by an *array* (denoted by the 
square brackets) of one or more resource titles:

{% highlight puppet %}
Type['title']
{% endhighlight %}

We've already covered a couple of the resources you'll need, so why not make
a simple SSH module to explore resource relationships?

SSH is already running on the Learning VM, so we'll make things a little more
interesting by managing its configuration as well as the package and service.

Specifically, we'll change the `GSSAPIAuthentication` setting for the SSH daemon
to `no`. You're not using this method of authentication to connect to the
Learning VM, so this will be a safe setting to change without disrupting any
aspects of the service you need for the Learning VM itself.

{% task 1 %}
---
- execute: mkdir -p /etc/puppetlabs/puppet/environments/production/modules/sshd/{tests,manifests,files}
{% endtask %}

To get started with your module, create an `sshd` directory with `tests`,
`manifests`, and `files` subdirectories.

{% task 2 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  content: |
    class sshd {  

      package { 'openssh-server':
        ensure => present,
      }

      service { 'sshd':
        ensure => running,
        enable => true,
      }

    }

{% endtask %}

With your directory structure in place, it's time to get started on your `sshd` class.
Create an `sshd/manifests/init.pp` manifest and fill in your `sshd` class with the
`openssh-server` package resource and `sshd` service resource. Don't forget to include
a `require` or `before` to specify the relationship between these two resources.
(If you need a hint, feel free to refer back to the examples above!)

When you're done use the `puppet parser validate` command to check your manifest.

We haven't added the `file` resource to manage the the `sshd` configuration, but
before getting to this, let's take a look at the relationship between the `package` and
`service` resources from another perspective.

When Puppet compiles a catalog, it generates a **graph** that represents the network
of resource relationships in that catalog. Not to be confused with the more general sense
of meaning "chart," *graph*, in this context, refers to a method commonly used in computer
science and mathematics to model connections among a collection of objects. Puppet uses
a graph to determine a workable order for applying resources.

This graph can also be a great tool to help a user visualize and understand the relationships
among resources.

{% task 3 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp
  content: include sshd
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp --noop --graph
{% endtask %}

The quickest way to get Puppet to generate a graph for this kind of testing is to run a test
manifest with the `--noop` and `--graph` flags. Go ahead and set up a `sshd/tests/init.pp`
manifest. You don't have any parameters here, so you can use a simple:

{% highlight puppet %}
include sshd
{% endhighlight %}

With this done, run a `puppet apply` of your test manifest with the `--noop` and `--graph`
flags:

    puppet apply sshd/tests/init.pp --noop --graph

{% task 3 %}
---
  - execute: dot -Tpng /var/opt/lib/pe-puppet/state/graphs/relationships.dot -o /var/www/html/questguide/relationships.png
{% endtask %}

Puppet outputs a `.dot` file to a location defined as the `graphdir`. You can find
the `graphdir` location with the `puppet config print` command:

    puppet config print graphdir

Use the `dot` command to convert the `relationships.dot` file in the `graphdir` into
a `.png` image. Set the location of the output to the root of the Quest Guide's web
directory so that it will be easily viewable from your browser.

    dot -Tpng /var/opt/lib/pe-puppet/state/graphs/relationships.dot -o /var/www/html/questguide/relationships.png

Take a look at (the graph)[/relationships.png]. Notice that the `openssh-server`
and `sshd` resources you defined are connected by an arrow to indicate the
dependency relationship.

{% figure '/relationships1.png' %}

{% task 2 %}
---
- execute: cp /etc/ssh/sshd_config /etc/puppetlabs/puppet/environments/production/modules/sshd/files/sshd_config
{% endtask %}

Now let's move on to the next step. We'll use a `file` resource to manage the `sshd`
configuration. First, we'll need a source file. As you did for the `vimrc` file in
the Modules quest, you can copy the existing configuration file into your module's
`files`.

    cp /etc/ssh/sshd_config sshd/files/sshd_config

{% task 4 %}
---
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/files/sshd_config
  input:
    - "/#GSSAPIAuthentication no\r"
    - "x"
    - "/GSSAPIAuthentication yes\r"
    - "i#"
    - ":wq\r"
{% endtask %}

Now, let's disable GSSAPIAuthentication. Open the `sshd/files/sshd_config` file
and find the `GSSAPIAuthentication` line. Uncomment the `no` line, and comment out the
`yes` line.

{% task 5 %}
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  input: 
    - "/class sshd {\r"
    - o
    - |
      file { '/etc/ssh/sshd_config':
        ensure     => present,
        source     => 'puppet:///modules/sshd/sshd_conf',
        require    => Package['openssh-server'],
      }
    - "\e"
    - ":wq\r"
{% endtask %}

With the source file prepared, go back to your `sshd/manifests/init.pp`
manifest and add a `file` resource to manage the `sshd_config` file.
You want to ensure that this `file` resource is applied *after* the
`openssh-server` package, so include a `require` metaparameter targeting
that resource.

{% highlight puppet %}
class sshd {

  ...

  file { '/etc/ssh/sshd_config':
    ensure     => present,
    source     => 'puppet:///modules/sshd/sshd_conf',
    require    => Package['openssh-server'],
  }

}
{% endhighlight %}


{% task 3 %}
---
  - execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp --noop --graph
  - execute: dot -Tpng /var/opt/lib/pe-puppet/state/graphs/relationships.dot -o /var/www/html/questguide/relationships.png
{% endtask %}

Apply your test manifest again with the `--graph` and `--noop` flags,
then use the `dot` tool again to regenerate your graph image.

    dot -Tpng /var/opt/lib/pe-puppet/state/graphs/arelationships.dot -o /var/www/html/questguide/relationships.png

Check (your graph)[/relationships.png] again to see how your new `file` resource
fits in.

{% figure '/relationships2.png' %}

You can easily see from the graph diagram that both the `file` and `service` resources
require the `package` resource. What's missing from the picture so far?
If you want your configuration changes to have an effect, you will have to
either make those changes before the service is started, or restart the service
after you've made your changes.

Puppet uses another pair of metaparameters to manage this special relationship
between a service and its configuration file: `notify` and `subscribe`. The `notify`
and `subscribe` metaparameters establish the same dependency relationships as `before`
and `require`, respectively, and also trigger a refresh in the whenever Puppet
makes a change to the dependency.

While any resource can be the dependency that triggers a refresh, there are only
two resource types that can respond to one: `service` and `exec`. When
a `service` receives a refresh event, it will restart. When an `exec` receives
a refresh message, it will execute its specified command again.

Like `before` and `require`, `notify` and `subscribe` are mirror images of each other.
Including a `notify` in your `file` resource has exactly the same result as including
`subscribe` in your `service` resource.

{% task 6 %}
- execute: vim /etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp
  input: 
    - "/service\r"
    - o
    - subscribe => File['/etc/ssh/sshd_config'],
    - "\e"
{% endtask %} 

Edit your `sshd/manifests/init.pp` manifest to add a `subscribe` metaparameter
to the the `sshd` resource.

{% highlight puppet %}
class sshd {

  ...
  
  service { 'sshd':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ssh/sshd_config'],
  }

  ...

}
{% endhighlight %}

Validate your syntax with the `puppet parser` tool. When your syntax checks out,
apply your test manifest with the `--graph` and `--noop` flags, then use the `dot`
tool again to regenerate your graph image again.

Check (your graph)[/relationships.png] one more time. Notice that the `sshd`
resource now depends on the `/etc/ssh/sshf_config` file.

{% figure '/relationships2.png' %}

Finally, drop the `--noop` flag to actually apply your changes. You'll see a notice
that the content of the config file has changed, followed by a notice for the 'refresh'
for the `sshd` service.

## Chaining arrows

**Chaining arrows** provide another means for creating relationships between
resources or groups of resources. The approiate occasions for using chaining
arrows involve concepts beyond the scope of this quest, but for the sake of
completeness, we'll give a brief overview.

The `->` (ordering arrow) operator causes the resource to the left to be applied
before the resource to the right.

The `~>` (notification arrow) operator causes the resource on the left to be
applied before the resource on the right, and sends a refresh event to the
resource on the right if the left resource changes.

Though you may see chaining arrows used between resource declarations themselves,
this generally isn't good practice. It is easy to overlook chaining arrows,
especially if you're refactoring a large manifest with many resources and
resource relationships.

So what are chaining arrows good for? Unlike metaparameters, chaining
arrows aren't embedded in a specific resource declaration, which means
that you can use them between resource references, arrays of resource
references, and resource collectors to concisely and dynamically create
one-to-many or many-to-many dependency relationships among groups
of resources.

## Autorequires

**Autorequires** are relationships between resources that Puppet can figure out
for itself. For instance, Puppet knows that a file resource should always
come after a parent directory that contains it, and that a user resource should
always be managed after the primary group it belongs to has been created. You can
find these relationships in the (type reference)[http://docs.puppetlabs.com/references/4.1.latest/type.html]
section of the Puppet Docs page, as well as the output of the `puppet describe`
tool.

## Review

In this Quest, you learned how to specify relationships between resources. These
relationships let you specify aspects of the order Puppet follows as it applies
resources. You learned how to use the `--graph` flag and `dot` tool to visualize
resource relationships, and how to use `notify` and `subscribe` to refresh
a service when a related configuration file changes. Finally, you learned about
chaining arrows, an alternate syntax for specifying resource relationships, and
autorequires, Puppet's built-in knowledge about how some resources should be
ordered.
