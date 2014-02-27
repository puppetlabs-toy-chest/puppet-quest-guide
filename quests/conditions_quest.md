---
title: Conditions
layout: default
---

# Conditional Statements

Conditional statements let your Puppet code behave differently in different situations. These statements are most helpful when combining facts with data retrieved from an external source. This is not necessary to using Puppet, only ad added bonus proving the power of Puppet. To start this quest enter the following command:

		quest --start conditions

## Structure

Puppet has several kinds of conditional statements, however the structure stays roughly the same. By using facts as conditions, you can easily make Puppet do different things on different kinds of systems. Below is a common structure for constructing a conditional statement.

		<insert clause here> <insert condition here> {
		  <insert block of code here>
		}

## `if` Statements

Puppet’s `if` statements behave much like those in any other language. The if condition is evaluated first and, if it is true, only the if code block is executed. If it is false, each elsif condition (if present) is tested in order, and if all conditions fail, the else code block (if present) is executed.

If none of the conditions in the statement match and there is no else block, Puppet will do nothing and move on.

The `if` statements will execute a maximum of one code block.

		if $is_virtual == 'true' {
		  warning('Tried to include class ntp on virtual machine; this node may be misclassified.')
		}
		elsif $operatingsystem == 'Darwin' {
		  warning('This NTP module does not yet work on our Mac laptops.')
		}
		else {
		  include ntp
		}

{% tip %}
The `elsif` and `else` clauses are optional.
{% endtop %}

## `unless` Statements

The `unless` statement works like a reversed `if` statement. They take a boolean condition and an arbitrary block of Puppet code, and will only execute the block if the condition is false. The condition is evaluated first and, if it is false, the code block is executed. If the condition is true, Puppet will do nothing and move on.

		unless $memorysize > 1024 {
		  $maxclient = 500
		}

{% tip %}
You cannot include `elsif` or `else` clauses in `unless` statements.
{% endtip %}

## Case Statements

Like `if` statements, case statements choose one of several blocks of arbitrary Puppet code to execute. They take a control expression and a list of cases and code blocks, and will execute the first block whose case value matches the control expression.

		case $operatingsystem {
		  'Solaris':          { include role::solaris } # apply the solaris class
		  'RedHat', 'CentOS': { include role::redhat  } # apply the redhat class
		  /^(Debian|Ubuntu)$/:{ include role::debian  } # apply the debian class
		  default:            { include role::generic } # apply the generic class
		}

Puppet compares the control expression to each of the cases, in the order they are listed. It will execute the block of code associated with the first matching case, and ignore the remainder of the statement.

- Basic cases are compared with the `==` operator (which is case-insensitive).
- Regular expression cases are compared with the `=~` operator (which is case-sensitive).
- The special `default` case matches anything.

## Selectors

## Tasks

1. 

