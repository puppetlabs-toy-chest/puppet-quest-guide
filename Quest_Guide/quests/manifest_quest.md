---
title: Manifests
layout: default
---

# Manifests

### Prerequisites

- Resources Quest

## Quest Objectives

As you saw in the Resources quest, Puppet's **resource declarations** can be used to keep track of just about anything in this Learning VM. So far, you have made changes to the world without using Puppet. You looked at resource declarations only in order to keep track of the effects of what you did. In this quest, you will learn to craft your own resource declarations and inscribe them in a special file called a **manifest**. When you're ready to get started, type the following command:

    quest --start manifest

{% aside Quests Completed %}

Before you get started lets take a look at quests you have completed

	quest --completed

This is useful incase you forget which Quests you've already done. In this case it shows that you have completed the Resources Quest. Now lets get back to learning about Puppet manifests.

{% endaside %}

## Puppet Manifests

Once you've created a manifest, you will use the `puppet apply` tool to implement it. Puppet will check each resource in your environment against the resource declaration in the manifest. Puppet's **providers** will then do everything neccessary to bring the state of those resources in line with the resource declarations in your manifest.

Manifests, like the resource declarations they contain, are written in Puppet's Domain Specific Language (DSL). In addition to resource declarations, a manifest will often contain **classes**, which organize resource declarations into functional sets, and **logic** to allow you to manage resources according to variables in the Learning VM environment. You will learn more about these aspects of manifest creation in a later quest.

{% aside Useful Puppet Tools %}
You can use `puppet describe user` and `puppet resource user` for help using and understanding the user resource.
{% endaside %}

To establish the manifest, you want to place it in your home directory (`/root`). Make sure you're in this directory before creating your manifest.

	cd /root

{% aside Text Editors %}

For the sake of simplicity and consistency, we use the text editor nano in our instructions, but feel free to use vim if you prefer.

{% endaside %}

{% task 1 %}
Now we are ready to create a manifest to manage the user Byte. The `.pp` extension identifies a file as a manifest.

	nano byte.pp

{% task 2 %}
Type the following instructions into your manifest:

{% highlight puppet %}
user { 'byte':
	ensure => 'absent',
}
{% endhighlight %}

Save the file and exit your text editor.

## Puppet Parser

The `puppet parser` tool is like Puppet's version of a spellchecker. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default site manifest. If there are no syntax errors, Puppet will return nothing, otherwise Puppet will display the first syntax error encountered. 

{% warning %}
The puppet parser can only ensure that the syntax of a manifest is well-formed. It can't guarantee that your variables are correctly named, your logic is valid, or, for that matter, that your manifest does what you want it to.
{% endwarning %}

{% task 3 %}
Let's check if what you wrote has any errors. Type the following command:

	puppet parser validate byte.pp

If the parser returns nothing, continue on. If not, make the necessary changes and re-validate until the syntax checks out.

## Puppet Apply

This is a very handy execution tool for applying manifests locally. However, you'll probably use this tool to apply configurations across an entire system with a single file. The file being applied will be constructed as a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! You will see how this can be a more manageable process when you come across **Classes** during your journey.

{% task 4 %}
Once your `byte.pp` file has no errors we're going to simulate the change in the system without actually enforcing the manifest. Let's see what happens:

	puppet apply --noop byte.pp

{% task 5 %}
Since the simulated change is what we truly want, let's actually enfore the change using `puppet apply`. Type the following:

	puppet apply byte.pp

{% task 6 %}
How is Byte doing?

	HINT: Remember using puppet resource?
		
Byte does not seem to be doing well. Actually, he's gone. The `ensure => 'absent'` valuec learly shows Byte was no match for your Puppet skills.

{% task 7 %}
With manifests you can create as well as destroy. Lets create a new, stronger assistant by adding user `gigabyte` to the Learning VM.

	nano gigabyte.pp

{% task 8 %}
Write the following code to your manifest:

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
Check your syntax:

	HINT: refer to puppet parser above
	
{% task 10 %}
Simulate your changes:

	HINT: check out Task 4 if you're stuck
	
{% task 11 %}
Now enforce your changes:

	puppet apply gigabyte.pp
	
{% task 12 %}
Now check in on GigaByte. 

	HINT: Remember how to inspect a resource. This is important to remember!	

You have an extordinary power to add and remove whomever and whatever you may like. Use your powers wisely.
