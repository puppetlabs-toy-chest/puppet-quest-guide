---
title: Resource Ordering
layout: default
---

# Resource Ordering

In this quest you will learn how to specify the order in which Puppet should manage the resources in a manifest.

## Explicit Ordering

You are likely used to reading instructions from top to bottom. If you wish to master the creation of Puppet manifests, however, you must learn think of ordering in a different way. Rather than processessing instructions from top to bottom, Puppet interprets the resource declarations in a manifest in whatever order is most effecient.

Often, however, you will need to ensure that once resource declaration is applied before another. For instance, if you wish to declare in a manifest that a service should be running, you need to ensure that the package for that service is already installed and configured.

If you require that a group of resources be managed in a specific order, you must to explicitly state the dependency relationships between these resources within the resource declarations.

## Relationship Metaparameters

{% fact %}
In Puppet's DSL, a resource metaparamter is a variable that doesn't refer directly to the state of a resource, but rather tells Puppet how to process the resource declaration itself.
{% endfact %}

There are four metaparameter attributes that you can include in your resource declaration in order to establish order relationships among resources. The value of any relationship metaparameter should be the title or titles (in an array) of one or more target resources.

* `before`
	
	Causes a resource to be applied **before** a target resource.
	
* `require`

	Causes a resource to be applied **after** a target resouroce.

* `notify`

	Causes a resource to be applied **before** the target resource. The target resource will refresh if the notifying resource changes.

* `subscribe`

	Causes a resource to be applied **after** the target resource. The subscribing resource will refresh if the target resource changes.

These parameters are included in a resource declaration just like any other attribute value pair. For instance, refer to the following example:

{% highlight ruby %}
service { 'sshd':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

Here, the service resource with the title 'sshd' will be applied **after** the file resource with the title '/etc/ssh/sshd_config'. Furthermore, if any other changes are made to the targeted file resource, the service will refresh.
