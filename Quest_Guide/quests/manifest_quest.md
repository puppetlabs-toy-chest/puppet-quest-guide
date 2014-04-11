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

- Identify what a Puppet manifest is
- Apply acquire Puppet resource knowledge in constructing a Puppet Manifest
- Describe "best practices" for enforcing a Puppet manifest

## Getting Started

As you saw in the Resources Quest, Puppet's resource declarations can be used to keep track of just about anything in this Learning VM. So far, you have made changes to the Learning VM without using Puppet. You looked at resource declarations using `puppet describe` and `puppet resource` only in order to track your effects. In this quest, you will learn to craft your own resource declarations and inscribe them in a special file called a **manifest**. When you're ready to get started, type the following command:

    quest --start manifest

{% aside Let's See What Quests You've Completed %}
Before you get started, let's take a look at the quests you have completed. Type the following command:

	quest --completed

This is useful incase you forget which Quests you've already done. In this case it shows that you have completed three quests: (1)Welcome Quest (2)Power of Puppet Quest and (3)Resources Quest.
{% endaside %}

## Puppet Manifests

Puppet programs are called “manifests” and use the `.pp` file extension. The core of the Puppet language is the resource declaration as it describes a desired state for one resource. However, this information needs to be stored somewhere. That is where the Puppet manifest comes into play.

Manifests, like the resource declarations they contain, are written in Puppet's Domain Specific Language (DSL). In addition to resource declarations, a manifest will often contain classes, which organize resource declarations into functional sets, and logic that allows you to manage resources according to variables in this Learning VM. You will learn more about these flexable and scalable aspects of manifest creation in the coming quests.

{% aside Don't Forget These Tools Too %}
You can use `puppet describe` and `puppet resource` for help using and understanding the `user` resource...and any other resource type you're curious about.
{% endaside %}

Let's get started by making sure you're in your home directory: `/root`.  This is where you want to place newly created manifests.

	cd /root

{% aside Text Editors %}
For the sake of simplicity and consistency, we use the text editor `nano` in our instructions, but feel free to use `vim` or another text editor of your choice.
{% endaside %}

{% task 1 %}
Unfortunately Byte just doesn't seem to be working out as a sidekick. Let's create a manifest to get rid of Byte. Type the following command:

	nano byte.pp

{% task 2 %}
Type the following instructions into Byte's manifest:

{% highlight puppet %}
user { 'byte':
	ensure => 'absent',
}
{% endhighlight %}

Save the file and exit your text editor. We touched on this in the Resources Quests, but the `ensure => absent` attribute/value pair states that we are going to make Byte does not exist in the Learning VM.

## Puppet Parser

What if I made in error when writing our Puppet code? The `puppet parser` tool is like Puppet's version of a spellchecker. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default `site.pp` manifest. If there are no syntax errors, Puppet will return nothing when this command is ran, otherwise Puppet will display the first syntax error encountered. 

{% warning %}
The `puppet parser` tool can only ensure that the syntax of a manifest is well-formed. It cannot guarantee that your variables are correctly named, your logic is valid, or that your manifest does what you want it to.
{% endwarning %}

{% task 3 %}
Using the `puppet parser` tool, let's check your manifest for any syntax errors. Type the following command:

	puppet parser validate byte.pp

Again, if the parser returns nothing, continue on. If not, make the necessary changes and re-validate until the syntax checks out.

## Puppet Apply

Once you've created a manifest you will use the `puppet apply` tool to enforce it. The `puppet apply` tool is a standalone execution tool to apply individual manifests locally.  However, in the real world, you'll probably use this tool to apply configurations across an entire system with a single file. The file being enforced will be constructed with a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! Puppet will check each resource in your environment against the resource declaration in the manifest. Puppet's **providers** will then do everything necessary to bring the state of those resources in line with the resource declarations in your manifest. You'll see how this can be a more manageable process when you get to the Classes Quest and Modules Quest.

{% task 4 %}
Once your `byte.pp` manifest is error free, we're going to simulate the change in the Learning VM without actually enforcing those changes. Let's see what happens:

	puppet apply --noop byte.pp

In the returned output, Puppet tells us that it has not made the changes to the Learning VM, but if it had, this is what would be changed.

{% task 5 %}
Since the simulated change is what we want, let's enforce the change on the Learning VM.

	puppet apply byte.pp

{% task 6 %}
How is Byte doing?

	HINT: Use the puppet resource command discussed in the Resource Quest.
		
Byte does not seem to be doing well. Actually, he's gone. The `ensure => 'absent'` value clearly shows Byte was no match for your Puppet skills.

{% task 7 %}
With Puppet manifests you can create as well as destroy. Lets create a new, stronger sidekick by adding user `gigabyte` to the Learning VM using Puppet. If you need help on how to do this, refer to the previous tasks you've just completed in this quest. One thing to note: `ensure => 'present'` will make sure GigaByte exists in the Learning VM.

## Review

This is a foundational quest you must understand in order to successfully use Puppet. As you saw when completing this quest we've added two new tools to your toolbox: `puppet parser` and `puppet apply`. You always want to use `puppet parser` to check the syntax of your manifest before using `puppet apply` to enfore it. This quest contained a walkthough of the "best practice" methods to creating, checking, applying your manifest. We've also have a simplified version below for your reference:

1. `cd` in to your home directory: `/root`
2. Open or create a manifest with the `.pp` extension
3. Add or edit your Puppet code
4. Use the `puppet parser` tool to check for syntax errors _(recommended)_
5. Simulate your manifest using `puppet apply --noop` _(recommended)_
6. Enfore your manifest using `puppet apply`
7. Check to make sure everything is working correctly _(recommended)_


