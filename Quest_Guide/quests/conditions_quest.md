---
title: Conditions
layout: default
---

# Conditional Statements

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Classes Quest
- Variables Quest

## Quest Objectives
 - Learn how to use conditional logic to make your manifests adaptable.
 - Understand the syntax and function of the `if`, `unless`, `case`, and
`selector` statements. 

## Getting Started

Conditional statements allow you to write Puppet code that will return different values or execute different blocks of code depending on the conditions you specify. This, in conjunction with Facter facts, will enable you to write Puppet code that accomodates different platforms, operating systems, and functional requirements.

To start this quest enter the following command:

	quest --start conditions

## Conditions

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Conditional statements let your Puppet code behave differently in different situations. They are most helpful when combined with facts or with data pertaining to the systems. For example, you can configure your Puppet manifests to perform as desired on a variety of operating systems and under differing system conditions. Pretty neat, don't you think?

Puppet supports a few different ways of implementing conditional logic:
 
 * `if` statements
 * `unless` statements
 * case statements, and
 * selectors

## The 'if' Statement

Puppet’s `if` statements behave much like those in many other programming and scripting languages.

An `if` statement includes a condition followed by a block of Puppet code that will only be executed __if__ that condition evaluates as __true__. Optionally, an `if` statement can also include any number of `elsif` clauses and an `else` clause. Here are some rules:

- If the `if` condition fails, Puppet moves on to the `elsif` condition (if one exists)
- If both the `if` and `elsif` conditions fail, Puppet will execute the code in the `else` clause (if one exists)
- If all the conditions fail, and there is no `else` block, Puppet will do nothing and move on

The following is an example of an `if` statement you might use to raise a warning when a class is included on an unsupported system:

{% highlight puppet %}
if $is_virtual == 'true' {
  # Our NTP module is not supported on virtual machines:
  warn( 'Tried to include class ntp on virtual machine.' )
}
elsif $operatingsystem == 'Darwin' {
  # Our NTP module is not supported on Darwin:
  warn( 'This NTP module does not yet work on Darwin.' )
}
else {
  # Normal node, include the class.
  include ntp
}
{% endhighlight %}

{% aside The Warn Function %}
The `warn()` function will not affect the execution of the rest of the manifest, but if you were running Puppet in the usual Master-Agent setup, it would log a message on the server at the 'warn' level.
{% endaside %}

{% task 1 %}
Just as we have done in the Variables Quest, let's create a manifest and add a simple conditional statement.

	nano ~/conditionals.pp

Enter the following code into your `conditionals.pp` manifest:

{% highlight puppet %}
if $uptime_hours < 2 {
  $uptime = 'Uptime is less than two hours.\n'
}
elsif $uptime_hours < 5 {
  $uptime = 'Uptime is less than five hours.\n'
}
else {
  $uptime = 'Uptime is greater than four hours.\n'
}
file {'/root/conditionals.txt':
  ensure  => present,
  content => $uptime
}
{% endhighlight %}

{% task 2 %}
Use the `puppet parser` tool to check your syntax, then simulate the change in `--noop` mode without enforcing it. If the noop looks good, enforce the `conditionals.pp` manifest using the `puppet apply` tool.

Have a look at the `conditionals.txt` file using the `cat` command.

{% task 3 %}
Use the command `facter uptime_hours` to check the uptime yourself. The notice you saw when you applied your manifest should describe the uptime returned from the Facter tool.

## The 'unless' Statement

The `unless` statement works like a reversed `if` statement. An `unless` statements takes a condition and a block of Puppet code. It will only execute the block **if** the condition is **false**. If the condition is true, Puppet will do nothing and move on. Note that there is no equivalent of `elsif` or `else` clauses for `unless` statements.

## The 'case' Statement

Like `if` statements, case statements choose one of several blocks of arbitrary Puppet code to execute. Case statements take a control expression, a list of cases, and a series of Puppet code blocks that correspond to those cases. Puppet will execute the first block of code whose case value matches the control expression.

- Basic cases are compared with the `==` operator (which is case-insensitive).
- Regular expression cases are compared with the `=~` operator (which is case-sensitive).
- The special `default` case matches anything. It should always be included at the end of a case statement to catch anything that did not match an explicit case.

{% task 4 %}
Create a `case.pp` manifest with the following conditional statement and `file` resource declaration.

{% highlight puppet %}
case $operatingsystem {
  'CentOS': { $apache = 'httpd' }
  'Redhat': { $apache = 'httpd' }
  'Debian': { $apache = 'apache2' }
  'Ubuntu': { $apache = 'apache2' }
  default: { fail("Unrecognized operating system for webserver") }
}

file {'/root/case.txt':
  ensure  => present,
  content => "Apache package name: ${apache}\n"
}
{% endhighlight %}

When you've validated your syntax and run a `--noop`, apply the manifest:

	puppet apply case.pp
	
Use the `cat` command to inspect the `case.txt` file. Because the Learning VM is running CentOS, you will see that the selected Apache package name is 'httpd'.

For the sake of simplicity, we've output the result of the case statement to a file, but keep in mind that in an actual practice, instead of using the result of the case statement like the one above to define the contents of a file, you could use it directly in a `package` resource declaration like the following:

{% highlight puppet %}
package {'apache':
  name   => $apache,
  ensure => latest,
}
{% endhighlight %}

This would allow you to always install and manage the right Apache package for a machine's operating system. This  kind of careful accounting for different the conditions under which a manifest might run is an important part of writing flexible and re-usable Puppet code. It is a paradigm you will encounter frequently in published Puppet modules.

## The 'selector' Statement
Selector statements are very similar to `case` statements, but instead of executing a block of code, a case statement assigns a value directly. A selector might look something like this:

{% highlight puppet %}
$rootgroup = $osfamily ? {
  'Solaris'  => 'wheel',
  'Darwin'   => 'wheel',
  'FreeBSD'  => 'wheel',
  'default'  => 'root',
}
{% endhighlight %}

Here, the value of the `$rootgroup` is determined based on the control variable `$osfamily`. Following the control variable is a `?` (question mark) keyword. In the block surrounded by curly braces are series of cases, followed by the value that the selector should return if that case matches the control variable.

Because a selector can only return a value and cannot execute a function like `fail()` or `warn()`, it is up to you to make sure your code handles unexpected conditions gracefully. You wouldn't want Puppet to forge ahead with with an inappropriate default value and encounter errors down the line.

## Before you move on

We have discussed some intense information in the Variables Quest and this Quest. The information contained in all the quests to this point have guided you in creating flexible and scalable manifests for your infrastructure. Should you not understand any of the topics previously discussed, we highly encourage you to revisit those quests before moving on to the Resource Ordering Quest. The Resource Ordering Quest will be the final scalable concept for manifests as it adds another layer of customized functions to your manifest.


