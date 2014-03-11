---
title: Conditions
layout: default
---

# Conditional Statements

### Prerequisites

- Resources Quest
- Mainfest Quest
- Classes Quest
- Varibales Quest

## Quest Objectives

Conditional statements let your Puppet code behave differently in certain situations. By using facts as conditions, you can easily make Puppet do different things on different operating systems, but conditional statements are most helpful when combining facts with data retrieved from an external source. Conditional statements are not a required necessity to using Puppet, but offer an added flexible bonus proving the power of Puppet. To start this quest enter the following command:

	quest --start conditions

## `if` Statements

Puppet’s `if` statements behave much like those in any other language. The `if` condition is evaluated first and, if it is true, only the `if` code block is executed. If it is false, then the `elsif` condition kicks in (if present). Should the `if` condition and `elseif` condition fail, then the `else` condition picks up the slack and is executed (if present). If all the conditions fail and there is no `else` block, Puppet will do nothing and move on.

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


## `unless` Statements

The `unless` statement works like a reversed `if` statement. They take a condition and an arbitrary block of Puppet code, and will only execute the block if the condition is false. The condition is evaluated first and, if it is false, the code block is executed. If the condition is true, Puppet will do nothing and move on.

	unless $memorysize > 1024 {
	  $maxclient = 500
	}

{% tip %}
You cannot include `elsif` or `else` clauses in `unless` conditional statements.
{% endtip %}

{% task 7 %}


## Case Statements

Like `if` statements, case statements choose one of several blocks of arbitrary Puppet code to execute. They take a control expression and a list of cases and code blocks, and will execute the first block whose case value matches the control expression.

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

Puppet compares the control expression to each of the cases, in the order they are listed. It will execute the block of code associated with the first matching case, and ignore the remainder of the statement.

- Basic cases are compared with the `==` operator (which is case-insensitive).
- Regular expression cases are compared with the `=~` operator (which is case-sensitive).
- The special `default` case matches anything.

{% task 8 %}

