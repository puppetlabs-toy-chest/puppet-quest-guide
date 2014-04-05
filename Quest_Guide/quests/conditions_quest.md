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
Just as we discussed about bringing flexibility and scalability to our manifest in the Variables Quest, we can further exemplify that with conditional statements. In this quest, you will learn how to use conditional statements and how to combine conditional logic with variables in order to make your manifests adaptable. To start this quest enter the following command:

	quest --start conditions

## Conditions

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Conditional statements allow you to write Puppet code that will behave differently under different conditions.

By writing conditional logic in your manifest allows the system to draw upon facts accessible through the facter tool. For example, you can configure your Puppet manifests to perform as desired on a variety of operating systems and under differing system conditions. Pretty neat, huh?

Puppet supports a few different ways of implementing conditionals:
 
 * `if` statements
 * `unless` statements
 * case statements
 * selectors
 
We'll go over each of these below.

## 'if' Statements

Puppet’s `if` statements behave much like those in many other programming and scripting languages.

An `if` statement includes a condition followed by a block of Puppet code that will only be executed **if** that condition evaluates as **true**. Optionally, an `if` statement can also include any number of `elsif` clauses and an `else` clause. If the `if` condition fails, Puppet moves on to the `elsif` condition. If both the `if` and `elsif` conditions fail, Puppet will execute the code in the `else` clause. If all the conditions fail, and there is no `else` block, Puppet will do nothing and move on.

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
Just as we have done in the Variables Quest, let's create a manifest and add a simple conditional statement.

	nano ~/conditionals.pp

Enter the following code into your `conditionals.pp` manifest:

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

{% task 2 %}
Check your `conditionals.pp` manifest syntax using the `puppet parser` tool.

{% task 3 %}
Once there are no errors in your `conditionals.pp` manifest, simulate the change in `--noop` mode in the Learning VM without enforcing it.

{% task 4 %}
Since this what we want, enforce the `conditionals.pp` manifest using the `puppet apply` tool.

{% task 5 %}
Have a look at the `conditionals.txt` file using the `cat` command.

{% task 6 %}
Use the command `facter uptime_hours` to check the uptime yourself. The notice you saw when you applied your manifest should describe the uptime returned from the facter tool.

### Adding other conditions

Let's add another `if` statement to the end of the `conditionals.pp` manifest. Go back into your `conditionals.pp` manifest and add the following Puppet code:

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

Next, go ahead and check your `conditionals.pp` manifest syntax once again using the `puppet parser` tool.

Once there are no errors in your `conditionals.pp` manifest, simulate the change in `--noop` mode, then enforce the `conditionals.pp` manifest in the Learning VM using the `puppet apply` tool.

Have a look at the updated `conditionals.txt` file using the `cat` command. You will see the notice:

	Notice: I am a real machine.
	
But what happened here? We told the manifest to notify us if the Learning VM is real, which it most certainly is.

{% task 7 %}
If you like, run `facter is_virtual` to double-check. So why the incorrect result?

What you've encountered is a common mistake when using conditionals with facts from Facter. To understand what's going on here requires a basic understanding of how conditional statements interpret the data you give them.

### Thank you George Boole

A conditional statement requires a data type called a Boolean. A Boolean has only two possible values: `true` and `false`. A value of `true` tells the conditional to execute its code, while a value of `false` tells the conditional not to execute its code (or to continue on to an `elsif` or `else` clause).

{% tip %}
Boolean is named after the great mathematician George Boole.
{% endtip %}

When a conditional statement receives data other than a Boolean, it must convert that data type into a Boolean before the conditional statement can decide what to do. 

So here's where our manifest got tripped up: all Facter facts are actually constructed as a *string* data type. When converted to a Boolean, only empty strings (represented by empty quotes, e.g. `''`) are `false` and all other strings (including the string `'false'`!) are treated as `true`. Confused? Don't worry. Puppet has you covered.

Luckily this isn't a problem as long as we remember to properly convert a fact before feeding it to a conditional. Luckily Puppet includes a `str2bool()` function to convert strings to Booleans in a more sensible way.

We need to go back into your `conditionals.pp` manifest to properly convert the `$is_virtual` fact to a Boolean with the `str2bool()` function. Update your existing Puppet code to the following:

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

Go ahead and enforce your changes in the `conditionals.pp` using the `puppet apply` tool. Great! You are on your way to becoming a Puppet Master!

### 'unless' Statements

The `unless` statement works like a reversed `if` statement. They take a condition and a block of Puppet code, and will only execute the block **if** the condition is **false**. If the condition is true, Puppet will do nothing and move on. Note that there is no equivalent of `elsif` or `else` clauses for `unless` statements.

## Case Statements

Like `if` statements, case statements choose one of several blocks of arbitrary Puppet code to execute. Case statements take a control expression, a list of cases, Puppet code blocks, and will execute the first block of code whose case value matches the control expression.

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

Puppet compares the control expression to each case, in the order the cases are listed. Puppet will execute the block of code associated with the first matching case, and ignore the remainder of the statement.

- Basic cases are compared with the `==` operator (which is case-insensitive).
- Regular expression cases are compared with the `=~` operator (which is case-sensitive).
- The special `default` case matches anything. It should always be included at the end of a case statement to catch anything that did not match an explicit case.

## Before you move on

We have dicussed some intense information in the Variables Quest and this Quest. The information contained in all the quests to this point have guided you in creating flexible and scalable manifests for your infrastructure. Should you not understand any of the topics previously discussed, we highly encourage you to revisit those quests before moving on to the Resource Ording Quest. The Resource Ordering Quest will be the final scalable concept for manifests as it adds another layer of cusomtized functions to your manifest.


