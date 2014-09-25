---
title: Variables and Conditionals
layout: default
---

# Variables and Class Parameters

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Manifest Quest

## Quest Objectives

- Learn how varaibles and conditionals can make Puppet code more flexible.
- Understand the syntax and function of the `if`, `unless`, `case`, and `selector` statements.
- Learn how to interpolate variables.
- Use system data from facter to assign variables and manage conditionals.

## Getting Started

In this quest you will learn how to assign, invoke, and interpolate variables. You will see how to use Facter facts in your Puppet code to improve its portability and flexibility. Expanding on what you've already learned about the *user* resource, you will write a module to manage users, using variables and conditional logic to ensure applicability across several different operating systems.

When you're ready to get started, type the following command to begin:

	quest --start variables

## Writing for Flexibility

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> -Confucius

Because Puppet manages configurations on a variety of systems fulfilling a variety of roles, great Puppet code means flexible and portable Puppet code. While the *types* and *providers* that form the core of Puppet's *resource abstraction layer* do a lot of heavy lifting around this kind of adaptation, there are some things better left in the hands of competent practitioners, rather than hard-coded in Puppet itself.

As you move from general platform-related implementation details to specific application-related implementation details, it starts making less sense to rely on Puppet to make decisions automatically, and much more sense for a module developer or user to make his or her own choices based on specific requirements. 

It's sensible, for example, for Puppet's `package` providers take care of installing and maintaining packages. The inputs and outputs are standardized and stable enough that what happens in between, as long as it happens reliably, can be safely hidden by abstraction; once it's done, the details are no longer important.

*What* package is installed, on the other hand, isn't something you can safely forget. In this case, the inputs and outputs are not so neatly delimited. Though there are often broadly equivalent packages for different platforms, the equivalence is rarely complete; configuration details will often vary, and these details will likely have to be accounted for elsewhere in your Puppet module.

While Puppet's built-in providers can't themselves guarantee the portability of your Puppet code at this higher level of implementation, Puppet's DSL gives you the tools to build adaptability into your modules. The bread and butter of this toolset are the the **variable** and **conditional statement**.

## Variables

> Beauty is variable, ugliness is constant.

> -Douglas Horton


Variables allow you to assign data to a variable name and later use that name to reference that data elsewhere in your manifest. In Puppet's syntax, variable names are prefixed with a `$` (dollar sign). You can assign data to a variable name with the `=` operator. You can also use variables as the value for any resource attribute, or as the title of a resource. In short, once you have defined a variable with a value you can use it anywhere you would have used the value or data.

{% warning %}
Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest *before* you can use it.
{% endwarning %}

The following is a simple example of assigning a value, which in this case, is a string, to a variable. 

{% highlight puppet %}
$myvariable = "look, data!\n"
{% endhighlight %}

A simple module to manage user accounts will give you a chance to see variables in action. Before you get started, make sure you're in the `modules` directory.

	cd /etc/puppetlabs/puppet/modules
	
Now create the directory structure for your `accounts` module.

	mkdir accounts
	
	mkdir accounts/{manifests,tests}
	
With Vim, create an `init.pp` manifest in your module's `manifests` directory.

	vim accounts/manifests/init.pp

## Conditionals

> Just dropped in (to see what condition my condition was in)

> -Mickey Newbury

Conditional statements allow you to write Puppet code that will return different values or execute different blocks of code depending on conditions you specify. This is key to getting your Puppet modules to perform as desired on machines running different operating systems and fulfilling different roles in your infrastructure.

Puppet supports a few different ways of implementing conditional logic:
 
 * `if` statements
 * `unless` statements
 * case statements
 * selectors

### The 'if' and 'unless' Statements

Puppet’s `if` statements behave much like those in many other programming and scripting languages.

An `if` statement includes a condition followed by a block of Puppet code that will only be executed **if** that condition evaluates as **true**. Optionally, an `if` statement can also include any number of `elsif` clauses and an `else` clause. Here are some rules:

- If the `if` condition fails, Puppet moves on to the `elsif` condition (if one exists).
- If both the `if` and `elsif` conditions fail, Puppet will execute the code in the `else` clause (if one exists).
- If all the conditions fail, and there is no `else` block, Puppet will do nothing and move on.

**Unless** is just like 


## Variable Interpolation

The extra effort required to assign variables starts to show its value when you begin to incorporate variables into your manifests in more complex ways.

**Variable interpolation** allows you to replace occurences of the variable with the *value* of the variable. In practice this helps with creating a string, the content of which contains another string which is stored in a variable. To interpolate a variable in a string, the variable name is preceded by a `$` and wrapped in curly braces (`${var_name}`). 

The braces allow `puppet parser` to distinguish between the variable and the string in which it is embedded. It is important to remember, a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string. 

`"Variable interpolation is ${adjective}!"`  

{% tip %}
Wrapping a string without any interpolated variables in double quotes will still work, but it goes against conventions described in the Puppet Labs Style Guide.
{% endtip %}

{% task 2 %}

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember using the Facter tool when you first started? The Facter tool discovers information about your system and makes it available to Puppet as variables. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress` told you your IP address? What if you wanted to turn `facter ipaddress` into a variable? It would look like this: `$::ipaddress` as a stand-alone variable, or like this:
`${::ipaddress}` when interpolated in a string.

The `::` in the above indicates that we always want the top-scope variable, the global fact called `ipaddress`, as opposed to, say a variable called `ipaddress` you defined in a specific manifest.

## Review

In this quest you've learned how to take your Puppet manifests to the next level by using variables. There are even more levels to come, but this is a good start. We learned how to assign a value to a variable and then reference the variable by name whenever we need its content. We also learned how to interpolate variables, and how Facter facts are global variables available for you to use.

In addition to learning about variables, interpolating variables, and facts, you also gained more hands-on learning with constructing Puppet manifests using Puppet's DSL. We hope you are becoming more familar and confident with using and writing Puppet code as you are progressing.

Looking back to the Power of Puppet Quest, can you identify where and how variables are used in the `lvmguide` class?

