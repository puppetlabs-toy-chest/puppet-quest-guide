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

Are you seeing a pattern? Resources are the individual building blocks to using Puppet. Classes are a collection of resources to perform a task. Classes are housed in a Puppet manifest. Manifests contain instructions for automating a task. Now it's time to make manifests scalable. In this quest you will learn how to include variables in your manifests in order to increase their portability and flexibility. When you're ready to get started, type the following command:

	quest --start variables

## Variables

>The green reed which bends in the wind is stronger than the mighty oak which breaks in a storm.

> -Confucius

Portability and scalability are key advantages of using Puppet; it is important that you learn to write manifests in such a way that they can function in different contexts. Effective use of **variables** is one of the fundamental methods you will use to achieve this.

{% warning %}
Unlike resource declarations, variable assignments are parse-order dependent. This means that you must assign a variable in your manifest before you can resolve it.
{% endwarning %}

If you have used variables before in some other programming or scripting language, the concept should be familiar. Variables allow you to assign data to a variable name in your manifest and then use that name to reference that data elsewhere in your manifest. In Puppet's syntax, variable names are prefixed with a `$` (dollar sign). You can assign data to a variable name with the `=` operator. You can also use variables as the value for any resource attribute, or as the title of a resource.

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
Once your `pangrams.pp` manifest is error free, can you simulate the change in the Learning VM without enforcing it?

	HINT: Remember when we talked about --noop in the Manifest Quest
	
{% task 4 %}
Puppet is telling us that it hasn't made any changes, but this is what would change if the `pangrams.pp` manifest were enforced. Since this is what we want, can you enforce the `pangrams.pp` manifest?

	HINT: Enforce using the puppet apply tool discussed in the Manifest Quest

{% task 5 %}
Great job! Take look at the file to see that the contents have been set as you intended:

	cat /root/pangrams/fox.txt

{% fact %}
A pangram is a sentence that uses every letter of the alphabet. A perfect pangram uses each letter only once.
{% endfact %}

The string assigned to the `$pangram` variable was passed into your file resource's `content` attribute, which in turn told Puppet what the content of the `/tmp/pangram.txt` file should exist.



