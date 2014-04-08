---
title: Interpolation
layout: default
---

# Variable Interpolation

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Variables Quest

## Quest Objectives

In the Variables Quest we learned how to use variables to make our manifests more flexable and scalable. We're going to take that one level deeper and learn about inserting variables in strings by the means of interpolation. This too gives us even more options to customize Puppet in managing your infrastructure. When you're ready to get started, type the following command:

	quest --start interpolation

## Variable Interpolation

The extra effort required to assign variables starts to show its value when you begin to incorporate variables into your manifests in more complex ways.

One way to do this is called **variable interpolation**. Interpolation allows you insert a variable into a string. The syntax for variable interpolation has minor addition in conjunction with the syntax of a stand-alone variable. The variable name is still preceded by a `$`, but is now wrapped in curly braces (`${var_name}`).

These braces allow `puppet parser` to distinguish between the variable and the string in which it is embedded. It is important to remember, a string that includes an interpolated variable must be wrapped in double quotation marks (`"..."`), rather than the single quotation marks that surround an ordinary string.  

`"Variable interpolation is ${adjective}!"`  

{% tip %}
Wrapping a string without any interpolated variables in double quotes will still work, but it goes against conventions described in the Puppet Labs style guide.
{% endtip %}

{% task 1 %}
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

Here, the `$pgdir` variable resolves to `'/root/pangrams'`, and the interpolated string `"${pgdir}/perfect_pangrams"` resolves to `'/root/pangrams/perfect_pangrams'`. It is best to use variables in this way to avoid redundancy and allow for data separation in the directory and filepaths. If you wanted to work in another user's home directory, for example, you would only have to change the `$pgdir` variable, and would not need to change any of your resource declarations.

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

## You have some options

1. I would like to move on the the [Conditions Quest]().
2. I would like to learn more about using facts as variables in the [Facts Quest]().
