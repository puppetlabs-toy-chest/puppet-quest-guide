---
title: Ordering
layout: default
---

# Resource Ordering

### Prerequisites

- Resources Quest
- Mainfest Quest
- Classes Quest
- Varibales Quest
- Conditions Quest

## Quest Objectives

The tasks we will accompish in this quest will help you learn more about specifying the order in which Puppet should manage the resources in a manifest. If you're ready to get started, type the following command:

	quest --start ordering

## Explicit Ordering

You are likely use to reading instructions from top to bottom. If you wish to master the creation of Puppet manifests you must learn to think of ordering in a different way. Rather than processessing instructions from top to bottom, Puppet interprets the resource declarations in a manifest in whatever order is most effecient.

If necessary, you will need to ensure that a resource declaration is applied before another. For instance, if you wish to declare in a manifest that a service should be running, you need to ensure that the package for that service is already installed and configured beforehand.

If you require that a group of resources be managed in a specific order, you must explicitly state the dependency relationships between these resources within the resource declarations.

## Relationship Metaparameters

{% fact %}
In Puppet's DSL, a resource metaparamter is a variable that doesn't refer directly to the state of a resource, but rather tells Puppet how to process the resource declaration itself.
{% endfact %}

There are four metaparameter attributes that you can include in your resource declaration to establish order relationships among resources. The value of any relationship metaparameter should be the title or titles (in an array) of one or more target resources.

* `before` - causes a resource to be applied **before** a target resource.
	
* `require` - causes a resource to be applied **after** a target resouroce.

* `notify` - causes a resource to be applied **before** the target resource. The target resource will refresh if the notifying resource changes.

* `subscribe` - causes a resource to be applied **after** the target resource. The subscribing resource will refresh if the target resource changes.

These parameters are included in a resource declaration just like any other attribute value pair. For instance, refer to the following example:

{% highlight ruby %}
service { 'sshd':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/ssh/sshd_config'],
}
{% endhighlight %}

In the above example, the `service` resource with the title `sshd` will be applied **after** the `file` resource with the title `/etc/ssh/sshd_config`. Furthermore, if any other changes are made to the targeted file resource, the service will refresh.

{% task 1 %}


## Let's do a Quick Review

Up until this point you've been on a journey towards learning Puppet. To be successful it is imperative you understand the fundatmental components of using Puppet: Resources and Manifests. Before we progress any further, it is important that you reflect on your understanding of these components. Feel free to revisit those quests should you not fully grasp the information. 

Furthermore, Puppet manifests are highly scable components to stablizing and maximizing your infrastructure. To customize that stablization, we examined Classes, Variables, Facts, Conditional Statements and Resource Ordering. It is important that you understand when and how these components are used in Puppet manifests. Should you be in doubt of your understanding, please revisit those quests. 
