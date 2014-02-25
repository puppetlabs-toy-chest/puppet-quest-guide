---
title: Welcome
layout: default
---

# Welcome 

In this quest you will be introduced to Elvium, the Learning Virtual Machine environment.

## Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to Elvium, user. Have a look around. Walk down a directory path and admire our landscape.

<!--
We'll need to have a few interesting files and directory structures already in place.
-->

Wander the verdant forests of files and hear the clamor of bustling services. But take note: what you see now is only the surface. The real channels of power in Elvium lie deeper, in the very bones of the kingdom, and you must learn of these things. You see, you are not an ordinary user, for you have been born into the Elvium with a user id of '0', the fabled mark of the **Superuser**.

In recognition of this auspicious sign, the venerable council of Sudoers has seen fit to present you with this Quest Guide.

If you choose to follow the path set forth herein, you will learn to channel your abilities by using the art of Puppet. With only a few words, slay nefarious daemons, raise armies of users, orchestrate magnificent services, and, most importantly, weave your power into abiding enchantments to ensure that your will continues to be done in Elvium as you journey out to bring other kingdoms into your dominion.

## Tasks

Your arrival has been foretold, user, and we have made the necessary preparations. You need not worry now about the details; you will learn soon enough. You need only speak a few words of power to set the prophecy in motion.

1. SSH to the VM with your IP address

		ssh root@<ipaddress>

	Use the following to login  
	**username:** root  
	**password:** puppet


2. Now that you are connected to Elvium, we need to set up a method for you to find your way! Run the following command: 

		puppet apply setup/guide.pp

   What we just did is set up a website to be served from your VM. You can access the website in your browser by visiting: _http://<ipaddress>_ (replace the <ipaddress> with the ipaddress of your VM)

{% tip %}
The power of Puppet is immense. With one command you will set up your entire enviornment created locally
{% endtip %}


2. Just in case you ever get stuck, we on Elvium have provided you an unlimited supply of help. To learn more about the help we provide, type the following command:

		puppet help
		
3. You are a curious being. Would you like to further investigate Elvium? To do this on Elvium we use the tool `facter` to obtains `facts` about the system. Here are a few for you to try out:

		facter ipaddress
		facter facterversion
		facter memorysize
		facter operatingsystem
		facter osfamily
		facter puppetversion

{% tip %}
You can see all `facter` commands [here](http://docs.puppetlabs.com/facter/latest/core_facts.html)
{% endtip %}

4. In order to learn more about Puppet, and to work your way through Elvium, you will have to complete a series of Quests. Each Quest has Tasks that need to be completed. Transparent information is essential on Elvium. To monitor your status with the quests on Elvium we've created custom commands for you.

The following command will help you with using the quest tool:

		quest --help

The quest command provides several tools such as the following:

    quest --start
    quest --progress
    quest --completed
    quest --showall
    quest --brief
    quest --name


If you wanted to list all the available quests, you can run the following command:
    
    quest --showall

To being a quest called _resources_, you can type:
    
    quest --start resources

To see your progress on the current quest you are pursuing, you can type:

    quest --progress

We'll explain the commands needed as we go.

Now that you have a quest guide, let's get started with the Quests!


