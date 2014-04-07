---
title: Ordering
layout: default
---

# Resource Ordering

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Classes Quest
- Varibales Quest
- Conditions Quest

## Quest Objectives

Just as with the Variables Quest and Conditions Quest, the Resource Ordering Quest will help you learn more about specifying the order in which Puppet should manage resources in a manifest. This ordering manges and controls (like instructions) for creating flexibility and scalability in your manifests. When you're ready to get started, type the following command:

	quest --start ordering

## Explicit Ordering

You are likely use to reading instructions from top to bottom. If you wish to master the creation of Puppet manifests you must learn to think of ordering in a different way. Rather than processing instructions from top to bottom, Puppet interprets the resource declarations in a manifest in whatever order is most efficient.

Sometimes, however, you will need to ensure that a resource declaration is applied before another. For instance, if you wish to declare in a manifest that a service should be running, you need to ensure that the package for that service is installed and configured before you can start it.

When you need a group of resources to be managed in a specific order, you must explicitly state the dependency relationships between these resources within the resource declarations.

## Relationship Metaparameters

{% fact %}
In Puppet's DSL, a resource metaparamter is a variable that doesn't refer directly to the state of a resource, but rather tells Puppet how to process the resource declaration itself.
{% endfact %}

Metaparameters follow the familiar `attribute => value` syntax. There are four metaparameter **attributes** that you can include in your resource declaration to order relationships among resources.

* `before` causes a resource to be applied **before** a target resource
* `require` causes a resource to be applied **after** a target resource.
* `notify` causes a resource to be applied **before** the target resource. The target resource will refresh if the notifying resource changes.
* `subscribe` causes a resource to be applied **after** the target resource. The subscribing resource will refresh if the target resource changes.

The **value** of the relationship metaparameter is the title or titles (in an array) of one or more target resources.

{% task 1 %}
We're going to use SSH as our example. Let's dive into the sshd_config file on the Learning VM and add the following Puppet code to it:

{% highlight puppet %}
file { '/etc/ssh/sshd_config':
  ensure => file,
  mode   => 600,
  source => '/root/examples/sshd_config',
}
{% endhighlight %}

However, we're only partial correct. It will change the config file, but those changes will only take effect when the service restarts. Let's now add a metaparameter to that will tell Puppet to manage the `sshd` service and have it `subscribe` to the config file. Add the following Puppet code below your file resource:

{% highlight puppet %}
service { 'sshd':
  ensure     => running,
  enable     => true,
  subscribe  => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

{% task 2 %}
We now have our Puppet code in the sshd_config file, but it's useless until we add it to the `site.pp` manifest so that the puppet agent can manage those resources. Copy and paste the code you just wrote in the sshd_config file into the `site.pp` manifest.

{% task 3 %}
Let's make sure the syntax is correct in our `site.pp` manifest is correct. Remember `puppet parser`? If not, refer back to the Manifest Quest.

{% task 4 %}
Once your syntax is error free, enforce the `site.pp` manifest using the `puppet apply` tool. If you're not sure how to do this, refer to the Manifest Quest.

{% task 5 %}
Now you need to go back into for your sshd_config file (`/etc/ssh/sshd_config`). We need to change the `PermitRootLogin` from `yes` to `no`.

{% task 6 %}
Manually restart the sshd service by typing the following command:

	service sshd restart

Finally you will need to log out then log back in to see the changes.

In the above example, the `service` resource with the title `sshd` will be applied **after** the `file` resource with the title `/etc/ssh/sshd_config`. Furthermore, if any other changes are made to the targeted file resource, the service will refresh.

## Package/File/Service

The **package/file/service** pattern is one of the most useful idioms in Puppet. 

- The package resource makes sure the software and its config file are installed.
- The file resource config file depends on the package resource.
- The service resources subscribes to changes in the config file.

It’s hard to overstate the importance of this pattern! If you only stopped here and learned this, you could still get a lot of work done using Puppet.

Wait a minute! What about the package resource that manages the `openssh-server`? We haven't added that yet. To stay consistent with the package/file/service idiom, let's dive back into the sshd_config file  and add the `openssh-server` package to it

{% highlight puppet %}
package { 'openssh-server':
  ensure => present,
  before => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

{% aside Quest Progress %}

Make sure the package information stays consistent with the package/file/service structure. Add the package information above the File and Service resources.

{% endaside %}

Make sure to check the syntax.  
Also, don't forget to add that code to the `site.pp` manifest!  
Once everything looks good, go ahead and restart the sshd service.

	HINT: Look at task Task 6

It's a thing of beauty isn't it?

## Let's do a Quick Review

Up until this point you've been on a journey towards learning Puppet. To be successful it is imperative you understand the fundamental components of using Puppet: Resources and Manifests. Before we progress any further, it is important that you reflect on your understanding of these components. Feel free to read through the Resources Quest and/or Manifest Quest again if you feel like you could use a refresher. 

Furthermore, Puppet manifests are highly flexible and scalable components to stabilizing and maximizing your infrastructure. To customize that stabilization, we examined Classes, Variables, Facts, Conditional Statements and Resource Ordering. It is important that you understand when and how these components are used in Puppet manifests. Again, if you could use a refresher on these topics, it could be good to go back and read through these quests again.
