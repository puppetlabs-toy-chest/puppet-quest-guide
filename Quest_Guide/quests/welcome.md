---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

In this quest you will be introduced to the Learning Virtual Machine environment.

## Welcome to Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to the Learning VM. Have a look around. What you see will be fairly typical of a Unix-based Operating System. You will see a filesystem populated with many of the usual directories and files. Some services are running in the background, including the SSH service that you can use to access the Learning VM from your own terminal.

You may have noticed that you are not an ordinary user; you are logged into the 'root' account with its user id of '0', the mark of the **Superuser**. This account gives you the ability to change just about anything you like in the Learning VM, just as you would if you were tasked with administrating a machine.

By following this Quest Guide, you will learn how Puppet allows you to use these priveleges easily and effectively.

## Quest Navigation

In order to learn more about Puppet, and to work your way through this learning virtual machine, you will have to complete a series of Quests and with each Quest you have certain amount of 'Tasks' that need to be completed. To monitor your status as you progress, we've created custom commands for you.

{% tip %}
These custom `quest` commands are not related to Puppet. They are only related to this Learning Virtual Machine.
{% endtip %}

The following command will help you with using the quest tool:

	quest --help

The `quest --help` command provides you with an understanding of several quest tools such as the following:

	quest --progress	# Display details of tasks completed (default: true)
	quest --brief		# Display number of tasks compelted
	quest --name		# Name of the quest to track
	quest --completed	# Display completed quests
	quest --showall		# Show all available quests
	quest --start		# Provide name of the quest to start tracking
	
{% tip %}
By typing `clear` into your terminal will clear everything on your screen.
{% endtip %}

{% aside Remember these commands %}
These will be integrated into the first few quests to help you remember them. We'll explain these commands further as you progress.
{% endaside %}

![image](../assets/terminal.png)

## Facter

Facter is a Puppet tool that helps you obtain facts about your system. Here are a few items for you to get to know your system a little better:

	facter ipaddress
	facter facterversion
	facter memorysize
	facter operatingsystem
	facter osfamily
	facter puppetversion

{% tip %}
You can see all the facts by running facter -p
{% endtip %}

## Summary

In this quest we introduced you to the quest navigation commands, which provides you real time feedback on your progress using the learning virtual machine. We also introduced you to a Puppet tool called Facter, which allows to easily obtain facts about Puppet, your system, this virtual machine and so much more. This is just a primer quest to get you familar with using the command line and introduction to the quest structure. When you're ready, let's get started learning about Puppet Resources.
