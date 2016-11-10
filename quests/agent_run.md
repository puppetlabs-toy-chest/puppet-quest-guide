{% include '/version.md' %}

# Agent run

## Quest objectives

- Understand the process of a Puppet agent run.
- List and sign agent certificates.
- Use the **site.pp** manifest to classify a node.

## Get started

> Quotation

> - Sayer of quotation

In this quest,

Ready to get started? Run the following command on your Learning VM:

    quest begin puppet_code

## Running the Puppet agent

The `puppet resource` command you explored in the previous quest gave you a
window into Puppet's resource abstraction, but by itself, this tool doesn't
offer considerable advantage over native commands or scripting. The real
benefit of Puppet's RAL is as an interface for centralization and automation.

Let's walk through a Puppet agent run so you can understand how your agent node
communicates with the Puppet master server.

First, let's take a moment to talk about certification. Certification is key to
making Puppet secure. While all communications between an agent and master
happen over SSL, the master needs a way to validate that a node is authentic.
This prevents unauthorized nodes from getting access to passwords or other
sensitive data by requesting configuration details from the master. (Puppet
provides options for further security by allowing you to encrypt sensitive data
in your Puppet code.)

To authenticate your agent node to the Puppet master, you must sign its
certificate.

<div class = "lvm-task-number"><p>Task 12:</p></div>

First, try to trigger a Puppet agent run without your agent node's certificate
signed. The agent will attempt to contact the Puppet master, but its request
will be rejected.

    sudo puppet agent -t

You'll see a notification like the following:

    Exiting; no certificate found and waitforcert is disabled

No problem, you just have to sign the certificate. For now, we'll show you how
to do it from the command line, but if you prefer a GUI, the PE console
includes tools for certificate management.

<div class = "lvm-task-number"><p>Task 13:</p></div>

First, exit your SSH session to return to the your Puppet master node.

    exit

Use the `puppet cert` tool to list unsigned certificates.

    puppet cert list

Sign the cert for `hello.puppet.vm`.

    puppet cert sign hello.puppet.vm

<div class = "lvm-task-number"><p>Task 14:</p></div>

With that taken care of, the Puppet agent on your node will be able to contact
the Puppet master to get a compiled catalog of all the resources on the system
it needs to manage. By default, the Puppet agent will do this every thirty
minutes to automatically keep your infrastructure in line. Because it would be
difficult to demonstrate much with these scheduled background runs, however,
we have disabled these periodic agent runs. Instead, you will use the `puppet
agent -t` command to trigger a run manually.

Go ahead and reconnect to your agent node:

    ssh learning@hello.puppet.vm

Trigger another agent run. With the certificate signed, you'll see some
action.

    sudo puppet agent -t

While you haven't yet told Puppet to manage any resources on the system, you'll
see a lot of text scroll by. Most of what you see is a process is called
pluginsync. During pluginsync, your agent checks to ensure that all the tools
its using match up with what the Puppet master expects.

This pluginsync process adds a lot of clutter. Without it, you'd see something
like the following.

```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for hello.puppet.vm
Info: Applying configuration version '1464919481'
```

Though this output only shows a few of the things the Puppet agent is doing, it
gives you a few clues about the conversation between the agent and master. For
now, we'll focus on two key steps in this conversation.

First, the agent node collects a set of **facts** about the system where it's
running, and sends them to the Puppet master. The master takes these facts and
uses them with your Puppet code to compile a **catalog**.

Puppet code consists largely of the resource declarations you used in the
previous quest, but it can also make use of language features such as
conditionals and variables that help determine the set of resources you want on
a system. We'll go into these language features in more depth in a later quest.
For now, you just need to know that the **catalog** is the final parsed list of
resources that the Puppet master sends back to the agent node to be applied.

![image](../assets/SimpleDataFlow.png)

When you triggered a Puppet run just now, the Puppet master didn't find any
Puppet code to apply to your agent node, so it didn't make any changes (other
than those involved in pluginsync). To make anything happen, we need to
describe a desired state for `hello.puppet.vm`.

<div class = "lvm-task-number"><p>Task 15:</p></div>

End your SSH session to return to the Puppet master:

    exit

In the next quest, we'll cover the structure of manifests, classes and modules,
used to organize Puppet code. For the same of demonstration, however, we'll
take a short-cut and write a resource declaration directly into your `site.pp`
manifest. This manifest is one of the ways you can tell the Puppet master to
apply code to a node. Go ahead and open your `site.pp` manifest.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

First, we'll create block of code called a node delcaration.

```puppet
node hello.puppet.vm {

}
```

When a Puppet agent contacts the Puppet master, it checks for a node
declarations in the `site.pp` manifest that matches the Agent node's domain.

The master then uses the Puppet code contained in any matching node
declarations to compile a catalog.

For now, we'll use a resource type called `notify` that will display a message
in the output of the Puppet run without making any changes to the system. The
notify resource

```puppet
node hello.learning.puppetlabs.vm {
  notify { 'Hello Puppet!':
    message => 'Hello Puppet!',
  }
}
```

(While you'll learn the syntax more quickly if you type your code manually, if
you do want to paste content into Vim, you can hit `ESC` to enter command mode
and type `:set paste` to disable the automatic formatting. Be sure to press `i`
to return to insert mode before pasting your text.)

Remember, use `ESC` then `:wq` to save and exit.

<div class = "lvm-task-number"><p>Task 17:</p></div>

Now SSH to your agent node:

    ssh learningt@hello.puppet.vm

And trigger another puppet run

    sudo puppet agent -t

The output will include something like this:

    Notice: Hello Puppet!
    Notice: /Stage[main]/Main/Node[hello.learning.puppetlabs.vm]/Notify[Hello Puppet!]/message: defined 'message' as 'Hello Puppet!'
    Notice: Applied catalog in 0.45 seconds

## Review

We introduced the role of certificates in the master/agent relationship, and
the communication that takes place during a puppet agent run. Finally, you
defined a `notify` resource in the master's `site.pp` manifest and triggered
a puppet agent run on the agent node to enforce that configuration.
