---
title: Manifests
layout: default
---

# Manifest Quest

In this quest you will gain a better understanding of resource declarations, the resource abstraction layer and using puppet apply for applying manifests.

## What you should already know

- Puppet Resource Quest

## Puppet Manifests

As you saw in the Resources quest, Puppet's **resource declarations** can be used to keep track of just about anything here in Elvium. So far, you have made changes to the world without using Puppet. You looked at resource declarations only in order to keep track of the effects of what you did. In this quest, you will learn to craft your own resource declarations and inscribe them in a special document called a **manifest**. 

Once you've created a manifest, you will use the `puppet apply` tool to implement it. Puppet will check each resource in your environment against the resource declaration in the manifest. Puppet's **providers** will then do everything neccessary to bring the state of those resources in line with the resource declarations in your manifest.

Manifests, like the resource declarations they contain, are written in Puppet's Domain Specific Language (DSL). In addition to resource declarations, a manifest will often contain **classes**, which organize resource declarations into functional sets, and **logic** to allow you to manage resources according to variables in the Elvium environment. You will learn more about these aspects of manifest creation in a later quest.

### Tasks

{% tip %}
You can use `puppet describe user` and `puppet resource user` for help using and understanding the user resource.
{% endtip %}

2. To establish the manifest you want to place it in your home directory (`/root`). Make sure you're in this directory before creating your manifest.

		cd /root

3. Now we are ready to create a manifest to manage the user Ralph. The `.pp` extension identifies a file as a manifest.

		nano ralph.pp

4. Type the following deadly incantation into your manifest:

{% highlight ruby %}
user { 'ralph':
	ensure => 'absent',
}
{% endhighlight %}

5. Save the file and exit nano.

## Puppet Parser

`puppet parser` is like Puppet's version of spellcheck. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default site manifest. If there are no syntax errors, Puppet will return nothing, otherwise Puppet will display the first syntax error encountered. 

### Tasks

{% warning %}
The puppet parser can only ensure that the syntax of a manifest is well-formed. It can't guarantee that your variables are correctly named, your logic is valid, or, for that matter, that your manifest does what you want it to.
{% endwarning %}

1. Enter the following command in the command line:

		puppet parser validate ralph.pp

If the parser returns nothing, continue on. If not, make the necessary changes with nano and re-validate until the syntax checks out.

## Puppet Apply

This is a very handy tool for learning to write code in Puppet's DSL and is a standalone puppet execution tool. However, in reality, you'll probably use this tool to describe the configurations of an entire system in a single file. This description will be constructed as a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! You will see how this can be a more manageable process when you come across **Classes** during your journey.

### Tasks

1. Simulate the change in the system without actually enforcing the `user.pp` manifest

		puppet apply --noop ralph.pp

2. Using `puppet apply` apply the simulate manifest `user.pp`

		puppet apply ralph.pp

3. Check in on Ralph. How is his health?:

		puppet resource user ralph
		
	If you like, you can check the old fashioned way as well. If the user doesn't exist, it will return nothing.
		
		egrep -i "^ralph" /etc/passwd
		
	He is not too well, it appears! Clearly Ralph was no match for your skills in magic.

4. Luckily for Ralph, manifests can create as well as destroy. Open your manifest again:

	nano ralph.pp

5. Write the following code to your manifest:

{% highlight ruby %}
user { 'ralph':
	ensure => 'present',
	gid => '501',
	home => '/home/ralph',
	password => '!!',
	uid => '501',
}
{% endhighlight %}

6. Check your syntax:

	puppet parser validate ralph.pp
	
7. Simulate your changes:

	puppet apply --noop ralph.pp
	
8. And apply:

	puppet apply ralph.pp
	
9. Now check in on Ralph again. Hopefully he has recovered fully from his bout of non-existence.

		puppet resource user ralph	

## The Resource Abstraction Layer

Our sages have long known that Elvium operates according to the rules of **CentOS**, which they call its **Operating System**. We know of distant continents, however, where the fabric of the world has a different weave; that is, there is a different Operating System. Considering your grand destiny, it is likely that at some point your journey will carry you to such an exotic location. If you arrive in such a strange place unprepared, you will at a considerable disadvantage.

If you wake up **ssh**ipwrecked and sandy on the shores of Ubuntu and croak out a `useradd`, you will be laughed right off the beach for getting it backwards; as any Ubuntu native could tell you, `adduser` is the right way to say it there. And attempting to install a package with `yum` on a system where `apt-get` is appropriate is a *faux pas* indeed. (Not only will your command fail, but Ubuntu users may whisper about your poor manners.)

These mistakes could be embarrassing, but they only scratch the surface of the profound differences of systems you may encounter. (Indeed, travelers speak of a strange region known as Windows, though their tales of this place are perhaps too fantastical to be given much credence!)

If you aspire to extending your influence across these distant shores, it will be wise to learn a method of applying your power consistently, no matter the local operating system.

Puppet uses **providers** to abstract away the complexity of managing diverse implementations of the same basic objects expressed by resource types. These providers take the descriptions expressed by resource declarations and use system-specific implementations to realize them. As a whole, this system of types and providers is called the **Resource Abstraction Layer**. By harnessing the power of the RAL, you can write manifests that work wherever you take them.