---
title: Resources
layout: default
---

# Resource Ordering

In this quest you will learn how to specify the order in which Puppet should manage the resources in a manifest.

## Order Agnosticism

You are likely used to reading instructions from top to bottom. To accomidate this habit, this Quest Guide itself follows that format. If you wish to master the Puppet arts, you must learn to see past this habit; Puppet has no regard for the order of resources in a manifest, and will manage resources in whatever order is most effecient.

Often, however, you will need to ensure that once resource declaration is applied before another. For instance, to run a service, you may first need to ensure that the package for that service is installed and configured.

If you require that a group of resources be managed in a specific order, you must to explicitly declare the dependency relationships between these resources.

## Relationship Metaparameters

There are four metaparameter attributes that you can include in your resource declaration in order to establish order relationships among resources. The value of any relationship metaparameter should be the title or titles (in an array) of one or more target resources.

* `before`
	
	Causes a resource to be applied **before** a target resource.
	
* `require`

	Causes a resource to be applied **after** a target resouroce.

* `notify`

	Causes a resource to be applied **before** the target resource. The target resource will refresh if the notifying resource changes.

* `subscribe`

	Causes a resource to be applied **after** the target resource. The subscribing resource will refresh if the target resource changes.

{% highlight ruby %}
service { 'sshd':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}