{% include '/version.md' %}

# Facts

## Quest objectives

 - Learn how to use the `facter` tool to access system information.
 - Use the `facts` hash to incorporate system information into your Puppet code.

## Getting started

The class parameters you learned about in the previous quest let you reduce
many of the tasks involved in configuring an application (or whatever system
component your module manages) to a single, well-defined interface. You can
make your life even easier by writing a module that will automatically use
available system data to set some of its variables.

In this quest, we'll discuss `facter`. The
`facter` tool allows Puppet to automatically access information about the
system where an agent is running as variables within your Puppet manifest.

As you'll see in this quest, these facts can be quite useful on their own. In
the next quest, you will see how they can be used along with *conditional
statements* to let you write Puppet code that will behave differently in
different contexts.

To start this quest enter the following command:

    quest begin facts

## Facter

>Get your facts first, then distort them as you please.

> -Mark Twain

You already encountered the `facter` tool when we asked you to run `facter
ipaddress` in the setup section of this Quest Guide. We briefly discussed
the tool's role in a Puppet run: the Puppet agent runs `facter` to get a list
of facts about the system to send to the Puppet master as it requests a
catalog. The Puppet master then uses these facts to help compile that catalog
before sending it back to the Puppet agent to be applied.

Before we get into integrating facts into your Puppet code, let's use the
`facter` tool from the command line to see what kinds of facts are available
and how they're structured.

<div class = "lvm-task-number"><p>Task 1:</p></div>

First, connect to the agent node prepared for this quest.

    ssh learning@pasture.puppet.vm

You can access a standard set of facts with the `facter` command. Adding the
`-p` flag will include any custom facts that you may have installed on the
Puppet master and synchronized with the agent during the pluginsync step of a
Puppet run. We'll pass this `facter -p` command to `less` so you can scroll
through the output in your terminal.
	
    facter -p | less

When you're done, press `q` to quit `less`.

Notice that the output of this command is shown as a hash. Some facts, such as
`os` include data in a nested JSON format.

    facter -p os

You can drill down into this structure by using dots (`.`) to specify the key
at each child level of the hash, for example:

    facter -p os.family

Now that you know how to check what data are available via `facter` and how the
data are structured, let's return to the Puppet master so you can see how this
can be integrated into your Puppet code.

    exit

All facts are automatically made available within your manifests. You can
access the value of any fact via the `$facts` hash, following the
`$facts['fact_name']` syntax. To access structured facts, you can chain more
names using the same bracket indexing syntax. For example, the `os.family` fact
you accessed above is available within a manifest as `$facts['os']['family']`.

Let's take a break from the Pasture module you've been working on. Instead,
we'll create a new module to manage an MOTD (Message of the Day) file. This
file is commonly used on \*nix systems to display information about a host when
a user connects. Using facts will allow you to create a dynamic MOTD that can
display some basic information about the system.

Creating a new module will also help review some of the concepts you've learned
so far.

<div class = "lvm-task-number"><p>Task 2:</p></div>

From your `modules` directory, create the directory structure for a module
called `motd`. You'll need two subdirectories called `manifests` and
`templates`.

    mkdir -p motd/{manifests,templates}

<div class = "lvm-task-number"><p>Task 3:</p></div>

Begin by creating an `init.pp` manifest to contain the main `motd` class.

    vim motd/manifests/init.pp

This class will consist of a single `file` resource to manage the `/etc/motd`
file. We'll use a template to set the value for this resource's `content`
parameter.

```puppet
class motd {

  $motd_hash = {
    'fqdn'       => $facts['networking']['fqdn'],
    'os_family'  => $facts['os']['family'],
    'os_name'    => $facts['os']['name'],
    'os_release' => $facts['os']['release']['full'],
  }

  file { '/etc/motd':
    content => epp('motd/motd.epp', $motd_hash),
  }

}
```

The `$facts` hash and top-level (unstructured) facts are automatically loaded
as variables into any template. To improve readibility and reliability, we
strongly suggest using the method shown here. Be aware, however, that
you will likely encounter templates that refer directly to facts using the
general variable syntax rather than the `$facts` hash syntax we suggest here.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Now create the `motd.epp` template.

    vim motd/templates/motd.epp

Begin with a parameters tag to make the set of variables used in the template
explicit. Note that the MOTD is a plaintext file without any commenting syntax,
so we'll leave out the conventional "managed by Puppet" note.

```
<%- | $fqdn,
      $os_family,
      $os_name,
      $os_release,
| -%>
```

Next, add a simple welcome message and use the variables assigned from our fact
values to provide some basic information about the system.

```
<%- | $fqdn,
      $os_family,
      $os_name,
      $os_release,
| -%>
Welcome to <%= $fqdn %>

This is a <%= $os_family %> system running <%= $os_name %> <%= $os_release %>

```

<div class = "lvm-task-number"><p>Task 5:</p></div>

With this template set, your simple MOTD module is complete. Open your
`site.pp` manifest to assign it to the `pasture.puppet.vm` node. 

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

We're not using any parameters, so we'll use the `include` function to add the
`motd` class to the `pasture.puppet.vm` node definition.

```puppet
node 'pasture.puppet.vm` {
  include motd
  class { 'pasture':
    default_character => 'cow',
  }
}
```

<div class = "lvm-task-number"><p>Task 6:</p></div>

Once this is complete, connect again to the `pasture.puppet.vm` node.

    ssh learning@pasture.puppet.vm

And trigger a Puppet agent run.

    sudo puppet agent -t

To see the MOTD, first disconnect from `pasture.puppet.vm`.

    exit

Now reconnect.

    ssh learning@pasture.puppet.vm

Once you've had a chance to admire the MOTD, return to the Puppet master.

    exit

## Review

In this quest, we introduced the `facter` tool and provided an overview of how
this tool can be used to access a structured set of system data.

We then showed you how to access facts from within a Puppet manifest and assign
the values of these facts to variables. Using data from Facter, you created a
template to manage a MOTD file.

In the next quest, we'll show you how you can add further flexibility to your
Puppet code with *conditional statements*. We'll give you an example of how
these facts can be used in conjunction with these conditional statements to
create intelligent defaults based on system information.

## Additional Resources

* Check out our [docs page](https://docs.puppet.com/puppet/latest/lang_facts_and_builtin_vars.html) for more information on facter and facts in Puppet.
* You can also find a [lesson on Facter](https://learn.puppet.com/elearning/an-introduction-to-facter) in our [self-paced training course catalog](https://learn.puppet.com/category/self-paced-training).
* Facts are covered in-depth in our Puppet Fundamentals, Puppet Practitioner, and Puppetizing Infrastructure courses. Explore our [in-person](https://learn.puppet.com/category/instructor-led-training) and [online](https://learn.puppet.com/category/online-instructor-led-training) training options for more information.
