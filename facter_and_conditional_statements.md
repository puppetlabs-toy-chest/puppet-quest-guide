{% include '/version.md' %}

# Facter and Conditional Statements

## Quest objectives

- TBD
- TBD 

## Getting started

To make a Puppet module adaptable, you will often want to use more than the
values passed in explicitly as parameters. A tool called **Facter** provides
access to a rich set of **facts** about the system where the Puppet agent is
running. Facts and class parameters can be used with **conditional statements**
to build Puppet code flexible enough to handle a wide variety of applications,
environments, and operating systems.

When you're ready to get started, enter the following command:

    quest begin forge_modules

## Facter

[Facter](https://docs.puppet.com/facter/) is one of the open-source projects at
the core of the Puppet ecosystem. It is a cross-platform system profiling
library that provides a set of data, called **facts**, about the details of
your system. While facter is integrated into Puppet, you can also use it
directly from the command line. This can be useful to check facts during Puppet
module development, or simply to access information about a system where you
may not be familiar with the native commands. 

It's very common to use Facter in a Puppet class to determine the OS where the
class is being applied.

Take a look at the `os` fact:

    facter os

Notice that the output is structured and returned in a JSON format. From the
command-line, you can drill down into this data structure by putting a dot
between your values. Let's use this syntax to check the OS family fact:

    facter os.family

Facter will output the Learning VM's OS family fact value:

    RedHat

Before moving on to using these facts in a Puppet manifest, let's take a look
at the range of facts available. Pass the `facter` command to `less` so you can
scroll through the full output. When you're done, use `q` to exit.

    facter | less

If you prefer an online reference, you can refer to the [Core
Facts](https://docs.puppet.com/facter/latest/core_facts.html) docs page.

(Note that custom facts introduced by Puppet modules will be visible on the
command-line through the `puppet facts` command, rather than the `facter`
command. Custom facts won't be covered here, but you can refer to the [docs
page](https://docs.puppet.com/facter/3.5/custom_facts.html) for more
information.)

## Accessing facts

A hash of all facts is automatically available in any Puppet manifest. You can
use `$facts['fact_name']` to access the value of `fact_name` anywhere you
would any other variable. (You may also see facts referenced to directly as
`$fact_name`, especially in older modules. While this direct reference will
result in the same value, we now prefer the more explicit `$facts['fact_name']`
syntax to clearly distinguish facts from other variables.)

You can access structured facts in a similar way, for example, you can access
the `os.family` fact in a manifest with `$facts['os']['family']`. (Note how
this hash syntax differs from the `os.family` syntax used with the command-line
Facter tool.)

Remember the vhost resource you used in your `cowsay::webserver` class? It
looked like this:

```puppet
apache::vhost { 'webserver.puppet.vm':
  port    => '80',
  docroot => $docroot,
}
```

Having this kind of data hard-coded into your module will cause problems when
you try to apply your module on a system with a different hostname. While you
could set this with a parameter using Facter will allow Puppet to automatically
set this to the system's hostname. (Actually the most robust solution would
likely be to set the fact as a parameter default so that it could also be set
explicitly, but using the fact directly will suffice in this case.)

Go ahead and open your `webserver.pp` manifest:

    vim cowsay/manifests/webserver.pp

Replace the title of the `apache::vhost` resource with `$facts['fqdn']`.

```puppet
  [...]
  apache::vhost { $facts['fqdn']:
    port    => '80',
    docroot => $docroot,
  }
  [...]
```

Use the `puppet parser` tool to check your syntax.

    puppet parser validate cowsay/manifests/webserver.pp

We've set up an agent node at `webserver01.puppet.vm`. To try out the changes
to your class, you'll have to change your node declaration to be a little bit
more flexible as well. Instead of using a simple string to define your node
block, you can use a regular expression. We'll want to include anything that
matches "webserver" followed by zero or more digits, then ".puppet.vm".

Open your `site.pp` manifest:

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

And change your node declaration to look like this:

```puppet
node /webserver\d*\.puppet\.vm/ {
  class { 'cowsay':
    docroot => 'var/www/cowsay/',
  }
}
```

Note that we use forward slashes (`/`) instead of single quotes (`'`) to
indicate a regular expression. Also, remember that some characters (such as
`.`) have to be escaped with a backslash (`\`) in a regular expression to
distinguish them from regular expression characters with a special meaning. (It
can be useful to use an external site like [rubular](http://rubular.com/) to
quickly validate that your regular expressions work as expected. Also note that
Puppet uses a Ruby flavor of regular expression, which differs a bit from other
flavors such as Perl.)

Now that your `webserver01` is classified, connect to it.

    ssh learning@webserver01.puppet.vm

And trigger a Puppet agent run.

    sudo puppet agent -t

After the run completes, open a web browser on your host system and navigate
to:

    http://<VM's IP Address>/webserver01

Is your cow enjoying its new pastures?

## Conditional Statements

While a fact (like the `fqdn` fact you just used) can sometimes be passed
directly to a resource declaration, you'll often want to use the value of a
fact to decide how to set a new variable or even decide which resource or set
of resources should be applied to an agent node.

To do this, you need to use a **conditional statement**. There are four forms
of conditional statement in the Puppet language: "If" statements, "Unless"
statements, Case Statements, and Selectors. In this quest, we'll be focused on
the "If" statements. All of these forms of conditional statement are very
similar, so once you understand the basic principal, a quick look at the
[docs](https://docs.puppet.com/puppet/latest/lang_conditional.html) will be
enough to understand the other forms.



## Review

TBD
