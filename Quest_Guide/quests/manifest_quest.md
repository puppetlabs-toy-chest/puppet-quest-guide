---
title: Manifests
layout: default
---

# Manifests

### Prerequisites

- Welcome Quest
- Power of Puppet Quest
- Resources Quest

## Quest Objectives

- Understand the concept of a Puppet manifest
- Construct and apply manifests to manage resources

## Getting Started

As you saw in the Resources Quest, Puppet's resource declarations can be used to keep track of just about anything in this Learning VM. So far, you have made changes to the Learning VM without using Puppet. You looked at resource declarations using `puppet describe` and `puppet resource` only in order to track your effects. In this quest, you will learn to craft your own resource declarations and inscribe them in a special file called a **manifest**. When you're ready to get started, type the following command:

    quest --start manifest

{% aside Let's See What Quests You've Completed %}
Before you get started, let's take a look at the quests you have completed. Type the following command:

	quest --completed

This is useful incase you forget which Quests you've already done. In this case it shows that you have completed three quests: (1)Welcome Quest (2)Power of Puppet Quest and (3)Resources Quest.
{% endaside %}

## Puppet Manifests

Manifests are files containing Puppet code. They are standard text files saved with the `.pp` file extension. The core of the Puppet language is the resource declaration as it describes a desired state for one resource. Puppet manifests contain resource declarations. Manifests, like the resource declarations they contain, are written in Puppet Language. 

{% aside Don't Forget These Tools Too %}
You can use `puppet describe` and `puppet resource` for help using and understanding the `user` resource...and any other resource type you're curious about.
{% endaside %}

Let's get started by making sure you're in your home directory: `/root`.  This is where you want to place newly created manifests.

	cd /root

{% aside Text Editors %}
For the sake of simplicity and consistency, we use the text editor `nano` in our instructions, but feel free to use `vim` or another text editor of your choice.
{% endaside %}

{% task 1 %}

Create a manifest to remove user byte:

Unfortunately byte just doesn't seem to be working out as a sidekick. Let's create a manifest to get rid of byte. We will create a manifest, with some code in it. Type the following command, after you make sure you are in the `/root` directory as mentioned above:

	nano byte.pp

Type the following instructions into Byte's manifest:

{% highlight puppet %}
user { 'byte':
	ensure => 'absent',
}
{% endhighlight %}

Save the file and exit your text editor. We touched on this in the Resources Quests, but the `ensure => absent` attribute/value pair states that we are going to make sure user byte does not exist in the Learning VM.

## Puppet Parser

What if we made an error when writing our Puppet code? The `puppet parser` tool is Puppet's version of a syntax checker. When provided with a file as an argument, this tool validates the syntax of the code in the file without acting on the definitions and declarations within. If no manifest files are provided, Puppet will validate the default `site.pp` manifest. If there are no syntax errors, Puppet will return nothing when this command is ran, otherwise Puppet will display the first syntax error encountered. 

{% warning %}
The `puppet parser` tool can only ensure that the syntax of a manifest is well-formed. It cannot guarantee that your variables are correctly named, your logic is valid, or that your manifest does what you want it to.
{% endwarning %}

{% task 2 %}
Using the `puppet parser` tool, let's you check your manifest for any syntax errors. Type the following command:

	puppet parser validate byte.pp

Again, if the parser returns nothing, continue on. If not, make the necessary changes and re-validate until the syntax checks out.

## Puppet Apply

Once you've created a manifest you will use the `puppet apply` tool to enforce it. The `puppet apply` tool enables you to apply individual manifests locally.  In the real world, you may want an easier method to apply multiple definitions across multiple systems from a central source. We will get there when we talk about classes and modules in suceeding quests. For now, manifests and `puppet apply` aid in learning the Puppet language in small, iterative steps. 

When you run `puppet apply` with a manifest file as the argument, a *catalog* is generated containing a list of all resources in the manifest, along with the desired state you specified. Puppet will check each resource in your environment against the resource declaration in the manifest. Puppet's **providers** will then do everything necessary to bring the state of those resources in line with the resource declarations in your manifest. 

{% task 3 %}
Once your `byte.pp` manifest is error free, we're going to simulate the change in the Learning VM without actually enforcing those changes. Let's see what happens:

	puppet apply --noop byte.pp

In the returned output, Puppet tells us that it has not made the changes to the Learning VM, but if it had, this is what would be changed.

{% task 4 %}
Since the simulated change is what we want, let's enforce the change on the Learning VM.

	puppet apply byte.pp

{% task 5 %}
How is byte doing?

	HINT: Use the puppet resource command discussed in the Resource Quest.
		
byte does not seem to be doing well. Actually, he's gone. The `ensure => 'absent'` value clearly made short work of the user account.

{% task 6 %}
With Puppet manifests you can create as well as destroy. Lets create a new, stronger sidekick by adding user `gigabyte` to the Learning VM using Puppet. If you need help on how to do this, refer to the previous tasks you've just completed in this quest. One thing to note: `ensure => 'present'` will make sure GigaByte exists in the Learning VM.

The steps include creating a manifest file, and writing the minimal amount of Puppet code required to ensure that the user account is created. This task will be marked complete when the user exists on the system.

## Review

This is a foundational quest you must understand in order to successfully use Puppet. As you saw when completing this quest, we've added two new tools to your toolbox: `puppet parser` and `puppet apply`. You always want to use `puppet parser` to check the syntax of your manifest before using `puppet apply` to enforce it. This quest contained a walkthough of the "best practice" methods to creating, checking, applying your manifest. We've also created a simplified version below for your reference:

1. Open or create a manifest with the `.pp` extension
2. Add or edit your Puppet code
3. Use the `puppet parser` tool to check for syntax errors _(recommended)_
4. Simulate your manifest using `puppet apply --noop` _(recommended)_
5. Enfore your manifest using `puppet apply`
6. Check to make sure everything is working correctly _(recommended)_

On a final note, if you go back to the Power of Puppet quest, you will notice that the `init.pp` file containing the definition for `class lvmguide` is a manifest. 
