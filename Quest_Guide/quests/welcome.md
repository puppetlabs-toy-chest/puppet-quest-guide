---
title: Welcome
layout: default
---

# Welcome 

## Quest Objectives

In this quest you will be introduced to Elvium, the Learning Virtual Machine environment.

## Welcome to Elvium

> Any sufficiently advanced technology is indistinguishable from magic.

> -Arthur C. Clarke

Welcome to Elvium, user. Have a look around, if you like, but take note: what you see now is only the surface. The real channels of power in Elvium lie deeper. You will learn of these things. You see, you are not an ordinary user, for you have come into the Elvium with a user id of '0', the mark of the **Superuser**.

If you choose to follow the path set forth in this Quest Guide, you will learn to channel your powers by using the art of Puppet. With only a few words, shape the environment around as you see fit. Inscribe your wishes into potent Puppet manifests to ensure that your will continues to be done when journey beyond Elvium to bring other systems under your dominion.

<!-- I (Bruce) think we should get rid the Getting Started section -->

## Getting Started

Your arrival has been foretold, user, and all the necessary arrangements were made to ensure that this Quest Guide would fall into your hands. By entering the command `puppet apply setup/guide.pp`, you activated a Puppet **manifest** we had prepared in anticipation of your arrival.

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
	
{% tip Clear your terminal %}
By typing `clear` into your terminal will clear everything on your screen.
{% endaside %}

{% aside Remember these commands %}
These will be integrated into the first few quests to help you remember them. We'll explain these commands further as you progress.
{% endtip %}

![image](./assets/terminal.png)

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
