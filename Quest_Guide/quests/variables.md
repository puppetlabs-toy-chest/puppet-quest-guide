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
- Classes Quest

## Quest Objectives

Are you seeing a pattern? Resources are the individual building blocks to using Puppet. Classes are a collection of resources to perform a task. Classes are housed in a Puppet manifest. Manifests contain instructions for automating a task. Now it's time to make manifests scalable. In this quest you will learn how to include variables and facts in your manifests in order to increase their portability and flexibility. When you're ready to get started, type the following command:

	quest --start variables

## Variables

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> -Confucius

Portability and scalability are key advantages of using Puppet; it is important that you learn to write manifests in such a way that they can function in different contexts. Effective use of **variables** is one of the fundamental methods you will use to achieve this.

{% warning %}
Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest before you can resolve it.
{% endwarning %}

If you have used variables before in some other programming or scripting language, the concept should be familiar. Variables allow you to assign data to a variable name in your manifest and then use that name to reference that data elsewhere in your manifest. In Puppet's syntax, variable names are prefixed with `$` (a dollar sign). You can assign data to a variable name with the `=` operator. You can use variables as the value for any resource attribute, or as the title of a resource.

{% highlight puppet %}
$myvariable = "look, data!\n"
{% endhighlight %}

{% aside Also... %}
In addition to directly assigning data to a variable, you can assign the result of any expression or function that resolves to a normal data type to a variable. This variable will then refer to the result of that statement.
{% endaside %}

{% task 1 %}
Create a new manifest in your home directory.

	nano ~/pangrams.pp

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

{% task 2 %}
Can you check and make sure the syntax of your `pangrams.pp` manifest is correct?

	HINT: Refer to the puppet parser section Manifest Quest
	
{% task 3 %}
Once there are no errors in your `pangrams.pp` manifest, can you simulate the change in the Learning VM without enforcing it?

	HINT: Remember when we talked about --noop in the Manifest Quest
	
{% task 4 %}
Puppet is telling us that it hasn't made any changes, but this is what would change if the `pangrams.pp` manifest was enforced. Since this is what we want, can you enforce the `pangrams.pp` manifest?

	HINT: Enforce using the puppet apply tool discussed in the Manifest Quest

{% task 5 %}
Great job! Take look at the file to see that the contents have been set as you intended:

	cat /root/pangrams/fox.txt

{% fact %}
A pangram is a sentence that uses every letter of the alphabet. A perfect pangram uses each letter only once.
{% endfact %}

The string assigned to the `$pangram` variable was passed into your file resource's `content` attribute, which in turn told Puppet what the content of the `/tmp/pangram.txt` file should exist.

## Variable Interpolation

The extra effort required to assign variables starts to show its value when you begin to incorporate variables into your manifests in more complex ways.

One way to do this is called **variable interpolation**. Interpolation allows you insert a variable into a string. The syntax for variable interpolation has minor addition in conjunction with the syntax of a stand-alone variable. The variable name is still preceded by a `$`, but it is now wrapped in curly braces (`${var_name}`).

These braces allow `puppet parser` to distinguish between the variable and the string in which it is embedded. It is important to remember, a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string.  

`"Variable interpolation is ${adjective}!"`  

{% tip %}
Wrapping a string without any interpolated variables in double quotes will still work, but it goes against conventions described in the Puppet Labs style guide.
{% endtip %}

{% task 6 %}
Now you can use variable interpolation to do something more interesting. Go ahead and create a new manifest called `perfect_pangrams.pp`.

		nano ~/perfect_pangrams.pp

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

Here, the `$pgdir` variable resolves to `'/root/pangrams'`, and the interpolated string "${pgdir}/perfect_pangrams" resolves to `'/root/pangrams/perfect_pangrams'`. It is best to use variables in this way to avoid redundancy and allow for data separation in the directory and filepaths. If you wanted to work in another user's home directory, for example, you would only have to change the `$pgdir` variable, and would not need to change any of your resource declarations.

{% task 7 %}
Similar to above, can you make sure the syntax of your `perfect_pangrams.pp` manifest is correct?

	HINT: Refer to Task 2. This is a great habit to get use to in using Puppet.

{% task 8 %}
Once there are no errors in your `perfect_pangrams.pp` manifest, can you simulate the change in the Learning VM without enforcing it?

	HINT: Refer to Task 3. Again, another great habit to get used to.
	
{% task 9 %}
Just like above in Task 4, Puppet is telling us that it hasn't made any changes but this is what it would look like in the Learning VM if the `perfect_pangrams.pp` manifest was enforced. Since this is what we want, can you enforce the `perfect_pangrams.pp` manifest?

	HINT: Refer to Task 4 and/or the Manifest Quest

{% task 10 %}
Have a look at the `bortz.txt` file:

	cat /root/pangrams/perfect_pangrams/bortz.txt
	
You should see something like this, with your pangram variable inserted into the file's content string:

	A perfect pangram:
	Bortz waqf glyphs vex muck djin.
	
What this perfect pangram actually means, however, is outside the scope of this lesson!

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember the Puppet tool `facter` when you first started? The `facter` tool discovers information about your system and makes it available to Puppet as variables. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress`? Puppet told you your IP address without you having to do anything. What if you wanted to turn `facter ipaddress` into a variable? You guessed it. It would look like this: `$ipaddress` as a stand-alone variable, or like this:
`${ipaddress}` as a variable interpolation.

In the Conditions Quest, you will see how Puppet manifests can be designed to perform differently depending on facts available through `facter`.

For now, let's play with some facts to get a feel for what's available.

{% task 11 %}
We will write a manifest that will interpolate facter variables into a string assigned to the `$message` variable. We can then use a `notify` resource to post a notification when the manifest is applied. We will also declare a file resource. We can use the same `$string` to assign our interpolated string to this file's content parameter.

Create a new manifest in your text editor.
		
		nano ~/facts.pp

Type the following Puppet code into the `facts.pp` manifest:

{% highlight puppet %}

$string = "\nHi, I'm a ${osfamily} system with the hostname ${hostname}. \nMy uptime is ${uptime}. \nMy Puppet version is ${puppetversion} \nI have ${memorytotal} total memory."

notify { 'info':
  message => $string,
}

file { '/root/message.txt':
  ensure  => file,
  content => $string,
}

{% endhighlight %}

{% task 11 %}
Like above,  check your `facts.pp` manifest syntax using the `puppet parser` tool.

{% task 12 %}
Once there are no errors in your `facts.pp` manifest, simulate the change in `--noop` mode in the Learning VM without enforcing it.

{% task 13 %}
Since this what we want, enforce the `facts.pp` manifest using the `puppet apply` tool.

{% task 14 %}
Have a look at the `message.txt` file.

You should see your message displayed along with Puppet's other notifications. You can also use the `cat` command or a text editor to have a look at the `message.txt` file with the same content.

As you can see, by incorporating variables, variable interpolations, and facts into your manifest can bring a higher level funtion and purpose to completing automation tasks. In the next quest we will discuss conditional statements that will even further provide flexibility and scalability to using Puppet.
