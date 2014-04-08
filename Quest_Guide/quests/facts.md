---
title: Facts
layout: default
---

# Facts

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest
- Mainfest Quest
- Variables Quest
- Interpolation Quest

## Quest Objectives

In the Variables Quest we learned how to use variables to make our manifests more flexable and scalable. We're going to take that one level deeper and learn about turing facts in our manifest into variables to tell us information about or system. This too gives us even more options to customize Puppet in managing your infrastructure. When you're ready to get started, type the following command:

	quest --start facts

## Facts

>Get your facts first, then distort them as you please.

> -Mark Twain

Puppet has a bunch of built-in, pre-assigned variables that you can use. Remember using the Facter tool when you first started? The Facter tool discovers information about your system and makes it available to Puppet as variables. Puppet’s compiler accesses those facts when it’s reading a manifest.

Remember running `facter ipaddress`? Puppet told you your IP address without you having to do anything. What if you wanted to turn `facter ipaddress` into a variable? You guessed it. It would look like this: `$ipaddress` as a stand-alone variable, or like this:
`${ipaddress}` as a variable interpolation (which is discussed in the Interpolation Quest).

In the Conditions Quest, you will see how Puppet manifests can be designed to perform differently depending on facts available through `facter`. For now, let's play with some facts to get a feel for what's available.

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
