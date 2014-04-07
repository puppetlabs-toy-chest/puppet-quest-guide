---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

In this quest you will be introduced to the Learning Virtual Machine (VM) environment.

## Welcome to the Learning VM

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to the Learning VM. Have a look around. What you see will be fairly typical of a Unix-based operating system. You will see a filesystem populated with many of the usual directories and files. Some services are running in the background, including the SSH service that you can use to access the Learning VM from your own terminal.

You may have not noticed yet, but carry the mark of a **Superuser**. You are logged into the 'root' account giving you the user id of '0'. This account gives you the ability to change just about anything you like in the Learning VM, just as you would if you were tasked with administrating a machine.

By following this Quest Guide, you will learn how Puppet allows you to use these privileges easily and effectively.

## Quest Navigation

In order to learn more about Puppet, you will complete a series of Quests related to specific Puppet topics. Each of these Quests includes a number of interactive 'Tasks' that give you a hands-on opportunity to apply what you're learning. To monitor your status as you progress through these Quests and Tasks, we've created custom commands you can use through the Learning VM command line.

{% aside Custom Quest Commands %}
These custom `quest` commands are not a part of Puppet itself. We have included them Learning VM to provide you with real-time feedback as you progress through Quests and Tasks.
{% endaside %}

{% task 1 %}
The following command will help you with using the quest tool:

	quest --help

The `quest --help` command provides you with an understanding of several quest tools such as the following:

	quest --progress	# Display details of tasks completed (default: true)
	quest --brief		# Display number of tasks completed
	quest --name		# Name of the quest to track
	quest --completed	# Display completed quests
	quest --showall		# Show all available quests
	quest --start		# Provide name of the quest to start tracking
	
{% tip %}
Typing `clear` into your terminal will clear everything on your screen.
{% endtip %}

{% aside Remember these commands %}
These quest tools will be integrated into the first few quests to help with memory retention. We'll explain these commands in greater detail as you progress.
{% endaside %}

{% figure 'assets/terminal.png' %} <!--This screenshot needs updating when the final LVM is ready-->

## Facter

Puppet comes with prepackaged tools for you to use in administering your systems. One of these handy tools is called Facter, which helps you obtain facts about your system. Here are a few items for you to check out using the Facter tool and to get to know your system a little better:

{% task 2 - 6 %}

	facter facterversion
	facter memorysize
	facter operatingsystem
	facter osfamily
	facter puppetversion

{% tip %}
You can see all the facts by running `facter -p`
{% endtip %}

## Summary

In this quest we introduced you to the quest navigation commands, which provides you real time feedback on your progress using the Learning VM. We also introduced you to a Puppet tool called Facter, which allows you to easily obtain facts about Puppet, your system, this virtual machine, and so much more. This is just a primer quest to get you familiar with using the command line and introduction to the quest structure. When you're ready, let's get started learning about the Power of Puppet.
