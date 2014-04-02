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

Conditional statements let you write Puppet code to behave differently based on variables.

By writing conditional logic that draws on on system facts accessible through the facter tool, you can configure your Puppet manifests to perform as desired on a variety of operating systems and under differing system conditions.

Similarly, you can access facts defined at different scopes 

Puppet supports a few different ways of implementing conditionals:
 
 * `if` statements
 * `unless` statements
 * case statements
 * selectors
 
We'll go over each of these below.

### Scope 

### 'if' Statements

Puppet’s `if` statements behave much like those in any other language. The `if` condition is evaluated first and, if it is true, only the `if` code block is executed. If it is false, then the `elsif` condition kicks in (if present). Should the `if` condition and `elseif` condition fail, then the `else` condition picks up the slack and is executed (if present). If all the conditions fail and there is no `else` block, Puppet will do nothing and move on.

{% highlight puppet %}
if str2bool("$is_virtual") {
  service {'ntpd':
  ensure => stopped,
  enable => false,
  }
}

else {
  service { 'ntpd':
    name       => 'ntpd',
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['ntp'],
    }
}
{% endhighlight %}

{% tip %}
The `elsif` and `else` clauses are optional.
{% endtip %}

{% task 1 %}
Lets take a look at an existing manifest and update it with `if` conditions and a variable

	nano somthing/something.pp

{% task 2 %}
Lets write the `if` condition in Puppet's DSL with the following criteria:

	- 

{% task 3 %}
Now lets write the `elseif` considition in Puppet's DSL with the following criteria:

	- 

{% task 4 %}
Now lets write the `else` considition in Puppet's DSL with the following criteria:

	- 

{% task 5 %}
Save the manifest

{% task 6 %}
Apply the manifest


### `unless` Statements

The `unless` statement works like a reversed `if` statement. They take a condition and an arbitrary block of Puppet code, and will only execute the block if the condition is false. The condition is evaluated first and, if it is false, the code block is executed. If the condition is true, Puppet will do nothing and move on.

{% highlight puppet %}
unless $memorysize > 1024 {
  $maxclient = 500
}
{% endhighlight %}

{% tip %}
You cannot include `elsif` or `else` clauses in `unless` conditional statements.
{% endtip %}

{% task 7 %}


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
- The special `default` case matches anything.

{% task 8 %}

