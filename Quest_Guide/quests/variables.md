---
title: Variables
layout: default
---

# Variables

### Prerequisites

- Resources Quest
- Mainfest Quest
- Classes Quest

## Quest Objectives

In this quest you will learn to include variables and facts in your manifests in order to increase their portability and flexibility. If you're ready to get started, type the following command:

	quest --start variables

## Variables

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> -Confuscius

Portability and scalability are key advantages of using Puppet; it is important that you learn to write manifests in such a way that they can function in different contexts. Effective use of **variables** is one of the fundamental methods you will use to achieve this.

{% warning %}
Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest before you can resolve it.
{% endwarning %}

You have likely used variables before in some other programming or scripting language, so the concept will be familiar. Variables allow you to assign data to a variable name in one part of your manifest, then use that name to reference that data elsewhere in your manifest. In Puppet's syntax, variable names are prefixed with `$` (a dollar sign). You can assign data to a variable name with the `=` operator.

{% highlight puppet %}
$myvariable = "look, data!\n"
{% endhighlight %}

You can directly assign data of any normal data type to a variable.

{% tip %}
In addition to directly assigning data to a variable, you can assign the result of any expression or function that resolves to a normal data type to a variable. This variable will then refer to the result of that statement.
{% endtip %}

You can use variables as the value for any resource attribute, or as the title of a resource.

{% task 1 %}
Create a new manifest in your home directory.

	nano ~/pangrams.pp

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

Apply your manifest, and take look at the file to see that the contents have been set as you intended:

	cat /root/pangrams/fox.txt

{% fact %}
A pangram is a sentence that uses every letter of the alphabet. A perfect pangram uses each letter only once.
{% endfact %}

The string assigned to the `$pangram` variable was passed into your file resource's `content` attribute, which in turn told Puppet what the content of the `/tmp/pangram.txt` file should be.

## Variable Interpolation

The extra effort required to assign variables starts to show its value when you begin to incorporate variables into your manifests in more complex ways.

One way to do this is called **variable interpolation**. Interpolation allows you insert a variable into a string. The syntax for variable interpolation is just a little bit different than that for a stand-alone variable. The variable name is still preceded by a `$`, but it is also wrapped in curly braces (`${var_name}`).

These braces allow the Puppet parser distinguish between the variable and the string in which it is embedded. 

It is also important to remember that a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string.

`"Variable interpolation is ${adjective}!"`

{% tip %}
Wrapping a string without any interpolated variables in double quotes will still work, but it goes against conventions described in the Puppet Labs style guide.
{% endtip %}

{% task 2 %}
Now you can use variable interpolation to do something more interesting. Create a new manifest called `perfect_pangrams.pp`.

		nano ~/perfect_pangrams.pp

{% highlight puppet %}
$perfect_pangram = 'Bortz waqf glyphs vex muck djin.'

$pgdir = '/root/pangrams'

file {[$pgdir, "${pgdir}/perfect_pangrams"]:
	ensure => directory,
}

file {"${pgdir}/perfect_pangrams/bortz.txt":
  ensure  => file,
  content => "A perfect pangram: \n${perfect_pangram}",
}
{% endhighlight %}

There are a couple of things to notice here. First, the `title` of the first file resource you declared looks a little different than the normal resource declaration syntax:

	[$pgdir, "${pgdir}/perfect_pangrams"]

This is because you used an **array**, which lets you declare two resources at once. By including multiple resource titles wrapped in square braces `[...]` and separated by commas, you can declare multiple resources with identical attributes. This is a common pattern for concisely declaring nested directory structures.

In this case, the `$pgdir` variable resolves to `'/root/pangrams'`, and the interpolated string "${pgdir}/perfect_pangrams" resolves to `'/root/pangrams/perfect_pangrams'`.

Have a look at the `bortz.txt` file:

	cat /root/pangrams/perfect_pangrams/bortz.txt
	
You should see something like this, with your pangram variable inserted into the file's content string:

	A perfect pangram:
	Bortz waqf glyphs vex muck djin.

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember the Puppet tool `facter` when you first started? The `facter` tool discovers information about your system and makes it available to Puppet as variables. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress`? Puppet told you your IP address without you having to do anything. What if you wanted to turn `facter ipaddress` into a variable? You guessed it. It would look like this: `$ipaddress` as a stand-alone variable, or like this:
`${ipaddress}` as a variable interpolation.

When you learn about **conditionals**, you will see how Puppet manifests can be designed to perform differently depending on facts available through `facter`.

For now, let's play with some facts to get a feel for what's available.

{% task 3 %}
Open the manifest in your text editor.
		
		nano ~/mad_facts.pp

And edit it to look like the following:

{% highlight puppet %}

$madfact = "It took ${uptime} for the quick brown fox to realize that what the lazy dog told her was ${selinux}. Early on the morning of ${bios_release_date}, she put on her best ${osfamily} and took a cab to ${bios_vendor}."

file {'/root/madfact.txt':
  ensure => file,
  content => $madfact,
}

{% endhighlight %}