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

As you saw in the Resources Quest, Puppet's **resource declarations** can be used to keep track of just about anything in this Learning VM. So far, you have made changes to the Learning VM without using Puppet. You looked at resource declarations only in order to keep track of the effects of what you did. In this quest, you will learn to craft your own resource declarations and inscribe them in a special file called a **manifest**. When you're ready to get started, type the following command:

    quest --start manifest

{% aside Let's See What Quests You've Completed %}
Before you get started, let's take a look at the quests you have completed. Type the following command:

	quest --completed

This is useful incase you forget which Quests you've already done. In this case it shows that you have completed three quests: (1)Welcome Quest (2)Power of Puppet Quest and (3)Resources Quest.
{% endaside %}

## Puppet Manifests

Puppet programs are called “manifests” and they use the `.pp` file extension. The core of the Puppet language is the resource declaration. A resource declaration describes a desired state for one resource. This information is stored in a Puppet manifest.

Manifests, like the resource declarations they contain, are written in Puppet's Domain Specific Language (DSL). In addition to resource declarations, a manifest will often contain **classes**, which organize resource declarations into functional sets, and **logic** to allow you to manage resources according to variables in this Learning VM. You will learn more about these aspects of manifest creation in the coming quests.

Once you've created a manifest, you will use the `puppet apply` tool to enforce it. Puppet will check each resource in your environment against the resource declaration in the manifest. Puppet's **providers** will then do everything necessary to bring the state of those resources in line with the resource declarations in your manifest.

{% aside Useful Puppet Tools %}
You can use `puppet describe user` and `puppet resource user` for help using and understanding the user resource...and any other resource type you're curious about.
{% endaside %}

Make sure you place newly created manifests in your home directory (`/root`).

	cd /root

{% aside Text Editors %}
For the sake of simplicity and consistency, we use the text editor `nano` in our instructions, but feel free to use `vim` or another text editor of your choice.
{% endaside %}

{% task 1 %}
When you created Byte in the Resources Quest, a `byte.pp` manifest was also subsequently created. Unfortunately Byte just doesn't seem to be working out as a sidekick. We need to get rid of Byte and create a stronger sidekick to help you in learning Puppet. To access Byte's Puppet manifest, type the following command:

	nano byte.pp

{% task 2 %}
Type the following instructions into Byte's manifest:

{% highlight puppet %}
user { 'byte':
	ensure => 'absent',
}
{% endhighlight %}

Save the file and exit your text editor. We touched on this in the Resources Quests, but the `ensure => absent` attribute/value pair states that we are going to make Byte not exist in the Learning VM.

## Puppet Parser

What if I made in error when writing our Puppet code? The `puppet parser` tool is like Puppet's version of a spellchecker. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default `site.pp` manifest. If there are no syntax errors, Puppet will return nothing when this command is ran, otherwise Puppet will display the first syntax error encountered. 

{% warning %}
The `puppet parser` tool can only ensure that the syntax of a manifest is well-formed. It cannot guarantee that your variables are correctly named, your logic is valid, or that your manifest does what you want it to.
{% endwarning %}

{% task 3 %}
Using the `puppet parser` tool let's check your manifest for any syntax errors. Type the following command:

	puppet parser validate byte.pp

Again, if the parser returns nothing, continue on. If not, make the necessary changes and re-validate until the syntax checks out.

## Puppet Apply

This is a very handy execution and enforcement tool for applying manifests locally in the Learning VM. However, in the real world, you'll probably use this tool to apply configurations across an entire system with a single file. The file being enforced will be constructed with a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! You'll see how this can be a more manageable process in the  Classes Quest and Modules Quest.

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
With Puppet manifests you can create as well as destroy. Lets create a new, stronger sidekick by adding user `gigabyte` to the Learning VM.

	nano gigabyte.pp

{% task 8 %}
Write the following code in your manifest:

{% highlight puppet %}
user { 'gigabyte':
	ensure => 'present',
	gid => '501',
	home => '/home/gigabyte',
	password => '!!',
	uid => '501',
}
{% endhighlight %}

{% task 9 %}
Check the syntax of the `gigabyte.pp` manifest.

	HINT: If you're not sure check out Task 3 above
	
{% task 10 %}
Once your syntax is good to go, simulate your `gigabyte.pp` manifest changes in the Learning VM without actually enforcing them:

	HINT: If you're not sure check out Task 4 above
	
{% task 11 %}
Great! This is exactly what we would like Puppet to enforce. Can you now enforce `gigabyte.pp` manifest?

	HINT: If you're not sure check out Task 5 above
	
{% task 12 %}
How is GigaByte doing? Can you check in on GigaByte?

	HINT: Do the same thing as in Task 6 above
		
GigaByte is alive and strong in the Learning VM world. You have an extraordinary power to add and remove whomever and whatever you may like. Use your powers wisely.
