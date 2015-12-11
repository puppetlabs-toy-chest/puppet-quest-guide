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

So far, you've been managing one node, the Learning VM, which is running the
puppet master server itself. Though you certainly would use puppet to configure
the puppet master server, most of the nodes in your puppetized infrastructure will
run only the puppet agent.

In this quest, we'll use a tool called `docker` to simulate multiple nodes
on the Learning VM. With these new nodes, you can learn how to install the puppet
agent, sign the certificates of your new nodes to allow them to join your puppetized
infrastructure, and finally use the `site.pp` manifest to apply some simple
puppet code on these new nodes.

When you're ready to get started, type the following command:

    quest --start agent_node_setup

## Get Some Nodes

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

### Containers

We've created a `multi_node` module that will set up a pair of docker containers
to act as additional agent nodes in your infrastructure. Note that docker is not
a part of puppet; it's an open-source tool we're using to build a multi-node
learning environment. Running a puppet agent on a docker container on a
VM gives us a convenient way to see how Puppet works on multiple nodes, but
keep in mind that it isn't a recommended way to set up your Puppet infrastructure!

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
declaration. If you did, puppet would try to create docker containers on your
docker containers every time you did a puppet run!)

{% task 2 %}
{% endtask %}

Now trigger an agent run to apply the class. Note that this might take a little
while to run.

  puppet agent -t

Once this run has completed, you can use the `docker ps` command to see your two
new nodes. You should see one called `database` and one called `webserver`.

### install the puppet agent

Now you have two fresh nodes, but you don't have the puppet agent installed on
either! Installing the agent will be the first step of getting these nodes into
our puppet infrastructure.

{% task 3 %}
{% endtask %}

In most cases, the simplest way to install an agent is to use the `curl`
command to transfer an installation script from your puppet master and
execute it. Because our agents are running an Ubuntu system, we'll first
need to make sure that our puppet master has the correct script to provide.

Navigate to `https://<VM's IP address>` in your browser address bar. Use the
following credentials to connect to the console:

* username: **admin**
* password: **puppetlabs**

In the **Nodes** > **Classification** section, click on the **PE Master** node
group. Under the **Classes** tab, enter `pe_repo::platform::ubuntu_1404_amd64`.
Click the **Add class** button and commit the change.

Trigger a puppet agent run on your puppet master.

  puppet agent -t

For easy reference, you can find the `curl` command needed to install the
puppet agent in the *Nodes* > *Unsigned Certificates* section of the PE console:

  curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash

Ordinarily, you would probably use `ssh` to connect to your agent nodes and
run this command. Because we're using docker, however, the way we connect will
be a little different. To connect to your `webserver` node, run the following
command to execute an interactive bash session on the container.

  docker exec -it webserver bash

Paste in the `curl` command from the PE console to install the puppet agent
on the node. The installation may take a few minutes. When it completes, end your
bash process on the container:

  exit

And repeat the process with your database node:

  docker exec -it database bash

Now you have two new nodes with the puppet agent installed. 

While you're still in a bash session on the database node, you can try out
a few commands.

{% task 4 %}
---
- execute: puppet agent -t
{% endtask %}

Let's use facter to get some information about this node:

  facter operatingsystem

You can see that though the Learning VM itself is running CentOS, our new nodes
run Ubuntu.

  facter certname

We can also see that this node's certname is `database.learning.puppetlabs.vm`. This
is how we can identify the node in the PE console or the `site.pp` manifest on
our master.

{% task 5 %}
---
- execute: puppet agent -t
{% endtask %}

We can use the puppet resource tool to easily create a new test file.

  puppet resource file /tmp/test ensure=file

You'll see your new file created.

  Notice: /File[/tmp/test]/ensure: created
  file { '/tmp/test':
    ensure => 'file',
  }

{% task 6 %}
---
- execute: puppet agent -t
{% endtask %}

You can also use the `puppet apply` command to apply the contents of a manifest.
Create a simple test manifest to give it a try.

  vim /tmp/test.pp

We'll define a simple message:

{% highlight puppet %}
  notify { "Hi, I'm a manifest applied locally on an agent node": }
{% endhighlight %}

And apply it:

  puppet apply /tmp/test.pp

You should see the following output:

  Notice: Compiled catalog for database.learning.puppetlabs.vm in environment production in 0.32 seconds
  Notice: Hi, I'm a manifest applied locally on an agent node!
  Notice: /Stage[main]/Main/Notify[Hi, I'm a manifest applied locally on an agent node!]/message: defined 'message' as 'Hi, I'm a manifest applied locally on an agent node!'
  Notice: Applied catalog in 0.02 seconds

{% task 4 %}
---
- execute: puppet agent -t
{% endtask %}

So that's what you can do on an agent node, but what are the differences?
First, let's take a look at the directory where you'd find all your puppet
code on the master. Check:

  ls /etc/puppetlabs/code/environments/production/manifests

and

  ls /etc/puppetlabs/code/environments/production/modules

There's nothing there—no modules or `site.pp` manifest. Unless you're doing
local development and testing of a module, the Puppet code for your infrastructure
is kept on the puppet master node, not on each individual agent. When a puppet run
is triggered—either as scheduled or manually with the `puppet agent -t` command,
it is the puppet master that compiles your puppet code into a catalog to be applied
on your agent node.

Let's give it a try. Trigger a puppet run on your `database` node.

  puppet agent -t

You'll see that instead of completing a puppet run, puppet exits with the
following message:

  Exiting; no certificate found and waitforcert is disabled

### Certificates

The puppet master keeps a list of signed certificates for each node in your
infrastructure. This helps keep your infrastructure secure and prevents
puppet from making unintended changes to systems on your network.

{% task 4 %}
{% endtask %}

Before you can run puppet on your new agent nodes, you need to sign their certificates
on the puppet master. If you're still connected to your agent node, return to the master:

  exit

Use the `puppet cert list` command to list the unsigned certificates. (You could
also view and sign these from the inventory page of the PE console.)

  puppet cert list

Now sign each of your nodes' certificates:

  puppet cert sign webserver.learning.puppetlabs.vm

and

  puppet cert sign database.learning.puppetlabs.vm

Now your certificates are signed, so your new nodes will be managed by puppet.
To test this out, let's add a simple `notify` resource to the `site.pp` manifest
on the master.

  vim /etc/puppetlabs/code/environments/production/manifests/site.pp

Find the `default` node declaration, and edit it to add a `notify` resource
that will tell us some basic information about the node.

{% highlight puppet %}
node default {
  notify { "This is ${::certname}, running the ${::operatingsystem} operating system": }
} 
{% endhighlight %}

Now connect to our database node again.

  docker exec -it database bash

And try another puppet run:

  puppet agent -t

## Review
