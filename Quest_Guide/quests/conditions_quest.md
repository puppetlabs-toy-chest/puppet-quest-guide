---
title: Conditions
layout: default
---

# Conditional Statements

### Prerequisites

- Welcome
- Power of Puppet
- Resources
- Manifests and Classes
- Modules
- Variables and Class Parameters

## Quest Objectives
 - Learn how to use conditional logic to make your manifests adaptable.
 - Understand the syntax and function of the `if`, `unless`, `case`, and
   `selector` statements.

## Getting Started

Conditional statements allow you to write Puppet code that will return different
values or execute different blocks of code depending on conditions you specify.
In conjunction with Facter, which makes details of a machine available as 
variables, this lets you write Puppet code that flexibly accomodates different
platforms, operating systems, and functional requirements.

To start this quest enter the following command:

    quest --start conditionals

## Writing for Flexibility

>The green reed which bends in the wind is stronger than the mighty oak which
>breaks in a storm.

> -Confucius

Because Puppet manages configurations on a variety of systems fulfilling a
variety of roles, great Puppet code means flexible and portable Puppet code.
While the *types* and *providers* that form the core of Puppet's *resource
abstraction layer* do a lot of heavy lifting around this kind of adaptation,
there are some things better left in the hands of competent practitioners rather
than hard-coded in Puppet itself.

As you move from general platform-related implementation details to specific
application-related implementation details, it starts making less sense to rely
on Puppet to make decisions automatically, and much more sense for a module
developer or user to make his or her own choices. 

It's sensible, for example, for Puppet's `package` providers to take care of
installing and maintaining packages. The inputs and outputs are standardized and
stable enough that what happens in between, as long as it happens reliably, can
be safely hidden by abstraction; once it's done, the details are no longer
important.

*What* package is installed, on the other hand, isn't something you can safely
forget. In this case, the inputs and outputs are not so neatly delimited. Though
there are often broadly equivalent packages for different platforms, the
equivalence isn't always complete; configuration details will often vary, and
these details will likely have to be accounted for elsewhere in your Puppet
module.

While Puppet's built-in providers can't themselves guarantee the portability of
your Puppet code at this higher level of implementation, Puppet's DSL gives you
the tools to build adaptability into your modules. **facts** and **conditional
statements** are the bread and butter of this functionality.

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

You already encountered the *facter* tool when we asked you to run
`facter ipaddress` in the setup section of this quest guide. While it's nice the
be able to run facter from the command line, its real utility is to make
information about a system available to use as variables in your manifests.

{% fact %}
While facter is an important component of Puppet and is bundled with Puppet
Enterprise, it's actually one of the many separate open-source projects
integrated into the Puppet ecosystem.
{% endfact %}

Combined with conditionals, which we'll get to in a moment, **facts** give you a
huge amount of power to write portability into your modules.

To get a full list of facts available to facter, enter the command:
	
    facter -p | less
	
Any of the facts you see listed here can be used within your Puppet code with
the syntax `$::factname`. The double colons `::` indicate that the fact is
defined in what's called *top scope*, that is, before any variables in your node
definitions or classes are assigned. While you could technically use a fact
without the `::`, you would risk having it mistakenly overridden by a locally
defined variable with the same name. The `::` tells Puppet to look directly in
the top scope instead of using the first variable it finds with a matching name.
The Puppet style guide suggests using this syntax consistently to avoid naming
collisions.

## Conditions

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Conditional statements return different values or execute different blocks of
code depending on the value of a specified variable. This is key to getting your
Puppet modules to perform as desired on machines running different operating
systems and fulfilling different roles in your infrastructure.

Puppet supports a few different ways of implementing conditional logic:
 
 * `if` statements,
 * `unless` statements,
 * case statements, and
 * selectors.

### The 'if' Statement

Puppet’s `if` statements behave much like those in many other programming and
scripting languages.

An `if` statement includes a condition followed by a block of Puppet code that
will only be executed **if** that condition evaluates as **true**. Optionally,
an `if` statement can also include any number of `elsif` clauses and an `else`
clause. Here are some rules:

- If the `if` condition fails, Puppet moves on to the `elsif` condition (if one
  exists).
- If both the `if` and `elsif` conditions fail, Puppet will execute the code in
  the `else` clause (if one exists).
- If all the conditions fail, and there is no `else` block, Puppet will do
  nothing and move on.

Lets say you want to give the user you're creating with your accounts module
administrative priveleges. You have a mix of CentOS and Debian systems in your
infrastructure. On your CentOS machines, you use the `wheel` group to manage
superuser privileges, while you use an `admin` group on the Debian machines.
With the `if` statement and the `operatingsystem` fact from facter, this kind of
adjustment is easy to automate with Puppet.

Before getting started, make sure you're working in the `modules` directory:

    cd /etc/puppetlabs/puppet/environments/production/modules
	
{% task 1 %}
---
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/accounts
- execute: mkdir /etc/puppetlabs/puppet/environments/production/modules/accounts/{manifests,tests}
{% endtask %}
	
Create an `accounts` directory:

    mkdir accounts
	
And your `tests` and `manifests` directories:

    mkdir accounts/{manifests,tests}
	
{% task 2 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/accounts/manifests/init.pp
  content: |
    class accounts ($name) {
      
      if $::operatingsystem == 'centos' {
        $groups = 'wheel'
      }
      elsif $::operatingsystem == 'debian' {
        $groups = 'admin'
      }
      else {
        fail( "This module doesn't support ${::operatingsystem}." )
      }

      notice ( "Groups for user ${name} set to ${groups}" )

      user { $name:
        ensure => 'present',
        home => "/home/${name}",
        groups => $groups,
      }

    }
{% endtask %}
	
Open the `accounts/manifests/init.pp` manifest in Vim.

At the beginning of the `accounts` class definition, you'll include some
conditional logic to set the `$groups` variable based on the value of the
`$::operatingsystem` fact. In both cases, you'll add the user the new group made
solely for that user, defined by the `$name` parameter. If the operating system
is CentOS, you'll also add the user to the `wheel` group, and if the operating
system is Debian you'll add the user to the `admin` group.

So the beginning of your class definition should looks something like this:

{% highlight puppet %}
class accounts ($name) {

  if $::operatingsystem == 'centos' {
    $groups = 'wheel'
  }
  elsif $::operatingsystem == 'debian' {
    $groups = 'admin'
  }
  else {
    fail( "This module doesn't support ${::operatingsystem}." )
  }
  
  notice ( "Groups for user ${name} set to ${groups}" )
 
  user { $name:
    ensure => 'present',
    home => "/home/${name}",
    groups => $groups,
  }

}
{% endhighlight %}

Note that the string matches are *not* case sensitive, so 'CENTOS' would work
just as well as 'centos'. Finally, in the `else` block, you'll raise a warning
that the module doesn't support the current OS.

Once you've written the conditional logic to set the `$groups` variable, edit
the `user` resource declaration to assign the `$groups` variable to the `groups`
attribute.

{% highlight puppet %}
class accounts ($name) {

  ...
  
  user { $name:
    ensure => 'present',
    home   => "/home/${name}",
    groups => $groups,
  }

  ...

}
{% endhighlight %}

Make sure that your manifest can pass a `puppet parser validate` check before
continuing on.

{% task 3 %}
---
- file: /etc/puppetlabs/puppet/environments/production/modules/accounts/tests/init.pp
  content: |
    class {'accounts':
      name => 'dana',
    }
{% endtask %}

Create a test manifest (`accounts/tests/init.pp`) and declare the accounts
manifest with the name parameter set to `dana`.

{% highlight puppet %}

class {'accounts':
  name => 'dana',
}

{% endhighlight %}

{% task 4 %}
---
- execute: FACTER_operatingsystem=Debian puppet apply --noop /etc/puppetlabs/puppet/environments/production/modules/accounts/tests/init.pp
{% endtask %}

The Learning VM is running CentOS, so to test what would happen on a Debian OS
you'll have to override the `operatingsystem` fact with a little environment
variable magic. To provide a custom value for any facter fact as you run a
`puppet apply`, you can include `FACTER_factname=new_value` before your new
terminal command.

Combining this with the `--noop` flag, you can do a quick test of how your
manifest would run on a different system before setting up a full testing
environment.

    FACTER_operatingsystem=Debian puppet apply --noop accounts/tests/init.pp
	
Look in the list of notices, and you'll see the changes that would have been
applied.

{% task 5 %}
---
- execute: FACTER_operatingsystem=Darwin puppet apply --noop /etc/puppetlabs/puppet/environments/production/modules/accounts/tests/init.pp
{% endtask %}

Try one more time with an unsupported operating system to check the fail
condition:

    FACTER_operatingsystem=Darwin puppet apply --noop accounts/tests/init.pp

{% task 6 %}
---
- execute: puppet apply /etc/puppetlabs/puppet/environments/production/modules/accounts/tests/init.pp
{% endtask %}

Now go ahead and run a `puppet apply --noop` on your test manifest without
setting the environment variable. If this looks good, drop the `--noop` flag to
apply the catalog generated from your manifest.

You can use the `puppet resource` tool to verify the results.

## The 'unless' Statement

The `unless` statement works like a reversed `if` statement. An `unless`
statements takes a condition and a block of Puppet code. It will only execute
the block **if** the condition is **false**. If the condition is true, Puppet
will do nothing and move on. Note that there is no equivalent of `elsif` or
`else` clauses for `unless` statements.

## The 'case' Statement

Like `if` statements, case statements choose one of several blocks of Puppet
code to execute. Case statements take a control expression, a list of cases, and
a series of Puppet code blocks that correspond to those cases. Puppet will
execute the first block of code whose case value matches the control expression.

A special `default` case matches anything. It should always be included at the
end of a case statement to catch anything that did not match an explicit case.

For instance, if you were setting up an Apache webserver, you might use a case
statement like the following:

{% highlight puppet %}
case $::operatingsystem {
  'CentOS': { $apache_pkg = 'httpd' }
  'Redhat': { $apache_pkg = 'httpd' }
  'Debian': { $apache_pkg = 'apache2' }
  'Ubuntu': { $apache_pkg = 'apache2' }
  default: { fail("Unrecognized operating system for webserver.") }
}

package { $apache_pkg :
  ensure => present,
}
{% endhighlight %}

This would allow you to always install and manage the right Apache package for a
machine's operating system. Accounting for the differences between various
platforms is an important part of writing flexible and re-usable Puppet code,
and it's a paradigm you will encounter frequently in published Puppet modules.

## The 'selector' Statement
Selector statements are similar to `case` statements, but instead of executing a
block of code, a selector assigns a value directly. A selector might look
something like this:

{% highlight puppet %}
$rootgroup = $::osfamily ? {
  'Solaris'  => 'wheel',
  'Darwin'   => 'wheel',
  'FreeBSD'  => 'wheel',
  'default'  => 'root',
}
{% endhighlight %}

Here, the value of the `$rootgroup` is determined based on the control variable
`$::osfamily`. Following the control variable is a `?` (question mark) symbol.
In the block surrounded by curly braces are a series of possible values for the
`$::osfamily` fact, followed by the value that the selector should return if the
value matches the control variable.

Because a selector can only return a value and cannot execute a function like
`fail()` or `warning()`, it is up to you to make sure your code handles
unexpected conditions gracefully. You wouldn't want Puppet to forge ahead with
an inappropriate default value and encounter errors down the line.

## Review

In this quest, you saw how you can use facts from the `facter` tool along with
conditional logic to write Puppet code that will adapt to the envoronment where
you're applying it.

You used an `if` statement in conjunction with the `$::osfamily` variable from
facter to determine how to set the group for an administrator user account.

We also covered a few other forms of conditional statement: `unless`, the case
statement, and the selector. Though there aren't any hard-and-fast rules for
which conditional statement is best in a given situation, there will generally
be one that results in the most concise and readible code. It's up to you to
decide what works best.
