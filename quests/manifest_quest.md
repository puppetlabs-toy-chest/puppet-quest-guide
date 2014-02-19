---
title: Manifests
layout: default
---

# Manifest Quest

In this quest you will gain a better understanding of resource declarations, the resource abstraction layer and using puppet apply for applying manifests.

## What you should already know

- Puppet Resource Quest

## Puppet Manifests

As you saw in the Resources quest, Puppet's **resource declarations** can be used to keep track of just about anything here in Elvium. So far, you have made changes without using Puppet and looked at resource declarations only in order to keep track of the effects of those changes. In this quest, you will learn to craft your own resource declarations and inscribe them in a **manifest**. Use `puppet apply` to activate your manifest, and you will taste the true power Puppet. 

Manifests, like the resource declarations they contain are written in Puppet's Domain Specific Language (DSL). In addition to resource declarations, a manifest will often contain **classes**, which organize resource declarations into functional sets, and **logic** to allow you to manage resources according to variables in the Elvium environment. You will learn more about these aspects of manifest creation in a later quest.
### Tasks

1. Remember, you can use `puppet describe user` and `puppet resource user` for help using and understanding the user resource.
2. To establish the manifest you're going to want to place it in your earth version's home directory (`/root`)

		cd /root

3. So now we're ready to start writing are first manifest to manage the Earth verison of yourself on Elvium. First we are going to create you in the system. Enter the following command 

		nano user.pp
		
	Note the `.pp` extension that marks the file as a manifest.


4. Type the follow task into the manifest:

{% highlight ruby %}
user { 'earthname':
	ensure => 'present',
}
{% endhighlight %}

5. Save the file as `user.pp`

## Puppet Parser

`puppet parser` is like Puppet's version of spellcheck. This action validates Puppet's DSL syntax without compiling a catalog or syncing any resources. If no manifest files are provided, Puppet will validate the default site manifest. If there are no syntax errors, Puppet will return nothing, otherwise Puppet will display the first syntax error encountered. 

### Tasks

1. Enter the following command in the command line:

		puppet parser validate user.pp

## Puppet Apply

This is a very handy tool for learning to write code in Puppet's DSL and is a standalone puppet execution tool. However, in reality, you'll probably use this tool to describe the configurations of an entire system in a single file. This description will be constructed as a list of all resources you want to manage on your system, but as you can imagine, that might end up being a _really_ long file! You will see how this can be a more manageable process when you come across **Classes** during your journey.

### Tasks

1. Try the following command to learn more about the `puppet apply`

		puppet help apply

2. Simulate the change in the system without actually enforcing the `user.pp` manifest

		puppet apply --noop user.pp

3. Using `puppet apply` apply the simulate manifest `user.pp`

		puppet apply user.pp

4. See if your earth version exists

		puppet resource user earthname

You will see that puppet does, indeed create a user called `earthname`!

## The Resource Abstraction Layer

Our sages have long known that Elvium operates according to the rules of **CentOS**, which they call its **Operating System**. We know of distant continents, however, where the fabric of the world has a different weave; that is, there is a different Operating System. Considering your grand destiny, it is likely that at some point your journey will carry you to such an exotic location. If you arrive in such a strange place unprepared, you will at a considerable disadvantage.

If you wake up **ssh**ipwrecked and sandy on the shores of Ubuntu and croak out a `useradd`, you will be laughed right off the beach for getting it backwards; as any Ubuntu native could tell you, `adduser` is the right way to say it there. And attempting to install a package with `yum` on a system where `apt-get` is appropriate is a *faux pas* indeed. (Not only will your command fail, but Ubuntu users may whisper about your poor manners.)

These mistakes could be embarrassing, but they only scratch the surface of the profound differences of systems you may encounter. (Indeed, travelers speak of a strange region known as Windows, though their tales of this place are perhaps too fantastical to be given much credence!)

If you aspire to extending your influence across these distant shores, it will be wise to learn a method of applying your power consistently, no matter the local operating system.

Puppet uses **providers** to abstract away the complexity of managing diverse implementations of the same basic objects expressed by resource types. These providers take the descriptions expressed by resource declarations and use system-specific implementations to realize them. As a whole, this system of types and providers is called the **Resource Abstraction Layer**. By harnessing the power of the RAL, you can write manifests that work wherever you take them.






