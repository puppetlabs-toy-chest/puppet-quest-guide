---
title: Conditions
layout: default
---

# Conditional Statements

### Prerequisites

- Resources Quest
- Mainfest Quest
- Classes Quest
- Variables Quest

## Quest Objectives
In this quest, you will learn how to use conditional statements and how to combine this conditional logic with variables in order to make your manifests adaptable. To start this quest enter the following command:

	quest --start conditions

## Conditions

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Conditional statements allow you to write Puppet code that will behave differently under different conditions.

By writing conditional logic that draws on on system facts accessible through the facter tool, for example, you can configure your Puppet manifests to perform as desired on a variety of operating systems and under differing system conditions.

Puppet supports a few different ways of implementing conditionals:
 
 * `if` statements
 * `unless` statements
 * case statements
 * selectors
 
We'll go over each of these below.

### 'if' Statements

Puppet’s `if` statements behave much like those in many other languages.

An `if` statement includes a condition followed by a block of Puppet code that will only be executed if that condition evaluates as true. Optionally, an `if` statement can also include any number of `elsif` clauses and an `else` clause. If the `if` condition is fails, Puppet moves on to the `elsif` condition. If neither the `if` nor `elsif` conditions are true, Puppet will exectute the code in the `else` clause. If all the conditions fail and there is no `else` block, Puppet will do nothing and move on.

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

{% task 1 %}
Let's create a manifest to test out a simple conditional statement.

	nano ~/conditionals.pp

Enter the following code into your manifest:

{% highlight puppet %}
if $uptime_hours < 2 {
  notify { 'uptime' :
    message => 'Uptime is less than two hours.',
  }
}
elsif $uptime_hours < 5 {
  notify { 'uptime' :
    message => 'Uptime is less than five hours.',
  }
}
else {
  notify { 'uptime' :
    message => 'Uptime is greater than four hours.',
  }
}
{% endhighlight %}

Apply the manifest, and look at the output.

Use the command `facter uptime_hours` to check the uptime yourself. The notice you saw when you applied your manifest should describe the uptime returned from the facter tool.

{% task 2 %}
Let's add another `if` statement to the end of the `conditionals.pp` manifest.

{% highlight puppet %}
if $is_virtual {
  notify { 'virtual' :
    message => 'I am a virtual machine.',
  }
else {
  notify { 'virtual' :
    message => 'I am a real machine.',
  }
}
{% endhighlight %}

Apply the manifest, and have a look at the output. You will see the notice:

	Notice: I am a real machine.
	
But what happened here? We told the manifest to notify us if the machine is virtual, which the Learning VM certainly is. If you like, run `facter is_virtual` to double-check. So why the incorrect result?

What you've encountered is a common mistake encountered when using conditionals with facts from facter. To understand what's going on here requires a basic understanding of how conditional statements interpret the data you give them.

A conditional statement requires a data type called a Boolean (after the mathematician George Boole). A Boolean has only two possible values: `true` and `false`. A value of `true` tells the conditional to execute its code, while a value of `false` tells it not to (or to continue to an `elsif` or `else` clause).

When a conditional statement receives data other than a Boolean, it must convert that data type into a Boolean before it can decide what to do. 

So here's where where our manifest got tripped up: all facter facts are actually given as a *string* data type, that is, as strings of text characters. When converted to a Boolean, only empty strings (represented by empty quotes, e.g. `''`) are `false` and all other strings (including the string `'false'`!) are treated as `true`.

Luckily this isn't a problem as long as we remember to properly convert a fact before feeding it to a conditional. Luckily Puppet includes a `str2bool()` function to convert strings to Booleans in a more sensible way.

{% task 3 %}
Edit your `conditionals.pp` manifest to properly convert the `$is_virtual` fact to a Boolean with the `str2bool()` function.

{% highlight puppet %}
if str2bool($is_virtual) {
  notify { 'virtual' :
    message => 'I am a virtual machine.',
  }
else {
  notify { 'virtual' :
    message => 'I am a real machine.',
  }
}
{% endhighlight %}

### 'unless' Statements

The `unless` statement works like a reversed `if` statement. They take a condition and a block of Puppet code, and will only execute the block if the condition is false. If the condition is true, Puppet will do nothing and move on. Note that there is no equivalent of `elsif` or `else` clauses for `unless` statements.

### Case Statements

Like `if` statements, case statements choose one of several blocks of arbitrary Puppet code to execute. They take a control expression and a list of cases and code blocks, and will execute the first block whose case value matches the control expression.

{% highlight puppet %}
case $operatingsystem {
  centos: { $apache = "httpd" }
  redhat: { $apache = "httpd" }
  debian: { $apache = "apache2" }
  ubuntu: { $apache = "apache2" }
  default: { fail("Unrecognized operating system for webserver") }
  }

package {'apache':
  name   => $apache,
  ensure => latest,
}
{% endhighlight %}

Puppet compares the control expression to each of the cases, in the order they are listed. It will execute the block of code associated with the first matching case, and ignore the remainder of the statement.

- Basic cases are compared with the `==` operator (which is case-insensitive).
- Regular expression cases are compared with the `=~` operator (which is case-sensitive).
- The special `default` case matches anything. It should always be included at the end of a case statement to catch anything that did not match an explicit case.

