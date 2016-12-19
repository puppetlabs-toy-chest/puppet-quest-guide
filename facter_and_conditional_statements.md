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



## Review

TBD
