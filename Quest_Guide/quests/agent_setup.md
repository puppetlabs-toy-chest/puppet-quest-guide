---
title: Agent Node Setup
layout: default
---

# Agent Node Setup

## Quest objectives

- Learn how to install the puppet agent on a node.
- Use the PE console to sign the certificate of a new node.
- Understand a simple Puppet architecture with a puppet master
  serving multiple agent nodes.
- Use the `site.pp` manifest to classify nodes.

## Getting Started

So far, you've been running both the puppet agent and master on the Learning VM.
Though you certainly can use puppet to configure your puppet master server,
most of the work you'll be doing with puppet will be on separate nodes.

In this quest, we'll use a tool called `docker` to simulate multiple nodes
on the Learning VM. With these new nodes, you can learn how to install the puppet
agent, sign the certificates of your new nodes to allow them to join your puppetized
infrastructure, and finally use the `site.pp` manifest to apply some simple
puppet code on these new nodes.

When you're ready to get started, type the following command:

    quest --start agent_node_setup

## agent node setup

> A quote

> -The person who said it

So far, we've been using two different puppet commands to apply our puppet code:
`puppet apply`, and `puppet agent -t`. If you haven't felt confident about the
distinction between these two commands, it could be because we've been doing
everything on a single node where the difference between applying changes
locally and involving the puppet master clear. Let's take a moment to review.

`puppet apply` compiles a catalog based on a specified manifest and applies that
catalog locally. Any node with the puppet agent installed can run a `puppet apply`
locally. You can get quite a bit of use from `puppet apply` if you want to use
puppet on an agent without involving a puppet master server. For example, if you
are doing local testing of puppet code or experimenting with a small infrastructure
without a master server.

`puppet agent -t` triggers a puppet run. This puppet run is a conversation between
the agent node and the puppet master. First, the agent sends a collection of facts
to the puppet master. The master takes these facts and uses them to determine what
puppet code should be applied to the node. You've seen two ways that this
classification can be configured: the `site.pp` manifest and the PE console node
classifier. The master then evaluates the puppet code to compile a catalog that
describes exactly how the resources on the node should be configured. The master
sends that catalog to the agent on the node, which applies it. Finally, the agent
sends its report of the puppet run back to the master. Though we have disabled
automatic puppet runs on the Learning VM, they are scheduled by default to happen
automatically every half hour.

Though you only need a single node to learn to write and apply puppet code, getting
the picture of how the puppet agent and master nodes communicate will be much
easier if you actually have more than one node to work with.

### docker docker docker

We've created a `multi_node` module that will set up a pair of docker containers
to act as additional agent nodes in your infrastructure. (Keep in mind that while
running a puppet agent on a docker container on a VM will work as a learning tool,
it isn't a recommended way to set up your puppet infrastructure.)

{% task 1 %}
---
- execute:
    - vim /etc/puppetlabs/code/environments/production/manifests/site.pp
    - /node default {\rOnode learning.puppetlabs.vm {\r  include multi_node\r}
    - :wq
{% endtask %}

To apply the `multi_node` class to the Learning VM, add it to the
`learning.puppetlabs.vm` node declaration in your master's `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Insert `include multi_node` into the `learning.puppetlabs.vm` node declaration.

{% highlight puppet %}
node learning.puppetlabs.vm {
  include multi_node
}
{% endhighlight %}

(Note that it's important that you don't put this in your `default` node
declaration. If you did, you'd start creating docker containers on your
docker containers every time you did a puppet run!)

{% task 2 %}
---
- execute: puppet agent -t
{% endtask %}

Not trigger an agent run to apply the class:

  puppet agent -t



## Review

Review
