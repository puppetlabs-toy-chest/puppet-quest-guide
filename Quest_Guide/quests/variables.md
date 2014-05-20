---
title: Variables
layout: default
---

# Variables

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest

## Quest Objectives

- Learn how to make Puppet manifests more flexible using variables
- Learn how to interpolate variables in manifests
- Understand how facts can be used 

## Getting Started

Manifests contain instructions for automating tasks related to managing resources. Now it's time to learn how to make manifests more flexible. In this quest you will learn how to include variables, interpolate variables, and use Facter facts in your manifests in order to increase their portability and flexibility. When you're ready to get started, type the following command:

	quest --start variables

## Variables

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> -Confucius

Puppet can be used to manage configurations on a variety of different operating systems and platforms. The ability to write portable code that accomodates various platforms is a significant advantage in using Puppet. It is important that you learn to write manifests in such a way that they can function in different contexts. Effective use of **variables** is one of the fundamental methods you will use to achieve this.

If you've used variables before in some other programming or scripting language, the concept should be familiar. Variables allow you to assign data to a variable name in your manifest and then use that name to reference that data elsewhere in your manifest. In Puppet's syntax, variable names are prefixed with a `$` (dollar sign). You can assign data to a variable name with the `=` operator. You can also use variables as the value for any resource attribute, or as the title of a resource. In short, once you have defined a variable with a value you can use it anywhere you would have used the value or data.

{% warning %}
Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest before you can use it.
{% endwarning %}

The following is a simple example of assigning a value, which in this case, is a string, to a variable. 

{% highlight puppet %}
$myvariable = "look, data!\n"
{% endhighlight %}

{% aside Also... %}
In addition to directly assigning data to a variable, you can assign the result of any expression or function that resolves to a normal data type to a variable. This variable will then refer to the result of that statement.
{% endaside %}

{% task 1 %}

Using Puppet, create the file `/root/pangrams/fox.txt` with the specified content.

Create a new manifest in your home directory.

	nano ~/pangrams.pp
	
	HINT: Refer to the Manifest Quest if you're stuck.

Type the following Puppet code into the `pangrams.pp` manifest:

{% highlight puppet %}
$pangram = 'The quick brown fox jumps over the lazy dog.'

file {'/root/pangrams':
	ensure => directory,
}

file {'/root/pangrams/fox.txt':
  ensure  => file,
  content => $pangram,
}
{% endhighlight %}

Now that we have a manifest, let's test it on the VM. 

Remember to validate the syntax of the file, and to simulate the change using the `-noop` flag  before you use `puppet apply` to make the required change on the system.

Excellent! Take a look at the file to see that the contents have been set as you intended:

	cat /root/pangrams/fox.txt

{% fact %}
A pangram is a sentence that uses every letter of the alphabet. A perfect pangram uses each letter only once.
{% endfact %}

The file resource `/root/pangrams/fox.txt` is managed, and the content for the file is specified as the value of the `$pangram` variable.

## Variable Interpolation

The extra effort required to assign variables starts to show its value when you begin to incorporate variables into your manifests in more complex ways.

**Variable interpolation** allows you to replace occurences of the variable with the *value* of the variable. In practice this helps with creating a string, the content of which contains another string which is stored in a variable. To interpolate a variable in a string, the variable name is preceded by a `$` and wrapped in curly braces (`${var_name}`). 

The braces allow `puppet parser` to distinguish between the variable and the string in which it is embedded. It is important to remember, a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string. 

`"Variable interpolation is ${adjective}!"`  

{% tip %}
Wrapping a string without any interpolated variables in double quotes will still work, but it goes against conventions described in the Puppet Labs Style Guide.
{% endtip %}

{% task 2 %}

Create a file called perfect_pangrams. We will use variable substitution and interpolation in doing this.

Now you can use variable interpolation to do something more interesting. Go ahead and create a new manifest called `perfect_pangrams.pp`.

	nano ~/perfect_pangrams.pp
	
	HINT: Refer to the Manifest Quest if you're stuck

Type the following Puppet code into the `perfect_pangrams.pp` manifest:

{% highlight puppet %}
$perfect_pangram = 'Bortz waqf glyphs vex muck djin.'

$pgdir = '/root/pangrams'

file { $pgdir:
	ensure => directory,
}

file { "${pgdir}/perfect_pangrams":
	ensure => directory,
}

file { "${pgdir}/perfect_pangrams/bortz.txt":
  ensure  => file,
  content => "A perfect pangram: \n${perfect_pangram}",
}
{% endhighlight %}

Once you have create the `perfect_pangrams.pp` file, enforce it using the appropriate `puppet apply` command, but not before you verify that the syntax is correct and have tried simulating it first. Refer to the Manifests quest if you need to refresh you memory on how to apply a manifest.

Here, the `$pgdir` variable resolves to `'/root/pangrams'`, and the interpolated string `"${pgdir}/perfect_pangrams"` resolves to `'/root/pangrams/perfect_pangrams'`. It is best to use variables in this way to avoid redundancy and allow for data separation in the directory and filepaths. If you wanted to work in another user's home directory, for example, you would only have to change the `$pgdir` variable, and would not need to change any of your resource declarations.

Have a look at the `bortz.txt` file:

	cat /root/pangrams/perfect_pangrams/bortz.txt
	
You should see something like this, with your pangram variable inserted into the file's content string:

	A perfect pangram:
	Bortz waqf glyphs vex muck djin.
	
What this perfect pangram actually means, however, is outside the scope of this lesson!

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember using the Facter tool when you first started? The Facter tool discovers information about your system and makes it available to Puppet as variables. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress` told you your IP address? What if you wanted to turn `facter ipaddress` into a variable? You guessed it. It would look like this: `$::ipaddress` as a stand-alone variable, or like this:
`${::ipaddress}` when interpolated in a string.

The `::` in the above indicates that we always want the top-scope variable, the global fact called `ipaddress`, as opposed to, say a variable called `ipaddress` you defined in a specific manifest.  

In the Conditions Quest, you will see how Puppet manifests can be designed to perform differently depending on facts available through `facter`. For now, let's play with some facts to get a feel for what's available.

{% task 3 %}
We will write a manifest that will interpolate facter variables into a string assigned to the `$message` variable. We can then use a `notify` resource to post a notification when the manifest is applied. We will also declare a file resource. We can use the same `$string` to assign our interpolated string to this file's content parameter.

Create a new manifest with your text editor.
		
	nano ~/facts.pp

	HINT: Refer to the Manifest Quest if you're stuck

Type the following Puppet code into the `facts.pp` manifest:

{% highlight puppet %}
$string = "Hi, I'm a ${::osfamily} system and I have been up for ${::uptime} seconds." 

notify { 'info':
  message => $string,
}

file { '/root/message.txt':
  ensure  => file,
  content => $string,
}
{% endhighlight %}

Once you have created the facts.pp file, enforce it using the appropriate `puppet apply` command, after verifying that the syntax is correct. 

You should see your message displayed along with Puppet's other notifications. You can also use the `cat` command or a text editor to have a look at the `message.txt` file with the same content.

	cat /root/message.txt

As you can see, by incorporating facts and variables, and by using variable interpolation, you can add more functionality with more compact code. In the next quest we will discuss conditional statements that will provide for greater flexibility in using Puppet.

## Review

In this quest you've learned how to take your Puppet manifests to the next level by using variables. There are even more levels to come, but this is a good start. We learned how to assign a value to a variable and then reference the variable by name whenever we need its content. We also learned how to interpolate variables, and how Facter facts are global variables available for you to use.

In addition to learning about variables, interpolating variables, and facts, you also gained more hands-on learning with constructing Puppet manifests using Puppet's DSL. We hope you are becoming more familar and confident with using and writing Puppet code as you are progressing.

Looking back to the Power of Puppet Quest, can you identify where and how variables are used in the `lvmguide` class?

